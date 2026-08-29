# Flat Wire Mill — Open Questions Register

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 24, 2026 — **`Q87` added: the FL2 finished-coil label, and whether a coil built from two source rods prints one alpha or two.** Raised by us on the 24 Aug client call and deferred by UA the same day — *“we're going to have to figure out what the labeling is going to look like.”* It is the missing third member of the labelling set: **`Q44`** is the FL1 spool label, **`Q4`** is the skid, and the finished coil the customer receives had no owner. **`Q26`** also advanced without closing — the 1920×1080 requirement is now with Tim and Charles in writing. *(previously August 23, 2026 — **the `Spool` article registry is seeded at its real size: 45 rows, `SP-0001`…`SP-0045`** (44 active + `SP-0045` withdrawn), replacing four placeholder rows. **Four digits, not five, per `OQ-K`** — five would make a carrier number string-identical to a `SpoolProcessing.Alpha`. Seed-row total 210 → **251**; table/FK/index counts unchanged. `Q42` stays **open** on the format and on 30-vs-45. *(previously August 23, 2026 — **`Spool` and `SpoolCarrier` are SWAPPED (`Q60`).** The reusable stencilled article is now **`Spool`** in `01_Lookup`; the material record is now **`SpoolProcessing`** in `03_Materials`; `CarrierNo` → `SpoolNo`. ⚠ **A stale `Spool` reference is now *silently wrong*, not obviously stale** — see `[DBD §6.2a]`, the naming convention this closed. Object counts…)*)*

**Scope:** MVP-1
**Open Questions:** 57 · **Shopfloor scope:** 50
**Status Legend:** `Open` — every question in this register is open
**Recommendations:** every question carries one except `Q10` — **our proposed answer, not a decision**
**Scope Legend:** `Shopfloor` — Flat Wire Mill shopfloor changes · `Other` — adjacent modules
**Answered questions:** [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) — 25 decisions with their answers

> Questions marked **Critical** must be resolved before development begins on the dependent module.
> Questions marked **High** must be resolved before UAT (late September 2026).
> Questions marked **Medium** must be resolved before production go-live (fourth quarter 2026).
> Questions marked **Low** can be resolved post go-live.

---

## Shopfloor Scope — Filtered Index

**50 of the 57 open questions relate to Flat Wire Mill shopfloor changes** — the operator execution screens (Dashboards 1–12+) plus the reference data, equipment limits and validation rules those screens consume. The remaining 7 belong to adjacent modules (planning, scheduling, certification) and are retained here marked `Scope = Other`.

**This register holds open items only.** The answered questions are in [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) with their decisions. **The two files share one numbering space** — open questions are **`Q1`–`Q55`, `Q59` and `Q87`** (57 entries) and decided questions run **`Q56`–`Q86`, `Q88` and `Q89`** (32 entries, not contiguous — a question is numbered when raised and moves across when decided), and a `Q##` lives in exactly one of the two files, so an `OQ-##` reference from the phase files, [REVIEW.md](../MVP-1/ProjectPlan/Development/REVIEW.md) or the master specification resolves against whichever file holds that number. ⚠ **The open register was renumbered three times on 12 Aug 2026** — the last of them when 23 questions were withdrawn as ours to answer rather than the client's. **A `Q##` read in any document or commit written before that resolves against the maps in [CHANGELOG.md](../CHANGELOG.md)**, under this file's section, and the three maps must be read in order. Every inbound citation in the repository was rewritten in the same pass, so nothing outside `CHANGELOG.md` — which keeps its historical numbers by design — should still be on an older scheme.

**Every question carries a `Recommendation:` at the foot of its body, with one deliberate exception.** That is **our proposed answer — it is not a decision and carries no client authority.** **`Q10` (footage-to-weight conversion factor) carries none, by decision.** The dimensional basis it turns on — nominal or measured gauge and width, and whether the round edge is corrected for — is a measurement question United Aluminum must answer from its own practice, and a proposed default risks being adopted as the basis rather than confirmed. Every derived weight in the system rests on it, so it goes to the client as an open question. The `Recommended answer` field is optional in the workbook generator for this reason. It exists so a review is a confirm-or-correct exercise rather than a blank page, and so the build has a defensible default to work to while an answer is outstanding. Where the body already recorded a proposal, leaning or option preference, the recommendation crystallises **that** rather than inventing a new one. **Confirming a recommendation closes the question** — move it to [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) with the confirmation date and who gave it. Nothing here should be cited as settled, and nothing should be implemented as irreversible on a recommendation alone.

**Several recommendations deliberately point at the same conversation.** The three surviving PLC questions — **Q27**, **Q28** and **Q29** — all recommend closing in a single controls-engineer session, the one **`PLC-Q02`** asks for in [PLCTagSpecification.md](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md); that document carries its own `PLC-Q##` register and sign-off sheet, which is why the tag-path, station-rename, measure-name, unit and ordinal questions are tracked there rather than here. **Q32** must be closed from `PSG-Q29` rather than asked twice.

**Eight of these questions are partly answered, and the partial answer is in the body.** **Q1**, **Q12**, **Q13**, **Q17**, **Q18**, **Q22**, **Q23** and **Q24** each carry a decided portion — a basis, a shape, or some of their numbered items — with the rest still owed. They are `Open` because they are not closed; read them here, not in the decided file, and check the body before concluding nothing has been settled.

**There are no numbering holes** — `Q1`–`Q47` here, `Q61`–`Q85` decided, each contiguous. ⚠ **There were, until 20 Aug 2026.** `Q37`–`Q40` were minted on 19 Aug 2026 in `G45`, `[INT §8.0]`, `[REQ §5.26]`, `FW-220`'s task plan and `CHANGELOG.md`, and **never added here** — so this paragraph asserted contiguity at `Q36` while five documents cited four questions that did not exist. They are registered in **`A14`** below and the omission is recorded as gap **`G46`**. If you are reading a document that cites a `Q##` above 36, check it resolves here before trusting it. Withdrawn questions are **not** lost and their numbers are **not** reused as pointers. Earlier withdrawals for being outside shopfloor scope are carried in the master specification as **`OI-88`** (pass schedule authoring), **`OI-81`** (web application), **`OI-69`** / **`OI-49`** / **`OI-85`** (rod receiving), **`OI-60`** (metallic yield per route), **`OI-77`** (edger blades and roll regrind), **`OI-82`** (throughput rates) and **`OI-83`** (scrap handling).

**The 23 questions withdrawn on 12 Aug 2026 went for a different reason — they are ours to answer, not the client's** — and each has a named tracking home carrying the question, any decided portion and our recommendation:

| Withdrawn | Subject | Now tracked as |
|---|---|---|
| costing codes · standard times | Phase 12 inputs | **`OI-68`** |
| WIP REJ report columns | report definition | **`OI-84`** |
| anneal rules · shared furnace capacity | upstream scheduling | **`OI-64`** |
| rework weld on the certificate | with weld attribution and limits | **`OI-59`** |
| tolled cert liability | receiving | **`OI-86`** |
| published tolerance bands | SPC control limits | **`OI-57`** |
| coreless coil OD/ID limits | coil split | **`OI-65`** |
| stop-popup visibility and arbitration | with the short-close decision | **`OI-75`** |
| scale-vs-calculated spool weight | tolerance, basis, scale | **`OI-56`** *(PIN source: **`OI-38`**)* |
| `RodSeqno` scope | traveler ordering | **`OI-72`** |
| FL3 WIP station | one VPS or two | **`OI-26`** |
| FL1/FL3 bay uniqueness | `UX_RodStaging_Bay` scope | gap **`G21`** |
| rod bundle gross weight | contract examples disagree | **`OI-97`** |
| WIP rejection *list* screen | scope question | **`OI-107`** |
| *Welds this run* at cold start | absent or disabled | **`OI-108`** |
| destination after check-in | navigation only | **`OI-109`** |
| units carried in tag values | tag surface | **`PLC-Q15`** |
| confirmation of every tag path | tag surface | **`PLC-Q02`** |
| ordinal naming convention | tag surface | **`PLC-Q17`** |
| FM2 PLC station rename | tag surface | **`PLC-Q04`** *(gap **`G32`**)* |
| every measure name in the map | tag surface | **`PLC-Q05`** *(gap **`G33`**)* |

**Withdrawn is not answered.** Several remain blockers — the bay-uniqueness gap blocks the Phase-4 schema freeze, the tolerance bands gate every SPC control limit, and the three tag-surface confirmations are `Critical` on the `PLC-Q##` sign-off sheet.

**Filter rule applied:** a question is `Shopfloor` if a shopfloor screen **reads it, validates against it, or writes it**. That keeps reference data and equipment limits in scope (**Q10** footage-to-weight, **Q22** dimensional tolerances, **Q26** panel resolution) and leaves FL3 scheduling representation (**Q2**), pre-scheduling validation (**Q16**) and certificate frequency (**Q8**) out, even where they touch flat wire.

### Shopfloor — Open (50)

| Priority | Questions |
|---|---|
| `Critical` | **Q3** traveler fields per station · **Q10** footage-to-weight factor · **Q14** pass schedule selection at check-in · **Q15** FL3 hybrid schedule + FL2 validation · **Q41** what an FL2 pre-check-in does · **Q48** two orders with different pass schedules on one rod |
| `High` | **Q1** roll gap validation · **Q4** skid labeling rules · **Q5** cert traceability granularity · **Q6** weld footage attribution · **Q7** max weld joints per coil · **Q12** partial-rod re-check-in · **Q13** PLC tags on checkout · **Q17** spool state machine · **Q18** target spool weight source · **Q21** `FL{n}.LineState` vocabulary · **Q22** dimensional tolerance columns *(values owed)* · **Q23** failed-inspection row · **Q24** staging overrides · **Q25** rod scheduled on neither rod line · **Q26** shopfloor panel resolution · **Q27** speed pushed as target or limit · **Q28** edge type push + missing edger tags · **Q29** FM2 tag namespace on FL3 · **Q30** take-up load cells / completion weight · **Q31** no-weld wire-break disposition · **Q32** FM2 dancer modes · **Q33** OD→weight formula · **Q34** flat wire completion transaction token · **Q35** `ONSKID` for a finished flat wire coil · **Q37** check-in transaction token · **Q38** `wip_log` status value · **Q39** stamping the rod's `coils` row · **Q40** delete-vs-orphan on reqsum reversal · **Q42** spool carrier format + registry · **Q43** orders per spool + order selection · **Q44** spool label media + fields · **Q45** lead alpha — fact or prediction · **Q49** multi-order-last without a weld · **Q50** overrun bound · **Q52** shared rod exhausts before the order is satisfied · **Q53** fulfilment basis and what the certificate states · **Q54** does the acknowledgement close the FL1 spool · **Q87** FL2 finished-coil label + one alpha or two |
| `Low` | **Q55** carrier prefix versus material prefix |
| `Medium` | **Q19** TKUP-2 alert ladder · **Q20** supervisor mirroring · **Q36** sample number / planned operations · **Q46** mandrel diameter at FL1 · **Q51** the unconsumed remainder on an early acknowledgement |

### MVP-1 scope note — pass schedules, die life, shift boundaries

**Pass schedule authoring is outside MVP-1; the check-in *read* is not.** MVP-1 reads an approved schedule to build the PLC push payload and persists a snapshot of what it pushed. That read boundary — specified in `phase-04` — is why **Q14** (selection at check-in) and **Q15** (FL3 hybrid schedule) are in scope despite reading as pass-schedule questions.

**Die life is in scope at *size* granularity only.** The 60 / 85 % bands are read from `Drawer.LastGrindingFeet` / `Drawer.TotalFeetAllowed`; per-tool tracking and the die master table are not MVP-1.

**Q20** (supervisor mirroring) is in scope because it surfaces on **Dashboard 1**.

Two decided questions are only partly in MVP-1 and carry banners in [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md): **Q62** (the Active Run Monitor alert is in; the change-log table and editing flow are not) and **Q83** (the bands are in; the per-tool mechanism is not).

### Out of shopfloor scope (7)

**Q2** FL3 scheduling representation · **Q8** C of C frequency · **Q9** twist and torsion · **Q11** yield loss factor · **Q16** pre-scheduling validation · **Q47** max coil weight — target or search · **Q59** third-party minter versus an FL1 segment alpha

---

## Quick Reference — Decision Log

| # | Question (Short) | Scope | Priority | Owner | Status | Decided Date |
|---|-----------------|-------|----------|-------|--------|--------------|
| 1 | Roll gap validation before run start | `Shopfloor` | High | Jaspreet / Tim O. | Open | |
| 2 | FL3 scheduling representation | `Other` | Critical | Tim O. / Stephen | Open | |
| 3 | Traveler screen fields per station | `Shopfloor` | Critical | Jaspreet / Tim O. | Open | |
| 4 | Coreless coil skid labeling rules | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 5 | Traceability granularity for certs | `Shopfloor` | High | Tim O. / Mick | Open | |
| 6 | Weld attribution on output footage | `Shopfloor` | High | Jaspreet / Tim O. | Open | |
| 7 | Max weld joints per finished coil | `Shopfloor` | High | Tim O. / Sales | Open | |
| 8 | C of C frequency — per coil/order/heat | `Other` | High | Tim O. / Mick | Open | |
| 9 | Twist and torsion tolerance for welding wire | `Other` | High | Tim O. / Technical | Open | |
| 10 | Footage-to-weight conversion factor | `Shopfloor` | Critical | Tim O. / Bob S. | Open | |
| 11 | Yield loss factor for planning rod input | `Other` | High | Tim O. / Margo | Open | |
| 12 | Partial-rod re-check-in and traceability carry-forward | `Shopfloor` | High | Jaspreet / Tim O. | Open | |
| 13 | PLC tag behaviour on rod checkout | `Shopfloor` | High | Jaspreet / Tim O. | Open | |
| 14 | Pass schedule selection mechanism at check-in | `Shopfloor` | Critical | Tim O. / Jaspreet | Open | |
| 15 | FL3 hybrid pass schedule — one or two schedules? | `Shopfloor` | Critical | Tim O. / Jaspreet | Open | |
| 16 | Pass schedule validation during planning/scheduling | `Other` | Medium | Tim O. / Stephen | Open | |
| 17 | Spool status state machine — all valid transitions | `Shopfloor` | High | Tim O. / Jaspreet | Open | |
| 18 | Target spool weight source for the completion alert + over-target behavior | `Shopfloor` | High | Tim O. / Operations | Open | Jul 30, 2026 *(basis)* |
| 19 | Does the spool completion alert ladder apply to finished coils at TKUP-2 (FL2/FL3)? | `Shopfloor` | Medium | Tim O. / Jaspreet | Open | |
| 20 | Supervisor mirroring and audit persistence of milestone acknowledgements | `Shopfloor` | Medium | Tim O. / IT | Open | |
| 21 | `FL{n}.LineState` vocabulary, stop-dwell value, and pause-reason suppression | `Shopfloor` | High | Engineering / Tim O. | Open | |
| 22 | Dimensional tolerances — min/max for gauge, width, diameter **and ovality**; no column exists | `Shopfloor` | High | Tim O. / IT | Open | Jul 30, 2026 *(shape)* |
| 23 | Does a failed staging inspection persist a `RodStaging` row, and what releases it? | `Shopfloor` | High | Tim O. / IT | Open | Jul 31 *(items 1–2)* · Jul 30 *(item 3)* |
| 24 | Staging deviations — off-schedule (auto-switch), out-of-sequence (override), PIN source | `Shopfloor` | High | Tim O. / Shannon R. | Open | Jul 30, 2026 *(off-schedule)* |
| 25 | May a rod be processed when its order is scheduled on **neither** FL1 nor FL3? | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 26 | Shopfloor panel resolution — 1280×1024 (stocked) vs 1920×1080 (required) | `Shopfloor` | High | Tim O. / Charles / Juan | Open | |
| 27 | Is speed pushed to the PLC as a **target/setpoint** or a **limit/clamp**? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 28 | Is edge type pushed to the machine, and where are the **edger** tag paths? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 29 | On FL3, are FM2 tags addressed as `FL2.FM2.*` or `FL3.FM2.*`? | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 30 | Do take-up load cells exist, and is the spool-completion weight **read** or **derived**? | `Shopfloor` | High | Tim O. / Bob S. / Engineering | Open | |
| 31 | Wire break where the **customer accepts no welds** — the disposition set, the supervisor gate and where the decision is persisted | `Shopfloor` | High | Tim O. / Shannon R. | Open | Principle Aug 6, 2026 |
| 32 | **FM2 dancer modes** (dancer vs tension) — who selects, per dancer or per line, scheduled or machine-side, read or written | `Shopfloor` | High | Tim O. / Engineering | Open | |
| 33 | OD/diameter → weight conversion formula for spool | `Shopfloor` | High | Tim O. | Open | |
| 34 | **Transaction name for a flat wire coil completion** in the shared plant records, and whether any existing report filters on it | `Shopfloor` | High | Tim O. / IT | Open | |
| 35 | Whether a finished flat wire coil carries the **existing on-skid status** or needs one of its own | `Shopfloor` | High | Tim O. / IT | Open | |
| 36 | **Sample number and planned operations** for a flat wire output coil when they cannot be inherited from the rod | `Shopfloor` | Medium | Tim O. / Planning | Open | |
| 37 | **Transaction token for a flat wire rod check-in** in the shared plant records | `Shopfloor` | High | Tim O. / IT | Open | |
| 38 | **Transaction-log status value** for a rod on a flattening line — new value or reuse | `Shopfloor` | High | Tim O. / IT | Open | |
| 39 | Is **stamping the rod's shared coil row** with a flattening station safe for existing consumers? | `Shopfloor` | High | Tim O. / IT | Open | |
| 40 | On reversing the reqsum at pre-check-out, **delete the row or zero it**? | `Shopfloor` | High | Tim O. / IT | Open | |
| 41 | **What does an FL2 pre-check-in do** — persist or validate, hold a station or release it, gate check-in or not | `Shopfloor` | Critical | Tim O. / Bob S. | Open | Aug 20, 2026 *(that it exists)* |
| 42 | **Spool carrier identifier format**, and where the registry is mastered | `Shopfloor` | High | Tim O. / Bob S. | Open | Aug 20, 2026 *(static, stenciled, typed)* |
| 43 | **How many orders per spool**, and does FL2 check-in choose the order or inherit it? | `Shopfloor` | High | Tim O. / Planning | Open | Aug 20, 2026 *(many)* |
| 44 | **What the FL1 spool label prints**, and on what media | `Shopfloor` | High | Tim O. / Bob S. | Open | Aug 20, 2026 *(media)* |
| 45 | Is **last on, first off** guaranteed — is the label's lead alpha a fact or a prediction? | `Shopfloor` | High | Tim O. / Engineering | Open | Aug 20, 2026 *(principle)* |
| 46 | **Mandrel / core diameter at FL1** — selected per spool, fixed by the standard size, or read from the machine? | `Shopfloor` | Medium | Tim O. | Open | |
| 47 | Is the **maximum output coil weight** the optimisation target, or the start of a downward search? | `Other` | Medium | Tim O. / Planning | Open | Aug 20, 2026 *(method)* |
| 48 | **Can two orders on one rod have different pass schedules?** If so the boundary cannot be crossed mounted | `Shopfloor` | **Critical** | Tim O. / Planning | Open | |
| 49 | Does **multi-order-last** hold when **no weld** is involved? `Q73` item 6's unresolved branch | `Shopfloor` | High | Srikanth / Tim O. | Open | |
| 50 | **What overrun is acceptable** past the allocated weight — warn at what, escalate to whom? | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 51 | On an **early acknowledgement**, where does the unconsumed allocation go? | `Shopfloor` | Medium | Tim O. / Planning | Open | |
| 52 | A **shared rod exhausts** before the outgoing order is satisfied — top up, or stay short? | `Shopfloor` | High | Tim O. / Planning | Open | |
| 53 | Is fulfilment **consumed** or **produced** pounds — and which does the certificate state? | `Shopfloor` | High | Tim O. / Shannon R. | Open | |
| 54 | Does the order acknowledgement also **close the FL1 spool**, or may a spool span the boundary? | `Shopfloor` | High | Tim O. / Bob S. | Open | |
| 55 | Should the **spool carrier prefix** differ from the material one? `SP-0001` against `SP-00021` | `Shopfloor` | Low | Tim O. / Bob S. | Open | |
| 59 | Can **another caller** of the shared alpha generator be issued an alpha an FL1 segment already holds? | `Other` | Medium | IT / Srikanth | Open | |
| 87 | What does the **FL2 finished-coil label** carry, on what media — and does a two-rod coil print **one alpha or two**? | `Shopfloor` | High | Tim O. / Bob S. / Shannon R. | Open | |

---

## Detailed Questions

---

### Section A — Project-Specific Questions

---

#### A1. Pass Schedule & System Architecture

**Q1** · `High` · Owner: Jaspreet / Tim O. · `Open`
**Roll gap validation before run start**
How are roll gap settings confirmed before a run begins — manual measurement by the operator, encoder feedback logged by PLC, or a system confirmation step required before check-in is allowed to proceed?

**Status (May 4, 2026):** Tim needs to confirm with engineering. Three options remain open:
- **Option 1** — Operator physically measures each active roll gap and enters readings; system compares against pass schedule setpoints.
- **Option 2** — PLC encoder feedback available; system reads back actual achieved roll gap position and compares to setpoint. Run cannot start until all active rollers report within tolerance.
- **Option 3** — Operator acknowledges pass schedule, system pushes PLC tags, run starts with no readback (current implied design — rated HIGH risk).

Once the approach is confirmed, a secondary question must also be resolved: Is a supervisor override sufficient to bypass a gap-out-of-tolerance block, or should an out-of-tolerance gap be treated as a hard stop?

**Recommendation:** **Option 2** — PLC encoder readback compared against the pass schedule setpoint — for every component whose encoder exists, falling back to **Option 1** (operator measurement) per component where it does not. **Option 3 should not ship**: it is rated HIGH risk in the question itself, and a run that starts with no readback cannot tell a mis-pushed tag from a correct one. Treat an out-of-tolerance gap as a **supervisor-overridable block, not a hard stop** — same credential block as `OI-56`/`Q24` — because a hard stop with no override strands the line whenever the tolerance value itself is wrong. Ask encoder availability per component in the `PLC-Q02` session.

---

#### A2. Scheduling & FL3

**Q2** · `Critical` · Owner: Tim O. / Stephen · `Open`
**FL3 scheduling representation**
FL3 is the hybrid continuous mode (FL1 + FL2). How is it represented in the scheduling system — as a single machine booking entry, or as simultaneous bookings on both FL1 and FL2? Does scheduling a job on FL3 block both lines simultaneously?

**Partial decision (May 4, 2026):** FL3 cannot run if there are scheduled orders on FL1 or FL2. FL1, FL2, and FL3 are treated as separate machines in scheduling. The remaining open point is how FL3 is represented as a booking unit and whether it generates a single combined booking or simultaneous entries on both lines.

**Recommendation:** a **single FL3 booking that reserves FL1 and FL2 capacity as a side effect**, rather than two simultaneous bookings the scheduler must keep in step. `Q67` already fixes the operational rule — FL3 cannot run when either line is booked — so only the representation is open, and one booking with a two-line reservation cannot drift out of sync the way two linked bookings can. Runs report against the FL3 booking; capacity views subtract from both lines.

---

#### A3. Shopfloor & Traveler Screens

**Q3** · `Critical` · Owner: Jaspreet / Tim O. · `Open`
**Traveler screen fields per station**
Generic labels (e.g., "Incoming Bundle Information") are agreed in principle. The full field list per station for FL1, FL2, and FL3 has not been documented. Who is responsible for defining these, and by when?

**Recommendation:** **publish the field list derived from the approved mockups** (Dashboards 2, 2A, 5 and the FL3 variant) as a proposal for Tim O. to redline, rather than wait for it to be authored from scratch. Ownership is the blocker here, not the content — every field is already on an approved screen. Anchor it on `TRV004`/`TRV009` and target the redline before the Phase-4 build.

---

#### A4. Output & Packaging

**Q4** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Coreless coil skid labeling rules**
Final output is 2 coreless oscillated coils per skid. Do skid labeling, alpha assignment, and packaging records follow **UA's existing coil packaging rules** unchanged, or are flat wire-specific adjustments required?

**Recommendation:** follow the **existing coil packaging rules unchanged** — 2 coils per skid, same label fields, same alpha assignment — and treat any flat wire deviation as a change request with a stated reason. The output geometry and the handling are the same; a parallel rule set doubles the packaging logic for a difference nobody has named yet. Confirm with Shannon R. against one printed sample, and ask which existing line's convention is being inherited — the artifacts asserted a precedent without ever naming a definable one.

Related: **`Q87`** (the finished-coil label itself — raised 24 Aug 2026, and Bob proposed carrying the coil's information **on the skid label**, which makes these two one decision rather than two).

---

**Q87** · `High` · Owner: Tim O. / Bob S. / Shannon R. · `Open`
**What does the FL2 finished-coil label carry, on what media — and does a coil built from two source rods print one alpha or two?**

Raised on the **24 Aug 2026** call against a worked example: an FL2 coil wound from two contributing lengths — 400 ft and 500 ft — producing one physical coil with **two source identities behind it**. The direct question was *“what should be the alpha, a single alpha, or we will show multiple alpha at the coil?”* **UA deferred it on the call** — Tim: *“we're going to have to figure out what the labeling is going to look like”*; Shannon: *“we'll work it out outside the meeting.”*

Five constraints were stated while it was being deferred, and they narrow the answer:

1. **Consistency with existing coils is wanted.** Shannon: *“let's make it as consistent with the coils as possible so customers understand it.”* Bob named the existing field set — *“most customers want the alloy, temper, gauge”* — with the coil identity added.
2. **Traceability is wanted; both alphas on the customer face may not be.** Tim: *“I know we want to have the alphas for traceability purposes, but do we need to put both of them on the label?”*
3. **The cut label is the wrong medium.** Cut labels print as a **sheet**, and a finished oscillate-wound coil needs one. Tim: *“we would end up printing an entire sheet of cut labels for one label”*; Bob: *“I don't want to waste seven of the labels just for that … we'll have to make a specific one for the spool.”*
4. **The skid label is a candidate carrier.** Bob: *“the crate skid is going to happen at the same time, we might be able to accommodate the information needed on the coil label for the skid … the same way we do the skid label, the one that goes in the skid and on the skid.”* That makes this question and **`Q4`** answerable together, or not at all.
5. **Something must sit under the stretch wrap.** Shannon: *“they're going to want something under the stretch wrap … customers take the stretch wrap off and store it.”* Tim observed the opposite at a customer — *“there was nothing on the material itself, it was on the cardboard that was around it”* — and Shannon's answer was that UA **markets** the inside label: *“we kind of tout having labels inside and customers like that.”*

**Recommendation:** print **one coil alpha as the primary identity** — the coil is one saleable unit against one order, per the 20 Aug `D2` — and carry the contributing source alphas as **secondary traceability text**, not as co-equal identities. Use a **coil-specific label**, not a cut-label sheet, and place one **inside the wrap** and one on the skid, mirroring the existing skid-label practice Bob named. Answer this with **`Q4`** in one pass.

**Why:** two co-equal alphas on the customer face invite the customer to treat one coil as two line items, which is a reconciliation problem at their receiving dock and ours. The genealogy is exactly what **`CoilTraceability`** exists to hold, and the certificate — not the label — is where provenance is stated, which is **`Q53`**. The medium is the part with a hard constraint behind it: a sheet-fed cut label wastes seven labels per coil, so a decision to reuse the existing stock is a decision to change the stock.

**What is blocked meanwhile:** the FL2 coil-completion label print in [`OutputCoilCompletion.md`](../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md), and any field on it that states a **weight**, which rests on **`Q10`** like every other derived weight in the build.

Related: **`Q4`** (skid labelling — answer together, per constraint 4), **`Q44`** (the FL1 spool label — the same question one station upstream), **`Q53`** (what the certificate states), **`Q10`** (any printed weight), **`OI-98`** (the odd final coil), **`OI-99`** (lot number for a multi-rod coil), **`OI-121`** (weight per source alpha).

---

### Section B — Industry-Standard Questions

---

#### B1. Weld Traceability & Certification

**Q5** · `High` · Owner: Tim O. / Mick · `Open`
**Traceability granularity for certs**
What is the minimum traceability unit required by welding wire customers — full coil-level, lot-level, or heat-level? Does this granularity need to appear explicitly on the Certificate of Conformance, or is a lot reference sufficient?

**Recommendation:** build to **coil-level traceability with full rod genealogy behind it.** `CoilTraceability` already records which source rods produced which output footage, so a coil-level cert can resolve to lot or heat on demand without a second data model. Print the lot reference and hold the heat detail queryable — that satisfies the strictest plausible answer without waiting for it. Confirm with Mick only whether heat must be **printed**.

---

**Q6** · `High` · Owner: Jaspreet / Tim O. · `Open`
**Weld attribution on output footage**
When a weld joins two source rods (R1 and R2) into a continuous run, how is output footage attributed to each source for cert and yield purposes? Is there a footage-based split at the weld point, or is the entire output coil attributed to the dominant (largest contributor) rod?

**Recommendation:** **footage-based split at the weld point**, not dominant-rod attribution. `CoilTraceability` is already a per-footage-range genealogy chain, so the split is the natural read of data we hold anyway, whereas dominant-rod attribution makes a certificate assert that material came from a rod it did not. Cost at capture is nil — the weld already records its footage position.

---

**Q7** · `High` · Owner: Tim O. / Sales · `Open`
**Maximum weld joints per finished coil**
Is there a customer-specified limit on the number of weld joints permitted in a single coreless oscillated coil? Exceeding this limit can cause wire jams in customer welding equipment. This must be captured as a validation rule if applicable.

**Recommendation:** build the **validation now with a per-order configurable limit defaulting to unlimited**, rather than waiting for the number. The check is cheap to add at coil completion and expensive to retrofit once certs are issuing; a null limit leaves it inert until Sales supplies a value per customer. Per the `OI-59` recommendation, a superseded weld attempt should **not** count toward the limit.

---

**Q8** · `High` · Owner: Tim O. / Mick · `Open`
**C of C frequency — per coil, order, or heat**
Are Certificates of Conformance issued per coil, per order, or per heat for flat wire? Is this consistent across all flat wire customers or customer-specific?

**Recommendation:** issue **per order, with per-coil detail attached** rather than separate certificates, and allow a customer-specific override. That matches how the coil business already issues certs and avoids one certificate per ~900 lb coil on a 44,000 lb order. Mick to confirm whether any welding wire customer contractually requires per-coil.

---

#### B2. Dimensional Tolerances & Quality Standards

**Q9** · `High` · Owner: Tim O. / Technical · `Open`
**Twist and torsion tolerance for welding wire**
Is there a maximum allowable twist per foot for flat wire — particularly for welding wire feedability through automated welding equipment? Exceeding this limit causes wire jams at the customer and is a common first-shipment field failure.

**Recommendation:** treat it exactly as **camber under `Q81`** — an **optional SPC checkpoint field, active only when the order specifies a limit.** That is the pattern already agreed for a customer-conditional dimensional characteristic, it needs no new mechanism, and it lets a welding-wire order enforce twist without every order measuring it. Ask Technical for the limit only for the customers who require it.

---

#### B3. Yield Loss & Planning Inputs

**Q10** · `Critical` · Owner: Tim O. / Bob S. · `Open`
**Footage-to-weight conversion factor**
How is the footage-to-weight conversion calculated per alloy and cross-section? Is there a standard formula (density × cross-sectional area × footage), or is it measured empirically and maintained per product? This factor is the basis for output weight calculation (weight is derived from length, not scale).

Note that the formula is not what is actually in doubt: the open part is the **dimensional basis** (`OI-45`) — nominal or measured gauge and width, and whether the round edge is corrected for. `PSG-D30` asks for the same number in the generation spec and **must not resolve to a second value**.

**No recommendation is offered on this question** — see the note above the filtered index.

**Consequence added 22 Aug 2026.** [`RodOrderAllocation.md`](../LatestDocument/RodOrderAllocation.md) §4 makes this question's *shape* concrete without answering it: the converter takes a **`Basis`** — `Nominal` · `Measured` · `IntegratedRunReading` · `Override` — and **every consumption row persists the basis and the `lb/ft` factor it actually used**, so a later answer here cannot retro-change a historical record. The formula itself is **not** in doubt (`FR-137`, `[DBD §6.6]`); this question is the **dimensional basis** only, which is why the design can proceed without it and the certificate cannot.

---

**Q11** · `High` · Owner: Tim O. / Margo · `Open`
**Yield loss factor for planning rod input sizing**
Is there a per-pass scrap allowance (die entry crop, edge trim, end crop, weld scrap) that the planning algorithm must apply when sizing rod input weight for an order? If not built in, planners will systematically under-order rod and discover the shortage at the machine.

**Recommendation:** a **per-pass scrap allowance held as configuration, with die entry crop, edge trim, end crop and weld scrap as separate line items** so each can be tuned independently; seed provisionally and refine from trial. Rolling them into one factor makes the number impossible to improve later, because nobody can tell which component was wrong. Must agree with `OI-60`.

---

### Section C — Rod Checkout

---

#### C1. Rod Checkout Scenarios

**Q12** · `High` · Owner: Jaspreet / Tim O. · `Open`
**Partial-rod re-check-in and traceability carry-forward**

**Status (May 4, 2026):** Partial decisions received; full answer deferred.

- **Material remaining in mill:** Any material drawn/rolled will be scrapped as it remains in the mill when the rod is removed. The remaining rod going back to warehouse may need to be weighed to validate remaining weight. Tim has asked Scott, Bob, and Shannon to weigh in on whether a small scale at the payoff should be available for this purpose.
- **Multiple partial spool alphas per rod:** Yes, this functionality is needed. There is always potential for a rod to produce partial spool alphas across separate runs.
- **Carry-forward recommendation:** Full answer deferred — Tim will confirm. The proposed design (persistent rod record with footage_run_to_date and remaining_weight_estimate, carry-forward re-check-in, source_rod_alpha foreign key on each partial spool) is documented and awaiting confirmation.

**Recommendation:** build the **documented carry-forward design** — already delivered on 26 Jul 2026 as `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` and `SpoolProcessing.SourceRodAlpha` — and treat the **payoff scale as a separable question** (**`OI-56`** asks the same thing at the take-up). The design works from an estimated remaining weight; a scale only improves the estimate's accuracy. Do not hold the build for the scale answer.

---

**Q13** · `High` · Owner: Jaspreet / Tim O. · `Open`
**PLC tag behaviour on rod checkout**

**Status (May 4, 2026):** Tim needs to confirm the following proposed behavior with engineering:
- The application never sends a stop command to the PLC — the operator always controls the machine physically.
- Tags are only ever cleared when the line is confirmed stopped — no footage is lost, no control logic is disrupted mid-motion.
- The application checks whether the line is stopped before allowing checkout to proceed.

Proposed screen behavior (awaiting engineering confirmation):
- **If line is still running when operator clicks "Check Out Rod":** Checkout is blocked. Message shown: "Line is still running. Stop the line before checking out the rod." Checkout dialog does not open.
- **If line is confirmed stopped:** Checkout dialog opens. Footage counter value is read from the PLC and locked at that moment. Operator completes the form, clicks Confirm, and only then are PLC tags cleared and the checkout record written.

**Recommendation:** adopt the **proposed behaviour as written** — the application never commands a stop, checkout is blocked while `FL{n}.LineState` reports running, and tags clear only after the operator has physically stopped the line and confirmed the dialog. It is the only design that cannot drop footage or interrupt control logic mid-motion, so engineering is being asked to confirm the readback tag rather than to redesign the flow. Depends on `Q21` for the state vocabulary that makes "stopped" decidable.

---

### Section D — Pass Schedule Integration

---

#### D1. Pass Schedule Selection and Hybrid Mode

**Q14** · `Critical` · Owner: Tim O. / Jaspreet · `Open`
**Pass schedule selection mechanism at check-in — no-match path undefined**
The selection mechanism itself is now shown in the updated dashboards: the system performs an attribute-based lookup (alloy + rod diameter + target gauge × width + route mode) and surfaces the best match as a system recommendation in a confirm bar. The operator must explicitly confirm before "Acknowledge & Begin Check-in" is enabled. A "Change" dropdown shows alternatives, and selecting a non-recommended schedule is flagged for Operations review.

**Remaining open point:** What happens when the lookup returns no match — i.e., no active pass schedule exists for the order's attribute combination? The dashboards show no empty-match or error state. Must the check-in be blocked and an alert sent to Operations so a schedule can be created before the line starts? Or can the operator proceed by manually selecting from a list of schedules that don't match? The no-match notification path must be defined before development begins on the check-in gate logic.

**Recommendation:** **block the check-in and alert Operations**, showing which attributes failed to match so the missing schedule can be authored without a phone call. The operator must not be able to proceed by hand-picking a schedule that does not match the order — that is precisely the path that produces scrap under a plausible-looking configuration, and making the match explicit is the confirm bar's whole purpose.

---

**Q15** · `Critical` · Owner: Tim O. / Jaspreet · `Open`
**FL3 hybrid pass schedule — FL2 check-in validation for hybrid spools still undefined**
The updated FL3 rod check-in dashboard (dashboard_2_rod_checkin_fl3.html) implies Option A: a single unified pass schedule record (e.g., PS-1350-FL3-001) covers all FL1 and FL2 components together. The schedule list shows FL3 records with a "Hybrid" route tag, and the check-in attribute match includes "Hybrid route" as a lookup criterion. The data model question — one unified vs. two coordinated schedules — appears resolved toward a single record.

**Remaining open point:** When a spool produced on a hybrid FL3 run later arrives at FL2's TPO for spool check-in (Dashboard 5), how does the system validate it was produced under the correct hybrid pass schedule? The current Dashboard 5 mockup only shows standalone FL2 schedules (PS-1100-FL2-007). If a hybrid spool is loaded onto FL2 as a standalone re-pass job, is there a guard preventing the operator from applying a standalone FL2 schedule to material that was originally run under a hybrid configuration? This validation rule — how Dashboard 5 handles hybrid-origin spools — must be defined before FL2 check-in development begins.

**Recommendation:** record the **originating route mode on the spool** and have Dashboard 5 **refuse a standalone FL2 schedule for a hybrid-origin spool** unless a supervisor overrides with a reason. The spool already carries its producing run, so this is a lookup rather than new data — and without it, hybrid material can be re-passed under a configuration that never applied to it. Same override pattern as `OI-56`/`Q24`.

---

**Q16** · `Medium` · Owner: Tim O. / Stephen · `Open`
**Pass schedule validation during planning and scheduling**
Should the scheduling or planning system warn when a job is scheduled for FL1/FL2/FL3 but no active pass schedule exists for that product's alloy, gauge, width, and edge type combination? Without this check, operators will arrive at the machine ready to run with no pass schedule available, blocking the line until Operations creates one. A pre-scheduling validation prevents that delay.

**Recommendation:** **warn at scheduling time, do not block.** A scheduler should be able to book work before Operations has authored the schedule, but not unknowingly — and `Q14` already provides the hard gate at the point it matters, check-in. Warning at scheduling plus blocking at check-in covers the failure without making planning depend on pass schedule authoring.

---

### Section E — Spool Lifecycle

---

**Q17** · `High` · Owner: Tim O. / Jaspreet · `Open` — *the FL2-visible states are decided (Aug 2, 2026); the stored state machine is still open*

**Spool status state machine — all valid transitions**

> **Decided (August 2, 2026) — FL2 shows two statuses and runs one spool at a time.** Because **FL2 has no space to stage material**, a spool is either waiting for the line or on it; there is no third place for it to be. The operator-visible vocabulary at FL2 is therefore fixed at **`Ready for FL2`** (schema `RECEIVED`) and **`Checked in`** (schema `INFLAT`). **`STAGED` is never set at FL2** — staging is the FL1 concept (PCI002), and there is no "At TPO" status on the spool queue. Second half of the decision: **check-in is exclusive.** While any spool is checked in, **no spool offers a check-in action** — not the others and not the checked-in one — and the action returns only on checkout. Applied to [dashboard_5a_spool_queue.html](../MVP-1/ProjectPlan/Frontend/Mockups/dashboard_5a_spool_queue.html) and [SpoolQueue.md](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) §3.5 (rules SQ-7 to SQ-10). **Still open:** the stored status list and its transitions — this decision fixes what the FL2 operator sees, not what the database records, and the two rival vocabularies of **OI-06** are still unmapped. **Two consequences that need owners:** (1) exclusivity has **no backing constraint** — `dbo.SpoolProcessing` has no filtered unique index on `Status` and carries **no `LineId` at all**, so "one spool checked in per line" cannot currently be expressed in the schema; `POST /checkin/spool` must reject the second check-in with a `409`. (2) A **quality-held spool now has no place on the FL2 queue** — it is neither ready nor checked in, so it simply is not listed. Raised to the client as SpoolQueue.md open item 6.

**Status (May 4, 2026):** Tim provided the following operational framework:
- Spools shall have unique identifiers similar to furnace plates.
- Alphas are loaded onto a spool number at the start of the FL1 job; operators are required to input the spool number being used.
- The spool number is then tracked physically and in the system: tow motor moves it to the furnace, then to cooling, and then the operator on FL2 selects it by spool number for check-in.

The full formal state machine (all valid statuses and the events that trigger each transition) is still to be defined. Without a defined state machine, the system cannot enforce valid status progressions (e.g., preventing a spool from being planned for two orders simultaneously, or a completed spool being re-opened for FL2 check-in).

**Recommendation:** make the **stored** vocabulary the six-value set `SpoolProcessing.Status` already carries in `FlatWireDB` (`RECEIVED` / `STAGED` / `INFLAT` / `COMPLETE` / `HOLD` / `SCRAP`) and treat the Aug 2 two-status FL2 view as a **projection over it**, not a second vocabulary. ⚠ **Corrected 18 Aug 2026 — `D-32`.** This had said *"the shared `coils` status set already in use"*, which was never quite true and is now definitely not: `INFLAT` was only ever going to reach the shared vocabulary through `FW-002`, and that story is **cancelled with the shared-schema migration**. The recommendation is unchanged in substance — one vocabulary, not three — but its home is the **local** column, which is the only place the six values exist — that is what closes `OI-06` without inventing a third list. Then add the two things the Aug 2 decision left unbacked: a **`LineId` on `SpoolProcessing`** and a **filtered unique index** enforcing one checked-in spool per line, so exclusivity is a constraint rather than only a `409`. For the quality-held spool with nowhere to appear, add a third **view** state `Held` — visible on the queue, with no check-in action.

---

**Q18** · `High` · Owner: Tim O. / Operations · `Open` — *basis decided Jul 30, 2026; the source field and the over-target behaviour remain open*
**Target spool weight source for the completion alert, and over-target behavior**

> **Decided (July 30, 2026) — the basis is the customer weight range, not a fixed default.** Tim/Bob: the customer specifies a **min–max weight** (e.g. 900 lb max / 800 lb min) and completion is graded against **that range, by weight** — not against footage and not against an assumed default. Spools are sized at roughly **1,800 lb** so that **two finished coils** can be cut from one spool at FL2. Still open: **which order field carries the customer min/max**, and whether the ladder still escalates to a distinct over-target state.

The spool completion alert ([SpoolCompletionNotification.md](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md)) compares actual processed weight against a target. Two candidate sources exist: the order's **Max Wgt of Spool** (customer/order-driven) and the **take-up equipment capacity** (TKUP-1 = 3,500 lb). Note the customer maximum can be well below the TKUP-2 capacity of 1,100 lb, so on FL2/FL3 the customer value governs rather than the cap.

Second part: if the operator does not acknowledge the 100% notification, live weight keeps climbing past target. Should the notification escalate to a distinct **over-target** state (proposed as milestone M4, red, "over by *n* lb"), or continue showing "target reached" with a percentage above 100? Depends on **Q33** for the authoritative weight source.

**Recommendation:** carry the customer min/max on the **order**, reusing the existing *Max Wgt of Spool* field for the maximum and adding a matching minimum, rather than introducing a new spool-target entity — `Q79` grades short closes against the same range, so one source serves both. On the second part, **escalate to a distinct over-target state**: a percentage climbing above 100 with no change of state gives the operator nothing new to react to at exactly the moment the equipment limit is being approached.

---

**Q19** · `Medium` · Owner: Tim O. / Jaspreet · `Open`
**Does the completion alert ladder apply to finished coils at TKUP-2 (FL2 / FL3)?**

The 75 / 90 / 100 ladder was specified for spool creation at FL1 TKUP-1. FL2 and FL3 wind finished coreless coils at TKUP-2 (1,100 lb) with the same "approaching target weight" concern. Should the same notification run there with "coil" wording and the coil target weight? If yes, note that FL2 standalone broadcasts `null` live gauge/width, so its lb/ft factor must come from the pass schedule / order rather than live measurement.

**Recommendation:** **yes — run the same 75 / 90 / 100 ladder at TKUP-2**, with coil wording and the coil target weight. The operator concern is identical, and a second, differently-shaped notification on the same shop floor is a training cost for no benefit. Note the consequence the question already identifies: FL2 broadcasts `null` live gauge/width, so the lb/ft factor comes from the pass schedule or order — and it is the same `Q10` factor, not a new one.

---

**Q20** · `Medium` · Owner: Tim O. / IT · `Open`
**Supervisor mirroring and audit persistence of milestone acknowledgements**

Is the spool completion alert an operator-only notification, or is it also surfaced to the supervisor (Dashboard 1 line status / Operations Manager view) — particularly an **unacknowledged** 100% milestone, which indicates nobody is at the machine as the spool fills? And where does the acknowledgement audit record live: a new milestone/acknowledgement table hanging off `FlatWireRun`, or an entry in the existing run-event stream?

**Recommendation:** mirror to the supervisor **only the unacknowledged 100 % milestone**, not the whole ladder — an unanswered completion means nobody is at the machine while the spool fills, which is the one state a supervisor needs, and mirroring all three teaches them to ignore it. Persist the acknowledgement in the **existing run-event stream** rather than a new milestone table: it is an event with an actor and a timestamp, which is exactly what that stream already holds.

---

**Q21** · `High` · Owner: Engineering / Tim O. · `Open`
**`FL{n}.LineState` state vocabulary, stop-dwell value, and pause-reason suppression**

Part B of [SpoolCompletionNotification.md](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md) conditions the spool-removal popup on the PLC confirming a `RUNNING → STOPPED` transition, using the same `FL{n}.LineState` tag the system already reads as the rod-checkout gatekeeper. Three specifics are needed before it can be built:

1. **The tag's actual state vocabulary** — is it a two-state run/stop bit, or does it distinguish `RUNNING / STOPPED / PAUSED / FAULT / THREADING / JOG`? A jog or thread state that reports as STOPPED changes the filtering required.
2. **Dwell time** — how long must STOPPED persist before the stop is treated as real? Proposed default **5 seconds**, with speed ≈ 0 as corroboration. Needs a value from someone who knows how the drives behave on slow-down.
3. **Pause-reason suppression** — if the operator already used the software Pause dialog and captured a reason (die change, weld prep, break), should the popup be suppressed because the reason is already known? Proposed yes, unless the reason indicates spool removal.

**Recommendation:** adopt the two proposals — **5-second dwell with speed ≈ 0 as corroboration**, and **pause-reason suppression unless the captured reason indicates spool removal** — and treat only item 1 as genuinely owed. Ask engineering for the enumeration as a **list of literal values, not a description**, because the filtering depends on whether `THREADING` and `JOG` report distinctly or as `STOPPED`. Same conversation as `Q27`/`PLC-Q05`, and `Q13` depends on the answer.

---

**Q22** · `High` · Owner: Tim O. / IT · `Open` — *shape decided Jul 30, 2026; the values are owed by e-mail*
**Dimensional tolerances — min/max for gauge, width, diameter and ovality; no column exists**

> **Decision (July 30, 2026): the tolerances exist, they are min/max, and there are four of them.** Tim confirmed **upper and lower limits for height (gauge), width and diameter, plus ovality**. They are held in the **lookup** and applied at **both pre-check-in and check-in**. He did not have the figures to hand — *"I want to say it's plus or minus 10"* — and will **send the width, height, diameter and ovality tolerances by e-mail**.
>
> **Two structural consequences, both larger than this gap as first written:**
>
> 1. `AlloyProperty` holds `GaugeToleranceDefault` / `WidthToleranceDefault` as **single ± values**. Min/max means explicit `Min`/`Max` pairs — a **rename plus widen**, not the single `RodDiameterToleranceDefault` add proposed below (and in **OI-07**). Do diameter and ovality in the same change.
> 2. Ovality already exists as a *computed* check — `RodCheckin.SpcOvalityIn`, against a hard-coded **≤ 0.003"** that the April check-in implementation plan carried (deleted 13 Aug 2026, recoverable at `1964086`). **The value is per-alloy reference data, not a constant**, so it belongs in `AlloyProperty.RodOvalityMaxIn`; the computed check must read it from there, or ovality is validated two ways.
>
> **No values are to be seeded until the e-mail arrives.** "Plus or minus 10" is not a specification. Add the columns nullable, keep the Dashboard 2A per-alloy map visibly marked as mock, and hold the seed script. **Still blocks Phase 4 implementation** even though the shape is settled.

`CHK007` requires the measured rod diameter to be validated against nominal **± a lookup tolerance**, at both pre-check-in (Dashboard 2A) and check-in (Dashboard 2). There is nowhere to read that tolerance from.

`AlloyProperty` carries `GaugeToleranceDefault` and `WidthToleranceDefault`, but those are **flat wire output** dimensions — the gauge and width the mill produces. Incoming rod diameter is a different measurement, and no column for its tolerance exists in `FlatWireDB` or in the shared `coils` schema. A search across `Schema/` returns gauge and width tolerances only.

As a result the Dashboard 2A mockup hard-coded a single `0.005"` for every alloy, which is wider than every value in the standards table in [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) (*Alloy Lookup Table*: 1100 → ± 0.003", 1350 → ± 0.002", 3003 → ± 0.004") — so out-of-tolerance rod would have been accepted. The mockup now reads a per-alloy map mirroring that table, but the map is mock data with no backing store.

To resolve:

1. Add `AlloyProperty.RodDiameterToleranceDefault` (or confirm the tolerance belongs on a rod-spec record rather than the alloy)?
2. Are the standards-table values authoritative, or do they need Process Engineering sign-off first? That table already carries the note *"must be confirmed and maintained by Process Engineering (Tim O.) — editable via an admin table, not hardcoded."*
3. Can tolerance vary by rod vendor or by nominal size within one alloy, or is per-alloy sufficient?

Blocks the Phase 4 check-in and staging validation. Detail in [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md).

**Recommendation:** **make the structural change now and seed nothing.** Rename `AlloyProperty`'s single ± columns to explicit `Min`/`Max` pairs, add diameter and ovality in the same change, and put the hard-coded ovality ≤ 0.003″ into the lookup so ovality is validated once rather than twice. The shape is decided and the columns are nullable, so the schema is not waiting on the values — chase the e-mail as a separate action. **Per-alloy is sufficient granularity** unless Process Engineering states that tolerance varies by vendor or by nominal size.

---

**Q23** · `High` · Owner: Tim O. / IT · `Open` — *items 1–2 decided Jul 31, 2026; item 3 decided Jul 30, 2026; item 4 open*

> **Decided (Jul 31, 2026) — items 1 and 2.** `Blocked` is **derived** (`Status = 'Staged'` + any inspection column `= 'Fail'`), not a fourth `Status` value; and pre-check-in **commits the `RodStaging` row before the inspection gate**. `POST /staging/rod` now returns `201 Created` with `state: "Blocked"` and the WIP-rejection route, replacing the `422`-and-write-nothing behaviour. The deciding argument is physical: bundles are not unbanded until positioned at the payoff — which is *why* the inspection happens at staging — so a rod that fails is **already on the bay**. Writing no row left `GET /payoff/status` reporting an occupied position as `NotStaged`, Dashboard 2A offering it as "Empty — available", and the next rod stageable into a bay that physically holds a rejected bundle. `CHK010` is unchanged: no bypass, WIP Rejection remains the only forward path. Contracts updated in [04-APIContract.md](../MVP-1/ProjectPlan/Backend/APIs.md), [FlatWireSchema_Runs.md](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Runs.md) and [phase-04](../MVP-1/ProjectPlan/Development/Phases/phase-04-rod-checkin-plc-config.md).
>
> **Decided (July 30, 2026) — item 3, the blocking residual.** A failed staging inspection is **captured as a rejection on the rejection screen** — the operator enters the rejection reason there — and **the rod goes to `HOLD`**. That is what releases the `RodStaging` row and frees the bay: the WIP rejection carries the material out of the bay, so the row leaves `Status = 'Staged'` and `UX_RodStaging_Bay`'s filter with it. **A blocked bay is now clearable.**
>
> **Implementation choice, not a business one** — recorded here because the DDL has to pick one: reuse `Status = 'Unstaged'` with a release-reason discriminator, or add a fourth `Rejected` value. **Recommendation: reuse `Unstaged` plus a `ReleaseReason`.** A fourth value multiplies branches in every "staged" query and forces `CK_RodStaging_Unstaged`, the status vocabulary and the filtered index to change together for no operational gain — the bay genuinely *is* free once the bundle leaves. `CK_RodStaging_Unstaged` currently ties `Unstaged` to the pre-check-out column group, so that constraint must admit the rejection route as a second way in.

**Does a failed staging inspection persist a `RodStaging` row, or is nothing written?**

Dashboard 2A and `GET /payoff/status` both expose a **`Blocked`** bay state, defined as *"inspection failed at staging"*. `RodStaging.Status` has no such value — it is only `Staged | CheckedIn | Unstaged`.

The state *is* derivable: the three inspection columns are `NOT NULL` `Pass`/`Fail`, so a blocked bay is `Status = 'Staged'` with any inspection column `= 'Fail'`. That reading is also the correct one operationally, because `UX_RodStaging_Bay` is filtered on `Status = 'Staged'` — the failed bundle is still physically in the bay and must keep it occupied. But no artifact states this, and the alternative (a fourth status value) would change the filtered index.

The sharper problem is that **nothing currently writes the row**. On a failed inspection the wizard is a hard block with no bypass (`CHK010`) and the only forward action is a link to WIP Rejection, so the staging record is never committed and the inspection evidence is lost at navigation. The `Blocked` state is therefore unreachable in practice.

To resolve:

1. Confirm `Blocked` is **derived** (`Staged` + any `Fail`) rather than a fourth `Status` value.
2. Does pre-check-in commit a `RodStaging` row *before* routing to WIP Rejection, so the failure and its observation are persisted and the bay reads BLOCKED?
3. **What releases a blocked row — DECIDED Jul 30, 2026:** the WIP rejection itself releases it and the rod goes to `HOLD`. See the block above.
4. `InspectionNotes` is nullable but documented as *"expected when any item fails."* Should it be enforced NOT NULL when any item is `Fail`, matching the constraint style already used for the welded/unstaged/checked-in column groups?

**Two untraced consequences of the item-2 decision**, recorded rather than resolved: `RodStaging` now holds rows for material that was never accepted, which affects the **`TRV009`** traveler (is `Blocked` a third class alongside pre-checked-in and welded?); and the **`Available`** queue projection must exclude rods sitting blocked, or a rejected bundle reappears as stageable.

Related to `CHK010` and gap **G14**. Detail in [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md).

**Recommendation:** on the one item still open, **enforce `InspectionNotes` NOT NULL when any inspection column is `Fail`**, using the same constraint style already applied to the welded, unstaged and checked-in column groups. A failure with no observation is the one case where the note carries the whole evidentiary value, and the document already says it is expected. The release-route implementation choice is recorded above and stands: **reuse `Unstaged` plus a `ReleaseReason`**, not a fourth status value.

---

**Q24** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Staging deviations — off-schedule (auto-switch), out-of-sequence, PIN source, and the mid-order case**

**Decided (July 30, 2026) — off-schedule is not a deviation at all.** Tim's direction: **no blocking message and no override — the system selects the correct station automatically.** If the rod is planned for FL3 and the operator is on the FL1 tab, the screen **switches to FL3** and the transaction continues. The same behaviour applies to **pre-check-in and check-in**.

> **The off-schedule override columns are dropped** (project decision, Aug 1, 2026): `RodStaging.OffScheduleOverride`, `ScheduledLineId` and `CK_RodStaging_OffSched` are removed, and `CK_RodStaging_Override` keys on `OutOfSequenceOverride` alone.
>
> **`OverrideBy` / `OverrideAt` / `OverrideReason` survive.** They are shared with the out-of-sequence override, which stays. Dropping all five columns would delete the surviving override's audit trail.
>
> **Two things this raises rather than settles:** auto-switching moves the operator between stations **mid-transaction** — the behaviour of a part-completed wizard must be specified; and it presumes an FL3 tab exists on the FL1 panel at all, which is **OI-26/G21** surfacing as a UI question. If **Q25** later needs an authorisation for the not-scheduled-anywhere case, it **re-adds** a column group rather than reusing this one.

**Decided (July 30, 2026) — out-of-planned-sequence, provisionally confirmed.** The operator must be **notified** when the rod being checked in / pre-checked-in is not the one the planning system expects next, and a **supervisor override is required** to depart from the planned sequence. Same credential block: reason + badge/ID + PIN, remote-approval fallback, all recorded (`RodStaging.OutOfSequenceOverride` + `ExpectedRodAlpha`, sharing the credential stamp). "Expects next" is the lowest planned sequence still available, so a blocked bundle does not freeze the sequence behind it.

> **Re-review committed.** On the Jul 30 call Tim agreed the override *"might not be a bad idea"* and asked to **leave it in place for now** while he reviews something in the spec that it may support. **Confirm at the next review** before anything downstream treats it as final.
>
> Both sequence columns are retained — the deviation is authorised *and* recorded (see **OI-72**).

Rod→order comes from **`planning_routings`**, so the order is *resolved* from the scan rather than chosen — which is what makes even the first rod on a cold line validatable.

Still to confirm:

1. **PIN validation source** — the existing login/authorisation service, or a separate supervisor credential store? Inherited unresolved from the withdrawn spool-weight question and tracked as **`OI-38`**; it still gates the out-of-sequence override and the welded pre-check-out (**Q69**), so it should be settled once for all of them.
2. **The mid-order case** — per **Q70** (Jul 30, 2026) a rod can legitimately carry **more than one order**, so "a rod from another order" is not automatically a foreign rod. The refusal survives only for a genuinely unrelated order; the same-rod successor must pass. Sequencing across the two is **Q73**.
3. **Does the same override apply at check-in (Dashboard 2)?** The decision says "checkin/precheckin", so Dashboard 2 needs the identical out-of-sequence panel and the same columns on `RodCheckin`. Only Dashboard 2A carries it today.

**Recommendation:** **yes to item 3 — build the identical panel and columns on Dashboard 2**, because a validation enforced at one of two entry points is not enforced; `Q73` independently requires the same thing of the sequencing rule, so the two land together. Validate the **PIN against the existing login/authorisation service** (item 1), the same recommendation recorded at **`OI-38`**, so one credential path serves all three overrides. Item 2 follows `Q70`/`Q73` and needs no separate answer here. Separately, **close the committed re-review of the out-of-sequence override** — it is marked provisional pending Tim's spec check, and anything downstream treating it as final is doing so on an unconfirmed rule.

Detail in [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md).

---

**Q25** · `High` · Owner: Tim O. / Shannon R. · `Open`
**May a rod be processed when its order is scheduled on neither FL1 nor FL3?**

**Q24** settled what happens when a rod's order is booked on the *other* rod line — the station auto-switches. It does not answer the case where the order is scheduled on **no flattening line at all**, or the rod has no line-bearing schedule: an unscheduled job, a trial, a rush piece the floor is told to run before planning catches up.

Today that is a **hard refusal** by omission rather than by decision — staging validates that a `planning_routings` allocation exists, and scheduling then supplies the line. Nothing states what to do when the allocation exists but the booking does not, or when the operator is simply asked to run material that was never scheduled.

Asked on the Jul 30 call as *"is it possible to process an order or rod that is not scheduled on either FL1 or FL3?"*, with the suggestion that a **supervisor override** should gate it if it is allowed, applying to **both pre-check-in and check-in**. **Not covered in the call — carried forward to the next session.**

To resolve:

1. Is running unscheduled material a real case, or is planning always ahead of the floor?
2. If allowed, is a supervisor override the right gate, and does it apply at both pre-check-in and check-in?
3. If allowed, **what order does the run book against** — does scheduling get corrected after the fact, or does the run carry an "unscheduled" marker?

**Cost note:** the off-schedule override column group (`OffScheduleOverride`, `ScheduledLineId` and `CK_RodStaging_OffSched`) was **dropped** on Aug 1, 2026 when Q24 removed its only use. If the answer here is "allowed with an override", it **re-adds** a column group rather than reusing that one — the three shared credential columns (`OverrideBy` / `OverrideAt` / `OverrideReason`) do survive and can be reused.

Related: **Q24**, **Q16** (pre-scheduling validation), **Q73**.

**Recommendation:** **allow it behind a supervisor override**, at both pre-check-in and check-in, with the run carrying an **unscheduled marker** rather than being force-fitted to an order. Trials and rush pieces are real, and a hard refusal by omission means the floor works around the system instead of in it. Reuse the surviving `OverrideBy` / `OverrideAt` / `OverrideReason` columns and add only the marker — that is a far smaller change than the dropped group.

---

**Q26** · `High` · Owner: Tim O. / Charles / Juan · `Open`
**Shopfloor panel resolution — 1280×1024 (stocked) or 1920×1080 (required)?**

Every mockup is authored at **1280×1024**, `flat-wire-fit.js` measures against that design box and calibrates the 14 px minimum-text floor to it, and [phase-01a](../MVP-1/ProjectPlan/Development/Phases/phase-01a-angular-foundation.md) pins *"fixed 1280×1024 shopfloor canvas"* as an acceptance criterion.

Tim expects the new flat wire screens to use the **same monitors as the current ones — 1280×1024, which is what UA stocks** — but will **verify with Charles and Juan** before confirming. Our action from the call: **send Tim the required resolution (1920×1080) by e-mail**; if that is what the application needs, he will look at different screens.

> **Progress (August 24, 2026) — the requirement is with Tim in writing, but UA has still not answered.** Tim, opening the 24 Aug call: *“Divesh, I believe it was you that had asked about the workstation resolution … you were looking for the **1920 by 1080**? … Okay, perfect. **I'll respond to this e-mail from Charles.**”* So the Nagarro-side action is **closed** — the number is on record and Charles has it. **The question is not**: what UA will actually stock is Charles's and Juan's answer, and it has not been given. Note that Tim's phrasing is *workstation* resolution, which may not be the same panel as the shopfloor HMI this question is about — worth confirming that one answer covers both.

**Why this is `High` and time-critical:** 1920×1080 is a **1.5× width and 1.05× height** change, so it is a **re-layout of all 25+ screens, not a rescale** — the extra pixels are almost entirely horizontal. `flat-wire-fit.js` already degrades gracefully *downward* (it never scales above 1:1, and `data-fit="fill"` widens the design box to the window), so a wider panel is the cheap direction and the height barely moves. But the canvas is a **Phase 1 acceptance criterion** against a **14 Aug 2026 gate**, so an answer after Phase 1 closes is an answer that arrives too late to be free.

**Do not re-author anything until this is answered.**

Related: `flat-wire-fit.js`, [phase-01a](../MVP-1/ProjectPlan/Development/Phases/phase-01a-angular-foundation.md), the 14 px minimum text floor.

**Recommendation:** **hold the 1280×1024 canvas** and get Tim's confirmation in writing before the 14 Aug gate. `flat-wire-fit.js` already degrades gracefully onto a wider panel — `data-fit="fill"` widens the design box and it never scales above 1:1 — so 1920×1080 hardware would display these screens correctly today, merely leaving horizontal space unused. That makes 1280×1024 the safe commitment and any later re-layout an optimisation rather than a rescue.

---

**Q27** · `High` · Owner: Tim O. / Engineering · `Open`
**Is speed pushed to the PLC as a target/setpoint, or as a limit/clamp?**

Raised Aug 4, 2026 · client-facing as `PLC-Q06` in [PLCTagSpecification.md](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md). The delivered artifacts say both, and **the SRS contradicts itself**:

| Source | Wording |
|---|---|
| `02-SRS.md` §9.1 · `03-HLD` §9.2 · `04-APIContract` §6.1 · master spec §6.8 | speed **targets** |
| `02-SRS.md` `FR-073` · [RocCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RocCheckin.md) §3.6 | speed **limits** |

**These are not the same tag and they do not fail the same way.** A *setpoint* commands the drives to a speed; a *clamp* bounds whatever speed the operator selects. If the pass schedule's value is written to a setpoint tag when the machine expected a ceiling, acknowledging a check-in starts the line moving at the scheduled speed — which is a commissioning-time surprise on a threading line. If it is written to a clamp when the machine expected a setpoint, the line does not move at all and the fault looks like a missing tag.

Not resolvable from documents. It needs a controls answer, and it is the reason `FR-073`'s wording is left unfixed until this closes.

Related: **Q28**, **Q29**, `PLC-Q06`, `FR-073`, `OI-52`/**Q1** (roll-gap readback — the same "what does the machine actually accept" gap).

**Recommendation:** ask controls directly and, until answered, **implement against a clamp** and leave `FR-073` unfixed. Prefer the loud failure: a clamp that should have been a setpoint means the line does not move, whereas a setpoint that should have been a clamp starts a threading line at full scheduled speed on acknowledgement — a commissioning-time safety surprise. Ask it in the same session as `Q21`, `PLC-Q15`, `PLC-Q02` and `PLC-Q05`.

---

**Q28** · `High` · Owner: Tim O. / Engineering · `Open`
**Is edge type pushed to the machine, and where are the edger tag paths?**

Raised Aug 4, 2026 · client-facing as `PLC-Q07`. Two findings that only appear once the tag surface is read as one document:

1. **Edge type is in the push payload in four sources and absent from a fifth.** `02-SRS` §9.1, `03-HLD` §9.2, `04-APIContract` §6.1 and master spec §6.8 all list *edge type* among the values written at acknowledgement; [RocCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RocCheckin.md) §3.6 and `FR-073` do not. The likely explanation is that RocCheckin's list was written FL1-first and FL1 has no edger — but that is inference, not a confirmation.
2. **No edger tag path exists anywhere in the repo.** The only edger-adjacent tag in any published map is `FL1.EdgeSet.Status.Active` — on **FL1, the one line with no edger** (`D-20`/`D-21`, May 21 2026). FM2's edgers at S2 and S3 (the two 6″ stands) have no status, activation or blade-profile path. So the write side is specified to push an edge configuration to equipment that has no addressable tags on the read side.

Paths are **proposed** in `[PLC §4]` from the derived naming grammar (`FL2.FM2.S2.Edger.Status.IsActive`, `.Edger.Profile`, and the same for S3) so there is something concrete to confirm or correct, but they are our invention and are marked as such.

**The `.Edger.Profile` tag has no value set to carry.** Whether edger blade profiles are standardised or custom per edge type, and who maintains the profile library, is tracked as **`OI-77`** in the master specification. **Ask for the profile vocabulary in the same conversation as these paths**, because a profile tag whose permitted values are unknown cannot be commissioned.

Related: **`OI-77`** (edger blade profiles — the reference data these tags would carry), **OI-36** (the same stand has no roll-gap path either), **G29**, `PLC-Q07`.

**Recommendation:** push edge type on **FL2 and FL3 only**, and treat its absence from `RocCheckin.md` as the FL1-first omission it appears to be — FL1 has no edger, so there is nothing to write there. Put the **proposed edger paths** (`FL2.FM2.S2.Edger.Status.IsActive`, `.Edger.Profile`, and the same for S3) to the controls engineer as concrete strings to confirm or correct, clearly marked as our invention. **`OI-77`** supplies the profile values these tags carry — answer the two together.

---

**Q29** · `High` · Owner: Tim O. / Engineering · `Open`
**On FL3, are FM2 tags addressed as `FL2.FM2.*` or `FL3.FM2.*`?**

Raised Aug 4, 2026 · client-facing as `PLC-Q08`. Every published tag map writes the finishing-mill stands as **`FL2.FM2.…`** — including the map headed *"FL1 shown, other lines follow the same pattern"*. FL3 is the hybrid route and needs **both** FM1 and FM2 tags, pushed as a single batch on one acknowledgement (`FR-096`-adjacent; `phase-10:35`).

So one of two things is true, and no artifact says which:

1. **FM2 is physically owned by the FL2 controller**, and FL3 reaches it through the `FL2.*` namespace. The FL3 push then writes to **two controllers** in one logical batch — which is precisely the case where "the batch was rolled back" is least true (**G16**).
2. **FL3 has its own FM2 address space** (`FL3.FM2.*`), and the FL3 push is one controller.

**This is not a naming preference.** It decides whether the FL3 single-batch push crosses a controller boundary, which determines what partial failure looks like and what the compensating re-clear has to undo. Commissioning test **C5** — *"one acknowledgement configures FM1 and FM2"* — passes either way and therefore cannot distinguish them; it needs a step added once this is answered.

Related: **Q67** (FL1/FL2 simultaneous operation — the same controller-ownership question from the scheduling side), **G16**, **G30**, `PLC-Q08`.

**Recommendation:** assume **FM2 is owned by the FL2 controller and FL3 reaches it through `FL2.*`**, and **design the FL3 push for two controllers from the start** — a per-controller batch with an explicit compensating re-clear on partial failure. That is the harder of the two cases; building for it costs little now, whereas discovering it at commissioning costs a redesign of the push. Add a step to test **C5** that names which controller answered, since C5 passes either way today.

---

**Q30** · `High` · Owner: Tim O. / Bob S. / Engineering · `Open`
**Do take-up load cells exist, and is the spool-completion weight read from them or derived from footage?**

Raised Aug 4, 2026 · client-facing as `PLC-Q14` in [PLCTagSpecification.md](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md). Two artifacts disagree about where the most consequential number in the completion transaction comes from.

| Source | Says |
|---|---|
| The tag specification’s assumption **A2** — rescued from the deleted `HMIAndSCADALayout.md`, which was its **only** home | “Load cells are fitted on both payoff positions **and on both take-ups**” |
| [SpoolCompletionNotification.md](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md) §“Weight” | The weight is “**derived from the live footage counter and the measured cross-section**” |

**And the tag map contains no take-up weight path on any line.** So the interface currently specifies a behaviour — the machine-stop prompt fires when the take-up weight reaches target, and the latched value is what the completion records and the **printed label** carries — that reads a value with no published source.

Three things follow from the answer:

1. **If the weight is derived**, A2’s take-up load cells are real hardware that this interface never reads, and the accuracy of every completion weight rests entirely on **Q10 / `OI-45`** (the footage-to-weight dimensional basis) — already **Critical** and already open.
2. **If the weight is read**, two tag paths are missing from the map and must be added before commissioning test **C9** can pass.
3. **If both exist**, which one is authoritative when they disagree? The spool completion spec already has a scale-versus-calculated reconciliation question open as **OI-56**, and this is the same question one step upstream.

Not decided in the specification on purpose: it is answerable from `SpoolCompletionNotification.md` alone only if that document’s derivation is known to be the *whole* story, and A2 says it may not be.

Related: **Q10** / `OI-45` (footage-to-weight basis), **OI-56** (scale vs calculated spool weight), **Q33** (OD→weight formula), `PLC-Q03`, `PLC-Q14`.

**Recommendation:** specify the completion weight as **derived from footage × cross-section**, matching `SpoolCompletionNotification.md`, and treat any take-up load cell as a **corroborating** reading rather than the source. That makes `OI-56`'s scale-versus-calculated reconciliation the single place a disagreement is resolved, one level down, instead of two competing rules at this level. If the cells exist, add their paths so **C9** can read them — but do not make the transaction depend on them. Accuracy then rests on `Q10`/`OI-45`, which must close regardless.

---

**Q31** · `High` · Owner: Tim O. / Shannon R. · `Open` — principle decided Aug 6, 2026
**Wire break where the customer accepts no welds — what happens to both pieces?**

**Q73**'s companion case, raised by Yogender on the 6 Aug call. **Q61**/`OI-13` settle the normal break: weld and continue on the same alpha (see the decision recorded against `OI-13`). This asks what happens when the customer's specification **forbids welds**, so weld-and-continue is not available.

**Decided in principle:** it is handled with **the same logic as a Z-mill coil break**. Tim: *"that scenario would probably be handled just like the current e-mails where if we have a coil break and we're not going to meet the planned weight… we're going to replan the coil and use another input material coil and rerun the order."* Shannon converged on the same shape — *"it would be very, very similar to the coil break; they have to make a decision on both pieces. It could be returned to warehouse, it could be scrap, it could be continue processing, could be put it on hold."*

The judgement is made by a **supervisor** on the **total linear footage / weight already on the FL1 spool** against the planned weight:

- **Enough material** → approach the customer for a **concession** (*"will you still take this, it's underweight by 250 pounds"*).
- **Early in the run** → **WIP reject**, strip the spool, mount an **empty spool**, **replan** onto another input rod and rerun the order.

**What is still open:**

1. The **disposition vocabulary** — is it exactly the Z-mill set (warehouse / scrap / continue / hold / concession), and does it reuse the existing screen or need its own?
2. The **supervisor gate** — credential block, or an operator decision recorded against a supervisor name?
3. Does the **concession path reuse the existing coil-break e-mail flow**, or does flat wire need its own?
4. **Where the decision is persisted** — shares a target with **G34**.

**Scope note from the call:** Tim flagged this as a genuine **one-off** — a customer ordering one or two skids rather than a truckload, who also refuses welds — and cautioned against over-engineering it: *"we're trying to account for one-offs which we don't know for sure is going to be a thing."* Confirm the frequency before sizing the build.

Related: `OI-13`, **G34**, **Q75** (partial-run disposition — the same decision shape), **Q79** (short close), **Q6** (weld footage attribution — why a no-weld customer is knowable at all).

**Recommendation:** **reuse the Z-mill disposition set and the existing screens** — warehouse / scrap / continue / hold, with concession handled by the existing coil-break e-mail flow — and persist the decision against the run-event stream, the same target `G34` needs. Heed Tim's own caution and **confirm the frequency before sizing anything**: if this is genuinely a one-off, the right build is a supervisor disposition on existing rails. **Recommend no new screen.**

---

**Q32** · `High` · Owner: Tim O. / Engineering · `Open`
**FM2 dancer modes — who selects between dancer mode and tension mode, and how does it reach the machine?**

New equipment behaviour disclosed on the 6 Aug call, and **nothing in the repository models it**. Tim: *"On FM2 we are going to have two different modes on the mill dancers. The two dancers were essentially where the edgers are — between S1/S2 and S2/S3. Those dancers will have two modes: regular dancer mode, compensating speed control, and then they will also have tension mode… similar to what we see on the current mills."*

**Three things follow, and the third is a contradiction rather than a gap:**

1. **The equipment is on record; the model is not.** **FM1 carries one dancer and FM2 carries two**, between S1/S2 and between S2/S3 — decision `D-28` and the master spec glossary ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §234), with FM1's at §157 and [FlatWireProcessWalkthrough.md](FlatWireProcessWalkthrough.md) step 19. **What is missing is the model, not the equipment:** no lookup table beside `Stand`/`Drawer`/`Edger`, no `PassScheduleComponent` row, and no seed data.
2. **No tag element addressed a dancer** on any line, so a selectable mode had nowhere to be written and nothing to read back. **A read-only element was authored on 12 Aug 2026** — `Dancer` on FM1, `Dancer1`/`Dancer2` on FM2, ordinal per rule `R6`, all `[PROPOSED]` and carried as **`PLC-Q18`**. Read-only is deliberate: it is the half that holds whichever way item 4 below is answered. **The write surface is still absent.**
3. **Tension mode contradicts a stated rule.** `PSM012` and master spec §233 both say *"tension is derived from speed, never entered manually."* In tension mode it is not derived from speed. The rule needs **qualifying by mode**, not deleting.

**The questions:**

1. **Who selects the mode** — the operator at the HMI, the pass schedule, or is it fixed per product?
2. **Per dancer or per line?** Both dancers always in the same mode, or independently set?
3. Is it a **pass schedule parameter** (in which case it joins the check-in acknowledgement push) or a **machine-side setting** the system only reads?
4. If it is pushed, **what carries it** — a question for `[PLC]`, which currently has no dancer element.
5. In tension mode, **is a tension setpoint entered**, and if so where does it come from?

Answering 3 decides whether this adds a column and a component row (schema + DDL) or only a read subscription. Gap **G35**.

> **⚠ Two client statements conflict on question 3, and the earlier one is the one that answers it.** Ingested 12 Aug 2026 from the [23 Jul 2026 meeting summary](../BaseDocuments/ClientCall_2026-07-23_SyncPlan.md) §3.1.
>
> | Date | Position | If adopted |
> |---|---|---|
> | **23 Jul 2026** | *"Dancers **remove** tension rather than apply tension. Tension control will primarily be **machine-driven**. Configuration values controlled through **process settings**."* | Mode is **read-only** — no push payload, no `PassScheduleComponent` column, no MVP-1 → MVP-2 coupling |
> | **6 Aug 2026** — `D-28` | FM2 carries **two dancers, each with two modes**, one being **tension mode** | Mode may be **written**; `PSG-D27` models applied tension **reducing separating force** |
>
> **Not resolved here.** The 23 Jul position is the earlier one, and by convention later client direction wins — but nobody has said the two conflict, and they may not: a dancer can physically *absorb* tension while still offering a machine-side tension mode. **A second question rides on it:** if dancers remove rather than apply tension, `PSG-D27`'s substitution `σ̄_f,eff = σ̄_f − (σ_b + σ_f)/2` may model something the equipment does not do — and that feeds **separating force and roll gap through `F/K`**. That is an engineering answer, not an editorial one. Both are sent back to Tim O. / Engineering.

> **Do not ask this twice — it is also `PSG-Q29`.** The generation spec raises question 3 client-facing as **`PSG-Q29`** (*"is the mode a schedule parameter or a machine setting?"*) and the setpoints as **`PSG-D27`**, both added 6 Aug 2026. That document goes to the client on its own sign-off sheet, so **one answer must close both** — when `PSG-Q29` returns, close `Q32` from it rather than re-asking.
>
> **And there is an engineering consequence this register did not carry.** Applied tension **reduces roll separating force** — the standard result is that tension substitutes for roll pressure at the same draft. So in tension mode the untensioned force model **over-predicts `F`** (runnable schedules rejected against `F_max`) *and* the roll gap `S₀ = h_target − F/K` inherits the error and **delivers thin**. The generation spec states the substitution as `σ̄_f,eff = σ̄_f − (σ_b + σ_f)/2` (`[PSG §3.3.6]`); until `PSG-D27` arrives, schedules are generated untensioned and flagged — conservative for force, **not** for gauge. Mode selection is therefore not only a tag question: it changes two computed values on the pass schedule.

Related: **Q1** (roll gap validation — the other per-component setpoint), **Q28**/**G29** (the edgers, which sit in the same inter-stand positions), **`PSG-Q29`**/**`PSG-D27`** (the same question, client-facing), `PLC-Q##` to be raised once 3 is answered, gap **G35**.

**Recommendation:** ⚠ **Contested by the 23 Jul client statement above — read both before acting.** It argues the opposite of that statement and is left standing deliberately: if the client confirms machine-driven control, **this recommendation is wrong and the read-only surface already built is the whole answer**. Model the mode as a **pass schedule parameter**, not a machine-side setting the system merely reads — it changes two computed values on the schedule (separating force, and therefore roll gap), so a read-only treatment would let the schedule and the machine disagree about the physics. That implies a `Dancer` lookup row, a `PassScheduleComponent` entry, a tag element, and the mode joining the acknowledgement push. Recommend **per dancer**, since the two sit in different inter-stand positions. **Close this from `PSG-Q29` — do not ask it twice** — and until `PSG-D27` arrives keep generating untensioned and flagged, remembering that is conservative for force but **not** for gauge.

---

**Q33** · `High` · Owner: Tim O. · `Open`
**OD/diameter → weight conversion formula for spool**
When a spool is measured by outer diameter at the takeup, how is the remaining weight calculated? The formula (using OD, ID, coil width, and alloy density) must be confirmed by Tim O. and documented before spool weight tracking and "assign as-is" stock handling logic can be implemented. Weight distribution is tracked via footage and revolutions per the Apr 28 planning decision, but the OD-based verification formula is still needed.

**Recommendation:** derive it from **`Q10`'s single factor** rather than as an independent formula — annulus volume from OD, ID and coil width, times alloy density — so spool weight, coil weight and the printed label all trace to one number. Two independently confirmed formulas will disagree in the third decimal and nobody will know which is authoritative. `OI-56`'s accumulated scale-versus-calculated variances are the data that validates it.

---

#### A13. Shared-System Write-Back at Coil Completion

*New 18 Aug 2026, with `FR-509`–`FR-518` and `[INT §8.1]`. All three are **IT** questions about the existing shared schema, not design choices — we have proposed a value for each and each is a one-line change if the answer differs, but all three must be confirmed **before the write-back runs outside DEV**.*

**Q34** · `High` · Owner: Tim O. / IT · `Open`
**The transaction token for a flat wire coil completion**
Completing an FL2/FL3 coil writes a finished-goods coil row, a genealogy row and a WIP log row, and each of those carries an eight-character transaction name (`coils.transaction_name`, `coil_gen_history.in_xaction`, `wip_log.transaction_name`). What token should flat wire use, and does any existing stored procedure, view or report branch on that column in a way a new value would disturb?

**Recommendation:** a **new token, `FWCOMPLT`** — eight characters exactly, which is the full width of all three columns, so it fits everywhere without truncation and the same value makes the transaction traceable end to end. A **new** token rather than a reused one because both reuse candidates are actively wrong: `CREATSKD` would make flat wire indistinguishable from slitter skid creation in the WIP log, and `STORCOIL` would trip the `transaction_name = 'STORCOIL'` branch in `coils_iud_tg` and produce a **second, duplicate** WIP log row on top of the one the procedure writes.

**Why:** this is the one value in the write-back that is visible to every existing consumer of the WIP log, and the blast radius is unknown to us — the impact audit that would have found the answer was cancelled with `D-32`. It is the same class of question as **`OI-111`**, narrowed to a different column, and it is cheap to answer and expensive to get wrong.

---

**Q35** · `High` · Owner: Tim O. / IT · `Open`
**Is `ONSKID` the right coil status for a finished flat wire coil?**
The finished-goods row written at coil completion needs a value in `coils.coil_status`. Should flat wire reuse the existing `ONSKID`, or does finished flat wire need to be distinguishable from other material by status?

**Recommendation:** **reuse `ONSKID`.** It is literally true — the coil is complete and on a skid — and it is exactly what `CreateSkid_MoveCutsOnSkid` writes in the same situation. A new value would be an addition to the **shared status vocabulary**, which is precisely the change `D-32` cancelled, so it should only be introduced if a named consumer requires it.

**Why:** the question is not what the coil *is*, which is settled, but whether any availability check, report filter or scheduling screen needs to tell finished flat wire from finished rolled material. If one does, the answer is a report change rather than a new status value — and that is worth establishing before the first coil is written rather than after.

---

**Q36** · `Medium` · Owner: Tim O. / Planning · `Open`
**Sample number and planned operations for a flat wire output coil**
The order link written at coil completion carries `smp_no` and `planned_operations`. Where the source rod already has an order row these are copied from it, which is what the slitter path does. Where it does not, what should a flat wire output coil carry?

**Recommendation:** **copy from the rod's row wherever one exists** — that is the established behaviour and needs no decision — and fall back to `smp_no = 888` with `planned_operations = 'P'`, matching the equivalent fallback in `CreateSkid_MoveCutsOnSkid`. Confirm the fallback rather than the copy: the copy is safe, the fallback is a guess.

**Why:** the fallback only fires when a rod reaches coil completion without an order row, which should not happen if check-in did its job — so this is a question about what a **defensive** path should write, and the cost of being wrong is a misleading sample number on an edge case rather than a broken transaction. Ranked `Medium` for that reason.

Related: **Q34**, **Q35**, **`OI-114`** (the cut-record sentinels — the same class of question, but there is no majority among the legacy writers to follow), **`OI-111`** (which consumers read `coils.coil_status`), **`OI-112`** (the unreleased WIP station).

---

#### A14. Shared-System Write-Back at Rod Check-in

*Registered here 20 Aug 2026, and **they were minted on 19 Aug and never reached this register** — `G45`, `[INT §8.0]`, `[REQ §5.26]`, [`FW-220`'s plan](../MVP-1/ProjectPlan/Backend/tasks/FW-220.md) and `CHANGELOG.md` all cite `Q37`–`Q40` against a register that declared itself contiguous at `Q36`. Recorded as gap **`G46`** so it is not repeated. Like `Q34`–`Q36` these are **IT** questions about the existing shared schema rather than design choices; each has a proposed value and each is a one-line change if the answer differs. All four block **reaching a shared environment**, not the build.*

**Q37** · `High` · Owner: Tim O. / IT · `Open`
**The transaction token for a flat wire rod check-in**
Checking a rod in at FL1/FL3 writes nine shared objects, several of which carry an eight-character transaction name. What token should flat wire check-in use, and does any existing stored procedure, view or report branch on that column in a way a new value would disturb?

**Recommendation:** a **new token, `FWCHKIN`** — the same reasoning as `Q34`'s `FWCOMPLT`. A new value rather than a reused one, so a flat wire check-in is distinguishable from a mill or slitter check-in in the WIP log, and so the transaction is traceable end to end under one name.

**Why:** it is the value most visible to existing consumers of the WIP log, and the impact audit that would have identified them was cancelled with `D-32`. Cheap to answer, expensive to get wrong.

---

**Q38** · `High` · Owner: Tim O. / IT · `Open`
**The `wip_log` status value for a rod on a flattening line**
The transaction-log row written at check-in needs a value in `wip_log.coil_skid_status`. Does flat wire need one of its own, or does it reuse an existing value?

**Recommendation:** **reuse `INROLL`.** A new status-shaped value in a shared vocabulary is exactly the change `D-32` cancelled, and `INFLAT` was considered here and rejected for that reason. `INROLL` is true of the material — it is on a mill being rolled — and every existing reader already handles it.

**Why:** `INFLAT` exists only as a `FlatWireDB`-local value on `Rod.Status` / `SpoolProcessing.Status`, and letting it leak into a shared column would re-open the migration `D-32` closed. Confirm that no report needs to tell flattening from rolling in the log; if one does, that is a report change, not a new status.

---

**Q39** · `High` · Owner: Tim O. / IT · `Open`
**Is stamping the rod's shared coil row with a flattening station safe for existing consumers?**
Check-in stamps the rod's `proddb..coils` row with `wip_station`, `wip_badge_no`, `transaction_name` and `coil_rev_time` — restoring the upstream visibility lost when `D-32` cancelled `FW-002` — while deliberately **not** writing `coil_status`. Does any existing consumer read those four columns in a way a flattening-line value would disturb?

**Recommendation:** **write all four.** They are how every other operation marks a coil as being worked, the values are ordinary, and leaving them blank is what created `OI-111`. Confirm rather than assume, because it is the one place flat wire becomes visible in the shared schema at all.

**Why:** this is `OI-111` narrowed to four named columns. The alternative — a rod being processed with nothing in the shared record to say where — is the state that was found unacceptable on 18 Aug.

---

**Q40** · `High` · Owner: Tim O. / IT · `Open`
**On reversing the reqsum at pre-check-out, delete the row or leave it?**
Pre-check-out reverses the requirement summary written into `wip_coil_orders` at check-in. Should the reversal **delete** the row, or leave it in place with zeroed quantities?

**Recommendation:** **leave it and zero it**, not delete. A deleted row destroys the evidence that the material was ever claimed against the order, and the reversal already refuses when footage is greater than zero — because a Mode B removal's reqsum records material the order genuinely received. Zeroing is reversible and auditable; deletion is neither.

**Why:** the safe direction is the one that keeps the audit trail, and `RodCheckin.WipCoilOrdersWritten` already defaults to the safe direction so that a missing value never authorises a delete. Confirm whether any existing report counts rows rather than summing quantities — that is the one case where a zeroed row reads differently from an absent one.

Related: **Q34**–**Q36** (the same class at the other end of the run), **`OI-115`** (the FL2 half of this write set, undefined and **blocking**), **`OI-116`** (`coil_mill_processing`), **`G45`**, **`G46`**.

---

#### A15. The Spool as a Physical Carrier, and the Multi-Rod Spool

*New 20 Aug 2026, from the [client call of that date](../BaseDocuments/ClientCall_2026-08-20_SyncPlan.md). Seven questions arising from nine decisions — the spool carrier is now a confirmed physical article rather than an inference, a spool is confirmed to carry many rods and many orders, and FL2 is confirmed to want pre-check-in. **`Q41` is the only `Critical` one**, because a requirement asserted in a `CHECK` constraint has been reversed and its replacement shape is unknown.*

**Q41** · `Critical` · Owner: Tim O. / Bob S. · `Open`
**What does an FL2 pre-check-in actually do?**

> **Decided (August 20, 2026) — FL2 gets pre-check-in.** Tim and Bob, having agreed it between themselves: *"We do want pre-check-in for FL2 … to validate the next spool and to eliminate the potential for downtime due to the fact that they grabbed the wrong spool and then would find out at check-in and then have to go and locate the correct one."* This **reverses `FR-031`** (*"the system shall not support pre-check-in on FL2 — a `lineId` of `FL2` is rejected"*), which is asserted in **eighteen documents** — sixteen of them citing `PCI002` across thirty citations, including a `CHECK` constraint in the DDL and a *"deliberately NOT created"* comment against the `FL2PO` WIP station, plus two that assert the exclusion without citing the rule at all.

**What is not decided is its shape, and `PCI002`'s physical premise was never contradicted** — FL2 still has one traversing payoff and no floor space, and `RocCheckin.md` §4.3 states that spool visual inspection is **not required**. So Dashboard 2A cannot simply be pointed at FL2: its two defining mechanics, **two alternating payoff bays** and **inspection before unbanding**, do not exist there.

1. Does the pre-check-in **persist a record**, or is it a read-only validation the operator performs and moves on from?
2. Does it **claim a WIP station and hold it** until check-in, or claim and release within the transaction?
3. Does it **gate** check-in, or stay **`Should`** as FL1's does — where scanning an unstaged rod straight at check-in remains a supported path?
4. If it persists, does the record carry a **position** at all, given there is only one?

**Recommendation:** **validate and release, with a persisted record and no bay.** Write a row so that the validation is auditable and the operator's time is not lost, claim the `FL2PO` station within the pre-check-in and release it on completion rather than holding it, carry **no** payoff position, and keep the function **`Should`** — check-in must remain reachable without it, exactly as at FL1. That satisfies Tim's stated purpose, which is validation, without inventing staging on a line that has nowhere to stage.

**Why:** the answer decides whether this is a screen change or a schema change. `RodStaging` cannot host it — its columns are rod-shaped (oxidation / surface-defect / water-stain inspection, `IsWelded`, two-bay states, `PayoffPosition NOT NULL`, `CK_RodStaging_LineId IN ('FL1','FL3')`) — so a persisted answer adds a table and moves a published count (**`OI-118`**). The screen already exists as **Dashboard 5A**, which lists runnable spools and resolves the order from a scan; what it does not do is record anything, and its own rule SQ-12 says so.

Related: **`OI-118`** (where the record lives), **`OI-26`** (whether FL3 shares FL1's VPS — the same question one line over), **`G21`** (`UX_RodStaging_Bay` scope, still blocking the Phase-4 schema freeze), `FR-031`, `FR-533`+, story `FW-224`.

---

**Q42** · `High` · Owner: Tim O. / Bob S. · `Open`
**The spool carrier identifier format, and where the registry is mastered**

> **Decided (August 20, 2026) — spool numbers are static, not dynamic.** Standardised like plate numbers, in the client's own comparison: *"I can't make up a plate number, but a skid number I can make it up."* **30 purchased**, with a decision on a further **15** being taken the same day; **all one standard size**; **all identical except for identity**; and **marked physically** — *"the plan is to mark the spools with whatever nomenclature we're going to use to identify them."* The dynamic-number option was raised twice more and rejected both times. **Entry is a text box validated against the registry, not a drop-down** — 30 to 45 rows is too long to scroll on a shopfloor panel.

Still owed: the **format** of the stencil string, and where the registry lives.

1. What is the nomenclature — `S1`…`S45`, `SP-01`, zero-padded, something else? (**A5** on the call.)
2. Is it 30 or 45, once the purchase decision is made?
3. Is the registry mastered in `FlatWireDB`, or does an existing shared table already carry the plate-like articles?

**Recommendation:** a **`FlatWireDB` lookup named `Spool`**, with the client's stencil string as the natural key and a unique constraint on it, seeded from the physical inventory and soft-deletable like the other lookups. **Do not overload `SpoolProcessing.Alpha`** — that is the *material* identity (`SP-#####`, generated per spool of wire) and the carrier is a reusable physical article that outlives it; conflating them is the exact confusion `SpoolQueue.md` open item 1 was raised to prevent. Accept the stencil string as typed and case-insensitively, since an operator is reading paint off steel.

**Why:** nothing in the schema was a spool carrier (**`OI-120`**) until `Spool` was built on 22 Aug 2026 — **which makes the format question live rather than academic: the table has a `SpoolNo` column waiting for a decided format.** *(The clause "and nothing seeds it" was true until 23 Aug 2026 — 45 provisional rows now exist; see the note below.)* `SpoolConfiguration` looks like the candidate and is not — it is a **size class** (min/max weight, core and outer diameter) and the client has just confirmed every spool is one size, so it would hold exactly one row while the carriers number 30 to 45.

**Seeded, but still open (23 Aug 2026).** The registry now carries its **real size: 45 articles, `SP-0001`…`SP-0045`**, replacing four placeholder rows — 44 active plus `SP-0045` marked withdrawn so the `IsActive = 0` path stays covered. That settles **neither** half of this question: the **format** is provisional and the **count** (30 or 45) is still the client's, pending the purchase decision on the further fifteen.

**Four digits, deliberately, and this is the part not to undo.** `OQ-K` instructs *"build to `SP-0001`…`SP-0045` meanwhile"*, because five digits would make a carrier number **string-identical** to a `SpoolProcessing.Alpha` (`SP-#####`) rather than merely similar — the seeded material alphas `SP-00031`/`SP-00032`/`SP-00033` all fall inside 1–45. That would re-create the conflation the `Spool` / `SpoolProcessing` split (**`Q60`**) exists to prevent, and break `SpoolQueue.md` item 1, closed 20 Aug 2026: *"any one identifier on the label — the spool number or any alpha — resolves the spool."* `OQ-K`'s `SC-0001` prefix would remove the ambiguity outright and remains the better long-term answer.

**The format is built from one expression** in `FlatWire_SampleData_Lookup.sql`, not 45 literals, so answering this question is a one-line change. Deciding it is still cheap — do not treat the seeded rows as a commitment.

Related: **`OI-120`** (no carrier entity exists), **`Q17`** (the spool state machine — a carrier returning to the pool is a state of the *carrier*, not of the material), **`Q46`**, `SpoolQueue.md` §7 item 1 (closed by this decision).

---

**Q43** · `High` · Owner: Tim O. / Planning · `Open`
**How many orders may one spool carry, and does FL2 check-in choose the order or inherit it?**

> **Decided (August 20, 2026) — a spool carries many rods and many orders.** Bob: *"We could technically have two separate orders that are made onto a spool coming off of FL1. When it gets checked into FL2, we're only going to make **one order at a time** out of FL2, but there could be two orders or more on the spool going into FL2."* Srikanth: *"Spool to A-rods is one to many. In turn, that one A-rod could be on multiple orders as well."*

The open half is what check-in does with the set.

1. Is there a **bound** on the number of orders on one spool, or is it whatever planning allocates?
2. Does the FL2 operator **select** which order is being made, or is it derived from the lead alpha (**`Q45`**) or from planning?
3. May a spool be checked in with **no** order — the planning remainder and accepted-partial cases that `SpoolQueue.md` rule SQ-6 already permits?

**Recommendation:** **the set is planning's to allocate and check-in selects one from it.** `SpoolCheckin.OrderId` keeps its singular meaning — *the order being made now* — and is **relaxed to nullable** so that SQ-6's unallocated spool can actually be checked in, which the present `NOT NULL` forbids. Do not bound the count in the schema; validate that the selected order is a member of the spool's set, which is the check that matters. Default the selection to the lead alpha's order and let the operator change it, so the common case is one keypress.

**Why:** `SpoolProcessing.OrderNo` is a scalar `VARCHAR(50) NULL` and `SpoolCheckin.OrderId` a scalar `VARCHAR(20) NOT NULL`, and the second contradicts a published rule of the queue screen already (**`OI-119`**). Deciding the selection mechanism now is what stops the association table being designed around a single order and rebuilt later.

Related: **`OI-119`** (the two scalar columns), **`Q45`** (the lead alpha, if it is to drive the default), **`Q70`** (a rod may carry more than one order — decided 30 Jul; this is its spool-level consequence), **`G42`**.

---

**Q44** · `High` · Owner: Tim O. / Bob S. · `Open`
**What does the FL1 spool label print, and on what media?**

> **Decided (August 20, 2026) — the high-temp coil label, two per spool.** Spools pass through anneal, so no ordinary label survives. Bob: *"It'll be the **1½ by 3 inch label**, the ones that are output from the mills — you get **2 per label, one for each side of the spool**, slap it on."* Tim: *"My thought was the high-temp labels with the alphas on them, just like we do the cut labels now that are going to anneal."* And **any one identifier on the label resolves the spool** — Bob: *"Just like the furnace plate … they only have to scan one of the coil codes on a furnace plate to get it into anneal."*

Still owed: **the field list**, and whether the durable option replaces or supplements this one.

1. Exactly which fields print — the spool number and the alphas are confirmed; what about **weight per alpha**, the order or orders, gauge and width, the FL1 run?
2. Does the **etched stainless-steel barcode plate** (Bob's investigation, **A4**) replace the label or sit alongside it?
3. Is the label reprintable, and if a spool is re-labelled after anneal, what reconciles the two?

**Recommendation:** print the **carrier number, every alpha on the spool with its weight, and the order(s)** — carrier number as the primary barcode and each alpha as a secondary, so that scanning any of them resolves the spool as the client described. Keep the pass schedule off it, per `Q84`. Treat the etched plate as a **supplement** carrying the carrier number only: it is permanent and the carrier is permanent, whereas the material and its alphas change every cycle, so etching those would be wrong within one run.

**Why:** [`SpoolCompletionNotification.md`](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md) refers to printing the labels **nine times and never states what is on them**. The media and layout are now confirmed and recorded there; the field list is the half that still needs an answer, and it depends on **`Q10`** for any printed weight.

Related: **`Q45`** (the lead alpha on the label), **`Q10`** (any weight printed rests on it), **`Q4`** (skid labelling — the analogous open item at the finished-goods end), **`Q87`** (the FL2 finished-coil label — the same question one station downstream, raised 24 Aug), **`OI-121`** (weight per alpha), **`OI-115`** (which identifier reaches the shared WIP station).

---

**Q45** · `High` · Owner: Tim O. / Engineering · `Open`
**Is *last on, first off* guaranteed, and is the label's lead alpha therefore a fact or a prediction?**

> **Principle stated (August 20, 2026).** Bob: *"Whichever one is going to be the lead in printing the label should always be the one that is expected for check-in at the next operation."* Tim's basis: *"The last one on is going to be the first one off … say you have R1A and R2A on the spool and R2A came on last, then R2A would be the first one off on FL2 and R1A would be the last one off. We had discussed that the spool runs in reverse."*

> **⚠ The apparent contradiction on the call is between two different claims, and both are true.** Yogender objected that FL1 is a continuous run and *"we can't identify that this is going to be the first one"*. Tim's statement is about **rod alphas** and is determined by the take-up; Yogender's is about the **FL2 output coils** cut from the spool, which genuinely cannot be sequenced in advance. Anyone reading the exchange as a disagreement will conclude the wrong thing.

1. Does the **traversing take-up** guarantee reverse unwind, or can the spool be threaded from either end?
2. Is the lead alpha therefore a **fact** the system can validate against, or a **prediction** it must be willing to be wrong about?
3. If a non-lead alpha is scanned at FL2 check-in, is that an error, a warning, or normal?

**Recommendation:** treat it as a **prediction and accept any alpha on the spool.** Print the expected lead prominently, and on a non-lead scan resolve the spool and proceed **without a warning** — the operator is holding the spool and the system is not. Ask engineering to confirm the unwind direction anyway, because if it is guaranteed the label becomes checkable and a genuinely mis-threaded spool becomes detectable, which is worth having.

**Why:** the cost of the two errors is asymmetric. Treating a prediction as a fact stops a correct spool at check-in and puts the operator on the phone; treating a fact as a prediction loses a check nobody currently has. Until engineering answers, the permissive reading is the safe one.

**Consequence added 22 Aug 2026 — this question has arithmetic behind it, not only a label.** [`RodOrderAllocation.md`](../LatestDocument/RodOrderAllocation.md) §2.5 shows that the unwind direction decides **which output coil the weld lands in**, and therefore that coil's `CoilTraceability` rows, its primary rod, and the parentage its certificate states. On the shipped example: **LIFO** gives coil 1 = 900 lb of one rod and coil 2 = 500 + 400 across the weld; **FIFO** gives coil 1 = 400 + 500 across the weld and coil 2 = 900. Same coils, same weights, **different genealogy**. ⚠ **The client's own planner cannot settle it — it consumes FIFO and names LIFO**, contradicting itself in one procedure. The design builds to **LIFO** meanwhile, because a spool unwinding last-on-first-off is geometry.

**Consequence added 26 Aug 2026 — the unwind direction now decides HOW MANY alphas a coil carries, not only whose parentage it records.** Under `Q89`'s decision every output coil mints **one shared alpha per source rod**. On the shipped example **LIFO** gives coil 1 **one** parent (900 lb of `R00002`) and coil 2 **two** (500 + 400 across the weld); **FIFO** inverts that. So the direction changes the **cardinality** of the shared-schema write, the number of `coil_gen_history` rows, and the number of `proddb..coils` records — not merely which rod each names. ⚠ **A test asserting a coil's alpha count is asserting the unwind direction.**

Related: **`Q43`** (whether the lead alpha defaults the order selection), **`Q44`** (what the label prints), **`Q17`** (spool lifecycle), **`Q89`** (one shared record per source rod — decided), **`OI-121`**.

---

**Q46** · `Medium` · Owner: Tim O. · `Open`
**Mandrel / core diameter at FL1 — selected, fixed, or read?**

> **Context (August 20, 2026).** Confirmed on the same call that the carrier is captured at the **FL1 spool-completion transaction** and that the transaction cannot be created without it. Tim added a rider: *"Similar to kind of like when you're on a slitter and you have to select the mandrel size, almost like that. Like we need to know what spool is there. **We need to know what diameter mandrel is attached.**"*

Nothing captures it. `SpoolConfiguration` carries `MinCoreDiameterIn` / `MaxCoreDiameterIn` as a **range on the size class**, which is not a selection, and no screen or table records a per-spool value.

1. Is the mandrel **selected per spool** at the completion transaction, as on a slitter?
2. Or is it **fixed** by the single standard spool size the client has just confirmed?
3. Or is it **read from the machine** over the tag surface?

**Recommendation:** **fixed by the standard size, and therefore not entered.** The client confirmed all spools are one size, and a value that can only take one value is a field the operator will get wrong sooner than the system will. Record it as a property of the `SpoolConfiguration` row rather than as an input, and revisit only if a second spool size is ever bought. If the client says it does vary, it belongs on the completion transaction beside the carrier — not on check-in, which is at the other end of the machine.

**Why:** the slitter analogy is the client's, and on a slitter the mandrel genuinely varies. Here it may not, and the difference is a mandatory field on a hard-gated transaction. It also matters to **`Q33`**: an OD-to-weight calculation needs the core diameter, and taking it from a range rather than a value is how the third decimal place goes wrong.

Related: **`Q33`** (OD → weight needs the core diameter), **`Q42`** (the carrier registry that would hold it), **`Q30`** (whether the completion weight is read or derived at all), `SpoolCompletionNotification.md`.

---

**Q47** · `Medium` · Owner: Tim O. / Planning · `Open` · `Scope = Other`
**Is the maximum output coil weight the optimisation target, or the start of a downward search?**

> **Decided (August 20, 2026) — plan to the maximum output coil weight and work backwards.** Two constraints in order, from Bob: *"You want to maximise your spools out of FL1 so you can maximise your anneal capacity. And then you always have to take into account the min and maxes for the output customer and make multiples of those backwards at the max shippable weight … make sure that you're not creating waste at the FL2 side."* Tim: *"It should be rounded to the nearest **output**. If the customer's min is 700 lb for the finished coil off of FL2, then putting 400 lb on a spool does nothing for us but create scrap."* On which value to divide by, within an 800–900 lb range: Srikanth *"start with the 900 and work backwards"*; Tim *"we should be optimising to the max weight."* The method as worked on the call: **planned weight ÷ max coil weight, floor, multiply back** — 44,000 ÷ 900 = 48.8 → 48 → **43,200 lb**, no overage and inside tolerance. Also agreed: the input is the **planner's planned weight**, not the order weight, with the existing over-order warning; and where the order quantity is below the spool size, the order quantity governs.

The residual is narrow and was asked but not answered in the terms it was asked.

1. Is the maximum simply the divisor, or should the algorithm **search downward** — 899, 898 — for the value that minimises scrap or over-shipment?
2. If it searches, what is it minimising: scrap weight, over-shipment against the order, or the coil count?

**Recommendation:** **use the maximum as the divisor; do not search.** Both client voices said *optimise to the max*, the floor already guarantees no overage, and the largest coils mean the fewest cuts and the fewest units to the customer — which is what Srikanth gave as the reason. A downward search buys a smaller remainder at the cost of an algorithm nobody can predict the output of at the planning desk. Present the remainder to the planner instead and let them place it.

**Why:** Shray's question was specifically about searching downward, and the answer he received was about starting high — the two are compatible sentences that do not settle it. ⚠ **And record the arithmetic, not the audio:** the correct figure is **43,200 lb**; *"42,200"* and *"42,000"* were both said over the top of it on the recording, and either would plan 1,200 lb light.

Related: **`Q18`** (the customer min/max is the basis, and its order field is still owed), **`PSG-D32`** (the planned output multiple per line — must not resolve to two values), **`Q10`** (every weight here rests on it), **`OI-60`** (metallic yield per route).

---

### Section A16 — Rod ↔ Order Allocation

*Raised 22 Aug 2026 from [`RodOrderAllocation.md`](../LatestDocument/RodOrderAllocation.md), the design for the rod ↔ order many-to-many. Nothing in the repository persisted that pairing; it existed only implicitly in `united_db..planning_routings`.*

---

**Q48** · `Critical` · Owner: Tim O. / Planning · `Open`
**Can planning put two orders with different pass schedules on one rod?**

A rod split between two orders is processed **once, continuously** — checked in at mount and left on the payoff across the order boundary, with the operator marking order 1 complete and starting order 2 on the same mount. That is the client's rule 7.

**The schema makes one consequence unavoidable.** `FlatWireRun.PassScheduleId` is a scalar `NOT NULL`, and check-in is the moment the pass schedule is acknowledged and the PLC tags are pushed. No second check-in means **no second tag push** — so both orders necessarily run under the *first* order's pass schedule.

1. Can two orders sharing a rod ever differ in gauge, width or edge type — or does planning already guarantee they cannot?
2. If they can, is the correct behaviour to **refuse the mounted handoff** and require checkout plus re-check-in, so the tags are re-pushed?

**Recommendation:** **treat it as a refusal to cross mounted, not a refusal of the order.** Validate at the acknowledgement that the incoming order's schedule matches the running one; if it does not, tell the operator the rod must be checked out and re-checked-in. That keeps rule 7 true wherever it *can* be true and fails loudly where it cannot, rather than silently running an order on the wrong tags.

**Why:** this is the one question that decides whether rule 7 is universal or conditional, and the failure mode is silent — material produced to the wrong gauge under a schedule nobody re-acknowledged. `Q70` confirms the two orders share an **alloy**, which is suggestive but not the same guarantee: alloy is not gauge, width or edge.

Related: **`Q70`** (a rod may carry more than one order), **`Q73`** (the consumption sequence), **`Q14`** (pass schedule selection at check-in), `FR-137`.

---

**Q49** · `High` · Owner: Srikanth / Tim O. · `Open`
**Does multi-order-last hold when no weld is involved?**

`Q73` (6 Aug 2026) settled the consumption sequence as **full coils → partials → multi-order coils last**, and scoped the rule to the welded case. Its item 6 records that **the transcript supports two readings** and that the branch was never settled: Srikanth scoped it to welding (*"if welding is not involved… they can go in any which sequence, right? Because it's harmless"*), while Yogender argued the multi-order case differs regardless, because in a continuation one order must complete before the second starts.

**Asked as one sentence:** *when no weld is involved, may an operator run a rod that carries two orders before the other rods of the first order?*

**Recommendation:** **keep multi-order-last in both cases.** Build the stricter rule now and relax it only on an explicit answer.

**Why:** the orders are consumed **sequentially from one continuous rod** whether or not a weld joins it to the next — which is Yogender's point, and it is about the material rather than the joint. Relaxing the rule later is a validation change; discovering it was needed costs an order boundary that cannot be honoured. ⚠ **`Q73`'s own entry is currently the only record that this branch is open** — it has no `OI-##` mirror — which is why it is minted here.

Related: **`Q73`** (the three-tier rule), **`Q24`** (out-of-sequence override), gap **`G22`**.

---

**Q50** · `High` · Owner: Tim O. / Shannon R. · `Open`
**What overrun past the allocated weight is acceptable, and who is told?**

When the weight allocated to the running order is reached the system notifies the operator, but **does not close the order** — the operator marks it complete. The interval between those two moments is a real state, and the material keeps running through it, so the actual consumed weight **may exceed the allocation**.

1. Is there a bound past which the operator is warned a second time, or a supervisor is alerted?
2. Is there a bound past which the system should act — and if so, what action, given that stopping mid-rod scraps continuous material?

**Recommendation:** **warn and escalate; never stop the line.** Make the threshold configurable, warn the operator at the allocation, escalate to a supervisor at a second configurable bound, and record the overrun on the consumption record either way. Do not add an automatic stop.

**Why:** the overrun is attributed to the *next* order, so it is a planning variance rather than lost metal — while a mid-rod stop is unrecoverable scrap. No bound exists anywhere in the repository today; **`OI-103`** is the precedent for an unbounded machine-facing value, and the same reasoning applies.

Related: **`OI-103`** (no bound on a roll-gap change), **`FR-153`** (the ±2 % weight tolerance).

---

**Q51** · `Medium` · Owner: Tim O. / Planning · `Open`
**On an early acknowledgement, where does the unconsumed allocation go?**

The operator may mark an order complete **before** the allocated weight is reached — the acknowledgement is authoritative, so this is permitted rather than blocked. The pairing then closes under its allocation.

Does the shortfall roll forward to the next order on that rod, return to stock as available weight, or leave the order **short** and route to the planner?

**Recommendation:** **leave the order short and surface it; do not silently reallocate.** Close the pairing with the variance recorded, derive the order's status as `Short`, and let planning decide — the same shape as the existing back-to-stock path.

**Why:** an early acknowledgement is a judgement about the *material* (a defect, a break, a customer change) and the system cannot know which. Rolling the remainder forward automatically would silently change what the next order is made from, and the genealogy would record it without anybody having decided it.

Related: **`Q52`** (the same question when the rod runs out instead), **`Q73`** (a partial is a back-to-stock).

---

**Q52** · `High` · Owner: Tim O. / Planning · `Open`
**A shared rod exhausts before the outgoing order is satisfied — top up, or stay short?**

A rod carrying the boundary between two orders is the **last** rod of the outgoing order and the **first** of the incoming one. If it runs out before the outgoing order's allocated weight is reached, that order is short and the incoming order has lost its planned first rod.

1. May an **unplanned rod** be substituted in to finish the outgoing order?
2. If so, does it need a supervisor authorisation, and what does the run book against?

**Recommendation:** **allow a substitution behind a supervisor authorisation**, recorded as such on the allocation, reusing the existing credential columns rather than adding a new group.

**Why:** the alternative is an order left short for a reason nobody chose, on a line that has material available. Substitution is already a real case elsewhere — **`Q25`** asks the adjacent question for material scheduled on no line at all — so the mechanism should be one mechanism.

Related: **`Q25`** (unscheduled material), **`Q24`** (staging overrides and the credential columns), **`Q51`**.

---

**Q53** · `High` · Owner: Tim O. / Shannon R. · `Open`
**Is fulfilment consumed or produced pounds — and which does the certificate state?**

An order's progress can be measured on the **input** side (pounds of rod consumed against it) or the **output** side (pounds of finished coil produced for it). The two differ by yield, and both are computable from the design's records.

1. Which number is the order's **fulfilment** — the one that decides `Complete` against `Short`?
2. Which number does the **welding-wire certificate** state per alpha — and is it calculated or weighed?

**Recommendation:** **fulfilment is produced pounds; the certificate states produced pounds.** Consumption drives the operator notification only. Publish the two yield figures separately and name them apart — *yield on metal run* (`produced / consumed`) and *yield on metal issued* (`produced / allocated`) — because they differ by the unconsumed remainder and neither is "the" yield.

**Why:** what ships is what the customer is owed, so fulfilment must be the output side. ⚠ **The second half is the sharper question:** a *planned* allocation is not a *measured* weight, and the certificate states a weight a customer relies on — which is where **`Q10`**'s dimensional basis stops being a modelling concern.

Related: **`Q10`** (footage-to-weight basis), **`Q5`** (certificate traceability granularity), **`OI-60`** / **`Q11`** (metallic yield), **`FR-332`**.

---

**Q54** · `High` · Owner: Tim O. / Bob S. · `Open`
**Does the order acknowledgement also close the FL1 spool?**

The client confirmed on 20 Aug that a spool coming off FL1 **may carry two orders**. So an order boundary can fall in the middle of a spool being wound.

1. When the operator marks an order complete mid-spool, does the **spool** also complete — or does it carry on and legitimately hold both orders?
2. If it carries on, the spool crosses the boundary and FL2 must cut there. **Where is that boundary recorded?**

**Recommendation:** **let the spool carry on.** Forcing a spool completion at every order boundary would produce short spools for a planning reason rather than a physical one, and the client has already confirmed the two-order spool is legitimate. Record the boundary position on the spool's order association so FL2 can act on it.

**Why:** the finite carrier pool makes the cost concrete — 30 today and 45 planned, so a boundary-forced part-full spool consumes one of a fixed set. But the recommendation creates an obligation: the spool→order association carries **no positional column today**, so the boundary would be lost at that hop (gap **`G48`**).

Related: **`Q43`** (orders per spool), **`Q42`** (the carrier registry), gap **`G48`**, **`D5`** (the carrier is captured at the FL1 transaction).

---

**Q55** · `Low` · Owner: Tim O. / Bob S. · `Open`
**Should the spool carrier prefix differ from the material prefix?**

The 45 physical carriers are stencilled **`SP-0001`…`SP-0045`** (four digits). The material wound on them is **`SP-#####`** (five digits, e.g. `SP-00021`). One digit apart, on the same prefix, for the two objects the carrier registry exists to keep apart.

**Recommendation:** **use a distinct prefix — `SC-0001`…`SC-0045`** — if the stencils are not yet painted. If they are, keep `SP-` and rely on the field label.

**Why:** nothing can mis-resolve in the database — the two never share a column — so this is **not** a correctness issue, which is why it is `Low`. The exposure is a person reading one for the other on a screen, a log line or a label, and a distinct prefix removes it outright at no cost. The question is really *have the stencils been made yet*, which decides whether this is free.

Related: **`Q42`** (carrier format and where the registry is mastered), action **`A5`** (the 30 → 45 decision).

