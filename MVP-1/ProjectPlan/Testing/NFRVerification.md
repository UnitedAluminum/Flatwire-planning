# Flat Wire Mill — NFR Verification

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `06-TestPlanAndTestCases.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Non-functional verification
**Status:** Baselined — **four NFRs are untestable until their targets are defined**
**Owner:** QA stream
**Audience:** QA, developers, architects
**Shortcode:** `[NFR]`
**Part of:** `ProjectPlan/Testing/` — index: [README.md](../README.md)

---

## 6. NFR verification

### 6.1 Verifiable NFRs

| TC | NFR | Target | Method and tooling | Pass criterion |
|---|---|---|---|---|
| **TC-601** | `NFR003` | 4 ft per data point for **finished** product, configurable without a code change | Set a non-default cadence in configuration; run; count `RunReading` rows against footage | Applied cadence equals the configured value; **no rebuild or redeploy required** |
| **TC-602** | `NFR004` | 20 ft for **intermediate** product | Run FL1 with a subsequent rolling operation on the route | 20 ft cadence applied |
| **TC-603** | `NFR004` | **FL2 always 4 ft; FL3 hybrid both instances 4 ft** | Run FL2 standalone, then FL3 hybrid | 4 ft in all three instances; the rule "subsequent rolling operation exists → 20 ft, none → 4 ft" holds |
| **TC-604** | `NFR005` | **No polling** | Capture a full network trace over a 5-minute run | **Zero periodic GETs for live readings.** Any polling request fails the case |
| **TC-605** | `NFR005` | 1 s default, configurable to 5/10/30 s | Set each value; measure inter-message intervals | Each configured interval observed within tolerance |
| **TC-606** | `NFR006` | Cached state, never blank, auto-reconnect | Kill the transport mid-run; measure time to first painted frame | Cached state painted within one frame; banner shown; backoff observed; **no blank screen at any point** |
| **TC-607** | `NFR006` | Group re-join on reconnect | Restore the transport | Client re-joins its line group and resumes **without user action** |
| **TC-608** | `NFR007` | Two simultaneous dashboards | Two clients on FL1 and FL2 with independent jobs | Both receive only their own group's events; **no cross-talk** |
| **TC-609** | `NFR009` | Override alerts block passive dismissal | Escape, backdrop click, browser back, route change | **None dismisses.** Only Acknowledge or Stop Run |
| **TC-610** | `NFR009` | Spool prompt blocks passive dismissal | Same, on the stop-confirmation modal | Remains until Yes or No |
| **TC-611** | `NFR010` | Audit — supervisor overrides | Perform each of the four override types | Each records operator, supervisor, timestamp, station/line, old→new and reason. **PIN absent everywhere** |
| **TC-612** | `NFR010` | Audit — pass-schedule changes | Edit, override and acknowledge | Three `PassScheduleChangeLog` rows with the correct `ChangeType` |
| **TC-613** | `NFR010` | Audit — PLC tag writes and clears | Check in, roll adjust, check out | One audit entry per tag with path, value, operator, timestamp and result |
| **TC-614** | `NFR010` | Audit — retention | Query audit records for a completed run after 30 days of simulated ageing | All retained and retrievable |
| **TC-615** | `NFR011` | Audit — login/logout | Manual, auto shift-based and supervisor-override logins | All three captured with operator ID, station and timestamp |
| **TC-616** | `NFR012` | Weld genealogy queryable | Reconstruct the chain for a coil made from three rods across two welds | Full chain to supplier heat, with per-rod footage attribution |
| **TC-617** | `NFR012` | Coverage and non-overlap | Assert on the traceability rows | 100 % coverage, zero overlap, half-open ranges |
| **TC-618** | `NFR013` | Snapshot survives a schedule edit | Complete a coil, edit the schedule, re-render the technical record | The snapshot at creation is returned |
| **TC-619** | `NFR013` | R-series retained permanently | Query a historical rod alpha | Present in `coils` |

### 6.2 NFRs that are untestable until their targets are defined

**No threshold has been invented for these.** They are recorded as untestable so the gap is visible rather than silently passed.

| TC | NFR area | Missing target | Consequence | Owner | Needed by |
|---|---|---|---|---|---|
| **TC-620** | **AGC sample rate** | Undefined | The ingest channel size and decimation ratio cannot be sized or validated | Engineering | QA2 |
| **TC-621** | **Concurrent client count** | Undefined | **This is the `N` in "N clients × 3 lines × cadence". Without it there is no load test to run** | Architecture | QA2 |
| **TC-622** | **End-to-end latency budget** (PLC read → operator screen) | Undefined | The only number that says whether the real-time design succeeded | Architecture / Engineering | QA2 |
| **TC-623** | **`RunReading` retention and rollup** | Undefined | Unbounded time-series growth; report queries degrade silently | Architecture / DBA | Phase 1C |

> **The QA2 hub load test is scheduled and budgeted (16 h) with no pass criteria.** It will execute and produce numbers, but **it cannot fail**, which means it is not a gate. Gap **G9** / **OI-34**. Either the four targets above are set before 13 Sep, or QA2 must be recorded as *executed, not gating*.

### 6.3 Non-ID'd non-functional checks

| TC | Check | Pass criterion |
|---|---|---|
| **TC-624** | **Minimum text size** | No rendered text below **14 px** on any screen, **except** axis labels in the four documented vertically-compressed SVG charts. Form controls pinned to 14 px |
| **TC-625** | **Tap targets** | Every interactive element ≥ **48 px** |
| **TC-626** | **No hover dependency** | Every action reachable by touch alone; no action revealed only on hover |
| **TC-627** | **1280 × 1024 at 1:1** | Every screen renders complete with **no horizontal or vertical scrollbar** and no clipping |
| **TC-628** | **Angular coverage bar** | 95 % branches, functions, lines and statements |
| **TC-629** | **The word "strip"** | Absent from every screen, label, report and column heading |

---
