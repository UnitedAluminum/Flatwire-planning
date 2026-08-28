# FW-082 · PLC tag group push on check-in acknowledgement

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ⚠ **Four blockers, and one dependency reaches into MVP-2**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-082`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** This is the moment the software configures a machine, and
> three of its rules are about **restraint**.
>
> **Six value groups, nothing else.** The push writes component state, die sizes, roll gaps,
> edge type, speed, and gauge/width targets — and no other tag.
> **One trigger, ever.** Only the step-2 acknowledgement. Never at schedule generate or apply
> time, never at pre-check-in.
> **On failure, no `LineStatus` broadcast.** Compensating re-clears go out and the line is
> *not* announced as configured — a broadcast after a failed push tells every screen the
> machine is running a schedule it never received.
>
> ⚠ And one thing to know before starting: **`G29` means the payload contains a value with
> nowhere to write it.** Edge type is in the six groups and **no edger tag path exists on any
> line.**

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-082 · PLC tag group push on check-in acknowledgement
> **Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** RT
>
> **As an** operator,
> **I want** my acknowledgement to configure the machine in one operation,
> **So that** the line runs the schedule I confirmed and nothing else.
>
> **Acceptance Criteria:**
> - [ ] `PushPassSchedule(scheduleId, lineId, payoffPosition)` writes the six value groups the push needs: **component active/bypass state · die sizes · roll gaps · edge type · speed · gauge and width targets**. Nothing else
> - [ ] Written as a batch to the selected payoff position
> - [ ] **Triggered only by the step-2 acknowledgement** — never at schedule generate or apply time, and never at pre-check-in
> - [ ] Failure path performs **compensating re-clears**, and no `LineStatus` broadcast is emitted
> - [ ] Every tag write audited (tag, value, operator, result)
> - [ ] Runs under `SimulatePLCTagPush` until commissioning (FW-200)
>
> **Rate-card basis:** PLC tag group push + compensating clear @ 16 h (§2)
> **Dependencies:** FW-151, FW-157; **`FW-010`** *(MVP-2 — the schedule this reads)*
> **Blockers:** **G2 / OI-39** · **G29** · **G30** · **`PLC-Q04`/`Q05`**

### 1.1 ⚠ The MVP-2 dependency, and why it is not a blocker

The card depends on **`FW-010`** — pass-schedule authoring, which is **MVP-2**. That reads
like a stopper and is not:

- **`D-31` (15 Aug 2026) moved the three `PassSchedule*` tables into MVP-1** with a real,
  enforced FK, and the seed carries `PS-1100-FL1-001`, `PS-1100-FL2-002` and
  `PS-1100-FL3-001`. This story can **read** a schedule today.
- **MVP-1 never writes one.** No create, edit, approve or list.
- ⚠ **`OI-110`: nothing in MVP-1 populates these tables in production** — the seed covers
  development and the trial only. **Something outside MVP-1 must**, and that is what
  `FW-010` is.

**Build against the seeded schedules. The production data source is an open programme item,
not a code dependency.**

### 1.2 Out of scope

| Concern | Story |
|---|---|
| `PLCTagService` and its six operations | [`FW-151`](FW-151-PLCTagService.md) — *"this is the service; `FW-082` is its use at check-in"* |
| The check-in orchestration that calls this | [`FW-157`](FW-157-CheckIn-Rod-And-CheckInService.md) |
| The tag-path map | `[PLC]` owns it; [`FW-144`](FW-144-Configuration-Binding.md) binds it |
| The FL2 push | `FW-179`, Phase 8 — **FL2 tags only** |
| Commissioning | `FW-200` |

---

## 2. The six value groups — and nothing else

`[PLC §7.2]`, via `phase-01b` L59:

| # | Group |
|---|---|
| 1 | Component **active / bypass** state |
| 2 | Die sizes |
| 3 | Roll gaps |
| 4 | **Edge type** — ⚠ `G29` |
| 5 | Speed |
| 6 | Gauge and width targets |

**Written as one batch** to the selected payoff position — [`FW-151`](FW-151-PLCTagService.md)'s
batch-write operation, not six separate writes.

> ⚠ **`G29`: no edger tag path exists on any line**, yet edge type is group 4. The payload
> carries a value with nowhere to write it. **Do not invent a path** — `[PLC]` owns every tag
> string and inventing one here creates the seventh copy of a surface deliberately reduced to
> one ([`FW-144 §2.3`](FW-144-Configuration-Binding.md)).

### 2.1 One trigger

**Only the step-2 acknowledgement.** Not at generate, not at apply, not at pre-check-in.

This is why the push lives here and not in the pass-schedule track: a schedule may be
authored, approved and revised many times without a machine ever being configured. The
acknowledgement is the operator asserting *this* is what the line will run.

### 2.2 Failure: re-clear, and stay silent

Two halves, and the second is the one that gets forgotten:

1. **Compensating re-clears** for whatever landed — not "rollback" (`G2`, `G16`).
2. **No `LineStatus` broadcast.** A broadcast after a failed push tells every connected
   screen the line is configured. `PLC_PUSH_FAILED` → `500`.

---

## 3. Build order

1. Implement over [`FW-151`](FW-151-PLCTagService.md)'s `PushPassSchedule` — **this story adds
   no new tag operation**, it composes one.
2. Read the schedule locally (`D-31`) and project the six groups; persist the
   `PassScheduleSnapshot` — [`FW-157 §2.4`](FW-157-CheckIn-Rod-And-CheckInService.md) owns the
   write.
3. Batch-write to the selected payoff position.
4. Audit **before** the push (`FR-072`), every write and clear (`FR-075`).
5. Failure path per §2.2 — re-clears, no broadcast.
6. Honour `SimulatePLCTagPush`, which is **`true` in every environment until commissioning**
   and logs the write it would have made.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-40` precede this story.

### `P-41` — push the edge-type group with its path unresolved, and fail loudly

`G29` leaves group 4 with no destination on any line. Three options, and the middle one is
the trap:

| | |
|---|---|
| Drop edge type from the payload | **No** — it is one of the six `[PLC §7.2]` groups, and dropping it silently ships a machine configured without it |
| Write it to a guessed path | **No** — `[PLC]` owns every tag string, and `G33` means **a wrong path fails silently**, reporting success while the line keeps its previous settings |
| **Carry it, resolve the path from configuration, and fail the push if unconfigured** | ✅ |

**So: the value is built into the payload; its tag path resolves from configuration like
every other; and an unresolved path is a hard failure of *this* push, not a skipped group.**
That converts `G29` from a silent omission into a visible one, and
[`FW-144 §`P-16``](FW-144-Configuration-Binding.md)'s startup warning already counts
unconfirmed paths.

⚠ **`SimulatePLCTagPush` will mask this until commissioning** — a simulated write logs the
write it would have made and cannot tell that the path is fictional. **The first real test is
`C1`/`C11`.**

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and at commissioning;
`[NFR]` `TC-601`–`TC-613` cover the PLC audit.

| Check | Expected |
|---|---|
| Six groups, nothing else | Diff the written tag set against `[PLC §7.2]` — **no extra tag** |
| One batch | A single batch write to the selected payoff position |
| **Trigger** | Generating, applying or pre-checking-in a schedule writes **nothing** |
| **Failure** | Force a push failure → compensating re-clears issued **and no `LineStatus` broadcast**; `PLC_PUSH_FAILED`/`500` |
| Audit | Every write and clear, before the push |
| Simulate | Logs the write it would have made; on by default |
| Edge type | Present in the payload; unresolved path **fails the push** *(`P-41`)* |

---

## 6. Handoff

`FW-179` (Phase 8) does the FL2 equivalent — **FL2 tags only**, no DB or FM1 tags. Phase 7
adds the line-state gate before `ClearPayoffTags` and `FR-302`'s **never-send-a-stop**
invariant. Phase 10 adds the FL3 single-batch push. `FW-200` is commissioning.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`G2` / `OI-39`** *(blocker)* | Recovery undecided — **before T2**; carries the 24–64 h reserve |
| **`G29`** *(blocker)* | **No edger tag path on any line**, yet edge type is group 4 — `P-41` |
| **`G30`** *(blocker)* | FM2's controller namespace on FL3 — one failure domain or two, which changes what a re-clear covers. **Settle before `G2`** |
| **`PLC-Q04`** *(blocker)* | FM2 station names (`FL2.FM2.S1/S2/S3`) pending sign-off |
| **`PLC-Q05` / `G33`** *(blocker)* | **A wrong path fails silently.** The audit will record success |
| **`OI-110`** | Nothing in MVP-1 populates the schedule tables in production (§1.1) |
