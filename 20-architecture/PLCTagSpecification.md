# Flat Wire Processing — PLC Tag and Machine Interface Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** FL1 / FL2 / FL3
**Version:** 1.3
**Date:** September 5, 2026
**Status:** Issued for Client Review and Sign-off
**Last Updated:** September 5, 2026 — **`D-46`: every tag path gains a `PLC` element after the line.** `FL1.AGC.Gauge` is now `FL1.PLC.AGC.Gauge`. The grammar in §4.1, rules R2 and R3, and every path in §5.2 are rewritten. **Values only — no logical name moved**, which is the property §4 was built to have. ⚠ **`D-47`: FL3 has no controller of its own**; see §5.2.3.
**Interface reference:** The machine write surface (pass-schedule push and tag clear) · the machine read surface (subscribed values) · `ITInhibit`
**Requirement source:** This document specifies the flat wire PLC/OPC tag surface — every value the application writes to the line, every value it reads from it, and the one tag that blocks the machine from running.

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[PROPOSED]` | Our design recommendation, or a path derived from the naming convention, requiring your confirmation at review. **A proposed tag path is our specification, not a path anyone has verified against the machine.** |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 13.1. |

> **There is no `[CONFIRMED]` tag in this document, and its absence is the point.** Nothing here has been agreed as a *string* with United Aluminum or read off a controller, so the tag would have no members and would only create false confidence. A path becomes confirmed at the moment commissioning test **C1** or **C11** reports that the controller accepted it — see Section 12.

Open items carry a **`PLC-Q##`** identifier so that Section 13.1 and the sign-off sheet read as one contiguous list, **numbered in priority order**. **`PLC-Q##` is an index, never a replacement:** every entry carries an *Also tracked as* value pointing at its authoritative register — **`Q##`** in the project open-questions register, **`OI-##`** in the master specification's open-items register, **`G##`** in the roadmap's gaps register. Nothing is tracked only here.

---

# 1. Introduction

## 1.1 Purpose

This document has two jobs, and the second is the more urgent.

1. **It specifies the machine interface.** What the application writes to the line and when, what it reads from the line and why, and the one system-controlled tag that blocks the machine from running.
2. **It is a structured information request.** The tag paths in Section 5 follow **a naming convention, not a verified map.** They were written from the equipment description, not read off a controller. Every one of them needs confirmation by the controls commissioning engineer, and until that happens the interface is unproven at its most important point.

Commissioning is targeted for **September 30, 2026**, and its first test is *"read every configured tag path in turn."* Section 5 is the list that test reads from.

## 1.2 Scope

**In scope:** the values written to the machine and their triggers · the values read from the machine and their consumers · the tag naming convention · `ITInhibit` and its conditions · the full tag lifecycle from staging to checkout · per-line differences · how tag paths are configured and corrected · what is audited · the commissioning sequence that proves the interface.

**Not in scope:** the screens that consume these values, each specified in its own document · the pass schedule's contents and how it is authored or generated · the real-time delivery mechanism between the server and the browser · the internal software design, which is a separate internal note.

## 1.3 Why a wrong tag matters more than a wrong screen

Acknowledging a pass schedule at check-in is the moment the application **configures the machine**. It writes component activation, die sizes, roll gaps, edge configuration, speed and the gauge and width targets. Everything downstream — the wire's dimensions, whether it is in specification, what the certificate says — follows from those values landing correctly.

A tag push that writes the *right value to the wrong path* fails silently. The write reports success, nothing changes on the machine, and the line runs on whatever it was set to last. A tag push that writes to a path with the *wrong meaning* is worse: it configures the machine to something nobody chose.

Both are classified **Severity 1 — Critical**, alongside data loss and a wrong certificate. Confirming the tag map is therefore not documentation housekeeping; it is the control on the most consequential silent failure in the system.

## 1.4 Intended audience

| Reader | What they need from this document |
|---|---|
| **Controls / commissioning engineer** | Sections 4, 5, 6 and 12 — confirm or correct the naming convention and every path, and supply the line-state vocabulary |
| **Engineering (tag map owner)** | Sections 2 and 5 — confirm the map matches the equipment as built |
| **Operations** | Sections 3, 7, 8 and 9 — confirm when the machine is configured, what is never written, and why the line can be blocked from running |
| **IT / development** | All of it, plus the internal implementation note |

---

# 2. The Three Lines

Everything in Sections 5 and 7 — the three tag maps and the push payload — follows from the equipment described here.

## 2.1 Equipment as built

| Line | Flow | Edger | Dancers | Live gauge / width |
|---|---|---|---|---|
| **FL1** | Payoff → DB1 → DB2 → **FM1** (12″ mill) → intermediate take-up | **None — FL1 has no edger** | **1** — on FM1 | **Real-time** |
| **FL2** | Spool payoff → **FM2** (**S1 8″ → S2 6″ → S3 6″**) → final take-up | **S2 and S3 only** | **2** — inter-stand, between S1/S2 and S2/S3 | **Historical** — FL2 reports no live gauge or width |
| **FL3** | Payoff → DB1 → DB2 → FM1 → *(intermediate take-up bypassed)* → FM2 → final take-up | S2 and S3 | **3** — FM1's and both of FM2's | **Real-time** |

Two consequences worth stating plainly:

- **FL1 has no edger, so FL1 has no edger tag.** `FL1.PLC.EdgeSet.Status.IsActive` is deliberately absent from the FL1 map, and from this interface entirely.
- **FL2 measures nothing live**, so FL2 has no gauge or width tag at all. Its trace is reconstructed from the FL1 pass that produced the spool.
- **The dancers are equipment, not an assumption.** FM1 carries one and FM2 carries two, sitting **between** stands rather than at them. This is confirmed equipment (`D-28`); the **paths** that address them in §5.2 are our derivation and are `[PROPOSED]` (`PLC-Q18`).

## 2.2 Per-line differences at a glance

| | **FL1** | **FL2** | **FL3** |
|---|---|---|---|
| **Route** | Rod → DB1 → DB2 → FM1 → intermediate take-up | Spool → FM2 (**S1 8″ → S2 6″ → S3 6″**) → final take-up | Rod → DB1 → DB2 → FM1 → FM2 → final take-up |
| **Check-in type** | Rod, with visual inspection | Spool, no visual inspection | Rod, one acknowledgement for both mills |
| **Pushed** | Components, die sizes, FM1 gap, speed, gauge/width targets | **Components**, FM2 stand gaps ×3, edger activation and edge type, speed, targets | **Everything, in one batch** |
| **Edge type pushed** | **No — FL1 has no edger** | Yes, S2 and S3 | Yes, S2 and S3 |
| **Live gauge / width** | **Real-time** | **None — historical profile only** | **Real-time** |
| **Payoff bays** | 2, with welding between rods | Spool payoff | 2, with welding between rods |
| **Dancers** | 1, on FM1 | **2, inter-stand** — the pair with selectable modes | 3 — FM1's and both of FM2's |
| **Pre-check-in staging** | Yes | **FL2 has no staging space** — and it now has **pre-check-in** all the same, reversed by the client on 20 Aug 2026: a validation queue rather than a bay. **No tag is written at pre-check-in on any line** (§7.3), so this document is unaffected either way | Yes |
| **Explicitly absent** | Edger, FM2 stands, final take-up | Die blocks, FM1, live measurement, staging | Intermediate take-up (bypassed, not removed) |
| **Unresolved** | Whether a second take-up applies (§5.2.1) | Station names (`PLC-Q04`) · edger paths (`PLC-Q07`) · what clears the tags at end of spool (§13.2) | **The entire namespace** (`PLC-Q08`) |

---

# 3. The Rule That Governs Everything

> ### The machine is configured at exactly one moment.
>
> **PLC tags are pushed on one trigger and one trigger only: the operator's explicit acknowledgement of a pass schedule at check-in.**
>
> Never when a schedule is saved. Never when a schedule is loaded or viewed. Never when a schedule is generated from specifications or applied to a record. Never at pre-check-in, when a rod is staged on an idle payoff.

Section 9 is an elaboration of this rule, moment by moment; §7.3 is its negative form, stating what the system never writes under any condition.

---

# 4. Tag Naming Convention

Tag paths are **configuration, not code.** They are held in the application's environment configuration and read at startup, never compiled in — so a path found to be wrong at commissioning is corrected in a configuration file and an application-pool recycle, with no redeployment and no code change.

That property is what makes this section worth reading rather than skipping. **Confirming a convention is a far smaller task than confirming the ~60 individual strings the map publishes**, and a confirmed convention lets us publish the paths we do not yet have as concrete proposals instead of blanks.

## 4.1 The grammar `[PROPOSED]`

> ### ✅ The `PLC` element is the one part of this grammar that is no longer proposed — `D-46`, 5 Sep 2026.
>
> The first two flat wire tag paths actually read off a controller — `FL1.PLC._System._Error` and
> `FL2.PLC._System._Error`, supplied 5 Sep 2026 — both carry a **`PLC` segment after the line**, which
> nothing in this document's derivation had. The rest of the ecosystem agrees unanimously: all 313 of
> `UnifiedSlitterService`'s paths are `{Machine}.PLC.{…}` (`D72.PLC.LineSpeed`, `R48iQ.PLC.Running`),
> and `CoolingChamber` addresses `Cooling.PLC.CR.C{n}.NumberOfLoadsPresent`.
>
> So every path below gained the element. **This cost nothing but a values edit** — the 35 logical
> names in `TagNames.cs` did not move, and neither did any code — which is exactly what §4.2's R7 and
> the key/value decoupling in `[PLCC §2]` were designed to buy. It is also the first evidence
> **against** a derived path that `PLC-Q02` has ever produced, and it is worth reading as a warning:
> the remaining structure below is still derivation, not observation.


```
<tag>        ::= <line> "." <controller> "." <element> "." <measure>
               | <line> "." <controller> "." <scalar>

<line>       ::= "FL1" | "FL2" | "FL3"
<controller> ::= "PLC"

<element>    ::= <simple>
               | <assembly> "." <station>
               | <assembly> "." <station> "." <subunit>
<simple>     ::= "DB1" | "DB2" | "FM1" | "AGC"
               | "Payoff1" | "Payoff2" | "TKUP1" | "TKUP2"
<assembly>   ::= "FM2"
<station>    ::= "S1" | "S2" | "S3"
<subunit>    ::= "Edger"

<measure>    ::= <analogue> | "Status" "." <boolean> | <setting>
<analogue>   ::= "RollGap" | "Gauge" | "Width" | "Footage"
               | "Diameter" | "Weight"
<boolean>    ::= "IsActive" | "IsFaulted"
<setting>    ::= "EdgeType"

<scalar>     ::= "Speed" | "LineState" | "ITInhibit"
```

## 4.2 The rules

| # | Rule | Status |
|---|---|---|
| **R1** | Segments are separated by `.`, written in PascalCase, with no spaces or underscores | `[PROPOSED]` |
| **R2** | **The first segment is always the line, and the second is always `PLC`.** There is no plant-level tag — the run-block interlock is one tag per line, so a blocked line blocks only itself | `[PROPOSED]` — the `PLC` element is **`[CONFIRMED]`**, `D-46` |
| **R3** | An equipment tag is **the line, `PLC`, the element, and a measure** — four to seven segments, because the element may be an assembly, a station within it and a sub-unit of that station. A line-level scalar is the line, `PLC`, and the scalar | `[PROPOSED]` |
| **R4** | Booleans live under `Status.*` and carry an **`Is` prefix** — `Status.IsActive`, `Status.IsFaulted` | `[PROPOSED]` — `PLC-Q05` |
| **R5** | A multi-stand assembly interposes a station segment — `FM2.S2.…`. Single-instance equipment does not — `FM1.RollGap`. **The station segment applies to equipment *at* a station; equipment that sits *between* stations attaches to the assembly directly and takes an ordinal per R6** — which is how the dancers are addressed | `[PROPOSED]` — `PLC-Q17` |
| **R6** | Ordinal instances suffix the digit onto the element name — `DB1`, `Payoff2`, `TKUP1`. This is the rule for *"the nth instance of a thing"*; R5 is a different matter — an assembly's internal stations — and the two do not compete **Where two instances sit in a flow, the ordinal follows the material: `Dancer1` is upstream of `Dancer2`.** | `[PROPOSED]` — `PLC-Q17` |
| **R7** | **Units never appear in the path.** No measure names its unit, on any line | `[PROPOSED]` — `PLC-Q15` |
| **R8** | An analogue measure is a **single bare segment** — `RollGap`, `Gauge`, `Width`, `Footage`, `Diameter`, `Weight`. No unit, no qualifier group, no present-value suffix: **the tag *is* the present value.** So `FL1.PLC.DB1.Diameter` is the diameter of the die **fitted at DB1 now** — the machine holds no scheduled die to confuse it with | `[PROPOSED]` — `PLC-Q05` |

> ### `[CLIENT INPUT REQUIRED]` No tag states its unit, and that is the one item here that can produce scrap.
>
> R7 keeps units out of the path, which is the consistent choice — but it means **nothing in the tag surface declares what any value is measured in.** Gauge, width, roll gap and die diameter are *assumed* to be inches throughout this specification and throughout the application that displays them. A controller reporting gauge in **mils** or thousandths — entirely normal on a flattening line — would pass every structural check we are able to perform, push a plausible-looking roll gap, and produce out-of-specification wire. **`PLC-Q15`.**

**Why booleans keep a group segment and analogues do not.** The asymmetry is deliberate. `Status` names a *kind* of signal — a discrete condition of the equipment rather than a quantity — and so earns its place in the address. A present-value suffix, a unit and a qualifier each restate something the tag already says: a live tag on a physical die block reports the fitted equipment, at the present moment, in the machine's own unit, because there is nothing else it could report.

**Why `EdgeType` sits on the station, not on the edger subunit.** The `Edger` subunit exists for the tooling's own engagement state — `FM2.S2.Edger.Status.IsActive`, whether the physical attachment is in or out — because that is plausibly a distinct I/O point from the stand's own controls. `EdgeType` is different: it is **configuration of the station**, not a reading from the tooling, and the pass-schedule payload already carries it that way — as a field on the `FM2_S2` / `FM2_S3` component alongside `state` and `parameterValue`, not nested under a separate edger object. The tag mirrors that: `FL2.PLC.FM2.S2.EdgeType`, one segment, no `.Edger.` in between. If the controls engineer's actual wiring puts edge-type configuration on the tooling's own address block instead, that is a one-segment correction, not a redesign — but it is not the default assumption here.

**Because the grammar is regular, paths we do not have are derived rather than left blank.** The full `FL2.PLC.*` and `FL3.PLC.*` sets are published in Section 5 as `[PROPOSED]` derivations, so there is something concrete to correct rather than a gap to discover at commissioning.

## 4.3 FM2 station names `[CLIENT INPUT REQUIRED]`

FM2 has **three** stands, addressed by position: **`S1`** (8″ roller — stand *one*, not a pre-stage), **`S2`** (6″, edger position) and **`S3`** (6″, edger position, **final gauge control, non-bypassable**).

**The station segment carries position only.** Roll diameter is machine data, held against the stand record as `RollDiameterIn`, and is not part of an address — a diameter inside an identifier invites exactly the confusion that a position does not.

> **These three names require the controls engineer's confirmation — `PLC-Q04`.** Every FM2 row in §5.2.2 and §5.2.3 is `[PROPOSED]` until they are confirmed. **The stand count and the roller diameters are not in question**; only the station names are. Commissioning test **C11** records the station name the controller accepts.

---

# 5. The Read Surface — What the Application Subscribes To

## 5.1 Live data streams

The application subscribes to the machine and republishes to the operator screens. Expressed as streams rather than paths, this is what the screens require:

| Stream | Content | Required by |
|---|---|---|
| Gauge reading | Line, value, timestamp, footage position | Active run monitor traces · line status board · gauge-trace report |
| Width reading | Line, value, timestamp, footage position | Active run monitor traces · line status board · gauge-trace report |
| Line speed | Line, value, timestamp | Line status board · run monitor header · **the machine-stop prompt** |
| Payoff weight | Line, position, weight, percent remaining | Line status board · pre-check-in station · run monitor payoff bars · **the weld-readiness alerts** |
| Component status | Line, component, active flag, fault flag, current value | Run monitor component panel · **the component-fault alert** |
| Line state | Line, state | Line status badge · **the rod-checkout gate** · **the machine-stop prompt** |
| Footage counter | Line, footage, timestamp | Run monitor · spool progress · **die-life accumulation** |
| Remaining material | Line, position, remaining feet and derived weight, for the **active** input coil **and the next welded one** | Payoff bars and the weld alerts |

## 5.2 The tag map

**This is the list to confirm.** Each row carries either `[PROPOSED]` — the path follows the naming convention in Section 4 rather than a map anyone has verified — or `[CLIENT INPUT REQUIRED]`, where even the derivation is undetermined. A row may be settled on its *path* and open on its *values*, and says so.

> **Every row is `[PROPOSED]`, and that is the honest position.** The element and station names come from the equipment description; the measure names come from the convention (`PLC-Q05`, `PLC-Q17`). **No row in this table has been read off a machine** — that is `PLC-Q02`, and it is Critical. Confirming Section 4's eight rules is what converts this whole table at once, which is why the rules are presented first.

### 5.2.1 FL1 — rod line, standalone

| Tag path | Reads | Consumed by | Status |
|---|---|---|---|
| `FL1.PLC.DB1.Diameter` | Diameter of the die fitted at DB1 | Run monitor component panel | `[PROPOSED]` |
| `FL1.PLC.DB2.Diameter` | Diameter of the die fitted at DB2 | Run monitor component panel | `[PROPOSED]` |
| `FL1.PLC.DB1.Status.IsActive` | DB1 active or bypassed | Run monitor component panel · roll-adjust dialog (greys bypassed rows) | `[PROPOSED]` |
| `FL1.PLC.DB2.Status.IsActive` | DB2 active or bypassed | As DB1 | `[PROPOSED]` |
| `FL1.PLC.FM1.RollGap` | FM1 present roll gap | Run monitor component panel · **the roll-adjust dialog's *Current* column — whether that column is read back from the machine or is the last value the application wrote is itself unresolved, `PLC-Q09`** | `[PROPOSED]` |
| `FL1.PLC.FM1.Status.IsActive` | FM1 running | Run monitor component panel | `[PROPOSED]` |
| `FL1.PLC.FM1.Status.IsFaulted` | FM1 faulted | **Line status board — the Critical *component fault* alert** | `[PROPOSED]` |
| `FL1.PLC.AGC.Gauge` | Live gauge after FM1 | Run monitor gauge trace · line status board · gauge-trace report | `[PROPOSED]` |
| `FL1.PLC.AGC.Width` | Live width | Run monitor width trace · line status board · gauge-trace report | `[PROPOSED]` |
| `FL1.PLC.Speed` | Line speed | Line status board · run monitor header · **machine-stop prompt trigger** | `[PROPOSED]` |
| `FL1.PLC.Payoff1.Weight` | Payoff 1 load cell | Line status board · pre-check-in station · run monitor · **weld alerts at 3,000 lb and 2,000 lb** | `[PROPOSED]` |
| `FL1.PLC.Payoff2.Weight` | Payoff 2 load cell | As Payoff 1 | `[PROPOSED]` |
| `FL1.PLC.TKUP1.Footage` | Intermediate take-up footage counter | Run monitor · spool progress · **die-life accumulation** · every mid-run event's footage stamp | `[PROPOSED]` |
| **`FL1.PLC.FM1.Dancer.Status.IsActive`** | FM1's dancer active | Component panel | **`[PROPOSED]`** — no dancer path is on record (`PLC-Q18`) |
| **`FL1.PLC.FM1.Dancer.Position`** | Dancer arm position — the tension-compensation feedback | Run monitor (diagnostic) | **`[PROPOSED]`** — `PLC-Q18` |
| `FL1.PLC.LineState` | Machine run/stop state | **Rod-checkout gate** · **machine-stop prompt** · line status badge | `[PROPOSED]` path · **vocabulary `[CLIENT INPUT REQUIRED]` — see Section 6** |
| **`FL1.PLC.ITInhibit`** | The run-block interlock (**written**, not read — see Section 8) | System only | `[PROPOSED]` — line-scoped |
| **`FL1.PLC._System._Error`** | **The controller's system-error bit.** Not consumed by any screen — it is what `OPCConnection` requires in order to answer at all (see the note below) | `OPCConnection` only | ✅ **`[CONFIRMED]`** — supplied by the client, 5 Sep 2026 |

> **`[CLIENT INPUT REQUIRED]` Does FL1 address a second take-up?** FL1's flow ends at the intermediate take-up, and the final take-up belongs to FL2 and FL3 — so **`FL1.PLC.TKUP2.Footage` is deliberately absent** from the map above. Confirm that FL1 has one take-up and no second footage counter (`PLC-Q02`).

### 5.2.2 FL2 — finishing line, standalone

FL2 has **no die blocks, no FM1, and no live gauge or width measurement.** Its trace is the historical profile from the FL1 pass that produced the spool.

| Tag path | Reads | Consumed by | Status |
|---|---|---|---|
| `FL2.PLC.FM2.S1.RollGap` | **S1 (8″)** present roll gap | Component panel · roll-adjust *Current* column (`PLC-Q09`) | `[PROPOSED]` — station name per `PLC-Q04` |
| `FL2.PLC.FM2.S1.Status.IsActive` | S1 active or bypassed | Component panel · roll-adjust | `[PROPOSED]` — station name per `PLC-Q04` |
| `FL2.PLC.FM2.S2.RollGap` | **S2 (6″)** present roll gap | As above | `[PROPOSED]` — station name per `PLC-Q04` |
| `FL2.PLC.FM2.S2.Status.IsActive` | S2 active or bypassed | As above | `[PROPOSED]` — station name per `PLC-Q04` |
| `FL2.PLC.FM2.S3.RollGap` | **S3 (6″) — the final stand** | As above | `[PROPOSED]` — station name per `PLC-Q04` |
| `FL2.PLC.FM2.S3.Status.IsActive` | S3 active or bypassed | As above | `[PROPOSED]` — station name per `PLC-Q04` |
| **`FL2.PLC.FM2.S3.Status.IsFaulted`** | S3 faulted | Component-fault alert | **`[PROPOSED]`** — no fault path is on record for any FM2 stand |
| **`FL2.PLC.FM2.S2.Edger.Status.IsActive`** | **S2 edger active** | Component panel; edge configuration readback | **`[PROPOSED]` — no edger path is on record** |
| **`FL2.PLC.FM2.S3.Edger.Status.IsActive`** | **S3 edger active** | As above | **`[PROPOSED]`** |
| **`FL2.PLC.FM2.Dancer1.Status.IsActive`** | **Dancer 1 (between S1 and S2)** active | Component panel | **`[PROPOSED]`** — `PLC-Q18` |
| **`FL2.PLC.FM2.Dancer1.Position`** | Dancer 1 arm position | Run monitor (diagnostic) | **`[PROPOSED]`** — `PLC-Q18` |
| **`FL2.PLC.FM2.Dancer1.Mode`** | Dancer mode or tension mode — vocabulary in §5.5 | Component panel | **`[PROPOSED]`** — **read-only**; see §5.5 |
| **`FL2.PLC.FM2.Dancer1.Tension`** | Tension setpoint — **meaningful in tension mode only** | Component panel | **`[PROPOSED]`** — `PLC-Q18`; unit per `PLC-Q15` |
| **`FL2.PLC.FM2.Dancer2.Status.IsActive`** | **Dancer 2 (between S2 and S3)** active | As above | **`[PROPOSED]`** — `PLC-Q18` |
| **`FL2.PLC.FM2.Dancer2.Position`** | Dancer 2 arm position | As above | **`[PROPOSED]`** — `PLC-Q18` |
| **`FL2.PLC.FM2.Dancer2.Mode`** | As Dancer 1 | As above | **`[PROPOSED]`** — **read-only**; see §5.5 |
| **`FL2.PLC.FM2.Dancer2.Tension`** | As Dancer 1 | As above | **`[PROPOSED]`** — `PLC-Q18`; unit per `PLC-Q15` |
| `FL2.PLC.Speed` | Line speed | Line status board · run monitor header · machine-stop prompt | `[PROPOSED]` — derived |
| `FL2.PLC.Payoff1.Weight` | The spool payoff load cell. **This position is named the *traversing payoff* (TPO)** in the equipment register; `Payoff1` is the tag-namespace name for it | Line status board · run monitor | `[PROPOSED]` — derived |
| `FL2.PLC.TKUP2.Footage` | Final take-up footage counter. **TKUP-2 *is* the traversing take-up** — the two names are the same equipment | Run monitor · coil progress · every event's footage stamp | `[PROPOSED]` — derived |
| `FL2.PLC.LineState` | Machine run/stop state | Checkout gate · machine-stop prompt · status badge | `[PROPOSED]` — derived; vocabulary per Section 6 |
| **`FL2.PLC.ITInhibit`** | Run-block interlock (written) | System only | `[PROPOSED]` — line-scoped |
| **`FL2.PLC._System._Error`** | As FL1 | `OPCConnection` only | ✅ **`[CONFIRMED]`** — supplied by the client, 5 Sep 2026 |

> **Every FM2 stand is addressable, including the final one.** All three stands are reachable, so this map covers the whole mill. What is open on these rows is the **station naming** — §4.3 and **`PLC-Q04`** — not whether a stand can be reached. Separately, the **edger** paths at S2 and S3 have no source at all: that is **`PLC-Q07`**.

> ### ⚠ `G95` — without a system-error tag, the whole line is invisible, not just that one tag.
>
> `_System._Error` looks like a diagnostic nicety and is nothing of the kind. `OPCConnection` answers
> `GetOPCInfo` from `GetOPCServerAndTagDetails`, whose **first result set INNER JOINs `OPCTags`
> filtered `IsSystemErrorTag = 1`**. A line with no such row therefore returns **no `OPCInfo` at
> all** — no `MachineId`, no `ConnectionType`, no servers, and none of the other tags either.
>
> The failure is indistinguishable from the line never having been registered, which is exactly the
> symptom `G60` describes. Two rows, one per line, are what make every other row on this page
> reachable. They are not optional and they are not a data tag.
>
> ⚠ The same result set joins `CommonDB.Machines`, which filters `STATUS = 1`. A `machines` row in
> any other status disappears the same silent way.

> **Equipment aliases, so the map is not read as incomplete.** FL2's output take-up is called **TKUP-2** in the tag namespace and **the traversing take-up** in the equipment register — the same machine, mapped above. Its *input* is likewise the **traversing payoff (TPO)**, mapped as `Payoff1`. Separately, the data model carries a third material-position value named `TraversingTakeup`; that is a **vocabulary entry so FL2 can be represented alongside the two rod payoffs**, not evidence of a fourth untagged piece of equipment.

### 5.2.3 FL3 — hybrid, FL1 feeding FL2 continuously

FL3 runs both mills in one pass with the intermediate take-up bypassed. It therefore needs **the FL1 draw-and-FM1 set and the FL2 finishing set at the same time** — and how it addresses them is now settled.

> ### ✅ `PLC-Q08` IS ANSWERED — `D-47`, 5 Sep 2026. **FL3 has no controller of its own.**
>
> Of the two topologies this section used to hold open, **option 1 is the answer**: FM2 is owned by
> the FL2 controller, FM1 and the die blocks by the FL1 controller, and FL3 reaches both through
> **`FL1.PLC.*` and `FL2.PLC.*`**. There is no `FL3.PLC.*` namespace on any machine.
>
> **The consequence this section always warned about is now real, and it is owed a design.** A single
> FL3 acknowledgement **writes to two controllers**, so:
>
> - the push is **two** `WriteTag` batches, not one — §7.1's *"one acknowledgement pushes all FM1 and
>   FM2 tags in a single batch"* is **superseded** for FL3;
> - §7.5's compensating re-clear now spans **two failure domains**, and the case where the FL1 half
>   commits and the FL2 half fails has never been specified;
> - `ITInhibit` is one tag per line (§8.1), so blocking FL3 means setting **both**
>   `FL1.PLC.ITInhibit` **and** `FL2.PLC.ITInhibit`. Setting one blocks nothing.
>
> **That design is `G99`, and it is open.** Until it lands, FL3 is **not registered with
> `OPCConnection` at all** — deliberately — so `GetOPCInfo` answers an empty list for FL3 and an FL3
> push fails by name rather than half-configuring a line. The registration script asserts machine 127
> is absent.
>
> ⚠ **The commissioning test is still blind.** *"One acknowledgement configures FM1 and FM2"* passed
> under either topology, which is why this went unresolved so long. Under `D-47` it must be rewritten
> to prove **both** controllers were written and that a partial failure re-clears both.

The map below is the union of what FL3 uses. **The `FL3.PLC.*` paths in it are now historical** — they
record which measures the hybrid route needs, not addresses that exist. Read the left-hand column as
*"the FL1 or FL2 path for this measure"* until `G99` re-points them:

| Tag path | Reads | Consumed by | Status |
|---|---|---|---|
| `FL3.PLC.DB1.Diameter` · `FL3.PLC.DB2.Diameter` | Diameters of the fitted dies | Run monitor component panel | `[PROPOSED]` |
| `FL3.PLC.DB1.Status.IsActive` · `FL3.PLC.DB2.Status.IsActive` | Die blocks active or bypassed | Component panel · roll-adjust dialog | `[PROPOSED]` |
| `FL3.PLC.FM1.RollGap` · `.Status.IsActive` · `.Status.IsFaulted` | FM1 gap, running, faulted | Component panel · roll-adjust *Current* · **component-fault alert** | `[PROPOSED]` |
| `{FM2-prefix}.FM2.S1.*` · `.S2.*` · `.S3.*` | The **three** finishing stands, gap and status | Component panel · roll-adjust dialog | `[CLIENT INPUT REQUIRED]` — `PLC-Q08` |
| `{FM2-prefix}.FM2.S2.Edger.*` · `.S3.Edger.*` | The two edgers | Component panel; edge-configuration readback | `[PROPOSED]` — `PLC-Q07` |
| `FL3.PLC.AGC.Gauge` · `FL3.PLC.AGC.Width` | Live gauge and width — **FL3 is real-time** | Run monitor traces · line status board · gauge-trace report | `[PROPOSED]` |
| **`FL3.PLC.FM1.Dancer.Status.IsActive`** · **`.Position`** | FM1's dancer on the hybrid route | Component panel | **`[PROPOSED]`** — `PLC-Q18` |
| **`FL3.PLC.FM2.Dancer1.*`** · **`FL3.PLC.FM2.Dancer2.*`** | Both FM2 dancers — same four measures as §5.2.2 | Component panel | **`[PROPOSED]`** — `PLC-Q18`; **namespace per `PLC-Q08`** |
| `FL3.PLC.Speed` | Line speed | Line status board · run monitor header · **machine-stop prompt** | `[PROPOSED]` |
| `FL3.PLC.Payoff1.Weight` · `FL3.PLC.Payoff2.Weight` | Payoff load cells — FL3 feeds from rod, so both bays apply | Line status board · pre-check-in · run monitor · **weld alerts** | `[PROPOSED]` |
| `FL3.PLC.TKUP2.Footage` | Final take-up footage — the intermediate take-up is bypassed | Run monitor · coil progress · **die-life accumulation** · event footage stamps | `[PROPOSED]` |
| `FL3.PLC.LineState` | Machine run/stop state | **Rod-checkout gate** · **machine-stop prompt** · status badge | `[PROPOSED]`; vocabulary per Section 6 |
| `FL3.PLC.ITInhibit` | Run-block interlock (written) | System only | `[PROPOSED]` |

## 5.3 Sampling, publication and retention

| Aspect | Position |
|---|---|
| **Who subscribes** | The existing OPC integration service, extended to the three new lines. The OPC servers themselves are unchanged; the PLCs are new hardware. **No new integration layer is introduced.** |
| **Publication to screens** | Values are batched and republished to the browser on a configurable interval, default **1 second**, selectable at 5, 10 or 30 seconds. Rare state changes — a payoff becoming occupied, a line changing state — are sent immediately rather than waiting for a batch. |
| **Sample rate at the machine** | **Not specified.** How often the AGC publishes a gauge reading, and what end-to-end delay is acceptable between the machine measuring and the operator seeing it, are both undefined (`PLC-Q11`). |
| **Retention** | Raw gauge and width readings **are persisted** against the run, keyed by footage position — this is what makes FL2's historical profile and the gauge-trace report possible. How long they are kept, and whether they are rolled up after a period, is undecided and is a project-side item (Section 13.2). |
| **Feet consumption** | Sourced from the machine wherever available, continuously updating remaining feet and derived weight for **both the active input coil and the next welded one**. Unavailable or invalid feet data sets `ITInhibit` and prevents rolling. **The footage→weight conversion basis is undecided (`PLC-Q03`, Critical)** — every derived weight on the payoff bars, the weld alerts and the spool completion depends on it. |

## 5.4 What the surface lacks

Three gaps are properties of the surface itself rather than questions about it, and they are stated here so they are not discovered at commissioning:

1. **The edgers and the dancers have no observed path on any line.** Edge type is in the push payload (§7.2), and there is no tag to write it to or read it back from. The paths in §5.2.2 are our derivations. `PLC-Q07`.
2. **There is no take-up weight tag on any line** — yet the machine-stop prompt, the completion transaction and the printed label all use a wound weight, and assumption **A2** says load cells are fitted on both take-ups. Either the weight is derived, in which case `PLC-Q03` carries its accuracy, or two paths are missing. `PLC-Q14`.
3. **A fault bit is specified for one component only** — FM1. No FM2 stand has one on record (`FL2.PLC.FM2.S3.Status.IsFaulted` is our proposal), and neither do the die blocks, so **the line status board's Critical *component fault* alert cannot fire for any of them**. `PLC-Q02` establishes whether the machine exposes a fault bit per component.

Every other open question about this surface — the line-state vocabulary, FL3's namespace, units, the station and measure names — is in Section 13.1 rather than repeated here.

---

## 5.5 Dancer mode — the vocabulary `[CLIENT INPUT REQUIRED]`

`Dancer{n}.Mode` is neither a boolean nor a plain analogue, so it falls outside R4 and R8. It is an **enumeration**, and the one precedent on this surface is `LineState` — a bare segment whose permitted values are listed rather than inferred. It is specified the same way.

| Value | Meaning |
|---|---|
| `Dancer` | **Compensating speed control** — the dancer absorbs the speed mismatch between stands. The expected default |
| `Tension` | **Tension mode** — the dancer works to a tension setpoint, read from `Dancer{n}.Tension` |

**The literal strings the controller uses are unknown.** The two above are ours. Confirm them with the controls engineer alongside the paths (`PLC-Q18`); if the controller exposes the mode as an integer or a different pair of words, we follow the controller.

> **This surface is read-only, and that is deliberate.** Two client statements disagree about whether the mode is a **pass schedule parameter** that the system writes at check-in, or a **machine-side setting** it only observes — the 6 Aug call described two selectable modes, while the 23 Jul meeting recorded tension control as *"primarily machine-driven"*, set through process settings. **Read-only is the half that holds either way.** If the mode turns out to be written, it becomes a row in §7.2 — an addition, not a correction. The question is open as `Q65`, with the conflict recorded in [ClientCall_2026-07-23_SyncPlan.md](../95-archive/source-documents/ClientCall_2026-07-23_SyncPlan.md) §3.1.

---

# 6. Line State and Its Vocabulary

`FL{n}.PLC.LineState` is read on every line, and **what the controller reports through it is undocumented.** That makes it the single riskiest ambiguity in the interface, because two operator-facing behaviours are conditioned on values nobody has written down.

We are **not** guessing at them. **The machine-value-to-application-state mapping is published as configuration**, on exactly the same principle as the tag paths themselves — so the answer supplied at commissioning is applied without a code change, in the same file and by the same mechanism as a corrected path.

## 6.1 What depends on the answer

| Behaviour | What it needs |
|---|---|
| **The rod-checkout gate** | To know, unambiguously, whether the line is running — and to treat threading and jogging correctly rather than as "stopped" |
| **The spool-completion prompt** | To detect a genuine run-to-stop transition, and to distinguish it from a momentary slow-down |
| **The line status badge** | To show the operator a state that matches what the machine is doing |

A machine that reports *jogging* or *threading* as stopped changes the filtering both the checkout gate and the stop prompt need. That is why the vocabulary is asked for rather than assumed.

## 6.2 `[CLIENT INPUT REQUIRED]` — the table to complete

This is what we are asking the commissioning engineer to fill in, and it is a scheduled step of the commissioning sequence (test **C2**): drive the line through each condition and record the tag's value.

| Machine condition | Raw value of `FL{n}.PLC.LineState` | Maps to application state |
|---|---|---|
| Running at production speed | | Running |
| Stopped, ready | | Idle |
| Stopped, being set up | | Setup |
| Paused by the operator | | Paused |
| Faulted | | Fault |
| Threading | | *(to be decided — must **not** read as Idle)* |
| Jogging | | *(to be decided — must **not** read as Idle)* |
| Emergency-stopped | | *(to be decided)* |
| Controller unreachable | | Offline |

Two further values are needed alongside it:

- **The stop dwell** — how long a stop must persist before it is treated as real. **5 seconds is proposed**, corroborated by speed at approximately zero. This needs a number from someone who knows how the drives behave on slow-down (`PLC-Q13`).
- **Prompt suppression** — if the operator already paused in software and gave a reason, should the spool-completion prompt be suppressed because the reason is known? **Proposed yes**, unless the reason indicates spool removal (`PLC-Q16`).

---

# 7. The Write Surface — What the Application Writes to the Machine

## 7.1 The five write operations

| Operation | Trigger | Content written | Evidence recorded on |
|---|---|---|---|
| **Pass-schedule push** | **Only** on the operator's explicit acknowledgement at check-in. **Never** on schedule save, load, generation or apply, and **never at pre-check-in** | Component active/bypass state · DB1 and DB2 die sizes · FM1 and FM2 roll gaps · edge type · speed · gauge and width targets | The rod check-in record, or the spool check-in record at FL2 |
| **Payoff tag clear** | Rod checkout, **and only after the line is confirmed stopped** | Reset to idle and bypass defaults | The rod checkout record |
| **Single-component write** | Roll adjust *Apply* | The new roll gap, for each **changed** component only | The roll-override record |
| **Hold / idle** | Pause | Drive enable and speed to idle | The pause record |
| **Simulated push** | Development and all environments before commissioning | Logs the intended writes and **makes no machine connection** | The application log only |

> ### ⛔ For **FL3** this is now TWO batches, not one — `D-47`, 5 Sep 2026.
>
> This section used to say *"one acknowledgement pushes all FM1 and FM2 tags in a single batch"*,
> with `PLC-Q08` open on how many controllers that batch reached. **`PLC-Q08` is answered: FL3 has
> no controller of its own.** FM1 and the die blocks are the FL1 controller's; FM2 is the FL2
> controller's. So one FL3 acknowledgement writes to **two** controllers, in two batches.
>
> **The single-batch guarantee survives only for FL1 and FL2.** For those, one acknowledgement is
> still one `WriteTag` POST carrying N tags, and §7.5's compensating re-clear has one failure
> domain to undo.
>
> ⚠ **What FL3's push actually looks like — the ordering, whether the two batches are sequential or
> concurrent, and what a half-committed push leaves behind — is `G99` and is NOT specified here.**
> Until it is, FL3 is not registered with `OPCConnection` and an FL3 push fails by name rather than
> configuring one mill and not the other.

## 7.2 The push payload, item by item

| Value | Source | FL1 | FL2 | FL3 |
|---|---|---|---|---|
| Component active / bypass state | Pass schedule components | DB1, DB2, FM1 | The **three** FM2 stands. **S3 may never be bypassed** — it is the final gauge-control stand | All of them |
| Die sizes | Pass schedule | DB1, DB2 | — | DB1, DB2 |
| Roll gaps | Pass schedule | FM1 | **S1, S2, S3** | FM1 **and** all three FM2 stands |
| **Edge type** | Pass schedule | **Not applicable — FL1 has no edger** | S2 and S3 edgers | S2 and S3 edgers |
| **Speed** | Pass schedule | ✓ | ✓ | ✓ |
| Gauge and width targets | Pass schedule | ✓ | ✓ | ✓ |

> **`[PROPOSED]` Edge type is pushed on FL2 and FL3 and is not applicable on FL1.** This is inference rather than a settled rule — confirm at review (`PLC-Q07`), and note that **there is currently no edger tag to write it to** (§5.4).

> **`[CLIENT INPUT REQUIRED]` Is speed written as a target, or as a limit?** The requirement set says both, and **these are different tags with opposite failure modes.** A setpoint commands the drives to a speed, so acknowledging a check-in would start the line moving at the scheduled rate. A clamp bounds whatever speed the operator selects, so writing the scheduled value to it changes nothing until the operator opens up. If we write a setpoint where the machine expected a ceiling, a check-in starts a threading line at production speed (`PLC-Q06`).

## 7.3 What the system never writes

> ### Three prohibitions, all deliberate.
>
> **1. The application never sends a stop command.** Not on checkout, not on a failed checkpoint, not on any alert. **The operator stops the machine physically, always.** The application is a gatekeeper that reads the line's state and refuses to proceed; it is never an actuator that halts it.
>
> *One distinction, because §7.1 looks like an exception and is not.* On **operator-initiated pause** the system writes drive enable and speed to idle — that is the operator's own hold, executed through the interface they pressed, and it is reversed on resume. It is not the system deciding to stop the line. **No condition the system detects on its own — an out-of-spec reading, a failed checkpoint, an alert, a checkout request — ever halts the machine.**
>
> **2. No tag is written at pre-check-in.** Staging a rod on an idle payoff writes records and updates the station display. It configures nothing.
>
> **3. No tag is written when a pass schedule is created, edited, generated, approved or applied.** A schedule reaching the machine requires an operator to acknowledge it at check-in. Generating a draft from specifications writes to the schedule record and nowhere else.

## 7.4 Ordering — records before tags

The order of writes is mandatory and is not an implementation preference:

1. **Every audit record is written first** — the visual inspection result, the pre-run measurement, the schedule identity and version on the run record, and the acknowledgement itself.
2. **Then the tags are pushed.**

The reason is recoverability. If the push fails after the records exist, there is an incomplete-push marker to recover from and evidence of what was attempted. If the tags were pushed first and the records failed, the machine would be configured for a run that does not exist.

## 7.5 Failure — a compensating re-clear, not a rollback

> **Machine writes are not transactional, and this cannot be changed.**

If any single tag write in a push fails, the check-in is **aborted**: the tags already written are **re-cleared**, the shared material status is reverted, the queue entry is reversed, the run is marked aborted, and the check-in is reported as failed with the tags recorded as *not pushed*. The operator sees a failure and starts again; the machine is left in its prior state.

**That sequence is a compensating re-clear, not an atomic rollback**, and the distinction is not pedantry. An atomic rollback is a guarantee the infrastructure provides; a compensating re-clear is a series of ordinary writes that can themselves fail. Describing it as a rollback misleads implementers, and the check-in spans three systems — this application's database, the shared material and order schema, and the machine — no two of which share a transaction.

**The recovery path for the case where one of the three succeeds and another fails is a project-side open item** (Section 13.2).

> ### ⛔ On FL3 the machine is **two** failure domains, and that case is unwritten — `D-47` / `G99`.
>
> This paragraph used to make settling `PLC-Q08` a prerequisite *"because it determines whether the
> machine is one failure domain or two"*. It is settled, and the answer is **two**.
>
> Everything above is written for one machine write that either lands or does not. An FL3 push has
> **two**, to different controllers, and they can disagree:
>
> | Outcome | What is left behind |
> |---|---|
> | Both succeed | The intended state. |
> | Both fail | Re-clear both; equivalent to the single-controller case above. |
> | **FL1 lands, FL2 fails** | **Unspecified.** The draw boxes and FM1 are configured for a run the finishing mill is not, and the compensating re-clear must now reach a controller that already accepted its write. |
> | **FL2 lands, FL1 fails** | **Unspecified**, and the mirror image. |
>
> The re-clear is a series of ordinary writes that can themselves fail — that is this section's own
> point — and spanning two controllers doubles the ways it can. **`G99` owns this.** Until it is
> designed, FL3 is not registered and cannot reach either controller.

---

# 8. `ITInhibit` — The Run-Block Interlock

## 8.1 What it is, and who owns it

`ITInhibit` is a **system-controlled tag that blocks the machine from running** when the prerequisites for recording a run are not met. Its purpose is to make it impossible to produce material the system cannot account for.

**It is one tag per line** — `FL1.PLC.ITInhibit`, `FL2.PLC.ITInhibit` — so a line blocked from running blocks **only itself**. An idle FL1 with no rod checked in does not stop a scheduled FL2.

> **It is set and cleared only by the system. Never by an operator.**
>
> There is no operator path to clear it, and **there must not be one.** It clears when — and only when — the condition that set it resolves.

On FL3, whether the line carries its own `FL3.PLC.ITInhibit` or asserts FL1's and FL2's together follows from the namespace question, `PLC-Q08` — FL3 is the one line where a block legitimately implicates a second, the two being one physical thread of material.

## 8.2 The five set conditions

`ITInhibit` is set when **any** of the following is true:

1. **No coil or rod is checked in.**
2. **No active material-tracking identifier exists.**
3. **Feet data from the machine is unavailable.**
4. **Feet data from the machine is invalid.**
5. **Two or more consecutive data recordings are missing.**

Condition 5 additionally raises a prominent data-recording alert on the operator's screen, so the cause is visible rather than inferred.

> ⚠ **The client's own inhibit list shares exactly ONE of these five — raised 2 Sep 2026 as `G80`, and unresolved.**
> `Reason Codes.xlsx` (Tim O'Brien, 1 Sep 2026) supplies **eight** IT inhibit reasons for flat wire. Only condition 1
> above appears among them, as *"No Bundle/Spool is Checked In"*. **Conditions 2–5 are absent from the client's list
> entirely** — although feet-data and periodicity conditions *are* visible in the two live-machine screenshots the
> client attached to the same mail.
>
> **These five are not loose prose.** They are `FR-008` / `FR-009`, alternate flows `ALT002`–`ALT005` and `DAT009`, and
> **five P1 test cases, `TC-011`–`TC-015`**. `TC-###` and `FR-###` are never renumbered, so dropping four of them
> orphans two requirements and five P1 tests; adopting the client's eight as a *replacement* is therefore not available
> as a silent editorial choice.
>
> **What was done instead of choosing.** All twelve are seeded in `FlatWireDB.ItInhibitReason` with a `Source` column
> (`Client` / `PLC-8.2`), and the four spec-only conditions are seeded **`IsActive = 0`** — present, traceable,
> evaluated by nothing, deciding nothing. **This section is unchanged and still normative.** Ask the client directly
> whether conditions 2–5 still hold for the flattening lines.
>
> Two more from the same list, both recorded as gaps rather than absorbed here:
> **`No Qualified Operators Are Logged In`** presumes the Leadman/Operator/Helper qualification matrix, which does not
> exist (`G81`); and **`Supervisor Monitor`** is marked as applying while the same mail answers *"No"* to a dedicated
> Supervisor Monitor (`D-38`, `Q20`). A **`Call Supervisor`** action also appears on both real dialogs and in no
> requirement.

## 8.3 What happens while it is set

The machine is blocked from running, related transactions are blocked, and **no rolling data is recorded without an active coil.** The last clause is the point of the whole mechanism: unaccounted production is worse than no production.

## 8.4 Clearing

Automatic, on the condition resolving. In practice condition 2 is the most common cause after an interrupted transaction — a material-tracking identifier orphaned from its run will hold the interlock set until it is closed or re-associated, and the operational runbook carries a reconciliation step for exactly that case.

## 8.5 The identifier this depends on has no defined format

Condition 2 turns on an *"active material-tracking identifier"* whose **format has never been specified**, and whose relationship to the run identity is unresolved — whether the two are the same thing or separate identities is an open question. The interlock is specified against a concept that is not yet fully defined (`PLC-Q12`).

---

# 9. The Tag Lifecycle

## 9.1 At a glance

Sixteen moments, from staging a rod to rolling back a release. **Moments 1 and 2 write nothing, and that is a requirement rather than an omission** — both are verified by tests that instrument the machine-write path and assert zero writes. (Moments 9, 10 and 13 also write no tags, but incidentally rather than by rule.)

| # | Moment | Writes | Reads | Lines |
|---|---|---|---|---|
| 1 | Rod staged at pre-check-in | **Nothing** | — | FL1, FL3 |
| 2 | Pass schedule generated or applied | **Nothing** | — | All |
| 3 | Rod check-in acknowledged | **The push** — full payload to the selected payoff | — | FL1, FL3 |
| 4 | Spool check-in acknowledged | **The push** — finishing-mill payload | — | FL2 |
| 5 | Hybrid check-in acknowledged | **The push** — FM1 and FM2 in one batch | — | FL3 |
| 6 | Roll adjust applied | One write **per changed component** | Present roll gap | All |
| 7 | Run paused | Hold / idle | — | All |
| 8 | Run resumed | Tags restored | — | All |
| 9 | Die changed | Nothing directly | **Footage counter**, for die life | FL1, FL3 |
| 10 | Staged rod released before check-in | **Nothing to clear** | **No line-state gate needed** | FL1, FL3 |
| 11 | Rod checked out, no footage run | Payoff tags cleared | — | **FL1, FL3** |
| 12 | Rod checked out mid-run | Payoff tags cleared **after the gate** | **Line state as a gate**; footage locked | **FL1, FL3** |
| 13 | Spool reaches target and the line stops | Nothing | **Line state and speed**; the completion **weight** — source unconfirmed, `PLC-Q14` | All |
| 14 | Continuously, whenever prerequisites are unmet | **`ITInhibit`** | The five conditions | All |
| 15 | Commissioning | Simulated push switched to live | Every path, once | All |
| 16 | Release rollback | Configuration restored | — | All |

## 9.2 Before the run — nothing is written

**1 — A rod is staged at pre-check-in.** The operator scans the next rod onto the idle payoff while the current one runs, inspects it, and confirms. A staging record is written, the material's status and queue entry are updated, and the station broadcasts that the bay is now occupied. **No tag is written.** The machine is still configured for the rod that is running, and it must stay that way.

**2 — A pass schedule is generated or applied.** A schedule may be hand-authored or drafted by the generation engine from the product specification. Either way it requires Operations approval, and **approval is not configuration.** The generate-and-apply workflow writes to the schedule record and nowhere else.

Both of these are verified by tests that instrument the machine-write path and assert **zero writes**.

## 9.3 At check-in — the push

**3 — Rod check-in on FL1 or FL3.** The operator works through the guided check-in: visual inspection, pass-schedule confirmation, pre-run measurement, die block, rolling mill, lubrication and safety. Acknowledgement is unavailable until every gate clears.

The sequence on acknowledgement is fixed:

```
Operator confirms the pass schedule  (the confirm bar turns green)
        │
        ▼
All audit records committed          (inspection · pre-run measurement ·
        │                            schedule ID and version on the run ·
        │                            the acknowledgement event)
        ▼
Tags pushed to the selected payoff   (components · die sizes · FM1 gap ·
        │                            edge type · speed · gauge/width targets)
        ▼
Run opens · timer starts · the line status board flips to RUNNING
```

**Confirming the schedule is the gate, not pressing the button.** A schedule that has been loaded and displayed but not explicitly confirmed cannot be acknowledged, and a check-in attempted in that state writes no tags at all.

If the push fails at any tag, the whole check-in aborts per §7.5.

**4 — Spool check-in on FL2.** The FL2 operator scans the spool, reviews the historical profile from the FL1 pass that produced it, and acknowledges against the same confirmation gate. The payload is the finishing mill only — **the three FM2 stands and the two edgers, with no die blocks and no FM1** — and there is no visual inspection step.

**5 — Hybrid check-in on FL3.** ⛔ **This test cannot be run as written, and could never have distinguished the two topologies it was meant to prove** — *"one acknowledgement configures FM1 and FM2"* passes whether the batch reaches one controller or two, which is how `PLC-Q08` stayed open so long. `D-47` settles it at **two**, so the test must be rewritten to assert that **both** controllers were written and that a partial failure re-clears both (`G99`). Until then FL3 is not registered and this scenario is **blocked, not merely pending**. *(Original text: one acknowledgement, at the rod end, configures both mills in a single batch.)* There is no intermediate spool and therefore no second check-in. A failure anywhere in the batch aborts the whole check-in.

## 9.4 During the run

**6 — Roll adjust.** The operator adjusts one or more roll gaps mid-run, with a measured gauge and width and a reason. On *Apply*, the override is recorded, **one tag write is issued per changed component**, and a measurement is logged at the current footage. An adjustment whose deltas are all zero writes nothing at all.

This is a **run-level override. It never edits the pass schedule.** The schedule remains the record of what was configured at check-in; the override records what was changed afterwards and at what footage.

> A configuration change saved by a supervisor from elsewhere does **not** take effect silently: the line keeps running on **the previous values** until the operator on the line acknowledges the change. The tag write follows the acknowledgement, not the save.

**7 — Pause.** The operator pauses with a reason from a governed list. The run timer pauses, **the footage counter freezes and its position is recorded**, and the tags go to a hold or idle state. The line status board shows PAUSED with the reason visible to the supervisor.

**8 — Resume.** Tags are restored and the run continues. Resume has four outcomes — resume, reject the material, stay paused, or check the rod out — and only the first restores the tags.

**9 — Die change.** Selecting the die blocks and scanning the incoming die records the change and creates a linked roll override; **the tag effect arrives through that override rather than from the die change itself.** The die change *reads* the footage counter, because cumulative footage per die is how die life is tracked — on a mid-run swap, accumulation closes on the outgoing die and a new counter starts on the incoming one. **No new sensor is required for this.**

A die change for gauge drift or a size change requires a measurement checkpoint to pass before full production resumes; thread mode is permitted in the interim.

## 9.5 Ending the run

**10 — A staged rod is released before check-in.** The rod was never checked in, so **there is no acknowledgement to void and no tags to clear** — and, unlike the two checkout modes below, **no line-state gate is needed**, because an idle bay is not running. A rod that has already been welded to the running rod is a different matter and requires supervisor authorisation.

**11 — Checkout with no footage run.** The acknowledgement is voided, **the payoff tags are cleared**, and the line goes idle.

**12 — Checkout mid-run.** This is the most constrained moment in the interface.

```
Operator requests checkout
        │
        ▼
Application READS the line-state tag ─── reports Running? ──► BLOCKED
        │                                "Line is still running. Stop the
        │                                 line before checking out the rod."
        ▼
Dialog opens · the footage counter is READ AND LOCKED at this instant
        │
        ▼
Operator completes the form and confirms
        │
        ▼
Line state is READ AGAIN and re-checked
        │
        ▼
Run closed · material held pending disposition · PAYOFF TAGS CLEARED
```

Three properties of this flow are load-bearing:

- **The line state is read twice** — before the dialog opens and again before the confirmation is accepted. A line that starts running between the two is caught.
- **The footage counter is locked when the dialog opens**, so the recorded footage is final and does not drift while the operator fills in the form.
- **No stop command is ever sent.** The operator stops the line. This is verified by instrumenting the machine-write path across every checkout path and asserting zero stop commands.

**13 — The spool reaches target and the line stops.** When the wound weight reaches target and the machine reports a run-to-stop transition **held for a configurable dwell**, the operator is asked whether the stop was to remove the completed spool. The weight is **latched at the machine's stop timestamp** — that latched value is what the prompt shows, what the completion records and what the label prints.

> **`[CLIENT INPUT REQUIRED]` Where that weight comes from is unconfirmed — and this interface publishes no tag for it.** The spool completion specification says it is **derived** from the live footage counter and the measured cross-section; assumption **A2** in §14 says **load cells are fitted on both take-ups**. Both cannot be the primary source, and **there is no take-up weight tag on any line in §5.2**. If it is derived, its accuracy rests entirely on `PLC-Q03` (the footage-to-weight dimensional basis). If it is read, two paths are missing from the map before commissioning test **C9** can pass (`PLC-Q14`).

This behaviour depends entirely on the line-state vocabulary, which is undocumented. See Section 6.

## 9.6 Always on

**14 — `ITInhibit`.** Section 8.

## 9.7 Outside the run

**15 — Commissioning.** The simulated push is switched to live and every path is exercised once. Section 12.

**16 — Release rollback.** Tag paths are configuration, so rolling back a release restores a configuration file and recycles the integration service. **Nothing is lost on the machine side** — the paths return to the previous map. Rolling back the application itself is different: a check-in interrupted mid-sequence may have left records without tags, **or tags without records**, and that case is reconciled by hand against the audit log.

---

# 10. Configuration and Simulation

## 10.1 Every path is configuration

> **No tag path is compiled into the application.** All of them are read from environment configuration at startup.

This is a deliberate design property with one purpose: **a wrong path found at commissioning is a configuration edit and a service recycle — not a code change, not a build, not a redeployment.** Commissioning is a scheduled window on a physical line with several people present; it cannot absorb a development cycle.

The same applies to the line-state mapping, whose **table is §6.2**.

## 10.2 Simulation until commissioning

| Setting | Value before commissioning | Value after |
|---|---|---|
| **Simulated push** | **On, in every environment** | Off |
| Machine writes | Logged as intended writes, **no connection made** | Real writes to the real controller |
| Machine reads | A mock stream supplies gauge, width, speed, weight and footage at the configured cadence | Live subscription |
| Line state | A test double the harness drives | The real tag, **whose vocabulary is documented at C2** |

**The switch from simulated to live is the commissioning event.** Until it happens the operator screens are fully testable and the interface is entirely unproven — those two facts are both true, and Section 12 exists because of the second one.

## 10.3 What cannot be proven before commissioning

- That the configured paths are correct.
- That the line-state tag reports the states the checkout gate and the stop prompt depend on.
- That the footage counter increments correctly and that die life reads it.
- **That a tag push actually configures the machine** — the end of the chain the whole system exists to drive.
- That `ITInhibit` genuinely blocks the machine from running.

## 10.4 Rollback

Restoring the previous configuration and recycling the integration service returns the tag map to its prior state, and **nothing is lost** — it is configuration only. Rolling back the application is a different matter: see moment 16 in §9.7.

---

# 11. Audit and Evidence

## 11.1 Every machine write is logged

> **Every tag write and every tag clear is recorded with: the tag path · the value · the operator · the timestamp · the result.**

No exceptions, including simulated writes, which log the write they would have made. A failed write is escalated on sight. **There is no such thing as a routine one:** a failed push aborts a check-in outright, and a failed clear, per-component write or hold leaves the machine configured differently from the record that describes it.

## 11.2 What is recorded on the transaction

Beyond the log, each write leaves a durable flag on the record it belongs to, so the state of the machine at any past moment can be reconstructed from the transaction rather than from log retention:

| Moment | Recorded on |
|---|---|
| Pass-schedule push at rod check-in | The rod check-in record — whether tags were pushed |
| Pass-schedule push at spool check-in | The spool check-in record — whether tags were pushed |
| Roll adjust | The roll-override record — whether the tag was written, per component |
| Rod checkout | The checkout record — whether tags were cleared. **Constrained to *not cleared* for a rod released before check-in**, where there was nothing to clear |

## 11.3 What a reviewer can establish afterwards

For any run: which pass schedule configured it, at which version, who acknowledged it and when, every value pushed and the result of each write, every mid-run adjustment with its measured readings and reason, and whether the tags were cleared at the end and after what confirmation.

Supervisor authorisations are logged with **who, when and why** — badge or identifier, timestamp, station and line, the old and new values, and a reason code or free text. Where a supervisor authorises by PIN, **the PIN authenticates only: it is never carried in the transaction and never stored.**

---

# 12. Commissioning

> **This section is reproduced from the project test plan so that it can be read alongside the tag map it proves. The test plan remains authoritative for the pass criteria.**

## 12.1 Safety preconditions

- The line is under the commissioning engineer's control, **not production control**.
- Area clear, guards in place, emergency stop verified.
- **No production order is loaded. Test material only.**
- **Everyone present knows the application never sends a stop command** — the operator stops the machine physically.

## 12.2 Who must be present

The commissioning engineer · Engineering as the tag map owner · one line operator · one developer with configuration write access · one person recording results.

## 12.3 The sequence

| # | Test | Method | Pass criterion | Closes |
|---|---|---|---|---|
| **C1** | Tag paths resolve | Read every configured path in turn, **recording the string the controller accepted for each** | Every path resolves. **A wrong path is corrected in configuration — no redeployment** | `PLC-Q02` · `PLC-Q05` · `PLC-Q17` |
| **C2** | Line-state vocabulary | Drive the line through run, stop, pause, fault, thread and jog, recording the tag value at each | **The observed vocabulary is documented** and the §6.2 table is complete | `PLC-Q01` |
| **C3** | Footage counter | Run a measured length | The counter matches within tolerance | — |
| **C4** | A push configures the machine | Acknowledge a pass schedule at check-in | Component states, die sizes, roll gaps, edge type and targets **all take effect on the machine** | — |
| **C5** | Single-batch push on FL3 | Acknowledge a hybrid check-in | **One** acknowledgement configures FM1 **and** FM2. **Record which controller(s) were written** † | `PLC-Q08` |
| **C6** | Tag clear on checkout | Stop the line, check the rod out | Tags cleared **only after the confirmed stop**; the payoff assignment cleared | — |
| **C7** | `ITInhibit` blocks the run | Set each of the five conditions in turn, **on one line at a time** | The machine is **blocked** in each case and clears only when the condition resolves — **and the other two lines still run** | — |
| **C8** | Machine data reaches the screen | Run at speed | Gauge and width stream at the configured cadence, **and the end-to-end latency is measured and recorded** | `PLC-Q11` |
| **C9** | Stop-confirmation edge | Run to target weight, stop, hold past the dwell | The prompt fires once; the weight is latched at the stop timestamp | `PLC-Q13` |
| **C10** | Checkout gate | Attempt a checkout with the line running | Blocked with the specified message, and **no stop command observed on the wire** | `PLC-Q10` |
| **C11** | FM2 station names and the three-stand set | Read the gap and status of each of the three FM2 stands, **recording the path string the controller actually accepted** | **Exactly three FM2 stands respond**, and the accepted station names are recorded. **A fourth stand must not respond** | `PLC-Q04` |
| **C12** | **The dancers** — one on FM1, two on FM2 | Read every dancer path in turn, **recording the string the controller actually accepted**, and read `Mode` on each FM2 dancer against the §5.5 vocabulary. Confirm which physical dancer answers to `Dancer1`. | Every path resolves; `Dancer1` is the **upstream** dancer; each `Mode` returns one of the two published values | **Severity 1** — a wrong path fails silently (§1.3) |

† C5 records which controller(s) were written, because without that step it passes whether the FL3 batch reaches one controller or two and so cannot settle `PLC-Q08`.

**Most of the register is not closed by commissioning.** Only `PLC-Q01`, `PLC-Q02`, `PLC-Q04`, `PLC-Q05`, `PLC-Q08`, `PLC-Q10`, `PLC-Q11`, `PLC-Q13` and `PLC-Q17` have a test above that closes them — and `PLC-Q02`, `PLC-Q05` and `PLC-Q17` close together at **C1**, because reading a path back is what proves the convention that generated it. **Two must be answered *before* the sequence runs**, because the tests are written assuming an answer: `PLC-Q06` (is speed a target or a limit — C4 would push the wrong kind of value) and `PLC-Q07` (the edger paths — C4 cannot verify an edge configuration with no tag to read back). `PLC-Q15` (units) is answered as a by-product of C1 and C3.

## 12.4 Abort criteria

Abort and reconvene if **any** of the following occurs: a tag write produces unexpected machine motion · `ITInhibit` fails to block the run · the footage counter is wrong by more than the agreed tolerance · any safety precondition lapses.

## 12.5 Severity and the go-live gate

Three outcomes are classified **Severity 1 — Critical**, fixed immediately and blocking the release: **a push that configures the wrong values**, **`ITInhibit` failing to block**, and **a checkout permitted while the line runs**.

Go-live requires a rehearsed rollback and a **green commissioning sequence**.

---

# 13. Open Items

## 13.1 Requiring client input

Numbered in priority order. Every row carries the identifier it is tracked under elsewhere. This is the list reproduced on the sign-off sheet.

| # | Question | What it blocks | Also tracked as | Priority |
|---|---|---|---|---|
| **`PLC-Q01`** | **The line-state vocabulary** — what values `FL{n}.PLC.LineState` can take (§6.2) | The rod-checkout gate, the spool-completion prompt and the line status badge | `Q21` / `OI-35` | **Critical** |
| **`PLC-Q02`** | **Confirmation of every tag path in Section 5.** They follow the naming convention in Section 4, not a verified map, and none has been read off a controller | The entire interface, before go-live. Commissioning test **C1** has no confirmed list to read from until this closes | *this document* | **Critical** |
| **`PLC-Q03`** | **The dimensional basis for converting footage to weight** — target dimensions, measured at completion, or integrated over the recorded readings | Output weight, spool completion, the weld alerts | `Q10` / `OI-45` | **Critical** |
| **`PLC-Q04`** | **Confirm the FM2 station names** — `S1`, `S2`, `S3`, carrying position only (§4.3). Every FM2 row in §5.2.2 is `[PROPOSED]` until this is answered. **The stand count and the roller diameters are not in question** — only the station names | Every FM2 read subscription and every FM2 write. Commissioning tests **C1** and **C11** | `G32` | **Critical** |
| **`PLC-Q05`** | **Confirm every measure name in §5.2** — `RollGap`, `Gauge`, `Width`, `Footage`, `Diameter`, `Weight`, `Status.IsActive`, `Status.IsFaulted`, and the unit-free scalars `Speed` and `LineState`. These follow rules R4, R7 and R8; **none has been read off a controller**, and they are **the largest single block of unconfirmed strings in this document** | Every read subscription and every write, on all three lines. If the measure names are wrong, **commissioning test C1 fails across the whole map rather than on isolated rows** | `G33` | **Critical** |
| **`PLC-Q06`** | **Is speed pushed as a target/setpoint or a limit/clamp?** (§7.2) | The push payload, and what a check-in does to a stationary line | `Q27` | High |
| **`PLC-Q07`** | **Is edge type pushed, and where are the edger tag paths?** No edger path is on record for any line | The FL2/FL3 edge configuration and its readback | `Q28` / `G29` | High |
| **`PLC-Q08`** | **On FL3, are the finishing stands addressed as `FL2.PLC.FM2.*` or `FL3.PLC.FM2.*`?** (§5.2.3) | Whether the single-batch push crosses a controller boundary, what recovery must undo, and whether FL3 carries its own interlock | `Q29` / `G30` | High |
| **`PLC-Q09`** | **Is the roll gap read back from the machine before a run starts?** Three options are open, and the currently implied design has **no readback at all** | Whether a run can start on gaps that were never verified | `Q1` / `OI-52` | High |
| **`PLC-Q10`** | **Confirm the checkout tag behaviour** — never send a stop, clear only when confirmed stopped, block while running | The checkout build | `Q13` / `OI-54` | High |
| **`PLC-Q11`** | **The machine's publish rate and the acceptable end-to-end latency** | The real-time design's acceptance criteria | `G9` / `OI-34` | High |
| **`PLC-Q12`** | **The format and lifetime of the material-tracking identifier** that `ITInhibit`'s second condition depends on | The interlock, and check-in | `OI-03` | High |
| **`PLC-Q13`** | **The stop dwell** before the spool prompt fires. 5 seconds proposed | The spool-completion prompt | `Q21` / `OI-35` | High |
| **`PLC-Q14`** | **Do take-up load cells exist, and is the spool-completion weight read from them or derived** from footage × cross-section? Assumption A2 and the spool completion specification disagree, and §5.2 publishes no take-up weight path | The machine-stop prompt, the completion transaction and the **printed label**. Commissioning test **C9**. Coupled to `PLC-Q03` | `Q30` | High |
| **`PLC-Q15`** | **What unit is each value in?** No tag names a unit (R7), and inches are assumed everywhere without ever being stated. **A controller reporting gauge in mils would pass every check we can perform and produce scrap** | Every displayed dimension, and the roll gaps computed from them | *this document* | High |
| **`PLC-Q16`** | **Should the stop prompt be suppressed** when a software pause already captured a reason? Proposed yes | The spool-completion prompt | `Q21` / `OI-35` | Medium |
| **`PLC-Q17`** | **Confirm the two structural rules** — **R6**, that an ordinal instance suffixes its digit onto the element name (`DB1`, `Payoff2`, `TKUP1`), and **R5**, that an assembly's internal stations take a station segment (`FM2.S2`) | Deriving any path that is still missing, which is the whole economy of confirming a grammar | *this document* | Medium |
| **`PLC-Q18`** | **Confirm the dancer element** — the paths, the **ordinal convention** (`Dancer1` upstream of `Dancer2`, per R5/R6), and the **`Mode` vocabulary** of §5.5. FM1 carries one dancer and FM2 two, between S1/S2 and S2/S3; the equipment is confirmed (`D-28`) but **no dancer path has been read off a controller**. Also: **does FM1's dancer have selectable modes?** Modes were attributed to FM2 only, and we have not assumed either way | The dancer element in §5.2.1–§5.2.3 and §5.5 | **C12** |
| **`PLC-Q19`** | **Confirm the jog, stand-roll and dancer-thread read surface** disclosed by the client on 1 Sep 2026: *"we will have jog events on **all three stands of FL2**, as well as **open/close on stand rolls**, and **thread position on dancers**"*. **None of the three has a path in any published map.** Jog and threading being real machine states also bears on `Q21`, which asks whether `FL{n}.PLC.LineState` is a two-state bit or distinguishes `THREADING` / `JOG` — a jog that reports as STOPPED changes the filtering the checkout gatekeeper needs. ⚠ The **thread position** element is a *second* dancer read, beyond `PLC-Q18`'s mode element | A new jog / roll-state / dancer-position element; `FL{n}.PLC.LineState` vocabulary | **C11** |

## 13.2 Project-owned — not client input

Listed for completeness, so the sign-off sheet is honest about what is ours to settle rather than yours.

| Item | What it is |
|---|---|
| Cross-system recovery path | Check-in spans this application's database, the shared material schema and the machine. The recovery path when one succeeds and another fails is undefined and must be settled before the check-in build. `PLC-Q08` is a prerequisite |
| Which lines expose roll adjust | Stated inconsistently, and it determines which lines can write a tag mid-run |
| Footage coordinate systems | Run-cumulative footage and coil-local footage are both in use, with no stated conversion |
| Reading retention | How long raw gauge and width readings are kept, and whether they are rolled up |
| Consumer confirmation | The roll-gap and component-status tags, whose consumer is to be confirmed against the run monitor's component panel and the roll-adjust dialog before we commit to subscribing to them |
| **What clears FL2's tags at end of spool** | Rod checkout is FL1/FL3 only, and the rod checkout specification puts spool and coil completion out of scope. No document states the FL2 equivalent, so §9.5 describes a tag clear this interface cannot currently point at. **Specify it before the FL2 build** |
| Supervisor approval durability | A mid-run checkout approval currently relies on a live connection to a supervisor |

---

# 14. Assumptions

| # | Assumption |
|---|---|
| A1 | Every value in Section 5 is readable from the machine controller and can be published continuously, per line. |
| A2 | **Load cells are fitted on both payoff positions and on both take-ups.** *(**Nothing in this interface currently reads the take-up load cells** — §5.2 publishes no take-up weight path on any line, and the spool completion specification derives the weight from footage instead. Confirm as `PLC-Q14`.)* |
| A3 | Gauge and width are measured live on FL1 and FL3. **FL2 has no live measurement** — its trace is the recorded profile from the FL1 pass that produced the spool. |
| A4 | The machine accepts the full tag set in **one push**. There is no partial-configuration mode. |
| A5 | Each line presents **one OPC namespace**, and the OPC servers are unchanged from those in service today. |
| A6 | Historical readings are retained long enough to serve the shift and custom reporting windows. |

---

# 15. Related Specifications

| Document | Relationship |
|---|---|
| [Rod Check-in](../10-requirements/screens/RocCheckin.md) | The acknowledgement that triggers the push, and the ordering of records before tags |
| [Rod Pre-Check-in](../10-requirements/screens/RodPreCheckin.md) | Staging, where **no tag is written** |
| [Rod Checkout](../10-requirements/screens/RodCheckout.md) | The line-state gate, the locked footage counter, and the tag clear |
| [Spool Completion](../10-requirements/screens/SpoolCompletionNotification.md) | The machine-stop prompt, which depends on the line-state vocabulary |
| [Pass Schedule Management](../10-requirements/screens/PassScheduleManagement.md) | The record whose contents are pushed, and the rule that approving it configures nothing |
| [Pass Schedule Generation](../10-requirements/screens/PassScheduleGenerationSpec.md) | How a schedule's values are derived — and why generation writes no tags |
| [Line Status Overview](../10-requirements/screens/LineStatusOverview.md) | The board that consumes line state, speed, gauge, width, payoff weight and the component-fault signal |
| [Die Change and Die Management](../10-requirements/screens/DieChangeAndManagement.md) | Die-life accumulation from the footage counter |
| [SPC Checkpoint](../10-requirements/screens/SPCCheckpoint.md) | The measurement checkpoints a die change and a roll adjust require |

---

# Client Sign-off

## Part A — Rules for confirmation

| Ref | Item | Accept | Amend |
|---|---|:--:|:--:|
| §2 | The equipment flow per line and the per-line differences — what each line has, what it pushes, and what it explicitly does not, including **FL1 having no edger** and **FL2 having no live measurement** | ☐ | ☐ |
| §3 | Tags are pushed on **one trigger only** — acknowledgement at check-in | ☐ | ☐ |
| §4.1–4.2 | The tag naming convention and rules R1–R8 | ☐ | ☐ |
| §4.3 | FM2's station names — `S1`, `S2`, `S3`, carrying position only | ☐ | ☐ |
| §5.2.1 | The FL1 tag map | ☐ | ☐ |
| §5.2.2 | The FL2 tag map | ☐ | ☐ |
| §5.2.3 | The FL3 tag map | ☐ | ☐ |
| §6 | Publishing the line-state mapping as **configuration** | ☐ | ☐ |
| §7.1 | The five write operations and their triggers | ☐ | ☐ |
| §7.2 | The push payload per line, including **edge type on FL2/FL3 only** | ☐ | ☐ |
| §7.3 | The three prohibitions — **never a stop command**, never at pre-check-in, never on schedule save or generate | ☐ | ☐ |
| §7.4 | Records are written **before** tags are pushed | ☐ | ☐ |
| §8 | The five `ITInhibit` conditions, that it is **one tag per line**, and that it clears **only** automatically | ☐ | ☐ |
| §9 | The tag lifecycle, all sixteen moments | ☐ | ☐ |
| §10.2 | Simulated writes in every environment **until commissioning** | ☐ | ☐ |
| §11 | What is audited: every tag write and clear logged with path, value, operator, timestamp and result — and that **a supervisor PIN is never stored** | ☐ | ☐ |
| §12.3 | The commissioning sequence C1–C12 | ☐ | ☐ |

## Part B — Information required

| Ref | Item | Owner | Supplied |
|---|---|---|:--:|
| **`PLC-Q01`** | The line-state vocabulary — **the §6.2 table** | | ☐ |
| **`PLC-Q02`** | **Confirmation of every tag path in Section 5** | | ☐ |
| **`PLC-Q03`** | The dimensional basis for footage-to-weight | | ☐ |
| **`PLC-Q04`** | **The FM2 station names** — `S1`/`S2`/`S3` (§4.3) | | ☐ |
| **`PLC-Q05`** | **Every measure name in §5.2** — `RollGap`, `Gauge`, `Width`, `Footage`, `Diameter`, `Weight`, `Status.IsActive`, `Status.IsFaulted`, `Speed`, `LineState` | | ☐ |
| `PLC-Q06` | Speed — target/setpoint or limit/clamp | | ☐ |
| `PLC-Q07` | Edge type push, and the edger tag paths | | ☐ |
| `PLC-Q08` | FL3's finishing-stand namespace | | ☐ |
| `PLC-Q09` | Roll-gap readback before run start | | ☐ |
| `PLC-Q10` | Confirmation of the checkout tag behaviour | | ☐ |
| `PLC-Q11` | Machine publish rate and acceptable latency | | ☐ |
| `PLC-Q12` | Material-tracking identifier format and lifetime | | ☐ |
| `PLC-Q13` | The stop dwell before the spool prompt | | ☐ |
| `PLC-Q14` | Take-up load cells, and whether the completion weight is read or derived | | ☐ |
| `PLC-Q15` | The unit each value is reported in | | ☐ |
| `PLC-Q16` | Stop-prompt suppression after a software pause | | ☐ |
| `PLC-Q17` | The two structural rules — R6 ordinals, R5 assembly stations | | ☐ |
| `PLC-Q18` | The dancer paths, the `Dancer1`-is-upstream convention, and the `Mode` vocabulary | | ☐ |
| `PLC-Q19` | Jog on all three FL2 stands, open/close on stand rolls, dancer thread position — and whether `LineState` distinguishes JOG/THREADING | | ☐ |

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **Operations** | | | |
| **Engineering / Controls** | | | |
| **IT** | | | |
