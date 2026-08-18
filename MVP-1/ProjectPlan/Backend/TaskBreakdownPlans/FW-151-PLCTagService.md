# FW-151 · `PLCTagService` skeleton and `SimulatePLCTagPush`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **blocked on `G2`/`OI-39` for the compensation design, not for the write surface**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-151`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Three things, and the first is a wording rule that is
> actually a design rule.
>
> **OPC writes are not transactional, so the word "rollback" must not appear** — in the
> code, in a comment, or in a log message. Recovery is **compensating re-clears**. A
> developer who writes `RollbackAsync` has not made a naming slip; they have described a
> guarantee the hardware does not give.
>
> **Second:** all six operations are built here in Phase 1 and **first exercised in Phase 4**
> — so this story ships code nothing calls yet, and that is correct (`[PLCC §4]`).
>
> **Third:** `SimulatePLCTagPush` is `true` in **every** environment until commissioning. It
> is not a dev-only mode, and it is selected by configuration, never by call site.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-151 · `PLCTagService` skeleton and `SimulatePLCTagPush`
> **Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> **As a** developer,
> **I want** the PLC write surface built with a simulate mode from the start,
> **So that** every check-in phase can be developed and demoed before commissioning.
>
> **Acceptance Criteria:**
> - [ ] `FlatWire.Infrastructure/Services/PLCTagService.cs` with `PushPassSchedule(...)` and `ClearPayoffTags(...)`, batch write
> - [ ] **`SimulatePLCTagPush` dev mode** logs an audit entry instead of writing, and is switchable by configuration
> - [ ] ⚠ **OPC writes are not transactional.** Failure recovery is modelled as **compensating re-clears**, and the code and comments say so — **the word "rollback" does not appear** (**G2**; `G16` closed 4 Aug 2026)
> - [ ] The saga/compensation boundary for a cross-database check-in is documented in the service
>
> **Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
> **Dependencies:** FW-144
> **Blockers:** **G2 / OI-39** (cross-DB check-in recovery undecided — saga/outbox vs `INFLAT` mirror; carries the 24–64 h Phase-4 reserve)
>
> > **This is the service; `FW-082` is its use at check-in.** Splitting them keeps `FW-082`'s cited meaning — *"PLC tag push on check-in ack"* — intact while giving the S0 scaffold its own card.

### 1.1 ⚠ Six operations, not two

The card names two. `phase-01b` L108 requires **all six built here**, *"even though later
phases call them"*:

| # | Operation | First called |
|---|---|---|
| 1 | `PushPassSchedule(scheduleId, lineId, payoffPosition)` | Phase 4 |
| 2 | `ClearPayoffTags(lineId, payoffPosition)` | Phase 4 |
| 3 | **Per-component write** | Phase 6 — roll adjust |
| 4 | **Hold/idle and restore** — drive enable + speed on pause/resume | Phase 6 |
| 5 | **`SetITInhibit(lineId, bool)`** | [`FW-205`](FW-205-ITInhibitService.md) |
| 6 | **Batch write** | Phase 4 |

Later phases add rules **on top of** these, not new operations: Phase 7 adds the line-state
gate before `ClearPayoffTags` and the **never-send-a-stop** invariant (`FR-302`); Phase 8 the
FL2 push; Phase 10 the FL3 single-batch push.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| Calling any of the six at check-in | `FW-082`, Phase 4 |
| The tag-path map's contents and binding | [`FW-144`](FW-144-Configuration-Binding.md) · `[PLC]` owns the paths |
| The audit writer this calls | [`FW-143`](FW-143-Serilog-And-Audit-Log.md) |
| Reading tags | [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) — this service **only writes** |
| `ITInhibit`'s watchdog and conditions | [`FW-205`](FW-205-ITInhibitService.md) |

---

## 2. The rules that shape the code

### 2.1 Compensating re-clears — and the banned word

`phase-01b` L111: OPC writes are **not transactional**. Cross-DB check-in is **not one ACID
transaction**. Model failure recovery as **compensating re-clears**.

A partial push leaves the line partly configured. Recovery is *"write the clears for what
did land"* — an action that can itself fail — not *"undo"*. **The code and comments say so,
and `rollback` appears nowhere.** Error codes: `PLC_PUSH_FAILED` → `500`,
`LINE_STILL_RUNNING` → `422`.

> **Document the saga/compensation boundary in the service** — AC 4. It is the only written
> record of where atomicity stops, and `G2` is Critical precisely because that boundary has
> never been decided.

### 2.2 The audit record is written **before** the push

`FR-072`. Not after, not in a `finally`. A push that fails must still leave an
**incomplete-push marker**. `FR-075`: every write **and clear** is audited. Sinks are
`PlcTagsPushed` / `PlcTagWritten` / `PlcTagsCleared`, each recording tag path, value,
operator, timestamp and result.

### 2.3 Simulate mode

`SimulatePLCTagPush` is **`true` in every environment until commissioning completes** and is
selected **by configuration, not by call site**. A simulated write **logs the write it would
have made** — which is what makes the whole audit path exercisable now rather than at `C1`.

> ⚠ It is one of **three** independent simulation switches. See
> [`FW-140 §2.2`](FW-140-DI-Registration-And-Stub-Swap.md) — collapsing them is a real and
> easy mistake.

### 2.4 Polly, and the silent-failure problem

**Polly on outbound OPC calls** (`phase-01b` L97) — this service owns that. Retry a transient
transport failure; do **not** retry a rejected write.

> ⚠ **`G33` / `PLC-Q05` is the sharpest risk in this story.** The measure segment of all
> **41** tag paths is ours, not the controller's, and **a wrong path fails silently — the
> write reports success while the line keeps its previous settings.** Polly cannot see that,
> the audit record will say success, and the line is misconfigured. **Do not treat a green
> write as proof the line took the value** until commissioning `C1`/`C11` confirms the path.

---

## 3. Build order

1. `FlatWire.Infrastructure/Services/PLCTagService.cs` behind an interface, with the six
   operations of §1.1. Tag paths from configuration, **never from code**.
2. Reach `OPCConnection` through `RestClient` — the `UA.Framework.RestClient` registration is
   [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md)'s. **`OPCManagerHub.cs` is not a
   template** (`D-05`).
3. Polly around the outbound call (§2.4).
4. Audit **before** the push, per §2.2.
5. `SimulatePLCTagPush` branch — log the write that would have been made.
6. Write the compensation path and the saga-boundary comment (§2.1).
7. Expose `SetITInhibit` for [`FW-205`](FW-205-ITInhibitService.md).

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-26` precede this story.

### `P-27` — build all six operations now; compensation shape waits on `G2`

The **write surface** is not blocked. `[PLCC §4]` says build in Phase 1, exercise in Phase 4,
and every later phase assumes the operations exist. Build all six.

What **is** blocked is the **compensation design** — `G2`/`OI-39` has not decided between a
saga/outbox and an `INFLAT` mirror, and it carries the 24–64 h Phase-4 reserve. So:

- implement compensating clears for the **single-line PLC push**, which is this service's own
  scope and does not depend on the cross-DB answer;
- **document the boundary** where this service's compensation stops and the cross-database
  saga begins, as AC 4 requires;
- do not implement the cross-DB saga here — it is Phase 4's and it is undecided.

`phase-01b` also says **settle `G30` first**, because it decides whether FM2 on FL3 is one
failure domain or two — which changes what a compensating clear has to cover.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 manual walkthrough, and by
`[NFR]` `TC-601`–`TC-613`, which cover the PLC audit.

| Check | Expected |
|---|---|
| Six operations | All present, callable, tag paths from config |
| **`grep -ri rollback`** | **Zero hits** in this service — code, comments and log messages |
| Audit ordering | Force a push failure → the audit record exists **and marks the push incomplete** |
| Every write **and clear** audited | `FR-075` |
| `SimulatePLCTagPush` | `true` by default; logs the write it would have made; switchable with no rebuild |
| Simulate is config-driven | No `IsDevelopment()` anywhere in the decision |
| Saga boundary | Documented **in the service**, not only in a plan |
| Polly | Retries transport failures, not rejected writes |

---

## 6. Handoff

`FW-082` calls `PushPassSchedule` at check-in acknowledgement. `FW-205` calls
`SetITInhibit`. Phase 6 calls the per-component write and the hold/restore pair. Phase 7 adds
the line-state gate and `FR-302`'s never-send-a-stop invariant. `FW-143` receives the audit
records.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`G2` / `OI-39`** *(blocker)* | Cross-DB check-in recovery undecided — Critical. Bounds `P-27`; **settle `G30` first** |
| **`G30`** | FM2's controller namespace on FL3 — one failure domain or two, which changes what a compensating clear must cover |
| **`G33` / `PLC-Q05`** | **A wrong path fails silently.** The single most dangerous unknown in this story (§2.4) |
| **`G29`** | **No edger tag path exists on any line, yet edge type is in the push payload** — `PushPassSchedule` has a value with nowhere to write it |
| **`G32` / `PLC-Q04`** | FM2 station names (`FL2.FM2.S1/S2/S3`) pending sign-off |
| **`G31`** | Read tags with no remaining consumer — affects `FW-N05`, not this write-only service |

No stale citations in this card beyond the two-vs-six operations count, which §1.1 resolves
in favour of `phase-01b` L108.
