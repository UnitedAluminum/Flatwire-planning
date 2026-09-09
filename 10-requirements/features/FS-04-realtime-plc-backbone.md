---
id: FS-04
title: Real-Time and PLC Backbone
phases: [1A, 1B, 3, 4, 5]
requirements: []
screens: []
jira:
owner:
---
# FS-04 · Real-Time and PLC Backbone

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — sections 1, 4, 6, 7 and 8 authored
**Document Type:** Consolidated parent story — the single source of truth for this functional area
**Status:** ✅ **Authored and current** — ⛔ *§3 carries no acceptance criteria of its own, and that is settled, not outstanding: measured, only 7 % of the 1,222 criteria cite any spec or `FR`, so they are original build detail and stay on their `[TB §7]` card. See [`README.md`](README.md).*
**Owner:** —
**Audience:** Anyone changing this functionality, and anyone assessing the impact of a change to it
**Shortcode:** — *(derived from the specifications; **not** citable as a requirement)*
**Part of:** `10-requirements/features/` — index: [README.md](README.md)
---

> **Precedence.** This file is the single source of truth for **what this functional area is,
> what it requires, where it stands and what is open**. It is **derived** and it does not
> outrank the documents it cites: against a phase specification the phase specification wins,
> against a build record the record wins, and on any number `[CE §3e]` and `[TB §7.3]` win.
> Its absorbed-story table is generated - do not edit inside the markers. Full rules in
> [README.md](README.md).

---

## 1. Overview

**Business purpose.** The pipeline that carries machine data to a screen and operator intent back to
a machine. `FlatWireHub` and its typed event contract; the OPC ingest that feeds it; the
cadence-driven broadcast loop; the SignalR client and its mock twin; `PLCTagService` and the tag push
that a check-in acknowledgement triggers; the `ITInhibit` interlock; and the **machine simulator**
that stands in for all of it until commissioning.

⚠ **This is the one genuinely functional cross-phase category**, carved by `stream: RT` across
phases 1A, 1B, 3, 4 and 5 rather than by layer. Four categories consume it, and it was separated from
`FS-01`/`FS-02`/`FS-03` because it is a *pipeline*, not a chassis. It carries the **most hours of any
category** (`[TB §7.3]`) and, at 11 `done` plus 2 `in-progress` and 2 `in-review`, is the second-most
delivered.

**Functional scope.** Ten broadcast events — `GaugeReading`, `WidthReading`, `SpeedFPM`,
`PayoffWeight`, `FootageCounter`, `ComponentStatus`, `LineStatus`, `AlertRaised`, `AlertCleared`,
`PayoffStateChanged` — plus run-event markers and the spool-completion events. Per-line groups
`FL1Data`/`FL2Data`/`FL3Data`, a bounded channel batched at ~100 ms, MessagePack.

⚠ **All three lines measure gauge and width live** — **FL2 at a 4 s update rate, FL1 and FL3 at
~10 Hz**. ⛔ Reversed 9 Sep 2026; anything asserting FL2 broadcasts `null` is stale.

⚠ **`[PLC]` owns every tag path string, and `[PLCC]` contains none by rule.** If you are about to
write a tag path anywhere else, don't. `[PLC]` is v1.0 with **no `[CONFIRMED]` tag by design** — a
path becomes confirmed when `FS-19`'s `C1`/`C11` says the controller accepted it.

⚠ **FL3 has no controller of its own.** An FL3 acknowledgement writes to **both** the FL1 and FL2
controllers (`D-47`, gap `G99`) — see [`FS-13`](FS-13-fl3-hybrid-route.md).

**Out of scope.**

- **The screens that consume the stream** — [`FS-06`](FS-06-line-visibility-alerting.md),
  [`FS-08`](FS-08-active-run-monitoring.md), [`FS-11`](FS-11-spool-lifecycle-fl2.md).
- **The alert *rules engine***, which is `FS-06`'s `FW-N06`. This category carries the transport for
  `AlertRaised`/`AlertCleared`; the lifecycle that decides them is there.
- **The acknowledgement that triggers a push** — [`FS-07`](FS-07-rod-checkin-plc-config.md).
- **Commissioning** — [`FS-19`](FS-19-integration-testing-golive.md), including the OPC sidecar.
- **Tag path strings.** `[PLC]` is their only home.

---

## 2. Consolidated existing stories

Per [`[SCM §2.3]`](../../90-registers/StoryConsolidationMap.md); the count and the list are generated below.

<!-- BEGIN GENERATED: absorbed-stories -->

> ⚙ **Written by `tools/build_features.py`, now hand-maintained** — the task files it derived from have been retired, so this table is the single writable record of status for this category. Keep the columns exactly as they are; `--check` and `FEATURES.md` both parse them.

**22 absorbed stories**, seeded one activity each. **Activities are expected to merge downward** as work proceeds — `FW-N17`/`N18`/`N19` are one rename, not three.

| Ref | Activity | Streams | Status | Depends on | Blocked by |
|---|---|---|---|---|---|
| `FW-080` | FlatWireHub — strongly-typed, MessagePack, line groups | RT | 🔵 in-review | FW-N04 FW-145 | **G10** **G9** **OI-34** |
| `FW-082` | PLC tag group push on check-in acknowledgement | RT | ⬜ not-started | FW-151 FW-157 FW-010 | **G2** **G29** **G30** **OI-39** **PLC-Q04** **Q05** |
| `FW-135` | SignalR client service | RT | ⬜ not-started | FW-N03 | **G10** **G105** |
| `FW-136` | MockSignalRService and the typed event set | RT | ⬜ not-started | FW-135 | — |
| `FW-137` | PWA cache sync and the reconnect banner | RT | ⛔ blocked | FW-135 | — |
| `FW-149` | IFlatWireClient typed event contract | RT | 🔵 in-review | FW-080 | — |
| `FW-150` | Cadence-driven broadcast loop | RT | ✅ done | FW-N05 FW-149 | **G9** **OI-34** |
| `FW-151` | PLCTagService skeleton and SimulatePLCTagPush | RT | ✅ done | FW-144 | **G2** **OI-39** |
| `FW-203` | OPC feed simulator — a stand-in for the real ingest | RT | ✅ done | FW-N05 FW-150 | **G9** **OI-34** |
| `FW-205` | ITInhibitService — the run-block interlock | RT | ✅ done | FW-144 FW-151 FW-N05 | **G30** |
| `FW-210` | Line model core — the kinematic state machine for FL1/FL2/FL3 | RT | ✅ done | FW-N05 FW-203 | **G9** **OI-34** **OI-35** **OI-45** **Q10** |
| `FW-211` | The simulation seam — IReadingSource and the in-process adapter | RT | ✅ done | FW-210 FW-144 FW-150 FW-203 | — |
| `FW-212` | Closed loop — the model consumes the SimulatePLCTagPush payload | RT | ✅ done | FW-210 FW-151 FW-082 FW-203 | **G2** **G29** **G30** **OI-39** |
| `FW-213` | Scenario and fault injection | RT | ✅ done | FW-210 | **G34** **OI-45** **Q10** |
| `FW-214` | Simulator control console DB-S1 — standalone WinForms desktop tool | FE | ✅ done | FW-218 FW-215 FW-145 | — |
| `FW-215` | Simulator control API — /sim/** | BE | ✅ done | FW-218 FW-210 FW-211 FW-213 FW-217 FW-138 FW-145 | **G69** |
| `FW-218` | Trial control surface for the feed generator — steer, stop, drop, | BE | ✅ done | FW-203 FW-138 FW-145 | — |
| `FW-236` | Per-tag write status from OPCConnection | BE | 🟡 in-progress | FW-151 | — |
| `FW-238` | Register flat wire with OPCConnection | BE·DB | 🟡 in-progress | FW-003 FW-144 FW-151 FW-241 | — |
| `FW-239` | Wire run-lifecycle invalidation into FW-150's per-run cache | RT | ⬜ not-started | FW-150 FW-208 | — |
| `FW-N05` | OPC ingest hosted service and bounded channel | RT | ⛔ blocked | FW-144 FW-080 | **G59** **G60** **G29** **G32** **G33** **PLC-Q05** |
| `FW-N25` | Machine interface tag surface revision - one write removed, two re | BE·RT | ⬜ not-started | FW-144 FW-082 | — |

<!-- END GENERATED: absorbed-stories -->

---

## 3. Functional requirements

**This category owns no `FR` range, and that is correct.** It serves the requirements of the screens
that consume it — chiefly `[REQ §5.4]` (Active Run) and `[REQ §5.20]` (Line Status) — and adds none
of its own. Its authorities are `[SIG]` (the real-time design and the `FlatWireHub` contract),
`[PLC]` (the only tag map), `[PLCC]` (integration, the write surface, the service contract, and **no
tag paths**) and `[SIM]` (the FL1/FL2/FL3 simulator and its `DB-S1` console).

⚠ **The hub event count is 10, not 9.** `PP-04` records that the "9" predates `PayoffStateChanged`.
`[API §10.3]` is the authority.

⚠ **`FlatWireHub` has no existing hub as a template** — no other UAL service's hub is a reference,
so its group model, batching and reconnect behaviour were designed here.

---

## 4. FE / BE / DB / RT scope

*Six streams exist, not four - `QA` and `BA` are named here where they apply.*

| Stream | Scope |
|---|---|
| **RT** | Fifteen activities. The hub, the typed client contract, the broadcast loop, the OPC ingest and bounded channel, the SignalR client and mock, PWA cache sync, `PLCTagService` and its simulate branch, the tag group push, `ITInhibitService`, the line-model kinematics, the simulation seam, the closed loop, fault injection, and cache invalidation |
| **BE** | The simulator control API `/sim/**`, the trial control surface, per-tag write status from `OPCConnection`, flat wire's `OPCConnection` registration, and the tag surface revision |
| **FE** | One, and it is unusual: **`DB-S1`, a standalone WinForms desktop console** (`D-33`) — the largest single activity here and not an Angular screen at all |
| **DB** | Only through `FW-238`'s registration, which writes `CommonDB.OPCTags` |
| **QA** | ⚠ **None.** The hub load test is `FS-06`'s and commissioning is `FS-19`'s |

⚠ **Tag paths are registered in `CommonDB.OPCTags`** (`D-44`/`D-45`) with `appsettings` as the
resolution map, and every path carries a `PLC` element (`D-46`).

---

## 5. Current status

⚙ **Generated.** See this category's row and activity table in
[`FEATURES.md`](../../FEATURES.md).

---

## 6. Open items and gaps

<!-- BEGIN GENERATED: blockers -->

> ⚙ **Generated by `tools/build_features.py`.** Do not edit inside the markers - the union of `blocked_by:` across this category, which exists in no other document.

**20 register items cited by 12 of 22 activities** - **20 open**.

| Item | State | Blocks | What is missing |
|---|---|---|---|
| **`G9`** | ⛔ open | `FW-080` · `FW-150` · `FW-203` · `FW-210` | NFRs absent (AGC Hz, concurrent clients, latency, reading retention) |
| **`OI-34`** | ⛔ open | `FW-080` · `FW-150` · `FW-203` · `FW-210` | G9 — the non-functional targets are absent. AGC sample rate, concurrent client count, latency budget and reading-retenti |
| **`G2`** | ⛔ open | `FW-082` · `FW-151` · `FW-212` | Check-in spans FlatWireDB (run/checkin/SPC) + the shared reqsum / wip_coil_orders / actual_start_date / wip_stations.coi |
| **`G29`** | ⛔ open | `FW-082` · `FW-212` · `FW-N05` | No edger tag path exists on any line, yet edge type is in the push payload. Four of five sources list edge type among th |
| **`G30`** | ⛔ open | `FW-082` · `FW-205` · `FW-212` | FM2's controller namespace on FL3 is undetermined, and it decides what partial failure means. Every published tag map ad |
| **`OI-39`** | ⛔ open | `FW-082` · `FW-151` · `FW-212` | Cross-database check-in has no defined recovery path. Check-in spans FlatWireDB + shared coils/wip_coil_orders/planning_ |
| **`G10`** | ⛔ open | `FW-080` · `FW-135` | Real-time deploy prereqs / MessagePack dependency |
| **`OI-45`** | ⛔ open | `FW-210` · `FW-213` | OQ-10 — footage-to-weight: the formula and the density source are now settled; the dimensional basis is not. §5.4 fixes |
| **`Q10`** | ⛔ open | `FW-210` · `FW-213` | > ⛔ THE CLIENT IS NOW DISPUTING OUR FIGURES — 3 Sep 2026, twice in one document. Tim O'Brien, on a worked example statin |
| **`G105`** | ⛔ open | `FW-135` | THE HUB PROTOCOL IS UNDECIDED, AND THE TWO OPTIONS PUT ENUMS ON THE WIRE IN DIFFERENT FORMS. FlatWire.API calls AddMessa |
| **`G32`** | ⛔ open | `FW-N05` | The FM2 PLC station names in the spec are ours, not the controller's. The 4 Aug 2026 roller-size correction established |
| **`G33`** | ⛔ open | `FW-N05` | The measure segment of every tag is ours, not the controller's — and it departs from thirteen observed strings. On 4 Aug |
| **`G34`** | ⛔ open | `FW-213` | Wire break now has a decided flow and still no persistence target. The client specified the whole sequence on 6 Aug 2026 |
| **`G59`** | ⛔ open | `FW-N05` | No service identity exists for a PLC write that no operator initiated. ✅ Mechanism confirmed by executing FW-151 on 28 A |
| **`G60`** | ⛔ open | `FW-N05` | ⚠ HALF CLOSED 6 Sep 2026 — the registration EXISTS on DEV00164-001; the running service is still unproven. 11_ ran and c |
| **`G69`** | ⛔ open | `FW-215` | [SIM §9.2] requires the console to show TWO state chips and the wire carries ONE vocabulary. The section is explicit - " |
| **`OI-35`** | ⛔ open | `FW-210` | OQ-21 — FL{n}.LineState vocabulary is undocumented. Two-state run/stop bit, or RUNNING / STOPPED / PAUSED / FAULT / THRE |
| **`PLC-Q04`** | ⛔ open | `FW-082` | Confirm the FM2 station names — S1, S2, S3, carrying position only (§4.3). Every FM2 row in §5.2.2 is [PROPOSED] until t |
| **`PLC-Q05`** | ⛔ open | `FW-N05` | Confirm every measure name in §5.2 — RollGap, Gauge, Width, Footage, Diameter, Weight, Status.IsActive, Status.IsFaulted |
| **`Q05`** | ⛔ open | `FW-082` | Traceability granularity for certs |

<!-- END GENERATED: blockers -->

**Twenty items — the second-highest in the module — and they divide cleanly.**

**The tag surface is a proposal.** **`G32`**/**`PLC-Q04`** (FM2 station names), **`G33`**/**`PLC-Q05`**
(every measure name), **`G29`** (no edger tag path exists on any line, yet edge type is in the push
payload), **`G30`** (FM2's controller namespace on FL3). ⛔ **Most of what this category writes to a
controller is unconfirmed**, and only commissioning can confirm it.

**The protocol itself is undecided.** ⛔ **`G105` — the hub protocol is undecided, and the two
options put enums on different sides of the wire.** This is the most structural open item here: it
changes the client contract, and `FW-149`'s typed event contract is already `in-review`.

**The non-functional targets are absent.** **`G9`**/**`OI-34`** — AGC sample rate, concurrent
clients, latency budget, reading retention. **`G10`** — real-time deploy prerequisites and the
MessagePack dependency. This is the category with the strictest timing requirements and **no number
to build to**.

**Identity and vocabulary.** **`G59`** (no service identity for an unattended PLC write),
**`G60`** (⚠ **half closed** — the registration exists on `DEV00164-001`, the other half does not),
**`OI-35`** (`FL{n}.LineState`'s vocabulary is undocumented), **`G69`** (the console must show two
state chips).

Plus items that belong to other categories and surface here: `G2` and `OI-39` (check-in's
transaction and its missing recovery path), `G34` (wire break), `OI-45` (footage-to-weight),
`Q05` (certificate granularity) and **`Q10`** — ⚠ *"the client is now disputing our figures"*.

**Gaps this category owns that no story cites:**

- ⚠ **`G126` — three of this category's cards carried a stale acceptance criterion whose
  correction lived only in the now-archived plan.** Corrected on the card 9 Sep 2026:
  **`FW-136`** nine events and no markers → **`[SIG §5.2]`'s full typed set**, `PayoffStateChanged`
  and every SCADA marker included — ⛔ *a diff against that card as written reports eleven
  mismatches, and the dangerous "resolution" is to trim the server to match*; **`FW-151`** two
  operations → **five**, none returning `void`; **`FW-205`** two `ITInhibit` tags → **three
  lines**, `FW-144` having already boot-asserted the three-line surface. ⛔ **`G126`'s other rows
  are unreviewed.** See [`Gaps.md`](../../90-registers/Gaps.md).

- ⛔ **`G105` should be settled before `FW-149` leaves review.** An undecided wire protocol with a
  typed contract in review is the wrong order.
- ⚠ **The simulator is not evidence about the controllers.** Eleven activities are `done` and the
  built pipeline runs end to end against `SimulatePLCTagPush` and the line models. **None of that
  says a real PLC will accept a single tag path.**
- ⚠ **`G39` — `[SIM §5.6]`'s assumption table is the only instrument for the simulator's
  assumptions**, and nothing validates them against real machine behaviour.
- ⚠ **`OI-28`'s alert lifecycle is unbacked** and this category carries the transport for it —
  tracked under `FS-06`, which owns the engine.

---

## 7. Dependencies

⚠ **This file carries no `depends_on`.** Consolidation turns the acyclic task graph into a
cyclic category graph - 15 mutually dependent pairs - so a category-level dependency list is
unusable. Dependencies live **per activity** in section 5. The category-level direction is
recorded, generated, in [`[SCM §2.4]`](../../90-registers/StoryConsolidationMap.md).

**On other categories.** `FS-04` → `FS-01`, `FS-02`, `FS-03`, `FS-05`, `FS-07`, `FS-18` and
`FS-19`, with the module's **strongest coupling** against `FS-02` — 14 edges out, 4 back. They
compile into one solution. Four categories consume the stream: `FS-06`, `FS-08`, `FS-11` and
`FS-13`.

**On `FS-19` — inverted, and it matters.** Normally testing depends on the thing tested. Here
**commissioning is a precondition of this category being correct**, because no tag path is confirmed
until `C1`/`C11` accepts it. `FS-04` can be complete and still wrong.

**On PLC and OPC.** Extends the **existing `OPCConnection` service**; the OPC servers are unchanged
and **the PLCs are new**. `FW-236` and `FW-238` are its two recorded defects — no per-tag write
status (`G58`) and no flat wire registration (`G60`) — both `in-progress`.

**On client and controls decisions.** Six tag-surface items and `G105`'s protocol. None is an
engineering choice this project can make alone.

---

## 8. Change-impact profile

**What a change here affects.** Four categories' screens and every machine interaction.

| A change to… | Affects |
|---|---|
| **the hub protocol** (`G105`) | `FS-01`'s client models, `FW-149`'s typed contract, and all four consuming categories. **Enums land on a different side of the wire depending on the answer** |
| **a broadcast event's shape** | `FS-06`'s tiles, `FS-08`'s trace and cards, `FS-11`'s FL2 trace, `FS-13`'s continuous trace. Ten events, four consumers |
| **the cadence** | `FS-08`'s rendering. FL2 at 4 s and FL1/FL3 at ~10 Hz through one path — a change to batching changes what "live" means on three screens |
| **a tag path** | `FS-07`'s acknowledgement and `FS-13`'s two-controller write. ⚠ Change it in `[PLC]` only |
| **`ITInhibitService`** | `FS-07`'s `FW-206`/`FW-257`, and `FS-18`'s `ItInhibitReason` lookup |
| **the simulator** | `FS-19`'s commissioning approach and the trial run. `DB-S1` is a desktop tool with its own lifecycle |

**Existing implementation to modify.** ⚠ **The second-largest body of working code in the module.**
Eleven activities are `done` with measured verification (see §2's generated evidence), two are
`in-progress` and two are `in-review`. The hub, the broadcast loop, `PLCTagService`'s simulate
branch, the line models, the simulation seam, the closed loop, fault injection, the `DB-S1` console
and the `/sim/**` API all exist and run.

**Regression areas.**

- ⛔ **Everything built here is validated against a simulator.** The pipeline demonstrably works;
  whether it works against a controller is unknown until `FS-19`. **Do not read `done` as
  commissioned.**
- **`G105`'s undecided protocol threatens `FW-149`'s reviewed contract**, and through it every
  client model in `FS-01`.
- **`G60` is half closed** — the registration exists on one instance only, and half-closed reads as
  closed.
- **No NFR target means no performance regression test is possible.** The hub could degrade
  measurably and nothing would fail.
- **`FW-N25` revises the tag surface** — one write removed, two reads added — so anything holding
  the older payload shape is stale.
- **The two `OPCConnection` defects are `in-progress` in a service this project does not own.**
  Changes there affect other UAL modules.

---

## 9. Implementation plan

⛔ **Deliberately absent.** An implementation plan is written only when this category is taken
up for implementation, and only for work that never had one. Work already built is recorded in
its build record, cited from section 2.
