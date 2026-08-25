# Flat Wire Mill — API Contract

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 25, 2026 — the five `lineId = FL2` → `422` sites marked withdrawn pending wave W5; `@expectedCoilNo` rename completed *(previously August 22, 2026 — **`POST /coil/complete`’s worked example was losing a foot** (`footageFrom: 1851` → `1850`): `CoilTraceability` ranges are **half-open `[From, To)`**, as the non-overlap trigger enforces, so the example a developer copies would have failed `TC-617` *(previously August 18, 2026 — **`D-32`: there is no shared-schema migration.** `ROD_UNAVAILABLE` and the staging/check-in availability tests move to local `Rod.Status`; the `coils.coil_status = INFLAT` side effect is struck from the check-in write list *(previously August 15, 2026 — **`SpoolController` added to §3.1** (fourteen → **fifteen**: §3.2 assigned `GET /spools` to a controller in no list) and the **endpoint count corrected to 31 live rows, of which MVP-1 implements 24** — *"28 of the 30"* contradicted this file's own *"the pass schedule is read, never written"*, which removes six endpoints rather than one. `[PLC §351–356]` retargeted to `[PLC §7.2]` *(otherwise August 13, 2026 — split out of `04-APIContract.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*)*))*
**Document Type:** REST contract — conventions, enums, endpoints, traceability
**Status:** Baselined for build — missing endpoint groups in §10
**Owner:** Backend (.NET) stream
**Audience:** Frontend and backend developers, integration testers
**Shortcode:** `[API]`
**Part of:** `ProjectPlan/Backend/` — index: [README.md](../README.md)

---

## 1. Conventions

### 1.1 Service and addressing

| Item | Value |
|---|---|
| Service | `FlatWire` — a new microservice at `API/Domain/FlatWire/` in `ual-api` |
| REST base URL | **`/api/v1/flatwire`** |
| Hub URL | **`/hubs/flatwire`** |
| Controller base class | `UAController` from `UA.Framework.API` |
| Authorization | **Every controller and every endpoint carries `[Authorize]`** |

> This resolved the inconsistency where the April check-in implementation prompt used a bare `ControllerBase` with no attribute (deleted 13 Aug 2026). **Use `UAController` + `[Authorize]`** — this contract is now the source of record for the rule.

### 1.2 Response envelope

Every endpoint returns the standard UAL envelope.

```json
// success
{ "data": { }, "success": true }

// validation error — 400
{ "success": false, "errors": ["Field X is required"] }

// not found 404 · conflict 409 · unprocessable 422 · server or PLC 500
{ "success": false, "errors": ["…"] }
```

`data` is `null` on any non-success. `errors` is always an array, never a bare string.

### 1.3 Status-code usage

| Code | Meaning in this contract |
|---|---|
| `200` | Success with a body |
| `400` | Request failed **shape or field-level** validation (missing required field, wrong type) |
| `401` / `403` | Not authenticated / role not permitted (see §9.2) |
| `404` | The named resource does not exist (rod alpha, schedule id, run id) |
| `409` | **Conflict with current state** — line already has an active run, bay already occupied, rod already staged or checked in, payoff mismatch, optimistic-concurrency failure |
| `422` | The request is well-formed but **violates a business rule** — inspection fail, ~~`lineId = FL2` at a staging endpoint~~ *(withdrawn, `FR-533`)*, `Draft` schedule at check-in, carry-forward not acknowledged, diameter outside tolerance, missing supervisor authorisation |
| `500` | Server error **or PLC push failure**, with the transaction aborted and compensating writes issued |

**The 409/422 split is load-bearing.** A `409` means "someone or something else got there first — re-read and retry"; a `422` means "this will never succeed as submitted".

### 1.4 Headers

| Header | Direction | Purpose |
|---|---|---|
| `Authorization: Bearer <jwt>` | request | Required on every endpoint |
| `X-Correlation-Id` | request / response | Set by the shared `correlation-id-interceptor`; echoed back and stamped on every Serilog line |
| `Content-Type: application/json` | both | |

### 1.5 Pagination

List endpoints (`GET /passschedule`) accept `page` (1-based, default 1) and `pageSize` (default 50, max 200), and return `{ items: [], totalCount, page, pageSize }` inside `data`. Non-paginated list endpoints (`GET /lines/status`, `GET /staging/queue`) return the full set — they are bounded by three lines and one order respectively.

### 1.6 Date, time and timezone

- All timestamps are **ISO 8601 with offset** and map to SQL `DATETIMEOFFSET`.
- **Every event timestamp is server-side at API receipt** — the client clock is never persisted, even when the screen displays it.
- `RunReading.ReadingTs` is `DATETIME2` in UTC (`SYSUTCDATETIME()`), the one deliberate exception, because it is a high-volume time series.

### 1.7 Units and precision

Units are **never** carried in field names as abbreviations alone; the suffix states them.

| Quantity | Unit | Wire type | DB type |
|---|---|---|---|
| Gauge, width, diameter, roll gap, die size | **inches** | `number` | `DECIMAL(8,4)` |
| Footage | **feet** | `number` | `DECIMAL(10,2)` on run/detail/reading; `INT` on event tables |
| Weight | **pounds** | `number` | `DECIMAL(8,2)` |
| Speed | **FPM** (feet per minute) | `number` | `INT` on schedule bounds, `DECIMAL(8,2)` on readings |
| Reduction, tolerance percent | **fraction** (0.220 = 22 %) on `AlloyProperty`; **percent** on generator responses | `number` | `DECIMAL(5,3)` |
| Temperature | **°F** | `number` | — |

> **Footage is `DECIMAL(10,2)` on `FlatWireRun`/`FlatWireRunDetail`/`RunReading` but `INT` on the event tables.** That is a known inconsistency (gap **G14**) the DDL has not resolved. Clients must not assume a fractional footage round-trips through an event endpoint.

### 1.8 Error-code catalogue

Machine-readable codes accompany the human-readable `errors[]` where a client must branch on the reason.

| Code | HTTP | Meaning | Client action |
|---|---|---|---|
| `ROD_NOT_FOUND` | 404 | Rod alpha not in `coils` | Show scan error, keep focus in the field |
| `ROD_NOT_ALLOCATED` | 422 | No `planning_routings` allocation | Refuse; the rod cannot be staged |
| `ROD_UNAVAILABLE` | 409 | `coils.coil_status` in `COMPLETE`/`HOLD`/`SCRAP`, **or `Rod.Status = 'INFLAT'`** *(local since `D-32` — `INFLAT` is not a shared status value)*, or already staged | Refuse |
| `ROD_WRONG_ORDER` | 409 | Rod belongs to a different order once one is established | Refuse — welding across orders breaks genealogy |
| `BAY_OCCUPIED` | 409 | `UX_RodStaging_Bay` violated | Re-read bay state and re-render |
| `ROD_ALREADY_STAGED` | 409 | `UX_RodStaging_RodActive` violated | Re-read |
| ~~`LINE_NOT_ELIGIBLE`~~ | ~~422~~ | ~~`lineId = FL2` at a staging endpoint~~ | ⚠ **Withdrawn in requirement text by `FR-533`** — FL2 gets a validation queue, so the action is **shown** on FL2, not hidden. Endpoint change owed (W5) |
| `INSPECTION_FAILED` | 422 | Any inspection item `Fail` | Route to WIP Rejection — payload carries `{route:"wipRejection", rodAlpha}` |
| `CARRY_FORWARD_REQUIRED` | 422 | `footageRunToDate > 0` without `acknowledgedCarryForward` | Show the carry-forward path only |
| `DIAMETER_OUT_OF_TOLERANCE` | 422 | Measured diameter outside nominal ± tolerance | Block, show the valid range |
| `SUPERVISOR_AUTH_REQUIRED` | 422 | A deviation applies and the credential block is missing or incomplete | Open the override panel |
| `SCHEDULE_NOT_ACTIVE` | 422 | The referenced schedule is `Draft` or `Inactive` | Block acknowledgement |
| `SCHEDULE_NO_MATCH` | 422 | **No active schedule matches the order attributes** | **Path undefined — OI-46.** Interim: block and alert Operations |
| `RUN_ALREADY_ACTIVE` | 409 | The line already has a `Running` or `Paused` run | Refuse |
| `PAYOFF_MISMATCH` | 409 | Requested payoff ≠ the staged position | Refuse |
| `LINE_STILL_RUNNING` | 422 | `FL{n}.LineState` reports Running at a checkout | Show "Stop the line before checking out the rod" |
| `PLC_PUSH_FAILED` | 500 | One or more tag writes failed; compensating clears issued | Show the abort, offer retry |
| `CONCURRENCY_CONFLICT` | 409 | `ROWVERSION` mismatch | Re-read and re-present |

---

---

## 2. Canonical enums

**Define once; mirror in three places.** Every enum below exists as a C# enum in `FlatWire.Domain/Enums`, a TypeScript union in the Angular library's `models/`, and a `CHECK` constraint in the DDL. **A change to any one is a change to all three** — this is the rule that the four defects in §2.3 all violated.

```csharp
enum LineId          { FL1, FL2, FL3 }
enum LineState       { Running, Idle, Setup, Paused, Fault, Offline }
enum RouteMode       { Standalone, Hybrid }
enum ScheduleStatus  { Draft, Active, Inactive }
enum ComponentName   { DB1, DB2, FM1, EdgeSet, FM2_S1, FM2_S2, FM2_S3 }   // FM2: S1 = 8", S2 = 6", S3 = 6" final
enum ComponentState  { Active, Bypass, Skip }          // three values — never a boolean
enum EdgeType        { Round, Square }                  // UI labels: "Round Edge" / "Flat Edge"
enum MaterialStatus  { RECEIVED, STAGED, INFLAT, COMPLETE, HOLD, SCRAP }
enum PayoffPosition  { Payoff1 = 1, Payoff2 = 2, TraversingTakeup = 3 }
enum CheckpointType  { PreRun, PostDieChange, RollAdjustTrigger, ManualSpotCheck, PostRun }
enum DispositionCode { Suspend, Scrap, Rework }
enum AlertSeverity   { Info, Warning, Critical }
enum CheckoutMode    { ModeP, ModeA, ModeB }
enum StagingStatus   { Staged, CheckedIn, Unstaged }
```

### 2.1 Edge type — the one vocabulary

**Three vocabularies were circulating** across the source documents: `Round`/`Square` (schema and API), `Round`/`Flat` (story FW-010), and `Round Edge`/`Flat Edge` (stories FW-050/052). **Nothing mapped "Flat" to "Square".**

**Resolution — the winner is `Round` / `Square`:**

| Layer | Value |
|---|---|
| Domain enum, DTO wire value, DB `CHECK` (`CK_Edger_EdgeType`, `CK_PSC_EdgeType`) | **`Round`** · **`Square`** |
| Operator-facing label, everywhere it renders | **"Round Edge"** · **"Flat Edge"** |
| Mapping | A single Angular display pipe. **No other translation exists anywhere in the system** |

> **`Bevel edge` has no domain value.** The Dashboard 9 / 9A Generate modal offers it as a third option on two screens; the domain and the DB `CHECK` allow only `Round`/`Square`. It is a **fourth** vocabulary on top of the three above. Either add the value or remove the UI option — **OI-05**. **Until it is decided, `Bevel` must not be accepted by any endpoint.**

### 2.2 `CheckpointType` — five values, not four

**The published enum had four values** — `{PreRun, PostDieChange, ManualSpotCheck, PostRun}` — but `POST /rolloverride` is specified to write a checkpoint of type **`RollAdjustTrigger`**, and the DB `CHECK` already allows it. **Inserts would fail as specified.**

**Resolution: `RollAdjustTrigger` is added.** The enum has **five** values.

> **A sixth is proposed but not adopted.** The Dashboard 6 selector offers **"Post DB1"**, and the 21 May 2026 corrections name it as a decided addition — but it is **absent from the persisted domain in both the API enum and the DB CHECK**. The decision was applied to the UI and never to the data model. **Do not accept `PostDb1` until the enum and the CHECK are both extended** — **OI-10**.

### 2.3 The four corrections applied to the published contract

| # | Defect in the April elaboration (now absorbed) | Correction |
|---|---|---|
| 1 | **`/passschedule/generate`'s worked example contradicts its own algorithm** on three counts | Corrected example published in §4.2. **Build to the formula, not the example** |
| 2 | **`CheckpointType` is missing `RollAdjustTrigger`** | Added — §2.2 |
| 3 | **Component state modelled two incompatible ways** — `State ∈ {Active,Bypass,Skip}` in the schema versus `IsActive (bool)` in story FW-010 | Standardised on the **three-value enum**. A boolean cannot express Bypass versus Skip |
| 4 | **Edge type has three vocabularies** with no mapping between them | One domain set + a display pipe — §2.1 |

Two further corrections this document also carries:

| # | Defect | Correction |
|---|---|---|
| 5 | **`POST /checkin/rod` omits three `NOT NULL` columns.** `RodCheckin.InspectionConnectorTag`, `SpcM1In` and `SpcM2In` are `NOT NULL`; the April body sent none of them, so **inserts fail as specified** | The contract is **extended** — §4.6 |
| 6 | **`ComponentName` modelled FM2 as four stands** and carried a stray `Edger` value | **Superseded Aug 4 2026 — FM2 has three stands and the 8" roller is S1.** The enum is now `FM2_S1` (8") / `FM2_S2` (6") / `FM2_S3` (6", final); the never-existent `FM2_6inS3` is withdrawn and diameter moved to `Stand.RollDiameterIn`. The stray `Edger` is dropped — the edger is expressed by `EdgeType` on the component, not by a component name. `PayoffPosition` also gains `TraversingTakeup = 3`, and the enum formerly called `LineStatus` is renamed **`LineState`** so it does not collide with the `LineStatus` hub event |

---

---

## 3. Controllers and endpoint index

### 3.1 Controllers

| Controller | Routes |
|---|---|
| `LinesController` | `/lines/status` |
| `PassScheduleController` | `/passschedule/**` |
| `RodReceivingController` | `/rod/**` |
| `PayoffStagingController` | `/payoff/status`, `/staging/**` |
| `CheckInController` | `/checkin/**` |
| `RunController` | `/run/**` |
| `SpcController` | `/spc` |
| `WeldEventController` | `/weldevent` |
| `RollAdjustController` | `/rolloverride` |
| `DieChangeController` | `/diechange` |
| `CheckOutController` | `/checkout` |
| `WipRejectionController` | `/wipreject` |
| `SpoolController` | `/spools` |
| `CoilController` | `/coil/**` |
| `ShiftSummaryController` | `/shiftsummary` |

> **Fifteen controllers, not fourteen — resolved 15 Aug 2026.** This table listed **fourteen** while §3.2
> row 16a assigned `GET /spools` to a `Spool` controller that appeared in no list, so an MVP-1 endpoint
> (`FR-097`–`FR-099`, DB5/DB5A, Phase 8) had **no host**. It does not fit `/checkin/**`, and `[TRP §1.4]`
> independently counts `Spool` among the trial's controllers. **§3.1 was the side that was wrong.**
> `phase-01b`, its acceptance criterion 2 and `FW-138` (now 15 controllers) carry the corrected count.

### 3.2 Endpoint index — 32 endpoints, of which MVP-1 implements 25

Roles use the matrix in `[SEC §8]`. "Any" means any authenticated role.

> **The count was corrected on 15 Aug 2026 and the arithmetic is worth stating, because three different
> figures were in circulation.** The table below has **32 live rows** — numbered 1–30 with **#13 retired**,
> plus **16a**, **16b** and **18a**. Of those, **seven are outside MVP-1**: the six pass-schedule endpoints
> (**2–7**) and `GET /shiftsummary` (**29**). **MVP-1 therefore implements 25 of 32.**
>
> **16b `POST /spool/complete` was added 15 Aug 2026** — the spool-completion commit had no route at all
> (`OI-32`), which is why `[TRP §1.4]` had it running through `CoilController`.
>
> ⚠ **The old "30 endpoints / MVP-1 implements 28 of the 30" was wrong in both halves.** It counted the
> retired row, missed 16a and 18a, and — the substantive error — deducted only `POST /passschedule/generate`
> when *"The pass schedule is read, never written"* below states that **MVP-1 exposes no pass-schedule
> endpoint of its own: no create, no edit, no approve, no list.** That is five more. The rows are **kept in
> the index on purpose** so the map shows the whole surface; deferred is not missing.

| # | Method + route | Purpose | Role | Controller | Phase | Serves |
|---|---|---|---|---|---|---|
| 1 | `GET /lines/status` | Snapshot of all three lines for DB1 on load | Any | `Lines` | 3 | `FR-420`–`FR-428` |
| 2 | `GET /passschedule` | Filtered, paginated schedule list + counts | Any (read) | `PassSchedule` | 2 | `FR-400`–`FR-408` |
| 3 | `GET /passschedule/{id}` | Full detail incl. components and recent overrides | Any (read) | `PassSchedule` | 2 | `FR-371`–`FR-374` |
| 4 | `POST /passschedule` | Create — starts `Draft` | OpsMgr, Eng | `PassSchedule` | 2 | `FR-360`, `FR-361`, `FR-409` |
| 5 | `PUT /passschedule/{id}` | Replace editable fields | OpsMgr, Eng | `PassSchedule` | 2 | `FR-364`, `FR-372` |
| 6 | `PATCH /passschedule/{id}/status` | `Draft→Active`, `Active→Inactive`, `Inactive→Active` | OpsMgr, Eng | `PassSchedule` | 2 | `FR-410` |
| 7 | `POST /passschedule/generate` | Run the generator; returns a **draft, unpersisted** | OpsMgr, Eng | `PassSchedule` | 2 | `FR-380`–`FR-391` |
| 8 | `GET /rod/{alpha}` | Validate + return rod details at scan | Any | `RodReceiving` | 4 (upstream data) | `FR-042`, `FR-064` |
| 9 | `POST /rod` | Receive a rod, generate an R-series alpha | Receiving | `RodReceiving` | upstream | — |
| 10 | `GET /payoff/status?lineId=` | Both payoff bays on one line — the DB2A primary read | Any | `PayoffStaging` | 4 | `FR-032`–`FR-034` |
| 11 | `POST /staging/rod` | Pre-check-in: stage a rod at a bay | Operator (+Supervisor for the out-of-sequence override) | `PayoffStaging` | 4 | `FR-039`–`FR-049` |
| 12 | `POST /staging/rod/unstage` | Pre-check-out — writes `RodCheckout` Mode P | Operator; **+Supervisor when the rod is welded** | `PayoffStaging` | 4 / 7 | `FR-052`–`FR-054` |
| ~~13~~ | ~~`POST /staging/rod/mark-welded`~~ **RETIRED 1 Aug 2026** — superseded by `POST /weldevent`, which is now the single weld write | — | — | — | `FR-050`, `FR-051` |
| 14 | `GET /staging/queue?lineId=` | The Traveler Queue projection | Any | `PayoffStaging` | 4 | `FR-035`–`FR-038` |
| 15 | `POST /checkin/rod` | FL1/FL3 rod check-in + PLC push | Operator | `CheckIn` | 4 | `FR-063`–`FR-084` |
| 16 | `POST /checkin/spool` | FL2 spool check-in + FM2 PLC push | Operator | `CheckIn` | 8 | `FR-090`–`FR-096` |
| 16a | `GET /spools[?spoolAlpha=]` | Spools available for FL2; with `spoolAlpha` the **backend resolves the order** and returns it with that order's spools, in one response | Any | `SpoolProcessing` **(§3.1, added 15 Aug 2026)** | 8 | `FR-097`–`FR-099` |
| 16b | **`POST /spool/complete`** | **Commit an FL1 spool**: writes the `SpoolProcessing` row (`SP-#####` alpha, source rods, footage, latched weight) and closes the run. Answers the `SpoolCompletionPromptDue` prompt, **and** serves the manual complete-spool path | Operator | `SpoolProcessing` | 5 *(rows written by `FW-202`)* | `FR-140`–`FR-155` |
| 17 | `GET /run/active?line=` | Active run for a line (DB3 load/resume) | Any | `Run` | 5 | `FR-100` |
| 18 | `GET /run/{runId}/gaugetrace` | Historical/decimated trace + weld markers | Any | `Run` | 5 / 8 | `FR-093`, `FR-120` |
| 18a | `GET /run/{runId}/weldevents` | Every weld recorded against one run — read-only | Any | `Run` | 4 *(rows written in 6)* | `PCI021` |
| 19 | `POST /run/{runId}/pause` | Pause with a categorised reason | Operator | `Run` | 6 | `FR-260`–`FR-264` |
| 20 | `POST /run/{runId}/resume` | Resume with one of four outcomes | Operator | `Run` | 6 | `FR-265`, `FR-266` |
| 21 | `POST /spc` | Record a checkpoint measurement set | Operator, QA | `Spc` | 4, 6 | `FR-180`–`FR-196` |
| 22 | `POST /weldevent` | Record a weld join | Operator | `WeldEvent` | 6 | `FR-160`–`FR-175` |
| 23 | `POST /rolloverride` | Run-level roll-gap override + PLC write + SPC log | Operator | `RollAdjust` | 6 | `FR-200`–`FR-211` |
| 24 | `POST /diechange` | Die change event; triggers PostDieChange SPC | Operator | `DieChange` | 6 | `FR-220`–`FR-234` |
| 25 | `POST /checkout` | Rod checkout Mode A / Mode B | Operator (+Supervisor for B) | `CheckOut` | 7 | `FR-300`–`FR-327` |
| 26 | `POST /wipreject` | WIP rejection + supervisor alert | Any | `WipRejection` | 7 | `FR-290`–`FR-299` |
| 27 | `POST /coil/complete` | Complete a coil: alpha, traceability, skid | Operator | `Coil` | 9 | `FR-330`–`FR-339` |
| 28 | `GET /coil/{alpha}/label` | Label render data | Operator | `Coil` | 9 | `FR-336` |
| 29 | `GET /shiftsummary` | Per-shift aggregation across lines | Supervisor, OpsMgr | `ShiftSummary` | 11 | `FR-480`–`FR-489` |
| 30 | `GET /health` | DB + OPC reachability | Any / anonymous per policy | — | 1 | `[DEP §5]` |

---

---

## 4. Endpoint detail

Only shapes carrying a correction or a non-obvious rule are given in full. The remainder follow the same envelope and the field names in `[DBD §6]`.

### 4.1 `GET /lines/status`

**Purpose:** one snapshot of all three lines so DB1 can render before the first hub message arrives.
**Role:** any authenticated. **Idempotent**, no side effects.

```json
{ "data": { "lines": [ {
      "lineId": "FL1", "status": "Running",
      "activeOrderId": "FW-00421", "activeAlpha": "R00041",
      "alloy": "1100", "routeMode": "Standalone",
      "speedFpm": 1620.0,
      "currentGauge": 0.110, "currentWidth": 0.625,
      "targetGauge": 0.110, "targetWidth": 0.625,
      "gaugeTolerance": 0.002, "widthTolerance": 0.005,
      "passScheduleId": "PS-1100-FL1-003",
      "runStartedAt": "2026-08-24T06:14:00Z",
      "payoffs": [
        { "position": 1, "weightLb": 4200.0, "percentRemaining": 47.0, "alpha": "R00041", "state": "Active" },
        { "position": 2, "weightLb": 8500.0, "percentRemaining": 100.0, "alpha": "R00043", "state": "Staged" } ],
      "activeAlerts": [ { "alertType": "PayoffLow", "severity": "Warning",
                          "message": "Payoff 1 below 3,000 lb — prepare weld",
                          "raisedAt": "2026-08-24T07:41:00Z" } ] } ],
    "asOf": "2026-08-24T07:42:00Z" }, "success": true }
```

**Three rules a client must implement:**

- **`activeOrderId` is `null` while a line is `Idle`.** The station must not display an order it has not started.
- **`currentGauge` and `currentWidth` are `null` for FL2.** FL2 broadcasts no live trace; its profile is `GET /run/{runId}/gaugetrace`.
- **`payoffs[].state` comes from `RodStaging`**, not from the weight feed. `weightLb` / `percentRemaining` come from the live `PayoffWeight` feed and are `null` on a bay that is not drawing. This split is what makes the "Payoff 2 not loaded" alert rule (`FR-424`) correct — a weight of zero does not distinguish an empty bay from a sensor reading zero.

**`activeAlerts` has no backing table.** Alerts are computed live; they cannot survive a restart and acknowledgements cannot be audited — **OI-28**.

### 4.2 · 4.18 — moved to MVP-2

> **Two endpoints sit in [`../../MVP-2/ProjectPlan/04-APIContract-MVP2.md`](../../../MVP-2/ProjectPlan/04-APIContract-MVP2.md)** — `POST /passschedule/generate` and `GET /shiftsummary`. **Copied verbatim.**
>
> **Four were extracted on 11 Aug 2026; two came back the same day.** **§4.15 `POST /coil/complete`** and **§4.16 `GET /coil/{alpha}/label`** returned with Phase 9, which is **wholly MVP-1** — they are the only writers of `CoilOutput` and `CoilTraceability`, and those tables carry the welding-wire certificate genealogy. They are restored below.
>
> **§3.2's endpoint index lists all 31 rows and is left whole on purpose**: the index is the contract's map of the whole surface, and holes in it would be read as missing endpoints rather than deferred ones. **The MVP-1 service implements 25 of the 32** — the six pass-schedule endpoints and `GET /shiftsummary` are out. *(Corrected 15 Aug 2026 from "28 of the 30", which contradicted the very next section — see §3.2's note.)*

### The pass schedule is read, never written — and never by an endpoint here

**Pass schedule generation and management are owned by a separate track.** `POST /passschedule/generate` above is theirs, and MVP-1 exposes **no** pass-schedule endpoint of its own: no create, no edit, no approve, no list.

> ⚠ **This heading still holds after `D-31` (15 Aug 2026), and the distinction is the whole point.**
> MVP-1 now **owns the three `PassSchedule*` tables** — they are in the MVP-1 runner and `PassScheduleId`
> is an enforced FK. **Owning the table is not owning the data.** MVP-1 reads; it does not author.
> Anyone who reads "MVP-1 builds the schedule tables" as licence to add a write endpoint has inverted it.

MVP-1 is a **consumer**. Rod check-in reads a schedule's contents to build the PLC push payload — the six value groups in `[PLC §7.2]` (component states, die sizes, roll gaps, edge type, speed, gauge/width targets) — and `POST /checkin/rod` carries only the `scheduleId` that identifies it. Three consequences for anyone implementing against this contract:

1. ⚠ **`scheduleId` is a real, enforced foreign key** — changed 15 Aug 2026 by **`D-31`**. `PassScheduleId` on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput` each has a constraint into `PassSchedule`, verified enforced and trusted on a live deploy. *It was previously "an opaque external identifier … the same class as `PlanId` and `SkidId`", and that is superseded.* **`PlanId`, `CoilOrderPlanId` and `SkidId` are unaffected** and remain external references with no local parents.
2. ✅ **The read mechanism is settled.** This contract carried an open assumption with two options — an API read from the owning track plus a local snapshot, *or* the owning track writes into `FlatWireDB` and the read is a local query. **`D-31` chooses the second.** The three `PassSchedule*` tables are built by the MVP-1 runner, so the read is a **local query**. This is arbitration between two published options, not new scope.
3. **Unavailable means check-in fails.** There is no default schedule and no partial push. If the schedule cannot be read, `POST /checkin/rod` must fail before any PLC write, not after — the push is not transactional and a partial configuration is worse than none (`[PLC §7.5]`, **G2**; `G16` closed 4 Aug 2026).
4. ⚠ **Nothing in MVP-1 populates these tables in production.** MVP-1 owns the tables and **reads** them; it has no authoring surface at all — no create, edit, approve or list, and DB9/DB9A are MVP-2. The seed covers development and the trial. **Who writes production schedules is `OI-110`**, and it is the residual risk `D-31` moved rather than removed.

### 4.3 `GET /rod/{alpha}`

**Purpose:** validate a scanned rod and return everything staging and check-in need in one round trip.
**Role:** any. **Idempotent.**

Returns `alpha, alloy, temper, diameterIn, grossWeightLb, netWeightLb, status, location, receivedAt` — **plus five fields that are required, not optional**:

| Field | Why it cannot be omitted |
|---|---|
| `orderId` | The rod→order resolution read from `planning_routings`. **`null` for a rod planning has not allocated — such a rod cannot be staged.** This is what lets a cold station identify which order it is starting |
| `scheduledLineId` | The line the order is booked on. Since 30 Jul 2026 this **drives navigation**: if it is not the line on screen, the client **switches to that station** and continues — no message, no override (**Q24**). Resolve it before posting to `/staging/rod` or `/checkin/rod` |
| `footageRunToDate` | Without it the caller cannot enforce the carry-forward gate; the scan would silently offer a fresh-start check-in for a rod that has already run footage, which `FR-043` forbids |
| `remainingWeightEstimateLb` | Starting weight for a carry-forward run |
| `stagedPayoffPosition`, `isWelded` | **Projected from the current `RodStaging` row where `Status='Staged'`** (null/false when not staged). They are **no longer columns on `Rod`** |

**Errors:** `404 ROD_NOT_FOUND`.

**Worked example**

```json
{
  "data": {
    "alpha": "R00041",
    "alloy": "1100",
    "temper": "O",
    "diameterIn": 0.375,
    "grossWeightLb": 2000.0,
    "netWeightLb": 1980.0,
    "status": "STAGED",
    "location": "Floor-A3",
    "receivedAt": "2026-04-29T14:00:00Z",

    "orderId": "FW-00421",
    "scheduledLineId": "FL1",

    "footageRunToDate": 0.0,
    "remainingWeightEstimateLb": null,
    "stagedPayoffPosition": null,
    "isWelded": false
  },
  "success": true
}
```

### 4.4 `GET /payoff/status?lineId=`

**Purpose:** the Dashboard 2A primary read — both bays on one line, as peers.
**Role:** any. **Idempotent.**

Returns, per bay: `position`, `state` (`NotStaged` \| `Staged` \| `Active` \| `Blocked`), `rodAlpha`, `rodSeqno`, `plannedSeqno`, `isWelded`, `diameterIn`, `grossWeightLb`, `netWeightLb`, `weightLb`, `percentRemaining`, `stagedAt`, `stagedBy`, `checkedInAt`, `operatorId`, and the override stamp (`outOfSequenceOverride`, `overrideBy`, `overrideAt`, `overrideReason`) where present — **`offScheduleOverride` was removed 1 Aug 2026**, see §4.5 — plus the order context header (`activeOrderId`, `orderMaterialSpec`, `stagedCount`, `availableCount`, `onOrderCount`).

**`state` is derived, not stored.** `Blocked` = `Status='Staged'` **and** any inspection column `Fail`. Adding a fourth stored `Status` value would fall outside the `UX_RodStaging_Bay` filtered index and free a bay that is still physically occupied.

**Errors:** ~~`422 LINE_NOT_ELIGIBLE` when `lineId = FL2`~~. ⚠ **The `lineId = FL2` refusal is WITHDRAWN in requirement text** (`FR-533`, `[REQ]` §5.29, client reversal 20 Aug 2026) **but is still specified here** — the contract change is wave W5 of the 20 Aug ledger and is not yet applied. Do not build the refusal; do not delete it from this contract without the W5 change.

**Worked example**

```json
{
  "data": {
    "lineId": "FL1",
    "bays": [
      {
        "position": 1,
        "state": "Active",
        "rodAlpha": "R00042",
        "rodSeqno": 1,
        "alloy": "1100",
        "temper": "F",
        "diameterIn": 0.375,
        "grossWeightLb": 8840.0,
        "netWeightLb": 8500.0,
        "weightLb": 2840.0,
        "percentRemaining": 33.4,
        "isWelded": false,
        "stagedAt": "2026-07-29T11:02:00Z",
        "stagedBy": "dave.m",
        "footageRunToDate": 14320.0,
        "runId": "RUN-0418",
        "inspection": { "oxidation": "Pass", "surfaceDefects": "Pass", "waterStains": "Pass", "notes": null }
      },
      {
        "position": 2,
        "state": "NotStaged",
        "rodAlpha": null,
        "rodSeqno": null,
        "weightLb": null,
        "percentRemaining": null,
        "isWelded": false,
        "runId": null,
        "inspection": null
      }
    ],
    "weldReadiness": {
      "severity": "Critical",
      "message": "Payoff 1 below 3,000 lb and Payoff 2 not staged"
    }
  },
  "success": true
}
```

### 4.5 `POST /staging/rod`

**Purpose:** pre-check-in. **Role:** Operator; Supervisor credentials required for either deviation. **Not idempotent** — a repeat is a `409` from the filtered unique index.

```json
{ "lineId": "FL1", "payoffPosition": 2, "rodAlpha": "R00043",
  "orderId": "FW-00421", "scrapBoxRef": "SB-1100-04",
  "diameterIn": 0.375, "grossWeightLb": 8780.0, "netWeightLb": 8440.0,
  "inspection": { "oxidation": "Pass", "surfaceDefects": "Pass",
                  "waterStains": "Pass", "observationNotes": null },
  "acknowledgedCarryForward": false,
  "supervisorOverride": {
      "outOfSequence": { "expectedRodAlpha": "R00043" },
      "supervisorBadge": "SUP-204", "supervisorPin": "••••",
      "reason": "R00043 blocked behind a forklift" },
  "operatorId": "dave.m" }
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `lineId` | enum | ✓ | `FL1` \| `FL3` today; **`FL2` is owed** (`FR-533`) — the `422` is withdrawn in requirement text, wave W5 not applied |
| `payoffPosition` | int | ✓ | 1 or 2 only |
| `rodAlpha` | string | ✓ | Must exist in `coils` |
| `orderId` | string | ✓ | **Re-resolved server-side; a mismatch is rejected** |
| `diameterIn` | number | ✓ | > 0, within the **min/max** band `nominal − RodDiameterToleranceMinusIn .. nominal + RodDiameterTolerancePlusIn`. **Unseeded today** — values owed by e-mail (**Q22**) |
| `grossWeightLb` / `netWeightLb` | number | ✓ | > 0 |
| `inspection` | object | ✓ | **Exactly three items.** No connector-tag item |
| `acknowledgedCarryForward` | bool | ✓ | Must be `true` when `footageRunToDate > 0` |
| `supervisorOverride` | object | conditional | Required only for an **out-of-sequence** stage; **omit entirely otherwise**. The `offSchedule` object was removed 1 Aug 2026 |

> **`rodSeqno` and `plannedSeqno` are not request fields — the server assigns and snapshots them.** Letting a client supply the actual sequence would let two operators claim the same position, and would let the UI echo a rod's *planned* number back as though it were the order it ran in.
>
> **The order is resolved, not supplied.** `orderId` in the body is what the client resolved from `planning_routings`; **the server re-resolves and rejects a mismatch.**
>
> **The PIN is never stored.** Only the flag, the supervisor badge/ID, the timestamp and the reason are persisted.

**Validation and outcomes**

| Check | Rule | Outcome |
|---|---|---|
| Allocation | Rod has a `planning_routings` entry, which **yields the order** | `422 ROD_NOT_ALLOCATED` |
| Order membership | Once an order is established the rod must belong to **that** order | `409 ROD_WRONG_ORDER` — welding across orders breaks genealogy. ⚠ **Knowingly wrong for a multi-order rod** — G22 |
| Order's line | The resolved order is scheduled on **this** line | **Not a refusal and not an override** — the client switches station. A mismatched POST returns `409 WRONG_STATION` with `correctLineId`; the client switches and re-posts |
| Availability | `coils.coil_status` not `COMPLETE`/`HOLD`/`SCRAP`, **`Rod.Status` not `INFLAT`** *(local since `D-32`)*, and no `Staged` row | `409 ROD_UNAVAILABLE` |
| Planned sequence | The rod is the one planning expects next (lowest `plannedSeqno` still available) | **Not a refusal** — supervisor override |
| Bay occupancy | `UX_RodStaging_Bay` / `UX_RodStaging_RodActive` | `409` **from the index, not a read-then-write race** |
| ~~Line~~ | ~~`lineId = FL2`~~ | ~~`422 LINE_NOT_ELIGIBLE`~~ — **withdrawn by `FR-533`**; W5 owed |
| Inspection | Any item `Fail` | **`201 Created` with `state: "Blocked"`** and `{"route":"wipRejection","rodAlpha":"…"}` — the row is **committed before the inspection gate** (changed 31 Jul 2026), because the bundle is already on the bay and writing nothing reported an occupied position as free. Still a **hard block, no override** (`CHK010`) |
| Carry-forward | `footageRunToDate > 0` without acknowledgement | `422 CARRY_FORWARD_REQUIRED` |
| Diameter | Outside the min/max lookup band | `422 DIAMETER_OUT_OF_TOLERANCE` |
| Rod | Not found in `coils` | `404 ROD_NOT_FOUND` |

**Side effects — compensating writes, not one ACID transaction:** `RodStaging` insert with server-assigned `RodSeqno` and snapshotted `PlannedSeqno` · **`coils.coil_status` is not changed** — and since **`D-32`** (18 Aug 2026) it is not changed at check-in either: `FW-002` is cancelled, so `INFLAT` is written to **`FlatWireDB`'s `Rod.Status`** instead (the **Q68** timing answer stands, the column has changed). Whether the reqsum + `wip_coil_orders` insert stays here is still the open half of that question (cross-database either way) · `PayoffStateChanged` broadcast. **No PLC write.**

> **Wrong station is corrected, not authorised (30 Jul 2026).** ~~Staging a rod whose order is booked on another line is a deviation requiring a supervisor override.~~ The system **selects the correct station**: the client reads `scheduledLineId` at the scan and switches to that line. `RodStaging.OffScheduleOverride`, `ScheduledLineId`, `CK_RodStaging_OffSched` and `CK_RodStaging_OffSchedLine` are **dropped**; the shared credential trio survives for the out-of-sequence override. **Open:** what happens to a part-completed wizard when the station switches mid-transaction, whether an FL3 tab exists on the FL1 panel at all (**OI-26**/**G21**), and what to do when the order is scheduled on **neither** rod line — there is no station to switch to (**Q25**, not covered on the call).

> **A blocked bay is cleared by the WIP rejection, and by nothing else.** `POST /wipreject` sets `RodStaging.Status → 'Unstaged'`, `UnstageKind = 'WipRejection'`, `WipRejectionId`, and broadcasts `PayoffStateChanged` (**Q23** item 3, 30 Jul 2026). Reusing `Unstaged` with a discriminator was chosen over a fourth `Rejected` status, which would have forced the vocabulary, `CK_RodStaging_Unstaged` and the `UX_RodStaging_Bay` filter to change together.

### 4.5a `POST /staging/rod/unstage`

**Purpose:** pre-check-out — release a staged rod that was never checked in. **Role:** Operator when the rod is unwelded; **a welded rod additionally requires a supervisor override** (`Q69`/`Q72`, decided 30 Jul 2026).

**Request:** `stagingId, reasonCode, reasonOther, disposition, notes, operatorId` — plus `supervisorOverride` when welded.

`reasonCode` — `WrongRodMisScan` · `OrderCancelledDeferred` · `FailedReInspection` · `RelocatedToLine` · `WrongRodWelded` · `Other` (`reasonOther` required).
`disposition` — `ReturnToFloorStorage` · `ReturnToWarehouse` · `HoldReturnToStorage` *(welded only)*.

**Approval depends on the weld:**

| Rod state | Approval | Rod status after | Why |
|---|---|---|---|
| **Not welded** | **None** — operator-only, reason captured | `RECEIVED` | Nothing was committed; the bundle simply comes off the bay |
| **Welded** (`IsWelded = 1`) | **Supervisor override** — badge/ID + PIN + documented reason | **`HOLD`** | The rod is induction-welded to the rod in the mill. Removing it means **cutting or splitting the material**, so this is a **rejection, not a return** |

**Side effects:** `RodStaging.Status → 'Unstaged'` with `UnstageKind = 'PreCheckOut'` · `RodCheckout` row with `Mode = 'ModeP'`, `RunId` NULL, `FootageAtCheckout` 0, `PlcTagsCleared` **false**, `WasWelded` per the staged row, and when welded `ApprovedBy`/`ApprovedAt`/`OverrideReason` plus `NewRodStatus = 'HOLD'` (enforced by `CK_RodCheckout_ModePWelded`) · `PayoffStateChanged` broadcast with `state: "NotStaged"`.

**No PLC tag clear.** Nothing was pushed, so there is nothing to clear — and unlike Mode A/B this needs **no `FL{n}.LineState` gate**, because an idle bay is not running. On the shared `coils` side there is **nothing to revert for `INFLAT`**, which staging no longer sets (`Q68`); whether the `wip_coil_orders` insert must be reversed depends on the open half of that question.

**Errors:** `422` when the rod is welded and `supervisorOverride` is missing or incomplete, or when `reasonCode` is `Other` with no `reasonOther`. **`409`** when the staged row is already `CheckedIn` — the caller must use `POST /checkout` with `mode: "ModeA"`, which does void the acknowledgement and clear tags. **The PIN is never stored.**

```json
// request — welded rod
{
  "stagingId": 412,
  "reasonCode": "WrongRodWelded",
  "reasonOther": null,
  "disposition": "HoldReturnToStorage",
  "notes": null,
  "operatorId": "dave.m",
  "supervisorOverride": {
    "supervisorBadge": "SUP-204",
    "supervisorPin": "••••",
    "reason": "Welded to the running rod in error; cut back and held for disposition"
  }
}

// 200 OK
{ "data": { "checkoutId": "CO-0052", "mode": "ModeP", "rodAlpha": "R00043",
            "newRodStatus": "HOLD", "plcTagsCleared": false }, "success": true }
```

> **This restores a control removed on 31 Jul 2026.** Dashboard 2A had dropped Unstage from welded rows entirely, reasoning that a welded rod cannot be returned to inventory. That was right about the *unqualified* control and wrong that there is no path at all: the path is a supervisor-approved rejection. `WLD011` remains unspecified for reversing a weld **in place**, on a rod that stays staged.

### 4.6 `POST /checkin/rod` — corrected request

**Purpose:** the gate for everything. **Role:** Operator. **Not idempotent** — a second call for the same line returns `409 RUN_ALREADY_ACTIVE`.

```json
{ "lineId": "FL1", "rodAlpha": "R00041", "payoffPosition": 1,
  "diameterMeasuredIn": 0.374,
  "grossWeightLb": 8840.0, "netWeightLb": 8500.0,
  "inspection": { "oxidation": "Pass", "surfaceDefects": "Pass",
                  "waterStains": "Pass", "connectorTag": "Pass",
                  "observationNotes": null },
  "preRunSpc": { "m1In": 0.375, "m2In": 0.374 },
  "passScheduleId": "PS-1100-FL1-003",
  "orderId": "FW-00421", "operatorId": "john.d" }
```

> **Correction 5 — three fields added to the published contract.** `RodCheckin.InspectionConnectorTag`, `SpcM1In` and `SpcM2In` are all `NOT NULL` in the DDL, and the April body sent none of them — **inserts would fail as specified.** The approved Dashboard 2 wizard captures all three (step 1 has four inspection items; step 3 captures M1 and M2). `SpcOvalityIn` is **computed by the database** and is never sent.
>
> **Note the deliberate asymmetry:** `POST /staging/rod` uses a **3-item** inspection object and `POST /checkin/rod` uses a **4-item** one. That is correct — the connector-tag check belongs to check-in. The wider 3-vs-4 divergence across older documents is gap **G14**; this contract resolves it as **three at staging, four at check-in**.

**Response:** `{ runId, lineId, rodAlpha, passScheduleId, checkedInAt, plcTagsPushed }`

**Side effects, in this mandatory order:**

1. `FlatWireRun` created (`Status='Running'`, `StartedAt`), `RodCheckin`, `SpcCheckpoint(PreRun)` + `SpcMeasurement` rows, inspection result — **all in the local transaction**
2. Shared schema: ~~`coils.coil_status = INFLAT`~~ *(struck — `D-32`, 18 Aug 2026; written to local `Rod.Status` instead)*, reqsum + `wip_coil_orders`, `actual_start_date` on `planning_routings` / `routings`, `wip_stations.coilno` — **all three surviving writes land in columns that already exist, so no migration is required**
3. **PLC:** `PushPassSchedule(scheduleId, lineId, payoffPosition)` — a single batch
4. `RodStaging.Status → CheckedIn` with `CheckedInAt` and `RodCheckinId`
5. Broadcast `LineStatus{Running}`, `PayoffStateChanged{Active}`, `ComponentStatus`

**Records first, PLC second.** On a PLC failure the recovery is **compensating writes** — see `[ARC §10]`.

**Errors:** `409 RUN_ALREADY_ACTIVE` · `409 PAYOFF_MISMATCH` against an existing staged row · `422 SCHEDULE_NOT_ACTIVE` when the schedule is `Draft` · `422 INSPECTION_FAILED` routed to DB8 · `500 PLC_PUSH_FAILED` with the check-in aborted · **`422 SCHEDULE_NO_MATCH` — behaviour undefined, OI-46.**

**FL3:** one acknowledgement pushes **all FM1 and FM2 tags in a single batch**; `RouteMode` is `Hybrid`; **no `SpoolProcessing` row is created**.

**Station selection applies here too (30 Jul 2026).** A rod scanned at check-in whose order is booked on the other rod line **switches the screen to that line** rather than being refused; a mismatched POST returns `409 WRONG_STATION` with `correctLineId`. Same rule as §4.5, same open questions.

### 4.6a `POST /checkin/spool`

**Purpose:** FL2 spool check-in and the FM2 PLC tag push. **Role:** Operator. **Not idempotent** — same `409 RUN_ALREADY_ACTIVE` rule as `§4.6`.

**Request:** `lineId, spoolAlpha, gaugeMeasuredIn, widthMeasuredIn, grossWeightLb, netWeightLb, passScheduleId, operatorId, orderId`

**Response:** `{ runId, lineId, spoolAlpha, passScheduleId, checkedInAt, plcTagsPushed }`

**Side effects:** the same shape as `§4.6` — `SpoolCheckin` + `FlatWireRun` written first, then the tag push, then `PlcTagsPushed` stamped — but against **FL2 component tags** (`FM2_S1`/`FM2_S2`/`FM2_S3`, edgers at S2/S3 only). **FL2 broadcasts `null` live gauge and width**; its trace is the historical profile, so no `GaugeReading`/`WidthReading` batch starts on this call.

> **`OI-47` is open on this endpoint:** hybrid-origin validation at FL2 check-in is undefined — whether a spool produced by an FL3 hybrid run may be checked in to FL2 standalone, and on what basis.

**Worked example**

```json
{
  "lineId": "FL2",
  "spoolAlpha": "SP-00021",
  "gaugeMeasuredIn": 0.126,
  "widthMeasuredIn": 0.877,
  "grossWeightLb": 850.0,
  "netWeightLb": 840.0,
  "passScheduleId": "PS-1100-FL2-001",
  "operatorId": "jane.s",
  "orderId": "FW-00421"
}
```

```json
{
  "data": {
    "runId": "RUN-0043",
    "lineId": "FL2",
    "spoolAlpha": "SP-00021",
    "passScheduleId": "PS-1100-FL2-001",
    "checkedInAt": "2026-04-30T07:00:00Z",
    "plcTagsPushed": true
  },
  "success": true
}
```

### 4.6b `GET /spools[?spoolAlpha=]`

**Purpose:** spools available for FL2. **Role:** any authenticated (read-only). **One endpoint, two modes, one response shape**, so the screen has a single renderer.

| Call | Meaning |
|---|---|
| `GET /spools` | Every spool **available for processing, irrespective of order**. `order` is `null` |
| `GET /spools?spoolAlpha=SP-00031` | The backend **resolves that spool's order** and returns the order context plus **only that order's spools** |

**Response:** `{ scannedAlpha, order{orderNo, customer, alloy, temper, setupGaugeIn, setupWidthIn, dueDate}, spools[{alpha, orderNo, sourceRunId, sourceRodAlphas[], gaugeIn, widthIn, netWeightLb, originRouteMode, status, eligible}] }`

**Seven contract notes, each of which is easy to get wrong:**

- **`order` is `null` in two different situations and both are `200`** — the unfiltered default view, and a scanned spool whose `OrderNo` is null. In the second case `spools` contains **just that spool**, so the client renders one shape either way.
- **`404` only for an unknown `spoolAlpha`.** An unallocated spool is **not** an error — planning remainders and supervisor-accepted partial spools legitimately have no order, and the screen shows them differently from a bad scan.
- **`gaugeIn`/`widthIn` must be read from the source FL1 run**, not from `SpoolProcessing.GaugeIn`/`WidthIn`, which are documented *"set at FL2/FL3 check-in"* and are therefore **null for every row this endpoint returns**.
- **`sourceRodAlphas` is a list and must come from `CoilTraceability`/`WeldEvent`.** `SpoolProcessing` carries only two single-valued rod FKs (`ParentRodAlpha`, `SourceRodAlpha`); a spool with a mid-run weld has more than one source rod.
- **The `order` block is a cross-database read** — order attributes live in the shared order/scheduling schema, not `FlatWireDB`, on the same unenforced-link basis as rod alphas.
- **`eligible` encodes an availability rule that is undefined (`Q17`).** The proposal is `RECEIVED` + `STAGED`, with `HOLD` returned but not eligible. **Do not hard-code this silently.**
- **`SpoolProcessing.OrderNo` needs an index.** It is unindexed today and the `spoolAlpha` mode is a `WHERE OrderNo = …` on a `VARCHAR(50)`.

No pagination — the list scrolls, consistent with every other list in the suite. **Blocks DB5A, and also serves DB5**, whose scan field currently validates against nothing because `POST /checkin/spool` was the only spool endpoint.

**Worked example**

```json
{
  "data": {
    "scannedAlpha": "SP-00031",
    "order": {
      "orderNo": "FW-00421",
      "customer": "Daddario",
      "alloy": "1100",
      "temper": "O",
      "setupGaugeIn": 0.110,
      "setupWidthIn": 0.630,
      "dueDate": "2026-07-21"
    },
    "spools": [
      {
        "alpha": "SP-00031",
        "orderNo": "FW-00421",
        "sourceRunId": "RUN-0117",
        "sourceRodAlphas": ["R00041", "R00042"],
        "gaugeIn": 0.113,
        "widthIn": 0.640,
        "netWeightLb": 3200.0,
        "originRouteMode": "Standalone",
        "status": "RECEIVED",
        "eligible": true
      }
    ]
  },
  "success": true,
  "errors": []
}
```

### 4.6c `POST /spool/complete`

**Purpose:** commit an FL1 spool — write the `SpoolProcessing` row and close the run. **Role:** Operator.
**Added 15 Aug 2026.** `OI-32` recorded that the spool-completion **commit** had no endpoint; it was
half-closed by naming `FW-202`'s `CompleteSpool` command without giving it a route, so the only published
way to reach it was `POST /coil/complete` — which is **Phase 9's FL2 output coil** (`FW-185`), *"a
different transaction on a different line"*. Routing a spool commit through it is exactly the conflation
**`G37`** was raised to fix.

> ⚠ **This is not the prompt.** `SpoolCompletionPromptDue` is raised **by the server** on the
> `RUNNING → STOPPED` edge and delivered over `FlatWireHub` — there is nothing for a client to poll and
> **no endpoint raises it** (`[SIG §5.5]`). This endpoint is the **answer**, and it is also the
> **manual** complete-spool path `TC-179` requires, so it must work when no prompt is outstanding.

```json
// request
{ "runId": "RUN-0042", "lineId": "FL1",
  "answer": "Yes",                       // Yes | No | AutoDismissed  — [SIG §5.2]'s vocabulary
  "scaleWeightLb": 1798.5,               // optional; null = use the calculated value
  "varianceAcknowledged": false,         // required true when |scale − calculated| > 2 %
  "operatorId": "jdoe" }

// 201 Created
{ "data": { "spoolAlpha": "SP-00022", "runId": "RUN-0042", "status": "COMPLETE",
            "netWeightLb": 1798.5, "footageFt": 15920.00,
            "weightBasis": "Scale",      // Scale | Calculated
            "sourceRods": [ { "rodAlpha": "R00041", "footageFrom": 0, "footageTo": 15920 } ] },
  "success": true }
```

**Five rules a client must implement:**

- **`answer: "No"` records nothing** — no transaction, no alpha, no print, no state change — but the
  decline **is logged** (`TC-176`). It is not an error and must not return one.
- **Commit precedes print** (`TC-175`). The label never prints before the row exists.
- **The weight is the latched one.** `PromptLatchedWeightLb` was captured at the PLC stop timestamp;
  a fresher `PayoffWeight` tick must never be substituted (`TC-172`).
- **A >2 % scale-vs-calculated variance requires `varianceAcknowledged`** → otherwise `422`
  `SUPERVISOR_AUTH_REQUIRED`. ⚠ **The override must never disable commit** — it gates, it does not block.
- **Idempotent per run.** A second call for a run already `COMPLETE` returns `409`
  `RUN_ALREADY_ACTIVE`'s counterpart rather than minting a second spool; the prompt is raised **once per
  stop** but duplicate *delivery* is expected, so the client may well call twice.

⚠ **`answer` is persisted to `FlatWireRun.PromptAnswer`**, whose `CHECK` allows exactly
`Yes` / `No` / `AutoDismissed` — the enum, the TypeScript union and that constraint are one mirror.

### 4.7 `GET /staging/queue?lineId=`

Returns rows of `{ plannedSeqno, rodSeqno, rodAlpha, alloy, temper, diameterIn, grossWeightLb, payoffPosition, status, isWelded, footageRunToDate }` with `status ∈ {Available, PreCheckedIn, Welded}`.

- An `Available` row has **`rodSeqno: null`** — nothing has happened to it yet.
- **`rodSeqno < plannedSeqno` is a normal, non-exceptional outcome.**
- Rows sort by `rodSeqno` where present (the actual run order, which is what the traveler documents), then by `plannedSeqno` for unprocessed rod.
- The queue returns **`[]` on a cold line** — it is a projection of *an order's* rod list, and no order is established.
- Later-planned rods **stay listed and stageable**; they are gated by the override, never omitted or disabled.

> **This is a derived projection, not a stored queue, and there must not be a `RodQueue` table.** `PreCheckedIn`/`Welded` rows come from `RodStaging`; `Available` rows are resolved at request time from `planning_routings` for the established order. Planning owns rod→order and Scheduling owns order→line; mirroring either into `FlatWireDB` would create a second source of truth **with no event channel to keep it current** — and a stale row costs an operator a physical trip with a 9,000 lb bundle.
>
> **The exact `ual-database` column names behind this projection are still unmapped — OI-33**, and Phase 4 cannot be built without them.

**Worked example**

```json
{
  "data": [
    {
      "plannedSeqno": 1, "rodSeqno": 2, "rodAlpha": "R00043", "alloy": "1100",
      "temper": "F", "diameterIn": 0.375, "grossWeightLb": 8780.0,
      "payoffPosition": 2, "status": "PreCheckedIn",
      "isWelded": false, "footageRunToDate": 0.0
    },
    {
      "plannedSeqno": 3, "rodSeqno": null, "rodAlpha": "R00045", "alloy": "1100",
      "temper": "F", "diameterIn": 0.375, "grossWeightLb": 8690.0,
      "payoffPosition": null, "status": "Available",
      "isWelded": false, "footageRunToDate": 0.0
    }
  ],
  "success": true
}
```

### 4.7a `GET /run/active?line=`

**Purpose:** the active run for a line — Dashboard 3 calls it on load and on resume. **Role:** any authenticated. **Query:** `line` = `FL1` | `FL2` | `FL3` (required).

**Response `200`:** `{ runId, lineId, orderId, alloy, passScheduleId, targetGauge, gaugeTolerance, targetWidth, widthTolerance, routeMode, status, startedAt, pausedAt, footageFt, payoffs[{position, alpha, weightLb, percentRemaining, status}], weldEvents[{weldEventId, outgoingAlpha, incomingAlpha, footagePosition, timestamp}], components[{componentName, state, currentValue}] }`

**Response `204 No Content`:** no active run on this line. This is the normal idle state, not an error.

```json
{
  "data": {
    "runId": "RUN-0042", "lineId": "FL1", "orderId": "FW-00421", "alloy": "1100",
    "passScheduleId": "PS-1100-FL1-003",
    "targetGauge": 0.125, "gaugeTolerance": 0.003,
    "targetWidth": 0.875, "widthTolerance": 0.005,
    "routeMode": "Standalone", "status": "Running",
    "startedAt": "2026-04-30T06:14:00Z", "pausedAt": null, "footageFt": 3840,
    "payoffs": [
      { "position": 1, "alpha": "R00041", "weightLb": 1240.0, "percentRemaining": 62.0 },
      { "position": 2, "alpha": null, "weightLb": 0.0, "percentRemaining": 0.0, "status": "NotLoaded" }
    ],
    "weldEvents": [
      { "weldEventId": "WLD-001", "outgoingAlpha": "R00040", "incomingAlpha": "R00041",
        "footagePosition": 1850, "timestamp": "2026-04-30T06:50:00Z" }
    ],
    "components": [
      { "componentName": "DB1", "state": "Active", "currentValue": 0.310 },
      { "componentName": "DB2", "state": "Active", "currentValue": 0.260 },
      { "componentName": "FM1", "state": "Active", "currentValue": 0.126 }
    ]
  },
  "success": true
}
```

> **`weldEvents[]` here is a trimmed marker list** feeding the gauge-trace chart — no quality, operator or weld type. Dashboard 2A needs those, which is why `§4.17a` exists as a separate run-scoped resource rather than this one being widened.
>
> **`gaugeTolerance` and `widthTolerance` are single-± fields**, and the 30 Jul client decision (`Q22`) replaced single-± tolerances with four min/max pairs. This response shape has not caught up — the same defect gap **`G51`** records against `SpcMeasurement`.

### 4.8 `POST /run/{runId}/pause` and `/resume`

**Pause** — reason categories and codes:

| Category | Codes |
|---|---|
| `EquipmentMechanical` | `DieChangeMidRun`, `RollAdjustment`, `LubricationCoolant`, `DrawBoxInspection`, `ComponentInspection` |
| `MaterialHandling` | `Payoff2LoadingWeld`, `DownstreamBlockage` |
| `QualityMeasurement` | `GaugeWidthInvestigation`, `ManualSpcMeasurement`, `SurfaceInspection` |
| `Operational` | `OperatorBreak`, `ShiftChangeover`, `AwaitingSupervisor` |
| `Safety` | `SafetyObservation` |
| `RodCheckout` | *(navigates to Rod Checkout instead of pausing — `FR-262`)* |
| `Other` | `Other` — **requires `notes`**, enforced by `CK_RunPauseEvent_NotesOther` |

**Side effects on pause:** `RunPauseEvent` written with `FootageAtPause` · `FlatWireRun.PausedAt` set and `Status='Paused'` · PLC tags to hold/idle · `LineStatus{Paused}` broadcast with the reason.

**Resume** — outcomes: `ResumeRun` · `LogWipRejection` · `ContinuePause` · **`CheckOutRod`**. Response returns `resumedAt` and `pauseDurationSeconds`.

> **The contract supports four outcomes; the shared `pause_run.js` implements three.** `Analysis/FlatWireShopfloorDashboards.md` specifies four including "No — check out rod (partial run)"; the script implements three and exposes Rod Checkout as a pause *reason* instead. **Both readings reach Mode B; they disagree on where the door is.** Since this endpoint accepts `CheckOutRod`, **the four-outcome model is what the contract currently supports** — **OI-14**.

**Worked example**

```json
{
  "reasonCode": "GaugeWidthInvestigation",
  "reasonCategory": "QualityMeasurement",
  "notes": "Gauge reading drifted high — investigating FM1 roll gap"
}
```

```json
{
  "data": {
    "runId": "RUN-0042",
    "pausedAt": "2026-04-30T07:10:00Z",
    "footageAtPause": 3840
  },
  "success": true
}
```

### 4.9 `POST /spc`

**Request:** `runId, lineId, checkpointType, footagePosition, operatorId, triggerDescription, measurements[{name, targetValue, toleranceValue, actualValue}]`

> **Correction — `toleranceValue` is required.** `SpcMeasurement.ToleranceValue` is `NOT NULL` and drives the computed `InSpec`; the April contract omitted it from its example. Omitting it produces a `400`.

**Measurement names by checkpoint type:**

| `checkpointType` | `measurements[].name` |
|---|---|
| `PreRun` | `IncomingRodDiameter` |
| `PostDieChange` | `WireDiameterPostDraw`, `FM1Gauge`, `FM1Width` |
| `ManualSpotCheck` | `FM1Gauge`, `FM1Width` |
| `PostRun` | `FinalGauge`, `FinalWidth` |
| `RollAdjustTrigger` | The gauge and width entered on DB11 |

**Response:** `{ checkpointId, allInSpec, results[{name, inSpec, deviation}] }` — `inSpec` and `deviation` are **computed by the database**, never sent.

**`footagePosition` is captured when the checkpoint opens, not when it is submitted** (`FR-191`). The client sends the value it captured on open.

> **A checkpoint cannot join to its trigger.** `PostDieChange` and `RollAdjustTrigger` checkpoints are auto-created by a `DieChangeEvent` / `RollOverride`, but the only link is the free-text `triggerDescription` — **there is no `dieChangeId` or `overrideId` field**. You cannot programmatically prove which die change a checkpoint verified. **OI-18.**

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "checkpointType": "PostDieChange",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "triggerDescription": "DB2 die changed from 0.310\" → 0.308\"",
  "measurements": [
    { "name": "WireDiameterPostDraw", "targetValue": 0.260, "actualValue": 0.261 },
    { "name": "FM1Gauge",             "targetValue": 0.125, "actualValue": 0.126 },
    { "name": "FM1Width",             "targetValue": 0.875, "actualValue": 0.874 }
  ]
}
```

```json
{
  "data": {
    "checkpointId": "SPC-0041",
    "allInSpec": false,
    "results": [
      { "name": "WireDiameterPostDraw", "inSpec": true,  "deviation": 0.001 },
      { "name": "FM1Gauge",             "inSpec": true,  "deviation": 0.001 },
      { "name": "FM1Width",             "inSpec": true,  "deviation": -0.001 }
    ]
  },
  "success": true
}
```

### 4.10 `POST /weldevent`

**Request:** `runId, lineId, outgoingRodAlpha, incomingRodAlpha, outgoingPayoffPosition, incomingPayoffPosition, footagePosition, weldType, weldQuality, weldQualityFailReason, operatorId`

| Rule | Enforcement |
|---|---|
| `footagePosition` is **read from the encoder, never typed** | The client sends the encoder value; the server does not accept an operator-entered footage |
| `weldType` is **`InductionWeld` only** | `LaserWeld` remains in the enum for historical genealogy and **must not be selectable** |
| `weldQualityFailReason` is **mandatory when `weldQuality = 'Fail'`** | `CK_WeldEvent_FailReason` — a `422` if omitted |
| The two payoff positions **must differ** | `CK_WeldEvent_PayoffDiff` — a bay cannot be welded to itself |
| Alloy, diameter and temper **must match the running coil** | `422` with a clear validation error |
| The incoming rod **defaults to the `Staged` rod on the idle bay** | The client pre-fills; the operator may override by scanning |
| The timestamp is **server-side at receipt** | Never the client clock |

**A `Fail` still writes the event and links the rods.** It flags for supervisor review and may raise an alert — **it does not silently block the run.** The confirmed event is **immutable**.

**This is the single weld write** *(1 Aug 2026)*. `POST /staging/rod/mark-welded` is retired; Dashboard 2A's *Mark as welded* dialog posts here, having gained the quality result (`PCI022`) that was the only NOT NULL `WeldEvent` column it lacked.

**The `RodStaging` write is conditional on quality:**

| `weldQuality` | `WeldEvent` row | `RodStaging.IsWelded` / `WeldedAt` / `WeldedBy` | Bay state |
|---|---|---|---|
| **`Pass`** | Written | **Set**, same transaction | Welded; transition awaits 0 ft remaining |
| **`Fail`** | Written | **Not set** | Stays **staged and un-welded** — the weld must be remade |

> A failed weld did not hold, so the rod is not joined to the running rod and the line cannot transition through it. Flagging it welded would assert a continuous feed that does not exist. **Consequence:** a fail-then-remake writes several `WeldEvent` rows for one physical join — no uniqueness constraint exists on the rod pair and none should; whether a superseded attempt reaches the certificate is **OI-59**, and footage attribution across the two boundaries is **Q6**.

**Side effects:** `WeldEvent` written · `RodStaging` weld columns set **on a Pass only** · the run's active-rod pointer advances (Pass) · the weld-pending flag clears (Pass) · a weld marker is queued for the gauge trace · `PayoffWeight` re-establishes for the new payoff · `PayoffStateChanged` broadcast (Pass).

> **`WLD016` cannot be enforced.** The maximum weld joints per finished coil is a customer contractual limit that the system is required to validate — **the limit is TBD (OI-59)**. The validation hook must exist; the threshold is configuration.
>
> **Naming.** The aggregate, the table, the endpoint and the story are all **`WeldEvent`**. The SignalR *marker method* keeps the name `WeldJoinEvent` — but only because it is documented here. **Do not let the aggregate drift back to `WeldJoinEvent`.**

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "outgoingRodAlpha": "R00041",
  "incomingRodAlpha": "R00042",
  "footagePosition": 3840,
  "weldType": "InductionWeld",
  "weldQuality": "Pass",
  "weldQualityFailReason": null,
  "operatorId": "john.d"
}
```

```json
{
  "data": {
    "weldEventId": "WLD-002",
    "runId": "RUN-0042",
    "footagePosition": 3840,
    "outgoingAlpha": "R00041",
    "incomingAlpha": "R00042",
    "weldQuality": "Pass",
    "isWelded": true,
    "timestamp": "2026-04-30T08:00:00Z"
  },
  "success": true
}
```

### 4.11 `POST /rolloverride`

**Request:** `runId, lineId, alpha, footagePosition, operatorId, reasonCode, notes, measuredGaugeIn, measuredWidthIn, adjustments[{componentName, scheduledValue, newValue}]`

**Both `measuredGaugeIn` and `measuredWidthIn` are required** (`FR-205`). `reasonCode` is one of `GaugeDriftHigh`, `GaugeDriftLow`, `WidthDrift`, `SpcFlag`, `RollWear`, `PostWeldCorrection`, `OperatorDiscretion`, `Other`.

**Side effects — three, and all of them:**

1. One `RollOverride` row **per adjusted component** (not one row for the batch)
2. A `PLCTagService` write **per component**, immediately
3. **An SPC checkpoint of type `RollAdjustTrigger`** at the footage position, carrying the measured gauge and width

**Response:** `{ overrides[{overrideId, componentName, oldValue, newValue, delta, plcTagWritten}], spcCheckpointId }`

**When every delta is zero the client must not call this endpoint at all** — the button relabels to "No changes — return to run" and writes nothing (`FR-211`).

**This never modifies the pass schedule record.** It is a run-level override.

> **There is no revert endpoint.** `FR-212` restricts reverting to the Operations Manager, and nothing implements it — **OI-32**.

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "alpha": "R00041",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "reasonCode": "GaugeDriftHigh",
  "notes": null,
  "measuredGaugeIn": 0.128,
  "measuredWidthIn": 0.876,
  "adjustments": [
    {
      "componentName": "FM1",
      "scheduledValue": 0.128,
      "newValue": 0.126
    }
  ]
}
```

```json
{
  "data": {
    "overrides": [
      {
        "overrideId": "OVR-0042",
        "componentName": "FM1",
        "oldValue": 0.128,
        "newValue": 0.126,
        "delta": -0.002,
        "plcTagWritten": true
      }
    ],
    "spcCheckpointId": "SPC-0042"
  },
  "success": true
}
```

### 4.12 `POST /diechange`

**Request:** `runId, lineId, rodAlpha, footagePosition, diePosition, outgoingDieAlpha, incomingDieAlpha, oldDieSizeIn, newDieSizeIn, incomingCondition, reasonCode, qualityHold{fromFootage, toFootage, flagForQa}, spcCheckpointRequired, operatorId`

| Rule | Detail |
|---|---|
| `diePosition` | `DB1` \| `DB2`. **The UI offers `Both`**, which the client sends as **two separate calls**, each with its own scanned incoming die |
| `reasonCode` | **Build the UI against five values** — `PlannedLife`, `GaugeDrift`, `DieFailure`, `SizeChange`, `Other`. The DB `CHECK` tolerates three more (`DieWear`, `Breakage`, `ScheduledChange`) from an earlier API list; **do not offer them** |
| Incoming die size | **Must match the outgoing size unless `reasonCode = 'SizeChange'`** |
| Incoming die size | **Must exist in the `Drawer` size catalogue** — `422` if not. **There is no per-tool die inventory in MVP-1**, so this validates a *size*, not a registered physical die (see the note below) |
| Routing | `GaugeDrift` \| `SizeChange` → response carries `{"route":"spcCheckpoint"}`, run stays blocked from full production, **thread mode permitted**. `PlannedLife` \| `DieFailure` → `{"route":"activeRun"}` |

**Side effects:** `DieChangeEvent` written · **an auto-created linked `RollOverride`** for the die size change, referenced by `LinkedOverrideId` · a `PostDieChange` SPC checkpoint when required · the die's cumulative footage counter closes on the outgoing die and opens on the incoming one · every "Require SPC on resume" **toggle-off** is audit-logged and surfaces the run as a flagged exception.

> **There is no die inventory in MVP-1, and there will not be one** — die inventory and lifecycle are owned outside MVP-1 (decision of 11 Aug 2026). This endpoint validates the incoming die **size** against the **`Drawer`** catalogue seeded in Phase 1, and reads life from `Drawer.LastGrindingFeet` / `TotalFeetAllowed` with the 60/85 % bands. **`D4` is enforced in its size-level form only**; the per-tool form is not implementable here. Note that `DieChangeEvent` stores `OldDieSizeIn`/`NewDieSizeIn` as decimals with **no `DrawerId` FK**, so this is an application check, not a database constraint. **Accepted consequence: die life is tracked per size — two dies of one diameter share a counter.** This closes **`OI-41`** (Phase 6 no longer depends on Phase 13); the missing die-inventory CRUD endpoint (**`OI-32`**) is moot in MVP-1. Authority: `DieChangeAndManagement.md` §2.4a.

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "alpha": "R00041",
  "footagePosition": 3840,
  "operatorId": "john.d",
  "diePosition": "DB2",
  "oldDieSizeIn": 0.310,
  "newDieSizeIn": 0.308,
  "reasonCode": "GaugeDrift"
}
```

```json
{
  "data": {
    "dieChangeId": "DC-0041",
    "overrideId": "OVR-0043",
    "spcCheckpointRequired": true,
    "spcCheckpointMode": "PostDieChange"
  },
  "success": true
}
```

### 4.13 `POST /checkout`

**Request:** `runId, lineId, rodAlpha, payoffPosition, mode, footageAtCheckout, reasonCode, rodDisposition, remainingWeightLbEstimate, inProcessMaterialDisposition, notes, operatorId`

| Mode | `runId` | `footageAtCheckout` | Reasons | Rod disposition | In-process disposition |
|---|---|---|---|---|---|
| **`ModeP`** — unwelded | **null** | **0** | `WrongRodMisScan`, `OrderCancelledDeferred`, `FailedReInspection`, `RelocatedToLine`, `Other` | `ReturnToFloorStorage` → `STAGED` · `ReturnToWarehouse` → `RECEIVED` | **must be null** |
| **`ModeP`** — **welded** | **null** | **0** | + `WrongRodWelded` | `HoldReturnToStorage` → **`HOLD`** *(the only permitted outcome)* | **must be null** |
| **`ModeA`** | **null** | **0** | Same five | Same two | **must be null** |
| **`ModeB`** | required | > 0, **PLC-locked** | `EquipmentFailure`, `QualityHold`, `OrderQuantityReached`, `ShiftDeferral`, `Other` | `HoldReturnToStorage` → `HOLD` · `Scrap` → `SCRAP` · `DeferContinueLater` → `STAGED` | `HoldPendingSupervisor` \| `Scrap` \| `AcceptAsPartialRun` |

`notes` is **required when `reasonCode = 'Other'`**.

**Approval — added 1 Aug 2026, and it was missing entirely.** The request also carries `wasWelded`, `approvedBy`, `approvedAt` and `overrideReason`:

| Mode | Supervisor approval | Source |
|---|---|---|
| `ModeP` **unwelded** | **Not required** — operator-only, reason captured | OQ-69 |
| `ModeP` **welded** | **Required**, with a documented reason, and the rod goes to **`HOLD`** — removal means cutting the material, so it is a **rejection**, not a return | OQ-69 / OQ-72, 30 Jul 2026 |
| `ModeA` | Not required | — |
| `ModeB` | **Required** | OQ-74, decided 4 May 2026 |

> **Until 1 Aug 2026 `RodCheckout` had no approval columns at all** (gap **G24**), so the OQ-74 and OQ-75 approvals decided in May were enforced at the UI and stored nothing. Adding them retro-enforced Mode B: the existing sample-data Mode B row failed the schema rebuild until it was given an approver. **The PIN is never stored** — only the badge/ID, the timestamp and the reason. Its validation source is still undecided and now gates three flows (**OI-38**).

**Enforced in the database:** `CK_RodCheckout_ModeP` (Mode P must have null `runId`, footage 0, `PlcTagsCleared` false, and both in-process fields null) · `CK_RodCheckout_ModeB` (`inProcessMaterialDisposition` permitted **only** in Mode B) · `CK_RodCheckout_WasWelded` (a welded removal is Mode P only) · `CK_RodCheckout_Approval` (the approval stamp is all-or-nothing) · `CK_RodCheckout_ModePWelded` (a welded Mode P needs the stamp **and** `NewRodStatus='HOLD'`) · `CK_RodCheckout_ModeBApproved` (Mode B needs the stamp).

**The PLC gatekeeper rule, for every mode with tags:**

1. The server reads `FL{n}.LineState` **before the dialog opens and again before accepting the confirmation**.
2. If it reports Running → `422 LINE_STILL_RUNNING`, message *"Line is still running. Stop the line before checking out the rod."*
3. **The application never sends a stop command.**
4. The footage counter is **read and locked at the moment the dialog opens**, so the recorded value is final.
5. Tags are cleared **only after a confirmed stop and an operator confirm**.

**Response:** `{ checkoutId, lineId, rodAlpha, newRodStatus, plcTagsCleared, partialSpoolAlpha }`

> **`partialSpoolAlpha` stays `null` until a supervisor approves.** Mode B creates a **Pending Disposition** with the material locked, not plannable and carrying no alpha, and pushes a SignalR notification to the Supervisor role. **There is no endpoint for the supervisor's Accept / Hold / Reject decision** — **OI-32** — and relying on a transient notification to reach a supervisor is gap **G7**: a durable pending-approval queue is required, with SignalR as a live nudge only.

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL1",
  "rodAlpha": "R00041",
  "payoffPosition": 1,
  "mode": "ModeA",
  "footageAtCheckout": 0,
  "reasonCode": "WrongRod",
  "rodDisposition": "ReturnToFloorStorage",
  "remainingWeightLbEstimate": null,
  "inProcessMaterialDisposition": null,
  "operatorId": "john.d"
}
```

```json
{
  "data": {
    "checkoutId": "CO-0041",
    "lineId": "FL1",
    "rodAlpha": "R00041",
    "newRodStatus": "STAGED",
    "plcTagsCleared": true,
    "partialSpoolAlpha": null
  },
  "success": true
}
```

### 4.14 `POST /wipreject`

**Request:** `runId, lineId, materialAlpha, stage, footagePosition, rejectionGroup, rejectionReason, measuredValue, targetMin, targetMax, disposition, observationNotes, returnToStage, operatorId`

`runId` and `footagePosition` are **nullable** — a pre-run incoming rejection has neither. `rejectionGroup` is one of `SurfaceQuality`, `Dimensional`, `WeldQuality`, `Material`, `Process`. `observationNotes` is **required when `disposition = 'Suspend'`**.

**Side effects:** `WipRejection` written · the alpha's status set (`HOLD` or `SCRAP`) · the WIP Held queue updated · **`AlertRaised` broadcast to DB1** · **when the material is a rod staged at a payoff bay** (a failed staging inspection), the `RodStaging` row is **released** — `Status → 'Unstaged'`, `UnstageKind = 'WipRejection'`, `WipRejectionId` set — and `PayoffStateChanged{NotStaged}` is broadcast. **This is the only thing that clears a `Blocked` bay** (**Q23** item 3, 30 Jul 2026).

> **`Rework` is accepted by the disposition enum but is currently unpersistable.** `NewMaterialStatus` admits only `HOLD` or `SCRAP`, and **there is no column for `returnToStage`**, which `FR-297` and the mockup both require. **A third of the disposition options cannot be stored** — **OI-22**, resolve before Phase 7.
>
> **`materialAlpha` is polymorphic (rod *or* spool) with no FK and no discriminator.** A typo produces a rejection against nothing — **OI-20**.

**Worked example**

```json
{
  "lineId": "FL1",
  "materialAlpha": "R00041",
  "stage": "FL1ActiveRun",
  "footagePosition": 3840,
  "rejectionGroup": "Dimensional",
  "rejectionReason": "GaugeOutOfSpec",
  "measuredValue": 0.131,
  "targetMin": 0.122,
  "targetMax": 0.128,
  "disposition": "Suspend",
  "observationNotes": "Gauge spiked after weld — FM1 roll may need inspection",
  "operatorId": "john.d",
  "runId": "RUN-0042"
}
```

```json
{
  "data": {
    "rejectionId": "REJ-0041",
    "materialAlpha": "R00041",
    "newStatus": "HOLD",
    "alertBroadcast": true
  },
  "success": true
}
```

### 4.15 `POST /coil/complete`

**Request:** `runId, lineId, grossWeightLb, netWeightLb, finalGaugeMeasuredIn, finalWidthMeasuredIn, skidAssignment, existingSkidId, operatorId`

`skidAssignment` is `Coil1Of2` \| `Coil2Of2` — **exactly two coils per skid.** `Coil1Of2` opens a skid and returns its new `skidId`; `Coil2Of2` requires `existingSkidId`, closes the skid, prints the skid label and moves it to the packing queue.

**Response:** `{ coilAlpha, skidId, skidStatus, footageTotal, netWeightLb, sourceTraceability[{rodAlpha, footageFrom, footageTo}], finalSpc{gaugeInSpec, widthInSpec} }`

**Side effects:** `CoilOutput` written with the **pass-schedule ID, version and JSON configuration snapshot** · `CoilTraceability` rows, one per contributing rod, **non-overlapping** (enforced by trigger) · final SPC checkpoint · skid state transition

**Side effects — the shared half, and it is a second transaction, not part of the first.** Since 18 Aug 2026 (`FR-509`–`FR-518`, `[INT §8.1]`) this endpoint also writes **eight shared objects** by calling `united_db.dbo.FlatWire_CompleteCoilOnSkid` once per coil: `proddb..coils` (the finished-goods row) · `proddb..wip_coil_orders` · `united_db..coil_gen_history` · `coil_cost` via `CoilCost_UpdateInsert` · `SlitterDB..coil_slit_cuts` (**one row — a flat wire coil is one cut**) · `united_db..wip_skids` · `proddb..wip_skid_coils` · `proddb..wip_log_view`. **Every one lands in a column that already exists, so `D-32` is untouched.**

⚠ **The two halves are compensating writes, not one ACID transaction** — the same boundary `[ARC §10]` draws for check-in. The `FlatWireDB` writes commit first; the procedure is then called and is itself atomic. Three rules follow and the handler must implement all three:

1. **Persist `CoilOutput.CoilNo` the moment the procedure returns.** It is the retry contract. A retry that does not pass it back through `@expectedCoilNo` **mints a second coil**, because the alpha generator returns the next free suffix each time.
2. **Never swallow the procedure's error.** It rolls back its own half completely, so a throw means no shared row survives — but it also means the coil is complete locally and invisible upstream, which is an operator-visible condition, not a log line.
3. **One call per coil, never batched.** `coils_iud_tg` is single-row only; a set-based insert silently skips the `coil_link_master_coil` row.

The response is unchanged — `CoilNo` is **not** added to it. `coilAlpha` remains the customer-facing identifier and the shared alpha is an internal mapping (`FR-509`).

**`netWeightLb` is derived from footage and cross-section, never from a scale during rolling.** The server computes `A(in²) × 12 × ρ` per foot with the round-edge correction; the operator may override with a scale reading, which lands in `NetWeightOverrideLb`, not `NetWeightLb`.

> **The dimensional basis is undecided** — target, measured-at-completion, or integrated over `RunReading` (integration recommended). **OI-45.** Until it closes, the endpoint must return the derivation alongside the number so the screen can show it.
>
> **Two footage coordinate systems.** Run events use **cumulative run footage**; `CoilTraceability.FootageFrom/To` are **coil-local**. Mapping a source rod to coil footage needs a coil-start offset **that no artifact states**. **Any run producing more than one coil will build wrong traceability rows** — **OI-25**, and this is the highest-consequence open item on this endpoint because `NFR012` is contractual.

**Worked example**

```json
{
  "runId": "RUN-0042",
  "lineId": "FL2",
  "grossWeightLb": 900.0,
  "netWeightLb": 885.0,
  "finalGaugeMeasuredIn": 0.126,
  "finalWidthMeasuredIn": 0.876,
  "skidAssignment": "Coil1Of2",
  "existingSkidId": null,
  "operatorId": "jane.s"
}
```

```json
{
  "data": {
    "coilAlpha": "FW-00421-C01",
    "skidId": "SKD-0021",
    "skidStatus": "Open",
    "footageTotal": 3840,
    "netWeightLb": 885.0,
    "sourceTraceability": [
      { "rodAlpha": "R00040", "footageFrom": 0,    "footageTo": 1850 },
      { "rodAlpha": "R00041", "footageFrom": 1850, "footageTo": 3840 }
    ],
    "finalSpc": {
      "gaugeInSpec": true,
      "widthInSpec": true
    }
  },
  "success": true
}
```

### 4.16 `GET /coil/{alpha}/label`

Returns `alpha, alloy, temper, gaugeIn, widthIn, grossWeightLb, netWeightLb, footageFt, lotNumber, sourceRodAlphas[]`.

**Pass-schedule data is deliberately absent** — it is logged against the coil record but **never printed on the customer label** (`FR-338`).

> **`lotNumber` has no column and no generator.** The endpoint is specified to return it and the label prints it. **The label cannot be rendered as specified** — **OI-24**.

---

**Worked example**

```json
{
  "data": {
    "coilAlpha": "FW-00421-C01",
    "alloy": "1100",
    "gaugeDiameterIn": 0.125,
    "widthIn": 0.875,
    "temper": "O",
    "grossWeightLb": 900.0,
    "netWeightLb": 885.0,
    "footageFt": 3840,
    "lotNumber": "LOT-2026-042",
    "sourceRodAlphas": ["R00040", "R00041"]
  },
  "success": true
}
```

### 4.17 `GET /run/{runId}/gaugetrace`

**Query:** `fromFt`, `toFt`, `resolution`. Backed by `sp_GetGaugeTrace`, which returns **two result sets** — the decimated readings and **the weld markers in the window**.

**Response:** `{ readings[{footageFt, gaugeIn, widthIn, speedFpm, inSpec}], weldMarkers[{footagePosition, incomingRodAlpha, weldQuality}], stats{min, max, avg, stdDev, sampleCount, outOfSpecCount} }`

**This is the FL2 profile source.** FL2 standalone broadcasts `null` live gauge and width, so DB5 and the FL2 variant of DB3 render from this endpoint, not from the hub.

**Worked example**

```json
{
  "data": {
    "runId": "RUN-0041",
    "lineId": "FL1",
    "targetGauge": 0.125,
    "upperLimit": 0.128,
    "lowerLimit": 0.122,
    "readings": [
      { "footage": 0,    "gauge": 0.124, "inSpec": true },
      { "footage": 10,   "gauge": 0.126, "inSpec": true },
      { "footage": 20,   "gauge": 0.131, "inSpec": false }
    ],
    "weldMarkers": [
      { "footage": 1850, "incomingAlpha": "R00041" }
    ],
    "totalReadings": 1920,
    "outOfSpecCount": 14
  },
  "success": true
}
```

### 4.17a `GET /run/{runId}/weldevents`

Every weld recorded against one run, oldest first. Backs the read-only **Welds this run** dialog on Dashboard 2A (`PCI021`), opened from the **active bay card** — so the caller always holds a `runId`. An **empty array is a normal response**, rendered as the dialog's empty state.

**Response:** `{ runId, lineId, totalCount, failedCount, weldEvents[{weldEventId, outgoingAlpha, incomingAlpha, outgoingPayoffPosition, incomingPayoffPosition, footagePosition, weldType, weldQuality, weldQualityFailReason, operatorId, timestamp}] }`

**Read-only — there is no PUT, PATCH or DELETE counterpart.** A recorded weld is a certificate input; reversing one in place is `WLD011`, which no document specifies.

| Rule | Detail |
|---|---|
| Ordered by `footagePosition` ascending | Chronological within a run |
| `weldQualityFailReason` is non-null exactly when `weldQuality = 'Fail'` | `CK_WeldEvent_FailReason` — consumers may rely on it and **must** render it |
| An empty array is a **`200`**, not a `404` | A run that has not yet reached its first payoff handover has no welds |
| No paging | `RunId` alone bounds the set — one weld per rod handover |

> **Not served by widening `GET /run/active`.** That endpoint's `weldEvents[]` is a trimmed marker list feeding the gauge-trace chart: no quality, operator or weld type. Dashboard 2A never calls it, so a run-scoped resource is the cheaper split.

> **Read lands a phase before write.** This sits in phase 4 with Dashboard 2A, while `POST /weldevent` writes its rows in phase 6. Until then it returns an empty array — a legitimate state — so **stub it with non-empty sample data** for the phase-4 gate review.

**Worked example**

```json
{
  "data": {
    "runId": "RUN-0418",
    "lineId": "FL1",
    "totalCount": 2,
    "failedCount": 1,
    "weldEvents": [
      {
        "weldEventId": "WLD-002",
        "outgoingAlpha": "R00040",
        "incomingAlpha": "R00041",
        "outgoingPayoffPosition": 1,
        "incomingPayoffPosition": 2,
        "footagePosition": 4120,
        "weldType": "InductionWeld",
        "weldQuality": "Pass",
        "weldQualityFailReason": null,
        "operatorId": "j.alvarez",
        "timestamp": "2026-07-31T06:48:00Z"
      },
      {
        "weldEventId": "WLD-003",
        "outgoingAlpha": "R00041",
        "incomingAlpha": "R00042",
        "outgoingPayoffPosition": 2,
        "incomingPayoffPosition": 1,
        "footagePosition": 9860,
        "weldType": "InductionWeld",
        "weldQuality": "Fail",
        "weldQualityFailReason": "Weld not fully fused — cut back and remade",
        "operatorId": "j.alvarez",
        "timestamp": "2026-07-31T09:22:00Z"
      }
    ]
  },
  "success": true
}
```

### 4.19 `GET /health`

Returns `{ status, database: {reachable, latencyMs}, opc: {reachable, latencyMs}, version, environment }`. Used by the deployment smoke suite — `[DEP §5]`.

---

---

### 4.20 `GET /rod/{alpha}/orders`

Returns the rod's **active allocation set** — the orders it may be consumed against, in planned sequence,
with the weight allocated to each and the tier each rod occupies. This is what makes the sequence
validation and the order-set membership check possible at both pre-check-in and check-in.

```json
{
  "data": {
    "rodAlpha": "R00001",
    "netWeightLb": 4000.00,
    "orders": [
      { "orderNo": "417154", "relLetter": "B", "orderSeqNo": 1, "rodSeqNoInOrder": 3,
        "allocatedWeightLb": 400.00, "rodWeightFrom": 3600.00, "rodWeightTo": 4000.00,
        "pinRole": "PinnedLast", "rodKind": "Full", "source": "Planned" }
    ]
  },
  "success": true, "errors": []
}
```

**`GET /rod/{alpha}` returns the order set too**, not a single order — since `Q70` a rod may legitimately
carry more than one. A consumer reading a scalar order from that response is reading a rod that happens to
have one.

| Code | When |
|---|---|
| `200` | rod found; `orders` may be empty where planning has not allocated |
| `404` | no such rod |

### 4.21 `POST /order/{orderNo}/complete`

The operator's acknowledgement — **the only thing that closes an order** `[ORD007]`. Not a confirmation of
a system decision: the system raises `OrderAllocationReached`, the operator decides.

```json
{ "consumptionId": "RC-0041", "operatorId": "jdoe", "relLetter": "B" }
```

**What it writes, in one transaction:** the acknowledgement stamps, the weight **latched a second time**,
the overrun between the two latches, the closing footage, and the consumed weight with the conversion basis
and factor it used. Then it opens the **next pairing on the same rod** and hands the station over — the two
writes must be atomic, or the station exclusivity index rejects the handover.

| Code | When |
|---|---|
| `200` | order closed; response carries the overrun and the next order, if any |
| `409` | no open pairing at that station, or another order is already open |
| `422` | the incoming order's pass schedule differs from the running one `[ORD015]` — the rod must be checked out and back in, because the tags cannot be re-pushed without a check-in |

**Early acknowledgement is permitted** — before the threshold — and is recorded as such; the overrun is
then negative. Where the unconsumed allocation goes is **`Q51`**.

---

## 7. Stub-first delivery contract

The shopfloor UI is built against dummy data before the service exists. This is what makes Phases 2–9 buildable in parallel with the backend.

### 7.1 The mechanism

`flat-wire-api.interface.ts` with **two implementations** DI-swapped by a `useMockData` environment flag:

| Implementation | Backing | Active when |
|---|---|---|
| `flat-wire-api-real.service.ts` | The shared `api-gateway.service` | `useMockData = false` — every environment except local development |
| `flat-wire-api-mock.service.ts` | The canonical fixture set | `useMockData = true` — `environment.development.ts` |

### 7.2 What a stub must return

| Requirement | Why |
|---|---|
| **The exact response envelope**, including `success` and `errors` | So error-path UI is exercised, not just the happy path |
| **The canonical fixture alphas**, mirroring the DB seed: `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042` / `RUN-0043` | So a developer moving from mock to real sees the same data |
| **At least one failing case per endpoint** — an inspection fail, an occupied bay, a `Draft` schedule | The error paths are where this system's behaviour lives |
| **`null` live gauge and width for FL2** | Otherwise the FL2 variant is built against data it will never receive |
| **A mock SignalR stream** at the real cadence with real batch shapes | Rendering performance is a design constraint, not an afterthought |

> **Older implementation documents ship inconsistent fixtures** — `PS-1100-FL2-001` versus `-007`, and `SP-00021` sourced from `RUN-0041` while its `sourceRods` `R00040`/`R00041` point to `SP-00031`. **Align to the DB seed, not to those documents.**

> ### ⚠ `PS-1100-FL1-003` is a `Draft` schedule — it is the **negative** fixture, not the happy path
>
> Confirmed against a live deploy 15 Aug 2026. A `Draft` schedule **must be refused** at check-in with
> `SCHEDULE_NOT_ACTIVE` → **422** (§1.8), so a stub or test that acknowledges `PS-1100-FL1-003`
> successfully is asserting the opposite of the contract.
>
> **Use the right one for the case you are building:**
>
> | Case | Schedule | Status |
> |---|---|---|
> | **FL1 happy path** | **`PS-1100-FL1-001`** (1100, Standalone) | `Active` |
> | **FL1 negative — `SCHEDULE_NOT_ACTIVE`** | `PS-1100-FL1-003` | `Draft` |
> | FL1 negative — inactive | `PS-1100-FL1-002` | `Inactive` |
> | **FL2 happy path** | **`PS-1100-FL2-001`** | `Active` |
> | FL3 hybrid | `PS-1100-FL3-001` | `Active` |
>
> The seed deliberately carries `Active`, `Inactive` and `Draft` variants of the same line and alloy so
> the status gate is testable. **`PS-1100-FL1-003` is still a canonical fixture** — it is named above and
> in `[CMP]` because the mock must mirror the seed; it is simply not the one an acknowledgement succeeds
> against. `[TRP §8]` step 2's happy path is **`PS-1100-FL1-001`**.

### 7.3 Switchover criteria

A screen moves off the stub when: the real endpoint returns the contracted shape · its error cases return the contracted codes · the hub emits the contracted events at the contracted cadence · and a de-stub pass has removed any assumption the stub baked in.

> **Schedule an explicit de-stub pass.** The stub check-in deliberately routes around **OI-46** (no-match path), **OI-48** (traveler field list) and **OI-47** (hybrid-origin validation) by assuming a single active schedule. When those close, the assumption must be removed — it will not remove itself.

---

---

## 8. Versioning and change policy

| Rule | Detail |
|---|---|
| Version in the path | `/api/v1/flatwire`. A breaking change mints `v2`; the two run side by side until every client moves |
| **Breaking** | Removing a field, narrowing a type, adding a required request field, removing or renaming an enum value, changing an HTTP status for an existing condition |
| **Non-breaking** | Adding an optional request field, adding a response field, adding an enum value **that existing clients can ignore** |
| **Enum values are not automatically non-breaking.** | Adding `PostDb1` to `CheckpointType` requires the C# enum, the TypeScript union **and** the DB `CHECK` to change together. A value added in one place only is the defect class that produced three of the four corrections in §2.3 |
| Hub events | Adding an event is non-breaking. **Changing a payload shape is breaking** — the typed client interface is a compile-time contract on both ends |
| Deprecation | Mark in this document with the replacement named and the removal version stated. Never remove silently |

---

---

## 9. Traceability

### 9.1 Endpoint → requirement → screen → phase

| Endpoint | `FR-###` | Screen | Phase |
|---|---|---|---|
| `GET /lines/status` | FR-420–428 | DB1 | 3 |
| `GET /passschedule` | FR-400–408 | DB9A | 2 |
| `GET /passschedule/{id}` | FR-371–374 | DB9 | 2 |
| `POST /passschedule` | FR-360, 361, 409 | DB9 / DB9A | 2 |
| `PUT /passschedule/{id}` | FR-364, 372 | DB9 | 2 |
| `PATCH /passschedule/{id}/status` | FR-410, FR-362 | DB9 | 2 |
| `POST /passschedule/generate` | FR-380–391 | DB9 Generate modal | 2 |
| `GET /rod/{alpha}` | FR-042, 064, 065 | DB2A / DB2 | 4 |
| `POST /rod` | — (upstream) | — | upstream |
| `GET /payoff/status` | FR-032–034, 037 | DB2A | 4 |
| `POST /staging/rod` | FR-039–049 | DB2A | 4 |
| `POST /staging/rod/unstage` | FR-052–054 | DB2A | 4 / 7 |
| ~~`POST /staging/rod/mark-welded`~~ *(retired 1 Aug 2026)* | FR-050, 051 | — | — |
| `GET /staging/queue` | FR-035, 036, 038 | DB2A / DB3 | 4 |
| `POST /checkin/rod` | FR-063–084 | DB2 | 4 |
| `POST /checkin/spool` | FR-090–096 | DB5 | 8 |
| `GET /spools` | FR-097–099 | DB5A *(also serves DB5's scan)* | 8 |
| `GET /run/active` | FR-100, 115–117 | DB3 | 5 |
| `GET /run/{runId}/gaugetrace` | FR-093, 120 | DB5 / DB3-FL2 | 5 / 8 |
| `GET /run/{runId}/weldevents` | `PCI021` | DB2A | 4 *(rows written in 6)* |
| `POST /run/{runId}/pause` | FR-260–264 | pause dialog | 6 |
| `POST /run/{runId}/resume` | FR-265, 266 | pause dialog | 6 |
| `POST /spc` | FR-180–196 | DB6 | 4, 6 |
| `POST /weldevent` | FR-160–175 | **DB2A** *(DB4 retired 1 Aug 2026)* | 6 |
| `POST /rolloverride` | FR-200–211 | DB11 | 6 |
| `POST /diechange` | FR-220–234 | DC | 6 |
| `POST /checkout` | FR-300–327 | DB12 / DB2A | 7 |
| `POST /wipreject` | FR-290–299 | DB8 | 7 |
| `POST /coil/complete` | FR-330–339 | DB7 | 9 |
| `GET /coil/{alpha}/label` | FR-336 | DB7 / DB7b | 9 |
| `GET /shiftsummary` | FR-480–489 | DB10 | 11 |
| `GET /health` | — | — | 1 |

### 9.2 Role → endpoint

| Role | Endpoints beyond read-only |
|---|---|
| **Operator** | `/staging/**`, `/checkin/**`, `/run/*/pause`, `/run/*/resume`, `/spc`, `/weldevent`, `/rolloverride`, `/diechange`, `/checkout` (Modes P, A; submits B), `/wipreject`, `/coil/complete` |
| **Supervisor** | All operator endpoints, plus the override credential on `/staging/rod`, plus approval of a Mode B disposition *(endpoint missing — OI-32)*, plus WIP disposition |
| **Operations Manager** | All of the above, plus `/passschedule` create/edit/activate, plus roll-override revert *(endpoint missing — OI-32)* |
| **Engineering / Maintenance** | `/passschedule/**`, alloy lookup CRUD *(endpoint missing — OI-32)*, die inventory CRUD *(endpoint missing — OI-32)* |
| **QA** | `/wipreject` dispose, SPC-HOLD release *(endpoint missing — OI-32)* |

---

---

## 10. Open contract issues

### 10.1 Six specified behaviours with no endpoint at all — OI-32

**Two of these are named in *decided* requirements**, which means the behaviour is agreed and only the API surface is missing.

| Missing endpoint group | Required by | Phase |
|---|---|---|
| **Alloy-lookup CRUD with audit** | Story FW-004 needs an editable, audited alloy table the generator reads | 2, 13 |
| **Roll-override revert** | `FR-212` — **a decided requirement**, Operations-Manager-only | 6 |
| **Supervisor disposition of a pending Mode B checkout** | `FR-325`, `FR-326` — **a decided requirement** (OQ-75) | 7 |
| **Die-inventory CRUD** | All of `[REQ §5.10]`; `POST /diechange` validates against an inventory that has no API and no table | 6, 13 |
| **Spool-completion prompt and commit** | `FR-140`–`FR-157` | 9 |
| **SPC-HOLD QA release** | `FR-189` | 6 |

### 10.2 Open items that change a contract shape

| ID | Issue | Endpoint affected |
|---|---|---|
| **OI-05** | `Bevel edge` has no domain value | `/passschedule/generate`, `/passschedule` |
| **OI-10** | "Post DB1" is in the UI, absent from the enum and the DB CHECK | `/spc` |
| **OI-14** | Three or four resume outcomes | `/run/{runId}/resume` |
| **OI-18** | An SPC checkpoint cannot join to its trigger | `/spc`, `/diechange`, `/rolloverride` |
| **OI-20** | Polymorphic material refs with no integrity | `/wipreject`, `/checkout` |
| **OI-21** | Two rejection-ID formats (`REJ-####` vs `REJ-2026-0418`) | `/wipreject` |
| **OI-22** | `Rework` disposition is unpersistable | `/wipreject` |
| **OI-24** | `lotNumber` has no column or generator | `/coil/{alpha}/label` |
| **OI-25** | Two footage coordinate systems with no stated offset | `/coil/complete` |
| **OI-33** | The `planning_routings` column mapping is unmapped | `GET /staging/queue`, `GET /rod/{alpha}` |
| **OI-45** | Weight dimensional basis undecided | `/coil/complete` |
| **OI-46** | The no-match path at check-in is undefined | `/checkin/rod` |
| **OI-47** | Hybrid-origin validation at FL2 check-in undefined | `/checkin/spool` |
| **OI-59** | Maximum weld joints per coil is TBD | `/weldevent` |
| **OI-93** | The generator's alloy-max source and its per-pass/cumulative semantics | `/passschedule/generate` |

### 10.3 Raised by this document

| ID | Finding | Resolution taken here |
|---|---|---|
| **PP-04** | **The hub event count is 14 as of 22 Aug 2026** — it was 9, then 10, then 12, and the master specification's status summary was still saying 10 until it was corrected in the same pass. Originally:  **The hub event count is 10, not 9.** The master specification's status summary says "9 hub events"; its own event table and `Business/BusinessRules.md` §3 both enumerate ten. The "9" predates `PayoffStateChanged` | §5.2 documents **ten**. Correct the summary line |
