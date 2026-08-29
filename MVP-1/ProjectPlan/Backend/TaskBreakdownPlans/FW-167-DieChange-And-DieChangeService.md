# FW-167 · `POST /diechange` and `DieChangeService`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **A de-stub — and its `D4` validation is at SIZE level, not per tool** (§2.3)
**Owner:** Backend (.NET) stream
**Audience:** The developer building `FW-167`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twelve hours, and **four details decide whether it is right.**
>
> **The gate is the point of the story.** *"The die-change → PostDieChange SPC gate is a hard
> block until it passes"* — and the user story says why: *"so that the gate cannot be skipped by
> going straight to the endpoint."* **The screen is not the enforcement.**
> **⛔ `D4` is restated at die-SIZE level, not per tool.** The die master table left MVP-1 with
> the Die Management screen, so the change validates the entered **size** against `Drawer`'s
> 13-row catalogue. **Die life is per size, and two dies of one diameter share a counter.**
> **It auto-creates a linked override** — `DieChangeEvent.LinkedOverrideId →
> RollOverride.OverrideId` — so [`FW-169`](FW-169-RollOverride-And-RollOverrideService.md) is a
> **hard predecessor**, and `OI-103`'s unbounded write reaches this story through it.
> **The toggle-off is Ops-Manager / Quality only and writes a logged exception** — ⚠ and
> `FW-145` is unbuilt, so no role claim is issued today.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-167 · `POST /diechange` and `DieChangeService`
> **Hours:** 12 h BE · **Priority:** Medium · **Sprint:** S2 · **Phase:** 6 · **Stream:** BE
>
> **As a** developer,
> **I want** a die change to create its own override and demand its SPC check,
> **So that** the gate cannot be skipped by going straight to the endpoint.
>
> **Acceptance Criteria:**
> - [ ] `DieChangeController POST /diechange`; `RecordDieChange` handler
> - [ ] `DieChangeService` **auto-creates the linked override** (`DieChangeEvent.LinkedOverrideId → RollOverride.OverrideId`) and sets `spcCheckpointRequired`
> - [ ] **Die-change → PostDieChange SPC gate is a hard block until it passes** (thread mode allowed); `OQ-65` decided
> - [ ] Incoming size validated against `Drawer`; unrecognised size → `422`
> - [ ] `Require SPC on resume` toggle-off is **Ops-Manager / Quality only** and writes a logged exception
>
> **Rate-card basis:** command endpoint 6 h + `DieChangeService` 6 h = 12 h (§2)
> **Dependencies:** FW-139, FW-171, FW-169
> **Blockers:** —

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| The `DieChangeEvent` table | [`FW-171`](../../Database/TaskBreakdownPlans/FW-171-Five-In-Run-Event-Tables.md) — ✅ built |
| The override this creates | [`FW-169`](FW-169-RollOverride-And-RollOverrideService.md) — **hard predecessor** |
| The SPC checkpoint the gate waits on | [`FW-168`](FW-168-Spc-And-SpcService.md) |
| ⛔ **Die inventory and lifecycle** | **MVP-2, for good** — including the die master table |
| The die-life status vocabulary | `DieChangeAndManagement.md` §5 — **stayed in MVP-1** at v2.4 |
| The `die_change.js` dialog | `Frontend/Mockups/` — a shared dialog, not a screen |

### 1.2 What already exists

Read off the built code and DDL on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| `DieChangeController` | `FlatWire.API/Controllers/DieChange/` | ✅ **Built** |
| `IDieChangeService` + stub + named-throw shell | | ✅ Built (`FW-140`, `P-64`) |
| `DieChangeEvent` table | `04_Runs.sql` | ✅ Built (`FW-171`) — including `LinkedOverrideId` |
| `DieChangeEvent.ReasonCode` + `CHECK` | | ✅ Built |
| `Drawer` lookup | `01_Lookup` — **13-row catalogue**, with `LastGrindingFeet` / `TotalFeetAllowed` | ✅ Built |
| `SpcCheckpoint.CheckpointType` incl. `PostDieChange` | `05_QualityOutput.sql:39` | ✅ Built |
| **A die master table** | — | ⛔ **Does not exist, and will not** — moved to MVP-2 with the screen (8 h) |
| **The handler and service body** | — | ⛔ **Absent.** This is the deliverable |
| `RollOverrideService` | — | ⛔ **Absent** — [`FW-169`](FW-169-RollOverride-And-RollOverrideService.md) |

---

## 2. The four details

### 2.1 The gate must live in the server, because that is the stated reason for the story

*"So that the gate cannot be skipped by going straight to the endpoint."* — the user story names
its own threat model.

⛔ **So the block is a state rule on the aggregate, not a check in the dialog.** After a die
change with `spcCheckpointRequired` set, the run is gated until a **`PostDieChange`** checkpoint
**passes**. Thread mode is allowed through.

⚠ **`die_change.js` already chains to the SPC dialog** — *"a gauge-drift or size-change die
change opens the SPC checkpoint it mandates"* — and that is a **convenience, not the
enforcement**. The two must agree, and only one of them is authoritative.

⚠ **Shape rules are FluentValidation's `400`; state rules are the aggregate's `422`**
(`[SVC §3.2a]`). **The gate is a state rule.**

### 2.2 The linked override makes `FW-169` a hard predecessor — and imports its open item

AC 2: `DieChangeService` **auto-creates** the linked override
(`DieChangeEvent.LinkedOverrideId → RollOverride.OverrideId`).

⛔ **So a die change performs a PLC write**, through `FW-169`'s service — which means
**`OI-103`'s unbounded roll-gap change reaches this story too**, and so does `G58`'s
"a `200` is not evidence of a write".

⚠ **The override is created by the system, not entered by the operator**, so the bound matters
*more* here, not less: there is no human sanity-check between the die size and the resulting
gap.

### 2.3 ⛔ `D4` is size-level — and the consequence is a shared counter

The die master table **left MVP-1 with the Die Management screen**, permanently. So the change
**validates the entered size against `Drawer`'s 13-row catalogue** and reads life from
`Drawer.LastGrindingFeet` / `TotalFeetAllowed`.

**Two consequences, and both look like defects if you do not know them:**

- It **rejects an unrecognised size, not an unregistered physical tool** (AC 4 → `422`).
- **Die life is per size**, so **two dies of one diameter share a counter.**

⚠ **`OI-12` (conflicting die-life bands) is *dormant, not answered*** — only the Die Change
**60/85 %** bands apply in MVP-1. ⛔ **Do not import `DieManagement.md`'s vocabulary**; it was
deliberately **not** copied across when the document was split.

### 2.4 The toggle-off is role-gated, and the role is not issued yet

AC 5: *"`Require SPC on resume` toggle-off is **Ops-Manager / Quality only** and writes a logged
exception."*

⚠ **`FW-145` is unbuilt**, so no role claim is issued and — per `P-136`'s finding on `/sim` —
a role-gated path **denies everyone** today. ⚠ **And the six claim *values* are unmapped**
(`G6`'s residual), which gates verification even after `FW-145` lands.

✅ **The logged exception is buildable now** and is the part that matters: a skipped SPC gate
must leave evidence regardless of who skipped it. ⚠ **Route it through
[`FW-234`](FW-234-Audit-Log-Persistence-Target.md)'s audit trail** once that exists, not only to
Serilog.

---

## 3. Build order

1. ⛔ **[`FW-169`](FW-169-RollOverride-And-RollOverrideService.md) first** — this service calls
   it (§2.2), and inherits `OI-103`'s bound.
2. `RecordDieChange` handler on the built `DieChangeController`.
3. **Size validation against `Drawer`'s 13 rows** → unrecognised → **`422`** (§2.3).
   ⚠ **A size, not a tool.**
4. `DieChangeService`: **auto-create the linked override** and set `spcCheckpointRequired`.
   ⚠ One transaction — the event and its override must not be separable.
5. **The gate as an aggregate state rule** (§2.1) — hard block until a `PostDieChange`
   checkpoint **passes**; thread mode allowed.
6. Toggle-off: role-gated, **logged exception** (§2.4). ⚠ **Build the exception now**; note the
   role cannot be verified until `FW-145` and `G6`'s residual.
7. Read die life from `Drawer.LastGrindingFeet` / `TotalFeetAllowed`, **60/85 % bands only**
   (§2.3).
8. Raise the domain event so [`FW-172`](FW-172-Run-Event-Markers.md) can mark the trace —
   ⛔ **without this handler touching SignalR** (`P-35`, `P-101`).

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-214` precede this story.

### `P-215` — the SPC gate is an aggregate state rule, and the dialog chain is a convenience

§2.1. The story's own justification is that the endpoint must not be bypassable, so the
enforcement cannot live where the bypass happens. `die_change.js`'s chain to the SPC dialog stays
— it is good UX — but it is **not** the gate.

⚠ **Two enforcements would drift**, and the client's would be the one people trust.

### `P-216` — the die change's auto-created override is bounded by `FW-169`'s bound, and it matters more here

§2.2. The operator enters a **die size**; the **gap** is derived. There is no human reading the
resulting number before it reaches the machine, so `OI-103`'s absent bound is **more** dangerous
on this path than on the manual one.

**Fallback:** none. If `FW-169` ships unbounded, this path ships unbounded.

### `P-217` — the logged exception is built now, independently of the role gate

§2.4. `FW-145` is unbuilt and `G6`'s residual gates verification even afterwards. **The evidence
half needs neither**, and a skipped quality gate with no record is the worse failure.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| **De-stub only** | The controller is not re-created |
| **Gate not bypassable** | ⛔ **Call `POST /diechange` then resume directly via the API** — the run is still blocked (`P-215`) |
| Gate releases | A **passing** `PostDieChange` checkpoint releases it; a failing one does not |
| Thread mode | Allowed through the gate |
| **Size validation** | An unrecognised **size** → `422`; ⚠ an unregistered **tool** is not a concept here (§2.3) |
| **Shared counter** | Two dies of one diameter share `Drawer`'s life counter — **expected**, not a defect |
| Bands | **60/85 %** only; ⛔ `DieManagement.md`'s vocabulary **not** imported (`OI-12` dormant) |
| Linked override | `DieChangeEvent.LinkedOverrideId` set, in the **same transaction** as the event |
| **Bound** | The auto-created override respects `FW-169`'s configured bound (`P-216`, `OI-103`) |
| Toggle-off | Writes a **logged exception** even while the role gate cannot be verified (`P-217`) |
| No SignalR | The handler injects no hub type (`P-101`) |

---

## 6. Handoff

[`FW-169`](FW-169-RollOverride-And-RollOverrideService.md) is the hard predecessor and owns the
override and its PLC write. [`FW-168`](FW-168-Spc-And-SpcService.md) supplies the `PostDieChange`
checkpoint the gate waits on — ⚠ **and its tolerance band is unseeded (`Q22`)**, so the gate can
be entered but its **pass** cannot be evaluated on a real band.
[`FW-172`](FW-172-Run-Event-Markers.md) marks the die change on the trace.
[`FW-234`](FW-234-Audit-Log-Persistence-Target.md) gives the logged exception a queryable home.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`OI-103`** | Inherited via `FW-169` — **and the derived gap has no human check** (`P-216`) |
| ⛔ **`Q22`** | The SPC band is unseeded, so the gate's **pass** cannot be evaluated on real data |
| ⛔ **`G58` / `G33`** | The linked override's PLC write can report success without applying |
| **`OI-12`** | ⚠ **Dormant, not answered.** Only the 60/85 % Die Change bands apply in MVP-1 |
| **`D4`** | Restated at **die-size** level — the die master table is MVP-2 for good |
| **`FW-145` / `G6` residual** | The role gate is unverifiable; the logged exception is not (`P-217`) |
| **`OQ-65`** | ✅ Decided — the gate is a hard block |
