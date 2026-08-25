# FW-157 · `POST /checkin/rod` and `CheckInService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Provisional until `G2`/`OI-39` closes** — the recovery design is what the 24–64 h reserve is for
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-157`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** This is the largest backend story in the trial (36 h) and the
> one where the system's hardest architectural fact bites: **check-in spans `FlatWireDB` +
> `coils` + `wip_coil_orders` + the PLC, and is not one ACID transaction.**
>
> Two consequences shape every line of it. **Records are written *before* the PLC push**, not
> after — so a push that fails leaves evidence rather than a silent gap. And recovery is
> **compensating writes, never "atomic rollback"** — the word must not appear, because it
> describes a guarantee this operation cannot give (`G2`, `G16` closed 4 Aug 2026).
>
> ⚠ **The trial runs a reduced version of this story.** `[TRP §4]` marks Phase 4's write path
> *"**no `RodStaging`**"* — so the staged-row consumption in AC 5 is **out of trial scope**
> while remaining an MVP-1 obligation. §2.3.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-157 · `POST /checkin/rod` and `CheckInService`
> **Hours:** 36 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE
>
> **As a** developer,
> **I want** check-in orchestrated as ordered, compensating writes across two databases and the PLC,
> **So that** a PLC failure never leaves a half-configured machine with a run marked Running.
>
> **Acceptance Criteria:**
> - [ ] `CheckInController POST /checkin/rod`; `CheckInRodCommand` (line, rodAlpha, payoff, diameterMeasured, weights, `InspectionDto`, scheduleId, operatorId, orderId) → `CheckInRodResponse` (runId, checkedInAt, plcTagsPushed)
> - [ ] **Records are written BEFORE the PLC push** — inspection result, pre-run SPC checkpoint, run record with schedule id + version, acknowledgement audit entry — then `PLCTagService.PushPassSchedule(scheduleId, lineId, payoffPosition)`
> - [ ] **MVP-1 persists its own snapshot of what it pushed** — schedule id, version and effective configuration — so a certificate stays reproducible after the owning system later edits the schedule
> - [ ] Business rules: Draft schedule not acknowledgeable (`422`); single active run per line (`409`); all-or-nothing
> - [ ] Where a staged row exists, the request's `payoffPosition` must match it (`409` on mismatch); check-in **consumes** the staged row (`RodStaging.Status → CheckedIn`, `RodCheckinId` linked) rather than creating a parallel record
> - [ ] ⚠ **Described and implemented as compensating writes, never "atomic rollback"** — check-in spans `FlatWireDB` + `coils` + `wip_coil_orders` + the PLC and **is not one ACID transaction** (**G2**; `G16` closed 4 Aug 2026)
> - [ ] PLC push audited (tag, value, operator, result); Operator+ policy
>
> **Rate-card basis:** complex command spanning two databases and the PLC 20 h + `CheckInRod` service and validation rules 16 h = 36 h (§3 worked derivation)
> **Dependencies:** FW-139, FW-141, FW-151
> **Blockers:** ⚠ **G2 / OI-39** *(recovery design undecided — this is what the 24–64 h reserve is for)* · **`Q14`**

### 1.1 Out of scope

| Concern | Story |
|---|---|
| The PLC push itself | [`FW-082`](FW-082-PLC-Tag-Push-On-Acknowledgement.md) — *this story calls it* |
| `PLCTagService` | [`FW-151`](FW-151-PLCTagService.md) |
| The staging endpoints | `FW-158` — **deferred with DB2A** |
| The DB2 wizard | `FW-061`, FE |
| `RodCheckin` / `INFLAT` write *(`FlatWireDB`-local since `D-32`)* | `FW-159`, DB |

---

## 2. The ordering, which is the design

### 2.1 Write, then push — `FR-072`

```
1. inspection result
2. pre-run SPC checkpoint
3. run record  (schedule id + version)
4. acknowledgement audit entry
   ─────────────────────────────
5. PLCTagService.PushPassSchedule(scheduleId, lineId, payoffPosition)
```

**The audit entry precedes the push** so a failed push leaves an **incomplete-push marker**
([`FW-151 §2.2`](FW-151-PLCTagService.md)). Reversing 4 and 5 loses the only evidence that a
configuration was attempted.

### 2.2 Compensating writes — and the banned word

`phase-01b` L111 and `[TRP §6]` blocker 3: describe it as compensating writes, **never
"atomic rollback"** (`G16`). A partial push leaves the line partly configured; recovery
issues the clears for what did land — itself an action that can fail — and marks the run
accordingly.

> **`G2`/`OI-39` is unresolved and this story is where it lands.** `[TRP §6]`: *"Phase 4 is
> provisional until it closes"*, needed **before T2**, and it carries the **24–64 h reserve**
> of `[TRP §2.3]`. `phase-01b`: **settle `G30` first** — whether FM2 on FL3 is one failure
> domain or two changes what a compensating clear must cover.

### 2.3 ⚠ The trial does not run the staging path

`[TRP §4]` prices Phase 4's write path as *"check-in write path + cross-DB `INFLAT`;
**no `RodStaging`**"*, because DB2A and pre-check-in left trial scope on 14 Aug.

| | MVP-1 | Trial |
|---|---|---|
| AC 5 — staged-row match + consumption | ✅ required | **out of scope** |
| Everything else | ✅ | ✅ |

**Build the staged-row path for MVP-1; expect it dark in the trial.** Do not delete it, and
do not let its absence turn into an assumption that check-in never has a predecessor row.

### 2.4 The snapshot rule survives `D-31`

`PassScheduleId` is a **real, enforced FK** since `D-31`, so an unavailable schedule is now a
`404`/FK failure rather than an unreachable service. **The snapshot rule is unchanged**:
MVP-1 persists its own copy of what it pushed — id, version, effective configuration —
because `[PLC §11.2]` and `Q64` need a certificate to stay reproducible **after the owning
system later edits the schedule**, which a local FK does nothing to prevent. The value object
is `PassScheduleSnapshot` ([`FW-207 §3`](FW-207-Domain-Model.md)).

---

## 3. Status codes this command owes

| Condition | Code | HTTP |
|---|---|---|
| Draft or Inactive schedule | `SCHEDULE_NOT_ACTIVE` | **422** |
| Line already has a `Running`/`Paused` run | `RUN_ALREADY_ACTIVE` | **409** |
| `payoffPosition` ≠ the staged row's | `PAYOFF_MISMATCH` | **409** |
| Rod ineligible (`coils.coil_status` in `COMPLETE`/`HOLD`/`SCRAP`, **or `Rod.Status = 'INFLAT'`** — local since `D-32`) | `ROD_UNAVAILABLE` | **409** |
| Prior footage without acknowledgement | `CARRY_FORWARD_REQUIRED` | **422** |
| PLC push failed | `PLC_PUSH_FAILED` | **500** |
| No active schedule matches | `SCHEDULE_NO_MATCH` | **422** — ⚠ **path undefined, `OI-46`.** Interim: block and alert Operations |

⚠ **`PS-1100-FL1-003` is `Draft` and must be refused.** The FL1 happy path is
**`PS-1100-FL1-001`** ([`FW-138 §4`](FW-138-Fifteen-Thin-Controllers.md)).

---

## 4. Build order

1. `CheckInRodCommand` / `CheckInRodResponse` in `FlatWire.Application/Commands/CheckIn/`,
   handler nested ([`FW-139 §2.2`](FW-139-MediatR-Registration-And-Pipeline-Behaviours.md)).
2. **Shape validation** in FluentValidation → `400`
   ([`FW-147`](FW-147-FluentValidation-Value-Objects-And-Enums.md)); **state rules in the
   aggregate** → `422` ([`FW-207`](FW-207-Domain-Model.md)). The split is the point.
3. `CheckInService` orchestrating §2.1's five steps in order.
4. Persist `PassScheduleSnapshot` (§2.4).
5. Call [`FW-082`](FW-082-PLC-Tag-Push-On-Acknowledgement.md)'s push **last**.
6. Compensation path + the saga-boundary comment — the boundary itself is documented in
   `PLCTagService` ([`FW-151`](FW-151-PLCTagService.md) AC 4).
7. Staged-row consumption (§2.3), behind MVP-1 scope.
8. `Operator+` policy ([`FW-145`](FW-145-JWT-And-Role-Policies.md)).

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-39` precede this story.

### `P-40` — build the ordered path now; leave the recovery *strategy* behind `G2`

The **write ordering** (§2.1), the **status codes** (§3) and the **snapshot** (§2.4) are all
specified and unblocked. What `G2`/`OI-39` has not decided is the **recovery strategy** —
saga/outbox versus an `INFLAT` mirror — and that choice changes what happens *after* a
partial failure, not what happens on the happy path.

**So: build the ordered writes and the compensating clears for the single-line PLC push, and
leave the cross-database recovery strategy as a documented seam.** Mark the run so a
half-configured line is detectable rather than silently `Running` — which is the story's own
"so that" clause and does not depend on the undecided part.

⚠ **Do not implement a two-phase commit or anything named for one.** The operation spans two
databases and a controller; the specification's answer is compensation, and `G16` was closed
on exactly this wording.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and by the trial's
acceptance run.

| Check | Expected |
|---|---|
| **Ordering** | Force a PLC failure → **all four records exist**, the audit entry marks the push incomplete, and the run is **not** left plainly `Running` |
| `grep -ri rollback` | **Zero hits** in this service |
| Draft schedule | `PS-1100-FL1-003` → `422` `SCHEDULE_NOT_ACTIVE` |
| Second run on a line | `409` `RUN_ALREADY_ACTIVE` |
| Snapshot | Schedule id, version and effective configuration persisted — and still readable after the source schedule is edited |
| Payoff mismatch | `409` — **MVP-1 only** (§2.3) |
| Audit | Tag, value, operator, result on every write |
| Authorization | Operator+ ; anonymous → `401` |

---

## 7. Handoff

[`FW-082`](FW-082-PLC-Tag-Push-On-Acknowledgement.md) is the push this triggers and the only
thing that may trigger it. `FW-159` (DB) owns the `RodCheckin` row and the cross-DB `INFLAT`
write. `FW-061` (FE) is the DB2 wizard that calls this. `FW-158`'s staging path is deferred
with DB2A.

---

## 8. Open items

| Item | Effect here |
|---|---|
| **`G2` / `OI-39`** *(blocker)* | Recovery undecided; **Phase 4 is provisional until it closes**, needed **before T2**, carrying the 24–64 h reserve. ⚠ **Settle `G30` first** |
| **`Q14` / `OI-46`** *(blocker)* | The no-match path is undefined. The stub assumes a single active schedule — **that assumption will not remove itself** (`[API §7.3]`) |
| **`OI-33`** | `planning_routings` columns unmapped, and this command reads them |
| **`G17`** | Cross-DB logical FKs, unenforced by design |
| **`FR-077`** | Check-in **writes** `actual_start_date` back to `planning_routings` **and** `routings` — a cross-database write, not just a read |
