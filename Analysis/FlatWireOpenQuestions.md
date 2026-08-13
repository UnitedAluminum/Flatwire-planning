# Flat Wire Mill — Open Questions Register

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 12, 2026
**Scope:** MVP-1
**Open Questions:** 33 · **Shopfloor scope:** 28
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

**28 of the 33 open questions relate to Flat Wire Mill shopfloor changes** — the operator execution screens (Dashboards 1–12+) plus the reference data, equipment limits and validation rules those screens consume. The remaining 5 belong to adjacent modules (planning, scheduling, certification) and are retained here marked `Scope = Other`.

**This register holds open items only.** The 25 answered questions are in [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) with their decisions. **The two files share one numbering space** — open questions are **`Q1`–`Q33`**, decided questions **`Q61`–`Q85`**, and a `Q##` lives in exactly one of the two files, so an `OQ-##` reference from the phase files, [REVIEW.md](../MVP-1/ProjectPlan/Development/REVIEW.md) or the master specification resolves against whichever file holds that number. ⚠ **The open register was renumbered three times on 12 Aug 2026** — the last of them when 23 questions were withdrawn as ours to answer rather than the client's. **A `Q##` read in any document or commit written before that resolves against the maps in [CHANGELOG.md](../CHANGELOG.md)**, under this file's section, and the three maps must be read in order. Every inbound citation in the repository was rewritten in the same pass, so nothing outside `CHANGELOG.md` — which keeps its historical numbers by design — should still be on an older scheme.

**Every question carries a `Recommendation:` at the foot of its body, with one deliberate exception.** That is **our proposed answer — it is not a decision and carries no client authority.** **`Q10` (footage-to-weight conversion factor) carries none, by decision.** The dimensional basis it turns on — nominal or measured gauge and width, and whether the round edge is corrected for — is a measurement question United Aluminum must answer from its own practice, and a proposed default risks being adopted as the basis rather than confirmed. Every derived weight in the system rests on it, so it goes to the client as an open question. The `Recommended answer` field is optional in the workbook generator for this reason. It exists so a review is a confirm-or-correct exercise rather than a blank page, and so the build has a defensible default to work to while an answer is outstanding. Where the body already recorded a proposal, leaning or option preference, the recommendation crystallises **that** rather than inventing a new one. **Confirming a recommendation closes the question** — move it to [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md) with the confirmation date and who gave it. Nothing here should be cited as settled, and nothing should be implemented as irreversible on a recommendation alone.

**Several recommendations deliberately point at the same conversation.** The three surviving PLC questions — **Q27**, **Q28** and **Q29** — all recommend closing in a single controls-engineer session, the one **`PLC-Q02`** asks for in [PLCTagSpecification.md](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md); that document carries its own `PLC-Q##` register and sign-off sheet, which is why the tag-path, station-rename, measure-name, unit and ordinal questions are tracked there rather than here. **Q32** must be closed from `PSG-Q29` rather than asked twice.

**Eight of these questions are partly answered, and the partial answer is in the body.** **Q1**, **Q12**, **Q13**, **Q17**, **Q18**, **Q22**, **Q23** and **Q24** each carry a decided portion — a basis, a shape, or some of their numbered items — with the rest still owed. They are `Open` because they are not closed; read them here, not in the decided file, and check the body before concluding nothing has been settled.

**There are no numbering holes** — `Q1`–`Q33` here, `Q61`–`Q85` decided, each contiguous. Withdrawn questions are **not** lost and their numbers are **not** reused as pointers. Earlier withdrawals for being outside shopfloor scope are carried in the master specification as **`OI-88`** (pass schedule authoring), **`OI-81`** (web application), **`OI-69`** / **`OI-49`** / **`OI-85`** (rod receiving), **`OI-60`** (metallic yield per route), **`OI-77`** (edger blades and roll regrind), **`OI-82`** (throughput rates) and **`OI-83`** (scrap handling).

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

### Shopfloor — Open (28)

| Priority | Questions |
|---|---|
| `Critical` | **Q3** traveler fields per station · **Q10** footage-to-weight factor · **Q14** pass schedule selection at check-in · **Q15** FL3 hybrid schedule + FL2 validation |
| `High` | **Q1** roll gap validation · **Q4** skid labeling rules · **Q5** cert traceability granularity · **Q6** weld footage attribution · **Q7** max weld joints per coil · **Q12** partial-rod re-check-in · **Q13** PLC tags on checkout · **Q17** spool state machine · **Q18** target spool weight source · **Q21** `FL{n}.LineState` vocabulary · **Q22** dimensional tolerance columns *(values owed)* · **Q23** failed-inspection row · **Q24** staging overrides · **Q25** rod scheduled on neither rod line · **Q26** shopfloor panel resolution · **Q27** speed pushed as target or limit · **Q28** edge type push + missing edger tags · **Q29** FM2 tag namespace on FL3 · **Q30** take-up load cells / completion weight · **Q31** no-weld wire-break disposition · **Q32** FM2 dancer modes · **Q33** OD→weight formula |
| `Medium` | **Q19** TKUP-2 alert ladder · **Q20** supervisor mirroring |

### MVP-1 scope note — pass schedules, die life, shift boundaries

**Pass schedule authoring is outside MVP-1; the check-in *read* is not.** MVP-1 reads an approved schedule to build the PLC push payload and persists a snapshot of what it pushed. That read boundary — specified in `phase-04` — is why **Q14** (selection at check-in) and **Q15** (FL3 hybrid schedule) are in scope despite reading as pass-schedule questions.

**Die life is in scope at *size* granularity only.** The 60 / 85 % bands are read from `Drawer.LastGrindingFeet` / `Drawer.TotalFeetAllowed`; per-tool tracking and the die master table are not MVP-1.

**Q20** (supervisor mirroring) is in scope because it surfaces on **Dashboard 1**.

Two decided questions are only partly in MVP-1 and carry banners in [FlatWireDecidedQuestions.md](FlatWireDecidedQuestions.md): **Q62** (the Active Run Monitor alert is in; the change-log table and editing flow are not) and **Q83** (the bands are in; the per-tool mechanism is not).

### Out of shopfloor scope (5)

**Q2** FL3 scheduling representation · **Q8** C of C frequency · **Q9** twist and torsion · **Q11** yield loss factor · **Q16** pre-scheduling validation

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

**Recommendation:** build the **documented carry-forward design** — already delivered on 26 Jul 2026 as `Rod.FootageRunToDate`, `Rod.RemainingWeightEstimateLb` and `Spool.SourceRodAlpha` — and treat the **payoff scale as a separable question** (**`OI-56`** asks the same thing at the take-up). The design works from an estimated remaining weight; a scale only improves the estimate's accuracy. Do not hold the build for the scale answer.

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

> **Decided (August 2, 2026) — FL2 shows two statuses and runs one spool at a time.** Because **FL2 has no space to stage material**, a spool is either waiting for the line or on it; there is no third place for it to be. The operator-visible vocabulary at FL2 is therefore fixed at **`Ready for FL2`** (schema `RECEIVED`) and **`Checked in`** (schema `INFLAT`). **`STAGED` is never set at FL2** — staging is the FL1 concept (PCI002), and there is no "At TPO" status on the spool queue. Second half of the decision: **check-in is exclusive.** While any spool is checked in, **no spool offers a check-in action** — not the others and not the checked-in one — and the action returns only on checkout. Applied to [dashboard_5a_spool_queue.html](../MVP-1/ProjectPlan/Frontend/Mockups/dashboard_5a_spool_queue.html) and [SpoolQueue.md](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) §3.5 (rules SQ-7 to SQ-10). **Still open:** the stored status list and its transitions — this decision fixes what the FL2 operator sees, not what the database records, and the two rival vocabularies of **OI-06** are still unmapped. **Two consequences that need owners:** (1) exclusivity has **no backing constraint** — `dbo.Spool` has no filtered unique index on `Status` and carries **no `LineId` at all**, so "one spool checked in per line" cannot currently be expressed in the schema; `POST /checkin/spool` must reject the second check-in with a `409`. (2) A **quality-held spool now has no place on the FL2 queue** — it is neither ready nor checked in, so it simply is not listed. Raised to the client as SpoolQueue.md open item 6.

**Status (May 4, 2026):** Tim provided the following operational framework:
- Spools shall have unique identifiers similar to furnace plates.
- Alphas are loaded onto a spool number at the start of the FL1 job; operators are required to input the spool number being used.
- The spool number is then tracked physically and in the system: tow motor moves it to the furnace, then to cooling, and then the operator on FL2 selects it by spool number for check-in.

The full formal state machine (all valid statuses and the events that trigger each transition) is still to be defined. Without a defined state machine, the system cannot enforce valid status progressions (e.g., preventing a spool from being planned for two orders simultaneously, or a completed spool being re-opened for FL2 check-in).

**Recommendation:** make the **stored** vocabulary the shared `coils` status set already in use (`RECEIVED` / `INFLAT` / `HOLD` / `COMPLETE` / `SCRAP`) and treat the Aug 2 two-status FL2 view as a **projection over it**, not a second vocabulary — that is what closes `OI-06` without inventing a third list. Then add the two things the Aug 2 decision left unbacked: a **`LineId` on `Spool`** and a **filtered unique index** enforcing one checked-in spool per line, so exclusivity is a constraint rather than only a `409`. For the quality-held spool with nowhere to appear, add a third **view** state `Held` — visible on the queue, with no check-in action.

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
