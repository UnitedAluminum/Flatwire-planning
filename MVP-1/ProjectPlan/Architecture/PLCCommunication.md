# Flat Wire Mill — PLC / OPC Communication

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `03-HLD-and-ERDiagram.md`, `02-SRS.md`, `04-APIContract.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** PLC integration design, the write surface and the service contract
**Status:** Baselined for build — **carries no tag path strings by rule**
**Owner:** Real-time / PLC stream
**Audience:** .NET developers, controls engineer, integration testers
**Shortcode:** `[PLCC]`
**Part of:** `ProjectPlan/Architecture/` — index: [README.md](../README.md)

---

## 9. Integration design — PLC / OPC

### 9.1 The rule that governs everything

**PLC tags are pushed on exactly one trigger: explicit operator acknowledgement of a pass schedule at check-in.** Never on schedule save, load or generation. Never at pre-check-in.

### 9.2 The tag surface

> **Specified in [`PLCTagSpecification.md`](PLCTagSpecification.md)** — the write operations and their triggers (`[PLC §7]`), the per-line tag map (`[PLC §5.2]`), `ITInhibit` and its five conditions (`[PLC §8]`), and the full tag lifecycle (`[PLC §9]`).

The architectural facts that belong here rather than there:

- **The integration layer is the existing OPC service, extended.** PLCs are new hardware; **OPC servers are unchanged**; no new integration layer is introduced (`INT007`).
- **Tag paths and the line-state mapping are configuration**, so both can be corrected after commissioning without redeployment.
- **Machine writes are not transactional.** Recovery is a **compensating re-clear**, never a rollback — gap **G16**. §9.1 above states the single-trigger rule; §10 below is the transactional boundary this creates.
- **On FL3 it is undetermined whether the single-batch push crosses a controller boundary** — every published map addresses the finishing stands under the FL2 namespace. That decides whether there are one or two failure domains for §10 to compensate. Gap **G30** / **`PLC-Q08`**.

---

### 9.1 – 9.2 The PLC / OPC interface

> **The full write surface, the read surface and the tag map are specified in [`PLCTagSpecification.md`](PLCTagSpecification.md) — the single home for the tag surface since 4 Aug 2026.** This section previously carried a write table and a representative FL1 tag map; both are superseded there, where the map is published **per line** and carries the paths this document never had.

The requirement-level rules, which remain normative here:

| ID | Requirement |
|---|---|
| `FR-022` | All OPC tag paths shall be sourced from configuration, **never hardcoded**, so a path found wrong at commissioning is corrected without redeployment. |
| `FR-049` | **No PLC write shall occur at pre-check-in.** |
| `FR-071` | Tags shall be pushed on **one trigger only** — explicit operator acknowledgement of a pass schedule at check-in. Never on schedule save, load, generation or apply. |
| `FR-072` | **Every audit record shall be written before the push**, leaving an incomplete-push marker if the push then fails. |
| `FR-075` | **Every tag write and clear shall be audit-logged** with tag path, value, operator, timestamp and result. |
| `FR-302` | The system shall **never send a stop command** to the PLC. |
| `FR-008`–`FR-010`, `FR-020` | `ITInhibit` is **system-controlled**: set and cleared only automatically, never by an operator. |

> **One correction still owed in this document.** The rollback wording is **fixed** — `FR-073` no longer calls the push a transactional batch and `FR-074` now states the compensating re-clear directly, which **closes gap G16**. What remains is that `FR-073` says *speed **limits*** where the interface sections said *speed **targets***. That is a genuine ambiguity rather than a typo — a setpoint and a safety clamp are different tags with opposite failure modes — so it is being asked as **`PLC-Q06`** and the wording is deliberately left alone until it closes.

---

## 6. PLC / OPC surface

The integration layer is the **existing `OPCConnection` service, extended** to subscribe to FL1/FL2/FL3 tags. PLCs are new hardware; **OPC servers are unchanged**; no new integration layer is introduced.

### 6.1 `PLCTagService` — the service surface

> **What each operation writes, when, and to which line is specified in [`PLCTagSpecification.md`](PLCTagSpecification.md) §4.** This section carries only the contract shape.

| Operation | Signature |
|---|---|
| Pass-schedule push | `PushPassSchedule(scheduleId, lineId, payoffPosition)` |
| Payoff clear | `ClearPayoffTags(lineId, payoffPosition)` |
| Per-component write | one call per changed component, on roll-adjust Apply |
| Hold / idle and restore | on pause and resume |
| Simulated push | `SimulatePLCTagPush` — selected by configuration, not by call site |

**The first parameter is `scheduleId`.** `phase-04` still uses `passScheduleId` and needs the one-line correction; the April elaboration that also used it has been absorbed and deleted.

### 6.2 Error codes

| Code | Status | Raised when |
|---|---|---|
| `PLC_PUSH_FAILED` | `500` | Any single tag write in a push batch fails. The check-in is aborted and compensated — **a compensating re-clear, not a rollback** (`[PLC §7.5]`) |
| `LINE_STILL_RUNNING` | `422` | The line-state tag reports running at a checkout attempt — checked both at dialog open and at confirm |

### 6.3 `ITInhibit` and the read surface

> Both in [`PLCTagSpecification.md`](PLCTagSpecification.md) — `ITInhibit` and its five conditions at `[PLC §8]`, the per-line tag map at `[PLC §5.2]`.

> **Naming.** The enum at §1 is renamed **`LineOperatingState`** and the hub event **`LineStateChanged`**, so that **`LineState`** unambiguously means the machine tag. The machine’s own vocabulary is undocumented and is being asked as **`PLC-Q01`**; it is resolved through a **configurable mapping table** (`[PLC §6]`), not by adding an enum member. Note `FR-141` fires the spool prompt on a *running → stopped* transition — a value the six-member enum does not contain.

---

## Appendix — implementation contract

> **Absorbed from `Architecture/PLCCommunication.md` on 13 Aug 2026**, the internal half of the PLC tag surface. It owns
> what a client would not sign: service signatures, configuration binding, persistence sinks, phase ownership,
> requirement traceability and provenance.
>
> **The anti-drift rule is unchanged and now applies to this whole file:** `MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md`
> owns **every tag path string** and this document contains **none**. If you are about to write a tag path here,
> you are creating a second copy of the tag map.

### 0. Scope and the anti-drift rule

The tag surface lives in two documents: **`[PLC]`**, which the client signs, and this note, which the client never reads. Splitting a specification in two creates a drift risk, and there is exactly one rule that contains it:

> ### The client document owns every tag path string. This document contains none.
>
> Refer to tags **by role** — *the FL1 gauge tag*, *the line-state tag*, *the footage counter* — and cite `[PLC §5.2]` for the path. Never reproduce a table row from it. In the configuration section, show the **key shape and binding mechanism** with `<path from [PLC §5.2]>` as the value placeholder, never a literal path.
>
> The reason is that a tag path string is simultaneously the client's sign-off artifact and an `appsettings` key. If it lives in two files it will diverge, and the copy developers read is the one that will be wrong.

**Standing verification:** this file must produce **zero** matches for a line-prefixed tag path.

| Belongs in `[PLC]` | Belongs here |
|---|---|
| Tag paths, per line | `PLCTagService` signatures and call sites |
| What is written and when | Configuration key shape and options binding |
| The naming convention | Persistence columns and their constraints |
| `ITInhibit` conditions | Phase ownership and the dependency chain |
| The tag lifecycle | `FR-###` / `INT###` / `TC-###` traceability |
| Open items requiring client input | Outstanding internal text fixes |
| Commissioning C1–C11 | Provenance — what `[PLC]` supersedes |

---

### 1. `PLCTagService` — the write surface

Five operations. Behaviour, triggers and payload are `[PLC §7]`; this is the shape.

| Operation | Signature | Called from |
|---|---|---|
| Pass-schedule push | `PushPassSchedule(scheduleId, lineId, payoffPosition)` | `CheckInService`, on the rod and spool check-in paths |
| Payoff clear | `ClearPayoffTags(lineId, payoffPosition)` | `CheckOutService`, Modes A and B only |
| Per-component write | one call per changed component | `RollOverrideService`, on roll-adjust Apply |
| Hold / idle and restore | drive enable and speed | `RunControlService`, on pause and resume |
| Simulated push | `SimulatePLCTagPush` | Selected by configuration, not by call site |

#### 1.1 The parameter name is `scheduleId`

**The parameter is `scheduleId`, not `passScheduleId`.** `04-APIContract.md` §6.1 rules it, and the April elaboration that used `passScheduleId` was absorbed into that document and deleted on 13 Aug 2026. **`phase-04` still says `passScheduleId` and needs the one-line correction.**

#### 1.2 Ordering — records before tags, enforced in the service

`[PLC §7.4]` states the rule; the implementation constraint is that it is **the service's responsibility, not the handler's**. `CheckInService` commits the local transaction, then the shared-schema writes, then calls the push. A handler that pushes before the records exist is a defect regardless of whether the test suite catches it.

#### 1.3 Failure is compensating, and the word matters

`[PLC §7.5]`. In code and comments, **never write "rollback" or "atomic" about the tag batch.** Use *compensating re-clear*. The wording matters because it has misled implementers before; gap **G16** exists for it and is closed.

The compensation sequence is the Mermaid diagram at `03-HLD-and-ERDiagram.md` §10, which stays in the HLD — it is architecture, not tag surface, and it is the home of **G2** / **OI-39**.

#### 1.4 Error codes

| Code | Status | Raised when |
|---|---|---|
| `PLC_PUSH_FAILED` | `500` | Any single tag write in a push batch fails. The check-in is aborted and compensated |
| `LINE_STILL_RUNNING` | `422` | The line-state tag reports running at a checkout attempt — either at dialog open or at confirm |

#### 1.5 `LineState` — the rename

Three things were called "line state": the PLC tag, a C#/TS enum, and a SignalR event. `[PLC §6]` explains the collision for the client. **The internal resolution:**

| Name | Resolution | Why | Applied? |
|---|---|---|---|
| The **machine's line-state tag** (path at `[PLC §5.2]`) | **keeps the name `LineState`** | It is the machine's own name. It wins | n/a — no change |
| `enum LineState { Running, Idle, Setup, Paused, Fault, Offline }` | → **`LineOperatingState`** | So "LineState" unambiguously means machine truth | **No — `04-APIContract.md:128` still declares the old name** |
| Hub event `LineStatus` | → **`LineStateChanged`** | Renaming the event is what settles the collision | **No — `04-APIContract.md:740` still declares the old name** |

**Do not add a seventh enum member for `Stopped`** on the assumption of what the machine reports — `FR-141` fires the spool prompt on a *running → stopped* transition, and the resolution is the configurable mapping table in `[PLC §6]`, not a guessed enum value.

#### 1.6 The interlock is line-scoped, so it takes a `lineId`

`[PLC §8.1]`. The run-block interlock is **one tag per line**, not one plant-level tag — the client confirmed the line-scoped form after every pre-consolidation source had recorded it without its prefix.

Three implementation consequences:

- **The write carries the line.** Whatever sets and clears the interlock takes `lineId`, and its logical key sits **under `Lines.FL{n}.Tags`** like every other path — not as a peer of `SimulatePLCTagPush` at the root. A single root-level key would be the plant-level reading expressed in configuration, and it would be discovered the first time an idle line blocked a running one.
- **The five conditions are evaluated per line.** Condition 1 (nothing checked in) and condition 2 (no active material-tracking identifier) are already per-run and therefore per-line; conditions 3–5 (feet data unavailable, invalid, two consecutive recordings missed) are evaluated **against that line's own stream**. A gap in FL1's feet data must not set FL2's interlock.
- **FL3 is the open case, and it is `PLC-Q08`, not a design choice.** Whether the hybrid line has its own interlock or asserts the interlocks of the two controllers it spans follows from the FL3 namespace answer. Bind it as one per-line key like the others and let the config value decide; **do not write a special case** before `PLC-Q08` closes.

`FR-008`–`FR-010` and `FR-020` are unchanged by this — they were always silent on scope.

#### 1.7 The mapping table is configuration

`[PLC §6]` commits to publishing the machine-value → application-state map as configuration, on the same principle as tag paths. That is a real implementation obligation, not a document flourish: the `PLC-Q01` answer arrives **at commissioning**, after the code freeze, and it must be applicable without a build.

---

### 2. Configuration binding

Every path is configuration (`FR-022` / `INT005`), owned by `OPCConnection`'s `appsettings.{Environment}.json`.

```jsonc
{
  "FlatWireOpc": {
    "SimulatePLCTagPush": true,        // true in every environment until commissioning
    "PublishIntervalMs": 1000,         // 1000 | 5000 | 10000 | 30000
    "Lines": {
      "FL1": {
        "Tags": {
          "Gauge":          "<path from [PLC §5.2.1]>",
          "Width":          "<path from [PLC §5.2.1]>",
          "Speed":          "<path from [PLC §5.2.1]>",
          "LineState":      "<path from [PLC §5.2.1]>",
          "DancerActive":   "<path from [PLC §5.2.1]>",   // FM1 carries one dancer
          "DancerPosition": "<path from [PLC §5.2.1]>"
          // ... one key per row of the FL1 map
        },
        "LineStateMap": {                       // per [PLC §6] — filled at commissioning
          "<raw value>": "Running"              // C2 supplies the left-hand side
        }
      },
      "FL2": { /* per [PLC §5.2.2] — note FM2 carries **two** dancers, so the
                     dancer keys are indexed: DancerActive1/2, DancerPosition1/2,
                     DancerMode1/2, DancerTension1/2 */ },
      "FL3": { /* per [PLC §5.2.3] */ }
    }
  }
}
```

**Binding rules:**

- Keys are **stable logical names**; values are paths. Code references the logical name and never a literal path — that is what makes a commissioning correction a config edit.
- **The keys above were realigned on 4 Aug 2026** — `GaugeCurrent`→`Gauge`, `WidthCurrent`→`Width`, `SpeedFpm`→`Speed` — when `[PLC §4.2]` respecified the measure segment (analogues bare, no units). **That was readability, not necessity.** The keys are deliberately decoupled from the paths, so a measure rename does *not* require a config-contract change and a path correction at commissioning must stay a values-only edit. If `PLC-Q05` comes back with different measure names, **only the right-hand side moves.**
- Bind to a strongly-typed options class and **validate on startup**: every logical name the code uses must be present. A missing key should fail fast at boot, not silently at the first read.
- A path marked `[PROPOSED]` in `[PLC §5.2]` is still a path — configure it, so C1 has something to test. **Do not log a warning per proposed path.** As of the v1.0 reissue **every path in the map is `[PROPOSED]`** — the `[CONFIRMED]` tag was retired because nothing had earned it — so a per-path warning fires for every tag on every line at every startup, which trains people to ignore the log. Emit **one warning at startup naming the count of unconfirmed paths**, and let that count fall as `C1` and `C11` confirm them. A count that reaches zero is the signal worth having.
- `LineStateMap` is **empty until C2**. Until then the harness drives the double, per `[PLC §10.2]`.
- **The dancer keys are read-only — subscribe, never write.** FM1 has one dancer, FM2 two. Whether the mode is ever *written* is unresolved (`Q32`): the 6 Aug call described two selectable modes, the 23 Jul meeting recorded tension control as machine-driven. `[PLC §5.5]` publishes the read surface only, so **`PLCTagService` is unchanged** — no new write operation, no change to the ordering rule or the compensating re-clear. If the mode becomes written, it joins the existing push batch and inherits both unchanged.
- **The interlock key belongs inside each line's `Tags` block, never at the root** — it is line-scoped per `[PLC §8.1]`. A root-level key is the plant-level reading in disguise. See §1.6.

**Deployment:** `SimulatePLCTagPush` is `true` everywhere until commissioning completes (`[DEP]:82`, restated in the go-live checklist at `:356`). Verification of a tag push happens **on a stopped line only** (`[DEP §4.5]`, step V12). Rollback restores the file and recycles `OPCConnection_<Env>` — configuration only, nothing lost (`[RB §6.2.2]`).

---

### 3. Persistence sinks

Each write leaves a durable flag, so machine state at a past moment is reconstructable from the transaction rather than from log retention.

| Moment | Column | DDL |
|---|---|---|
| Push at rod check-in | `RodCheckin.PlcTagsPushed` `BIT NOT NULL` | `Schema/SQL/FlatWire_DDL_04_Runs.sql:255` |
| Push at spool check-in | `SpoolCheckin.PlcTagsPushed` `BIT NOT NULL` | `Schema/SQL/FlatWire_DDL_04_Runs.sql:303` |
| Roll adjust, per component | `RollOverride.PlcTagWritten` `BIT NOT NULL` | `Schema/SQL/FlatWire_DDL_04_Runs.sql:421` |
| Checkout | `RodCheckout.PlcTagsCleared` `BIT NOT NULL` | `Schema/SQL/FlatWire_DDL_05_QualityOutput.sql:209` |

**One constraint worth knowing before writing checkout:** `CK_RodCheckout_ModeP` (`FlatWire_DDL_05_QualityOutput.sql:234`) forces `PlcTagsCleared = 0` for Mode P. That is correct and deliberate — a rod released before check-in never had tags, so there was nothing to clear, and recording `1` would assert a clear that never happened. Do not "fix" a Mode P row that reads `0`.

**Audit log** (`FR-075` / `INT004`): one line per tag write and per clear, carrying path, value, operator, timestamp and result. Simulated writes log the write they *would* have made. Escalation policy is *any* failure — there is no routine failed tag write, because every one aborted a check-in (`[DEP]:637`).

Supervisor PINs authenticate only. **Never in a payload, never stored** — persist the flag, the authorising identifier, the timestamp and the reason. The validation source is still unsettled (`OI-38`).

---

### 4. Phase ownership

`PLCTagService` is **built in Phase 1, exercised first in Phase 4**, and consumed by five phases (`Development/GapsRegister.md:37`):

| Phase | What it does with tags |
|---|---|
| **1** | Service, options binding, simulate mode, audit logging |
| **4** | The push at rod check-in; the confirmation gate; compensating re-clear on failure |
| **6** | Per-component write on roll adjust; hold/idle on pause; footage read for die life |
| **7** | Line-state gate then `ClearPayoffTags`; the never-send-a-stop invariant |
| **8** | The FL2 push — finishing mill only, no die blocks and no FM1 |
| **10** | The FL3 single-batch push across both mills |
| **14** | Commissioning: simulate → live, C1–C11 |

**Commissioning is targeted by Sep 30** and its 40 hours sit in Phase 14's W7 window, flagged in the plan as the worst compression in the schedule. Until then all three lines run simulated pushes and a mock stream, so the UI is fully testable and the interface is entirely unproven.

**Phase 4 carries a 24–64 h reserve** against **OI-39** / **G2**, the undecided cross-system recovery path. **G30** — client-facing as **`PLC-Q08`** — (FL3's controller topology) is a prerequisite for closing it: whether the push reaches one controller or two decides whether there is one failure domain to compensate or two.

---

### 5. Requirement traceability

| Requirement | Subject | Now specified in |
|---|---|---|
| `FR-008` – `FR-010`, `FR-020` | `ITInhibit`, its five conditions, its effects | `[PLC §8]` |
| `FR-014` | Remaining length and derived weight for the active **and** queued coil, from machine feet. **Anchor feet consumption on `FR-014` plus `FR-009`/`FR-010` — there is no `INT011` or `INT012` in this repository** (the series runs `INT001`, `002`, `004`–`007`, `010`) | `[PLC §5.1]`, `[PLC §5.3]`, `[PLC §8]` |
| `FR-022` / `INT005` | All paths from configuration, never hardcoded | `[PLC §10.1]` |
| `FR-049` | No PLC write at pre-check-in | `[PLC §7.3]`, `[PLC §9.2]` |
| `FR-071` | Explicit schedule confirmation before any push | `[PLC §9.3]` |
| `FR-072` | Records before push, incomplete-push marker | `[PLC §7.4]` |
| `FR-073` / `FR-074` | Push payload and batch failure | `[PLC §7.2]`, `[PLC §7.5]`. **`FR-073`'s speed wording is still owed — see §6** |
| `FR-075`, `NFR010`, `NFR011` | Audit of every write and clear | `[PLC §11]` |
| `FR-096` | The FL2 push set | `[PLC §7.2]`, `[PLC §9.3]` |
| `FR-141`, `FR-143`, `FR-150` | Stop-confirmed spool completion; weight latched at the stop timestamp | `[PLC §9.5]`, `[PLC §6]` |
| `FR-209` | Roll adjust writes immediately, per changed component | `[PLC §9.4]` |
| `FR-255` | Die footage from the machine counter, no new sensor | `[PLC §9.4]` |
| `FR-263` | Pause freezes footage, tags to hold/idle | `[PLC §9.4]` |
| `FR-301` – `FR-304`, `FR-321` | Checkout gate, never a stop, locked footage, clear after confirmed stop | `[PLC §9.5]` |
| `FR-362`, `FR-391` | No schedule reaches the machine except by acknowledgement; generation writes no tags | `[PLC §7.3]`, `[PLC §9.2]` |
| `FR-369`, `NFR009` | The line runs on previous values until the operator acknowledges | `[PLC §9.4]` |
| `INT002` | The batch. **`INT002`'s own wording is not authoritative — `[PLC §7.5]` is** | `[PLC §7.5]` |
| `INT004`, `INT007` | Audit of every write; no new integration layer — the existing OPC service, extended | `[PLC §11]`, `[PLC §5.3]` |
| `TC-041`, `TC-452` | Zero writes at pre-check-in and at generate/apply | `[PLC §9.2]` |
| `TC-083` – `TC-085` | Confirmation gates the push · records first · batch failure compensates | `[PLC §7.4]`, `[PLC §7.5]` |
| `TC-172`, `TC-335` | Weight latched at the stop timestamp; the speed tag triggers the prompt | `[PLC §9.5]` |
| `TC-257` | One write per changed component | `[PLC §9.4]` |
| `TC-304` | Die footage rises by run footage | `[PLC §9.4]` |
| `TC-319`, `TC-322` | Pause to hold/idle; resume restores | `[PLC §9.4]` |
| `TC-375`, `TC-377` | Checkout blocked while running; **zero stop commands** | `[PLC §9.5]` |
| `C1` – `C11` | The commissioning sequence | `[PLC §12]` — reproduced; `[COM §8]` stays authoritative for pass criteria |

---
### 6. Outstanding text fixes

One, and it is deliberately held rather than forgotten:

| File | Fix | Blocked on |
|---|---|---|
| `MVP-1/ProjectPlan/Business/BusinessRequirements.md` `FR-073` | *speed limits* vs *speed targets* — the requirement text and the interface section disagree | **`PLC-Q06`.** Fixing it now would pick a side between a setpoint and a safety clamp |

---

### 7. Provenance

#### 7.1 `[PLC]` v1.1 — the dancer element (12 Aug 2026)

**`[PLC]` carries no revision history by design** — the v1.0 reissue deleted its decision log because a first issue has none. The history for the pair therefore lives here.

**v1.1 adds a dancer element to the read surface.** FM1 carries one dancer and FM2 two, between S1/S2 and between S2/S3 (`D-28`). Nothing modelled them: no lookup row, no component row, no tag path — gap **`G35`**, and wave **W6** of the 6 Aug ledger.

Four decisions worth recording, because none is obvious from the result:

1. **Ordinal, not station-scoped.** A dancer sits *between* stands, so `FM2.S2.Dancer` would assert a relationship that does not exist. It takes an ordinal under the assembly per **R6**, which also **decouples the dancer paths from `PLC-Q04`** — the FM2 station-rename question — so they do not inherit that risk. **R5** was qualified to say so explicitly.
2. **Read-only, deliberately.** Two client statements disagree on whether the mode is written (`Q32`). Read-only is the half that holds either way, so a write surface would be an **addition**, not a correction.
3. **`Mode` is a third measure kind** — neither R4 boolean nor R8 analogue. It follows the `LineState` precedent: a bare segment with a published vocabulary (`[PLC §5.5]`).
4. **FM1 gets no `Mode` tag.** Modes were attributed to FM2 only; assuming FM1 is single-mode would be inventing a fact. Raised inside **`PLC-Q18`**.

Commissioning test **C12** and open item **`PLC-Q18`** were added with it.

#### 7.2 Document lineage


`[PLC]` is the single specification of the tag surface. It **supersedes** the tag content of `02-SRS.md` §9, `03-HLD-and-ERDiagram.md` §9, `04-APIContract.md` §6, `FlatWire_MasterSpecification.md` §6.8 and `RocCheckin.md` §3.6, each of which is now a pointer to it. **Do not "correct" `[PLC]` back to any of those sections.**

Three things stayed behind in their original homes because they are architecture rather than tag surface, and are cited from elsewhere:

- **`03-HLD-and-ERDiagram.md` §10** — the transactional boundary and the compensating-write sequence; the home of **G2** / **OI-39**.
- **`04-APIContract.md` §6.2** — the two error codes, reproduced in §1.4 above.
- **`RocCheckin.md` §3.6** — the check-in acknowledgement sequence.

`HMIAndSCADALayout.md` (deleted 4 Aug 2026 with the HMI/SCADA descope) contributed **`PLC-Q02`** and assumption **`A2`** to `[PLC]`; nothing else in it was unique. Both are now `[PLC]`'s only home for those items — **`A2` is read by open question `Q30`, and `PLC-Q02` is tracked in `[PLC]` alone since its register entry was withdrawn on 12 Aug 2026** — so neither can be dropped as stale. **`[PLC]` no longer names that document**, even as the source of `A2`: it is deleted, so a pointer to it is a dead reference. This note is where the attribution lives.

**Every tag path in `[PLC]` is `[PROPOSED]`, and that is now literally true (v1.0, 4 Aug 2026).** The `[CONFIRMED]` tag was **retired from the specification entirely** — the reading convention is two tags. It had rested on the second limb of its own definition, *"stated consistently across the source specifications,"* which let three internal copies of one unverified table agreeing with each other read as confirmation; **no client artifact contains a single tag path.** Two consequences for this file: the startup warning must be **one count, not one per path** (§2), and **the decision log `§12` is gone** — `D14`, `D15` and the rest were removed with the document's revision history, so cite `[PLC §8.1]` for the interlock rule and `Q84`/`Q85` in the register for the decisions behind it. Do not reintroduce a `D##` citation into `[PLC]`.

**`[PLC]` carries no history, by rule (4 Aug 2026).** Both client-facing artifacts — the markdown and `MVP-1/SRS/PLCTagSpecification.docx` — state the specification and nothing it replaced: no old→new tables, no `observed as …` footnotes, no struck-through rules. So when a path in `[PLC §5.2]` looks wrong at commissioning, **`[PLC]` cannot tell you what it used to be.** That trail moved on 12 Aug 2026 when the two register entries holding it were withdrawn to `PLC-Q05` and `PLC-Q04`, which may carry no old/new content: it is now in [`Development/GapsRegister.md`](../Development/GapsRegister.md) — gap **`G33`** for the measure segment (all nine measures, old→new) and gap **`G32`** for the FM2 station names — plus [`CHANGELOG.md`](../../../CHANGELOG.md) and git. **This file deliberately does not duplicate it**, because it carries no tag path strings at all; the gap register is the single home. `[PLC §4.2]` was renumbered to **R1–R8** in the same change, so any citation of R9 or of the old R5–R8 numbering is stale.
