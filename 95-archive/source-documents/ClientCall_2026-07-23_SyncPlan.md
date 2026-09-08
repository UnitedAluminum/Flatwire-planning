# Client Meeting 23 Jul 2026 — Requirement Clarifications and Document Sync Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 12, 2026
**Status:** **Ingested 12 Aug 2026.** Sixteen clarifications mapped onto the registers. One is a **direct conflict** with later client direction (`C6`, see §3.1) and is sent back rather than applied. Three have **no home in any register** and are raised as new items. Propagation waves in §5 are **not yet executed**.
**Source:** Meeting summary circulated by Jaspreet Singh — *"Shopfloor Review Priorities / Open Items / Flatwire Discussion"*, 23 Jul 2026, 1 h 02 m. Attendees: Srikanth Prabhala, Bob Scott, Timothy O'Brien, Jaspreet Singh, Waseem Khan, Ritika Raheja, Divesh Malhotra, Yogender Punia, Vicky Arora, Sushant.
**Registers touched:** `Q##` ([FlatWireOpenQuestions.md](../../90-registers/Questions.md)) · `OI-##` ([FlatWire_MasterSpecification.md](../../10-requirements/MasterSpecification.md)) · `G##` ([Development/GapsRegister.md](../../90-registers/Gaps.md)) · `PSG-##` ([PassScheduleGenerationSpec.md](../../10-requirements/screens/PassScheduleGenerationSpec.md)) · `PLC-Q##` ([PLCTagSpecification.md](../../20-architecture/PLCTagSpecification.md))

---

## 1. Why this document exists, and why it is dated out of order

**This meeting predates the 6 Aug call by two weeks but was ingested after it.** That matters, because one clarification — `C6`, dancer and tension control — **contradicts a decision recorded from the later call**. Under the repo's standing convention later client direction wins, which would make this position superseded. But the two may also be compatible, and the difference changes both a tag surface and a force model. **It is therefore recorded as a conflict and sent back to Tim, not applied in either direction.** See §3.1.

Everything else in this summary is additive. Its real value is that it **names owners and deliverables for six items that were open with no owner**, and it **partly answers three live register questions** — `Q20`, `OI-65` and `Q4`.

**Three subjects here have no home anywhere in the repository.** They are not refinements of existing items; nothing covers them. They are listed in §6 as new work.

---

## 2. Clarification ledger — sixteen items mapped to register IDs

| # | Clarification | Register ID | Status | Note |
|---|---|---|---|---|
| **C1** | Flat wire needs **dedicated downtime reasons**; Mill/Slitter reasons are not sufficient | `RunPauseEvent.ReasonCode` / `ReasonCategory` · [pause_run.js](../../50-frontend/mockups/pause_run.js) | **Owed by client** | 15 reasons in 5 categories already exist. Tim's list either ratifies or replaces them — **do not assume it extends them** |
| **C2** | Flat wire needs **specific web rejection reasons**; existing categories are a starting point | `WipRejection` · [WipRejection.md](../../10-requirements/screens/WipRejection.md) · `OI-84` | **Owed by client** | `OI-84` asks for the WIP REJ report *columns*; this is the *reason vocabulary*. Related, not the same |
| **C3** | **IT inhibit reasons** — coil not checked in · SPC not completed · missing required production transactions | `[PLC §8.2]` | **Corroborates** | Three of the five documented set conditions, independently confirmed. Tim owes the comprehensive list |
| **C4** | **Temper** is calculated differently from Mill logic — derived from **reduction rules and item configuration** | `PSG-D29` (strain→temper) · `V16` | **Sharpens** | `PSG-D29` asks for the strain→temper method; this names its inputs. Technical guidance still required |
| **C5** | **Drawdown impact on temper** is not fully understood | — | **Homeless** | No item covers it. See §6 |
| **C6** | **Dancers remove tension rather than apply it.** Tension control is **machine-driven**; values set through **process settings** | `Q32` · `PSG-D27` · `PSG-Q29` · `G35` | ⚠ **CONFLICT** | Contradicts `D-28` (6 Aug). **See §3.1 — not applied** |
| **C7** | Each output spool receives a **unique Alpha**; **Cut Number remains `1`** for every generated output spool | Alpha formats · `CoilOutput` | **Confirms + adds** | The unique alpha is already the design. The fixed cut number is new and needs a home in the output-coil rules |
| **C8** | **Rewind operations are not in the initial release**; may be added later | — | **Homeless** | Scope-limiting. No artifact mentions rewind at all. See §6 |
| **C9** | Initial spool is **12″ ID**, and the solution must stay **configurable** for other sizes | `SpoolConfiguration` · `OI-65` | **Already satisfied** | The table carries `MinCoreDiameterIn` / `MaxCoreDiameterIn`, so configurability exists. This is **seed data**, not a schema change |
| **C10** | Roles: **Leadman · Operator · Helper**, with a **qualification matrix** gating transactions; unqualified users blocked | [02-SRS.md](../../20-architecture/Security.md) §8 | ⚠ **Divergence** | §8 has Operator · Supervisor · Ops Manager · Eng/Maint · QA · Admin. **Neither Leadman nor Helper exists**, and a qualification matrix is a **new mechanism**, not a new row |
| **C11** | Labels: **standard** coil (receiving / return) · **high-temp** coil (FL1 output) · **cut + skid** (FL2/FL3 output) | `Q4` · [OutputCoilCompletion.md](../../10-requirements/screens/OutputCoilCompletion.md) §7 | **Partly answers `Q4`** | `Q4` asks whether flat wire follows existing packaging rules. This gives the label *types* per stage; the *rules* are still open |
| **C12** | Printers: **1 high-temperature + 3 standard ≈ 4 SATO** | — | **New hardware fact** | No artifact records printer hardware. Belongs with the label rules |
| **C13** | **Supervisor monitor** is desired but **not required for initial implementation** | `Q20` | **Partly answers** | `Q20` asks whether the completion alert mirrors to a supervisor. This defers the *screen*; it does not answer whether the **unacknowledged 100 % milestone** mirrors |
| **C14** | Tim to provide the **OD calculation formula** for a spool | `Q33` | **Owner named** | `Q33` had no owner-with-deliverable. Now it does. Also `A1`/`A3` of the 6 Aug ledger |
| **C15** | **Incoming rod is not perfectly cylindrical** — decide whether specialised calculation is needed or a cylinder approximation suffices | `Q10` · `OI-45` | **Sharpens exactly** | This *is* the dimensional-basis question `OI-45` asks. Strongest mapping in this summary |
| **C16** | Throughput and yield requirements are **already in the flat wire documentation**; review before implementing | `OI-68` · `OI-60` · `Q11` | ⚠ **See §3.2** | Tension with a scope decision taken 12 Aug |

**Programme-level items** — recorded, not actioned: pre-trial priorities (Coil Receiving · Machines Setup · **Throughput Data Collection** · Rejection Recording · Core Flat Wire Interface); production priority order (Flat Wire Interface → Planning → Item/SMP, Scheduling lower); **D72** as first deployment target; throughput to follow the **standalone service-based architecture** from the Slitter rewrite rather than the tightly-coupled legacy pattern; **AI-assisted development** encouraged, building a modern application rather than copying legacy screens.

---

## 3. The two items that need a decision before anything is applied

### 3.1 `C6` — dancer and tension control contradicts `D-28`

> ✅ **RESOLVED 1 Sep 2026, in favour of the position recorded here.** A 1 Sep statement is later client direction than the 6 Aug call, and it makes both readings true at once: dancers hold *"little to know [sic] tension by design"*, control is **the machine program**, each dancer holds a **position range**, and it *"will not be adjustable from an operator standpoint and will remain constant"* — while a tension mode does exist *"on FL2 however it will only work with heavier & larger dimension products"*. **Nobody selects the mode**, so no write surface is owed and the read-only tag element authored on 12 Aug was the correct call. Recorded as `D-36`; `Q32` items 1 and 2 are answered. ⚠ **Item 3 — the tension physics behind `PSG-D27` — stays open on the client's own engineering follow-up.** See [ClientEmail_2026-09-01_ReasonCodes_SyncPlan.md](ClientEmail_2026-09-01_ReasonCodes_SyncPlan.md) §4.5.

> *"Dancers remove tension rather than apply tension. Tension control will primarily be machine-driven. Configuration values will be controlled through process settings."* — 23 Jul 2026

| Date | Position | Consequence if adopted |
|---|---|---|
| **23 Jul 2026** *(this meeting)* | Dancers **remove** tension. Control is **machine-driven**. Values via **process settings** | Dancer mode is **read-only**. No push payload, no `PassScheduleComponent` column, no MVP-1→MVP-2 coupling |
| **6 Aug 2026** — `D-28` | FM2 carries **two dancers, each with two modes**, one of them **tension mode** | Mode may be **written**. `PSG-D27` models applied tension **reducing separating force** |

**Two questions, neither answered here.**

1. **Does the 23 Jul position still stand?** It is the earlier statement, and by convention the later one wins — but nobody has said the two conflict, and they may not. A dancer can physically *absorb* tension while still offering a machine-side "tension mode".
2. **If dancers remove rather than apply tension, is `PSG-D27` modelling something the equipment does not do?** The generation spec substitutes `σ̄_f,eff = σ̄_f − (σ_b + σ_f)/2` on the strength of applied front/back tension. **This is a physics question with two computed outputs downstream** — separating force, and roll gap through `F/K`. It is not a documentation fix, and it should go to whoever owns the force model rather than being settled editorially.

**What was done instead of choosing.** The dancer tag element was authored **read-only** — the subset that is true under *both* readings — so that when Tim answers, a write surface is an **addition** rather than a correction. `Q32` remains `Open` with its recommendation annotated as contested.

### 3.2 `C16` — throughput and yield

The summary says the requirements are already documented and asks the team to review them before implementing, and it lists **Throughput Data Collection** as a **pre-trial priority**.

**On 12 Aug 2026 the throughput-rates question was removed from the register as out of shopfloor scope**, along with baler dimensions and scrap banding. Its substance survives as **`OI-82`** in the master specification.

**This is surfaced, not reversed.** The removal was a deliberate scope decision; this summary is evidence that throughput has pre-trial delivery significance even if no flat wire *screen* consumes it. **Whether it returns to the register is the user's call**, and `OI-82` remains the tracking home either way.

---

## 4. Action items with owners

| # | Action | Owner | Status (3 Sep 2026) |
|---|---|---|---|
| **A1** | Provide the **OD calculation formula** | **Tim O'Brien** | ⛔ **STILL OWED.** Re-asked as question 1 on 22 Jul and **left blank** in the 1 Sep reply — the only one of thirteen with no answer |
| **A2** | Obtain **temper calculation logic** from the Technical Team | **Tim O'Brien** | ⚠ **PARTIAL, 1 Sep 2026.** Three regimes named (`D-39`); *"a formula work sheet will be sent separately"* — **not yet received**. ⛔ **STILL NOT RECEIVED, 2 Sep 2026 — and this is the one that did not come.** A worksheet **did** arrive that day (`D-43`, twenty formulas), answering the *width* half of Sushant's 27 Aug ask *"formulas for the width **and temper** as per cross sectional area"*. **The temper half is absent from it entirely** — no temper symbol in the 44-entry legend, no temper relation among the twenty. Tim, in the covering note: *"I will send the calculator next week after I have finished with some updates to the table lookups and **temper calculations**."* So there is now an **ETA (w/c 7 Sep 2026), not an answer**. `PSG-D29` and validation `V16` remain blocked; `D-39`'s three regimes remain unquantified |
| **A3** | Determine the **weight calculation approach for non-cylindrical rod** | **Tim O'Brien** | ⚠ **PARTIAL, 1 Sep 2026.** Rod is cylindrical and **weight is an input, not calculated** (`D-37`); footage is derived with a ± x ft tolerance. Worksheet **owed**. ⚠ **ADVANCED 2 Sep 2026, not closed.** `D-43`'s `F1` supplies the round-section footage relation — `L_F = tω / (π r² · 12 · ρ₁)`, i.e. `lb/ft = A × 12 × ρ`, **algebraically identical to `FR-332a`** (and that identity is what re-points `Q10`). ⛔ **The ± x ft tolerance is still unstated**, and Tim's density value is still unstated |
| **A4** | Share **flat wire downtime reasons** | **Tim O'Brien** | ✅ **CLOSED 1 Sep 2026** — 72 codes in four time buckets. ⚠ It **replaces** the existing taxonomy, exactly as `C1` warned |
| **A5** | Share **flat wire web rejection reasons** | **Tim O'Brien** | ✅ **CLOSED 1 Sep 2026** — 72 reasons. ⚠ No grouping supplied; all five groups are ours (`G79`) |
| **A6** | Share **flat wire IT inhibit reasons** | **Tim O'Brien** | ✅ **CLOSED 1 Sep 2026** — 8 reasons. ⚠ They share only **one** of `[PLC §8.2]`'s five conditions (`G80`) |
| **A7** | Review **throughput and yield documentation** | Jaspreet & Development Team |
| **A8** | Prepare flat wire **architecture, estimates, stories and execution plan** | **Yogender** |
| **A9** | Review **resource allocation and flat wire start dates** | Divesh, Shray, Ritika & Team |
| **A10** | Finalise **effort estimates and schedule** | Project Team |
| **A11** | Continue **readiness planning for August deployment** | Shopfloor Team |
| **A12** | Begin **Coil Receiving** development — highest-priority flat wire module | Vicky & Team |

✅ **Three of those four arrived on 1 Sep 2026** — `A4`, `A5` and `A6`, in `Reason Codes.xlsx`, 41 days after the questions were sent. **`A1` did not**, and it is the one that was owed twice over. Transcription and consequences: [ClientEmail_2026-09-01_ReasonCodes_SyncPlan.md](ClientEmail_2026-09-01_ReasonCodes_SyncPlan.md).

**Six of the twelve are Tim's, and four of those (`A1`, `A4`, `A5`, `A6`) are reference data the build cannot proceed without.** `A1` is the same deliverable as `A1`/`A3` on the [6 Aug ledger](ClientCall_2026-08-06_SyncPlan.md), so it is owed twice over.

### Decisions recorded on the call

- Slitter Rewrite remains the immediate priority; flat wire ramps up immediately after.
- **D72** will likely be the first deployment / testing target.
- Flat wire requires **dedicated downtime, rejection and inhibit logic** — `C1`, `C2`, `C3`.
- **Initial release supports running operations only** — no rewind (`C8`).
- **12″ ID spool initially**, remaining configurable (`C9`).
- Scheduling is **lower priority** than Flat Wire Interface, Planning and Item functionality.
- **AI-assisted development** to be leveraged wherever practical.

---

## 5. Propagation waves — not yet executed

| Wave | Targets | Blocked? |
|---|---|---|
| **W1 — Registers** | `Q32` annotated with the `C6` conflict *(done 12 Aug)* · `Q20`, `OI-65`, `Q4`, `Q33`, `Q10` gain the clarifications from `C13`, `C9`, `C11`, `C14`, `C15` | Not blocked |
| **W2 — New items** | Three homeless subjects (§6) need a `Q##` or `OI-##` each: drawdown-on-temper, rewind scope, flat-wire downtime-reason vocabulary | Not blocked — **but adds to register counts; report, do not absorb** |
| **W3 — Reference data** | `SpoolConfiguration` seed for the 12″ ID (`C9`) · downtime and rejection reason vocabularies once `A4`/`A5` arrive | ✅ **UNBLOCKED and EXECUTED 2 Sep 2026.** `A4`/`A5`/`A6` arrived 1 Sep; `DowntimeReason`, `WipRejectionReason` and `ItInhibitReason` are built in `01_Lookup` and **seeded inline by the DDL** — they are production reference data, not fixtures. `LineDowntimeEvent` came with them, because the `Downtime` bucket has no run to hang on |
| **W4 — Roles** | [02-SRS.md](../../20-architecture/Security.md) §8 — reconcile Leadman/Operator/Helper and the qualification matrix against the existing six roles (`C10`) | **Blocked** — needs a client decision on whether these replace or overlay the existing roles |
| **W5 — Labels and printers** | `Q4` · [OutputCoilCompletion.md](../../10-requirements/screens/OutputCoilCompletion.md) §7 — label types per stage, printer hardware (`C11`, `C12`) | Not blocked for the types; the *rules* remain open under `Q4` |
| **W6 — PLC surface** | Dancer element authored **read-only** *(done 12 Aug)*; the write surface waits on §3.1 | **Partly blocked** on `C6` |
| **W7 — Generation spec** | `PSG-D27` / `PSG-Q29` — the tension-physics question from §3.1 | **Blocked** on `C6` |
| **W8 — Programme** | [05-SprintPlanAndBacklog.md](../../60-delivery/SprintPlan.md), [CapacityAndEffortModel.md](../../60-delivery/CapacityAndEffortModel.md), [03-HLD-and-ERDiagram.md §14](../../20-architecture/Architecture.md) — priority order, D72, service-based throughput architecture | Not blocked — **partly executed 13 Aug**: the *AI-assisted development* decision is now costed in the new [DevelopmentEffortModel.md](../../60-delivery/DevelopmentEffortModel.md) (MVP-1 development **2,242 → 1,486 h**, 4.2 developer-FTE — **1,397 h of it in that sheet and Phase 12's 89 h in [YieldCostAndScrapSheet.md](../../60-delivery/YieldCostAndScrapSheet.md)**), cross-referenced from the effort model. **Still open:** priority order, D72 and the service-based throughput architecture in all three targets, and the AI basis is **not** propagated into the programme totals or the §7 staffing decision |

---

## 6. Send back to the client (open, blocking, or owed)

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | **`C6` / `Q32`** — does the 23 Jul *"machine-driven"* position stand after the 6 Aug two-mode disclosure? And if dancers **remove** tension, does `PSG-D27`'s substitution model something the equipment does not do? | Tim O. / Engineering | The dancer **write** surface · `PSG-D27` · `G35` |
| 2 | **Flat wire downtime reasons** (`A4`) — the full list, and whether it replaces or extends the existing 15 | Tim O. | Reason vocabulary, `RunPauseEvent` seed |
| 3 | **Flat wire web rejection reasons** (`A5`) | Tim O. | `WipRejection` seed |
| 4 | **IT inhibit reasons** (`A6`) — the comprehensive list against `[PLC §8.2]`'s five | Tim O. | Interlock conditions |
| 5 | **Temper calculation logic** (`A2`) — reduction rules and item configuration | Tim O. / Technical | `PSG-D29`, `V16` |
| 6 | **Drawdown impact on temper** — **homeless**, needs an item before it can be tracked | Tim O. / Technical | Temper accuracy |
| 7 | **Rewind operations** — confirm out of initial release and record the boundary; **homeless** today | Tim O. | Scope statement |
| 8 | **Non-cylindrical rod weight** (`A3`) — specialised calculation or cylinder approximation? | Tim O. / Bob S. | `Q10` / `OI-45`, every derived weight |
| 9 | **Roles** — do Leadman / Operator / Helper replace or overlay the six roles in `02-SRS` §8, and what drives the qualification matrix? | Tim O. / Shannon R. | Permission model |
| 10 | **`Q20`** — `C13` defers the supervisor *monitor screen*; does the **unacknowledged 100 % milestone** still mirror to a supervisor? | Tim O. / IT | Completion alert design |

---

## Related Documents

| Document | Why |
|---|---|
| [ClientCall_2026-08-06_SyncPlan.md](ClientCall_2026-08-06_SyncPlan.md) | The **later** call. `D-28` there is what `C6` conflicts with; `A1` is the same owed formula |
| [ClientCall_2026-07-30_SyncPlan.md](ClientCall_2026-07-30_SyncPlan.md) | The ledger pattern, and the call one week after this meeting |
| [FlatWireOpenQuestions.md](../../90-registers/Questions.md) | Authoritative open register — W1 |
| [FlatWire_MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `OI-##` register; `OI-45` and `OI-82` are cited here |
| [PLCTagSpecification.md](../../20-architecture/PLCTagSpecification.md) | Target of W6 — the dancer element |
| [PassScheduleGenerationSpec.md](../../10-requirements/screens/PassScheduleGenerationSpec.md) | `PSG-D27` / `PSG-Q29` — the tension-physics question |
| [Development/GapsRegister.md](../../90-registers/Gaps.md) | `G35` |
