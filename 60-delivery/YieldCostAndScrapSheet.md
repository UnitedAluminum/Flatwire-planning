# Flat Wire Mill — Yield, Cost Ledger & Scrap (Phase 12) Sheet

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** The FW-001 yield-form field renames are cancelled; ⚠ **rung 4 is deliberately held at 67 h** — the renames were never priced as a separate line, so there is no defensible figure to subtract *(previously August 13, 2026 — initial publication)*
**Document Type:** Phase sheet — scope, story-level effort on both delivery bases, descope role, blockers
**Status:** Published — **⚠ the phase is 177 h with no requirement specification for three of its four stories** (§3)
**Estimating unit:** **hours**. Day figures are derived (**1 dev-day = 8 h**) and shown only as a reading aid.
**Scope:** **Phase 12 only** — footage-based yield with weld attribution, flat-wire cost ledger configuration, and the scrap box/skid outlet. Stories **FW-100, FW-101, FW-102, FW-110**.
**Shortcode:** `[YCS]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

> ### ⚠ Headline
> Phase 12 is **177 h hand-coded / 126 h AI-assisted** (§2), sits wholly in **W7** — the three-day week the capacity
> model already calls arithmetically impossible — and is **the only phase in the plan that is 100% deferrable**: it is
> the entirety of descope-ladder rungs 1–4 (§4).
>
> **Two findings that should change how it is scheduled, not just how it is sized:**
>
> **1. Three of its four stories have no requirement specification.** `FW-101`, `FW-102` and `FW-110` carry **no
> `FR-` IDs anywhere in `02-SRS.md`**, and Phase 12 has **no owning requirement document** — it is not among the 17
> files in `MVP-1/ProjectPlan/Business/Screens/` and has no dashboard in the Dashboard Inventory. The only requirement text in
> existence is the Jira acceptance criteria (§3). Every other phase in the plan has an owning spec.
>
> **2. All four stories are blocked, and three of the four blockers are the client's to answer** (§5) — `Q10`
> (Critical; the one register question deliberately carrying **no** recommendation), `OI-60`, `OI-68` and `OI-83`.
>
> Together these mean Phase 12's estimate is the **softest in the plan**: 177 h costed against four Jira cards and
> four open items. The phase's own file already says *"Estimate provisional"*; this sheet quantifies why.

---

## 1. What Phase 12 is

| | |
|---|---|
| **Objective** | Footage-based yield with weld attribution · flat-wire cost ledger configuration · scrap box/skid outlet |
| **Owner** | **BE** stream (named owner TBD — [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §1) |
| **Window** | **W7** (Sep 28–30) — **3 working days**, 24 h per person |
| **Depends on** | Phase 9 (completion + `CoilTraceability`) · Phase 11 (reporting) |
| **Real-time** | **None** — the only substantial phase with no RT component |
| **User roles** | Production controller · Cost accountant · Scrap operator |
| **Priority** | Medium / Low — *"first candidates to slip past the Sep 30 window (post-trial acceptable)"* |

**Surfaces touched:** the yield form (a *"Flat Wire"* checkbox ~~plus FW-001 field renames~~ — **the renames are cancelled, `D-32`, 18 Aug 2026**; the form reads the existing field names), cost ledger configuration,
and the scrap module outlet. It extends the existing `CoilYield`, `CoilCosting` and scrap services rather than building
new ones, and it **reads** `CoilTraceability` / `WeldEvent` / `CoilOutput` without writing them.

**Note on FW-100.** The story is *delivered* in Phase 9 (the weight appears on Dashboard 7) and *consumed* in Phase 12
(the yield module). The roadmap writes this as `9 (yield 12)`. Its rate-card cost sits in rung 4 below.

---

## 2. Story-level effort

The hand-coded discipline columns are Phase 12's published figures from
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3. The **story split is the descope ladder's own split**
(§5 of that document: 33 / 49 / 28 / 67), which is why the rungs sum to the phase exactly.

### Hand-coded basis — 177 h

| Rung | Story | FE | BE | DB | QA | Cont | **Hours** | Days |
|---|---|---|---|---|---|---|---|---|
| 1 | **FW-110** Scrap module — Box/Skid outlet *(Low)* | 12 | 12 | — | 5 | 4 | **33** | 4.1 |
| 2 | **FW-102** Cost Ledger — flat-wire costing config *(Medium)* | 12 | 20 | 4 | 7 | 6 | **49** | 6.1 |
| 3 | **FW-101** Weld traceability in yield *(High)* | — | 16 | 4 | 4 | 4 | **28** | 3.5 |
| 4 | **FW-100** + remainder — footage weight, yield form, ~~FW-001 renames~~ *(cancelled, `D-32`)* | 20 | 24 | 4 | 10 | 9 | **67** | 8.4 |
| | | **44** | **72** | **12** | **26** | **23** | **177** | **22.1** |

**This table reconciles exactly in both directions** — the four rung totals are the ladder's published 33 / 49 / 28 /
67, and the five discipline columns are the phase row's published 44 / 72 / 12 / 26 / 23. Verify either axis by hand.

Rate-card basis per rung, reproducible from §2 of the capacity model:

- **Rung 1** — outlet control (12 FE) + 2 commands (12 BE). QA `0.20 × 24 = 5`; cont `0.15 × 29 = 4`.
- **Rung 2** — config UI (12 FE) + cost standards/times service (20 BE) + standards mapping (4 DB). QA `0.20 × 36 = 7`; cont `0.15 × 43 = 6`.
- **Rung 3** — per-rod attribution service across weld points (16 BE) + traceability queries (4 DB); **no new screen** — the yield form is in rung 4. QA `0.20 × 20 = 4`; cont `0.15 × 24 = 4`.
- **Rung 4** — yield form changes and field renames (20 FE) + weight service and yield endpoints (24 BE) + renamed yield fields (4 DB). QA `0.20 × 48 = 10`; cont `0.15 × 58 = 9`.

### AI-assisted basis — 126 h

Factors from [`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) §1 — **FE 0.62 · BE 0.75 · DB 0.65 · QA 0.80**,
contingency scaled by the ratio its own base fell. BE carries this phase's **0.75**, the *least* favourable BE factor
in the plan: the yield attribution and cost-standards work is domain reasoning, not boilerplate.

| Rung | Story | FE | BE | DB | QA | Cont | **Hours** | was | saved |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **FW-110** Scrap Box/Skid outlet | 7 | 9 | — | 4 | 3 | **23** | 33 | 30.3% |
| 2 | **FW-102** Cost Ledger config | 7 | 15 | 3 | 6 | 4 | **35** | 49 | 28.6% |
| 3 | **FW-101** Weld traceability in yield | — | 12 | 3 | 3 | 3 | **21** | 28 | 25.0% |
| 4 | **FW-100** + remainder | 12 | 18 | 3 | 8 | 6 | **47** | 67 | 29.9% |
| | | **26** | **54** | **9** | **21** | **16** | **126** | **177** | **28.8%** |

**Phase 12 is the second-least-compressible phase in the plan at 28.8%**, behind only Phase 14 — for the same
underlying reason in a different form. Phase 14 resists because it needs the mill; Phase 12 resists because it needs
**decisions**. AI assistance drafts a yield-attribution service quickly; it cannot supply the expected yield per route.

> **⚠ One rounding note, stated rather than hidden.** Decomposing to four rungs and *then* rounding gives **FE 26 /
> DB 9**, where rounding the phase aggregate gives **FE 27 / DB 8**. The two differ by 1 h in opposite directions and
> therefore **agree on every total that matters** — **126 h all-in** and **89 h development-only**. Quote the aggregate
> split (FE 27 / BE 54 / DB 8 / RT 0) when reconciling against the rate card, and this table when reconciling against
> the ladder.
>
> **This sheet is the sole home of Phase 12's figures.** Phase 12 was **removed from
> [`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) on 13 Aug 2026** so it could be priced at story level
> here; that sheet's totals are now stated **net of Phase 12** and cite 89 h from here, not the reverse. Its
> MVP-1 development figure is **1,397 h**, and **1,397 + 89 = 1,486 h** is complete MVP-1 development.

### Capacity

| Basis | Hours | In W7 (3 days, 24 h/person) |
|---|---|---|
| Hand-coded | 177 | **7.4 FTE** |
| AI-assisted | 126 | **5.3 FTE** |

This is Phase 12 **alone**. W7 also carries Phase 13 and the whole of Phase 14 — see
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §4, where W7 totals 24.5 FTE hand-coded.

---

## 3. ⚠ The specification gap

**Phase 12 has no owning requirement document, and three of its four stories have no requirement text beyond a Jira
card.** This was verified against `02-SRS.md`, not assumed:

| Story | `FR-` coverage | Owning spec | What exists |
|---|---|---|---|
| **FW-100** Footage-based weight | **`FR-332` / `FR-332a`** — but filed under §5.16, which the SRS maps to **DB7 / Phase 9** | `OutputCoilCompletion.md` (Phase 9) | Formula specified; **dimensional basis open** (`Q10` / `OI-45`) |
| **FW-101** Weld traceability in yield | **none** | **none** | Jira acceptance criteria only |
| **FW-102** Cost Ledger config | **none** | **none** | Jira acceptance criteria only — and its configuration is a **load-bearing TBD** (`OI-92`, `REVIEW.md` #55) |
| **FW-110** Scrap Box/Skid outlet | **none** | **none** | Jira acceptance criteria only |

**The scrap requirements that do exist are not this story.** `FR-063` and `FR-066` govern the **scrap box at rod
check-in** (mandatory/optional fields, alloy-driven list population); `FR-189`, `FR-273` and `FR-292` govern **WIP and
balance-of-coil dispositions** (`SPC-HOLD` release/quarantine, *Scrap Balance*, `SCRAP` alpha routing). None of them
describes selecting `Scrap Box` versus `Scrap Skid` as an **outlet**, which is what FW-110 adds. Do not read FW-110 as
already specified because the word "scrap" appears in the SRS.

**Consequence for the estimate.** Every other phase's hours were priced from a deliverable inventory the phase file
publishes and a spec that defines it. Phase 12's were priced from four Jira cards. The 177 h is a **rate-card estimate
against acceptance criteria**, which is why both the phase file and `CapacityAndEffortModel.md` §8 mark it provisional.
Writing the missing specification is not in the 177 h.

**One contradiction to resolve while writing it:** `FW-101`'s dependencies are `FW-063, FW-090` in
[05-SprintPlanAndBacklog.md](SprintPlan.md) and `FW-095` in `05-SprintPlanAndBacklog.md`. Both cannot be right.

---

## 4. Descope role — the whole phase is rungs 1–4

Phase 12 is **the only phase in the plan marked deferrable in its entirety**. The ladder defers it in four steps, and
because rungs 1–3 are Phase-12 stories, **rung 4 is the remainder of the phase, not the phase again** — the cumulative
column is additive with no double-counting.

| # | Rung | Hand-coded | AI-assisted | Cumulative (AI) | What is lost | Sign-off | Latest call |
|---|---|---|---|---|---|---|---|
| 1 | FW-110 Scrap Box/Skid outlet *(Low)* | 33 | **23** | 23 | Scrap routed manually post-go-live | Ops | W6 |
| 2 | FW-102 Cost Ledger config *(Medium)* | 49 | **35** | 58 | No flat-wire cost standards; costing reports blank | Cost accounting | W6 |
| 3 | FW-101 Weld traceability in yield *(High)* | 28 | **21** | 79 | Yield not attributed per source rod — **welding-wire certs affected** | Tim O. / Quality | W6 |
| 4 | Remainder — footage weight + yield form | 67 | **47** | **126** = whole phase | No footage-based yield at go-live | Programme | W6 |

> **⚠ Rung 3 and rung 4 disagree about who owns the yield form.** The ladder labels rung 4 *"footage-based weight +
> yield form"*, but **`FW-101`'s acceptance criteria claim the yield form** — the *"Flat Wire" checkbox* and the three
> field renames are written into that story, and `FW-101` is **rung 3**. So deferring rung 3 as the ladder intends would
> defer two criteria the ladder believes it is keeping. **This sheet prices the ladder's split** (rung 3 carries no FE,
> rung 4 carries the 20 FE for the form), which is the correct basis for the *effort* either way — both rungs are in the
> same phase, so the total is unaffected. It is the **descope decision** that breaks. Resolve before the W6 call: either
> move those two criteria to a rung-4 story or restate rung 3 as including the form. Raised 13 Aug 2026 — see
> [`TaskBreakdown.md`](TaskBreakdown.md) §7 · S3 · Phase 12, `FW-101`.

**Rung 3 is the one to argue about.** It is the only `High`-priority story in the ladder's first five rungs, and the
consequence — yield not attributed per source rod — lands on the **welding-wire customer certificates**, which are an
MVP-1 obligation and the stated reason `CoilOutput`/`CoilTraceability` were returned to MVP-1 on 11 Aug 2026. Deferring
rung 3 defers the *yield* attribution, not the traceability genealogy itself; confirm that distinction with Quality
before the W6 call rather than during it.

**AI assistance weakens this ladder.** In absolute terms the four rungs recover **126 h instead of 177 h** — the
deferrable work compresses while the non-deferrable commissioning sharing W7 does not. Deferring the whole phase
therefore removes **5.3 FTE from W7's requirement rather than 7.4**, which is the sense in which descoping is worth
*less* once the team is faster.

---

## 5. Blockers — all four stories are gated

| Item | Blocks | Status | Recorded position |
|---|---|---|---|
| **`Q10`** footage-to-weight factor | **FW-100**, and every derived weight in the system | **`Critical`, Open** — owner Tim O. / Bob S. | **Deliberately carries no recommendation.** The dimensional basis — nominal or measured gauge and width, and whether the round edge is corrected — is a measurement question **UA must answer from its own practice**; a proposed default risks being adopted as the basis rather than confirmed. It is the only one of the 33 open questions treated this way. Also tracked as **`OI-45`** for the dimensional basis |
| **`OI-60`** expected metallic yield per route | **FW-101** | Open — **sole tracking home** (the register entry was removed as out of shopfloor scope on 12 Aug 2026) | Yield is undefined for all three routes (rod → flat direct, rod → round wire → flat, flat → flat re-pass), **and it is also open whether the flat → flat re-pass route is real** — UA may be unable to run a spool back through FL1. Owner Tim O. / Jeff G. |
| **`OI-68`** standard times + costing standards / industry codes | **FW-102** | Open — **sole tracking home** (both register questions withdrawn 12 Aug 2026) | **Our reading is recorded and is buildable:** use the **existing industry codes unchanged by route**, and derive **provisional standard times arithmetically from the throughput rates owed as `OI-82`**, published visibly marked provisional and refined from run data after the trial. Waiting for authored standard times blocks the yield module for the whole build; a visibly provisional figure does not |
| **`OI-83`** baler maximum dimensions, scrap banding material | **FW-110**'s physical packing spec | Open — Plant / Tim O. | Steel versus aluminium alloy for the bander. **The `Scrap Box` \| `Scrap Skid` vocabulary itself is settled**, so the software selection is buildable ahead of the physical answer |

Also on the register for this phase: **`OI-92` / `REVIEW.md` #55** record **FW-102's configuration as a load-bearing
TBD placeholder** — one of only four such placeholders in the phase files.

### What is buildable now, and what is not

**Buildable today, without any further answer:**
- ⚠ ~~The **FW-001 field renames** on the yield form~~ — **CANCELLED 18 Aug 2026, `D-32`: there is no shared-schema migration**, so the labels below are not applied and the form keeps the existing names. Retained as the record of what was cancelled (*"Outgoing Gauge"* → *"Outgoing Gauge/Diameter"*, *"Coil #"* →
  *"Coil/Bundle #"*, *"Gauge"* → *"Gauge/Diameter"*). **The "Flat Wire" checkbox is unaffected and is still buildable today** — rung 4's FE.
  > ⚠ **Rung 4 is deliberately left at 67 h.** The renames were part of its FE 20 h but were never priced as a separate line, so there is no defensible figure to subtract. **Re-price rung 4's FE when the phase is planned rather than carrying an invented reduction.** `[CE §3c]` re-derives Phases 1C and 7, which *were* separable, and does not touch this one.
- The **weight service structure**. The formula is settled by `FR-332`/`FR-332a`, including the correction that the
  mockup's `14,200 ft × 0.069 lb/ft` **must not be implemented** (0.069 back-solves to ρ = 0.0836 lb/in³, which is not
  aluminium; `spool_notification.js`'s `24,900 ft × 0.0809 = 2,014 lb` is the correct reference). Only the
  **dimensional basis** is open, and it is a parameter, not a rewrite.
- The **scrap outlet selection** — the vocabulary is fixed and `OI-83` gates only the physical packing spec.
- The **per-rod attribution mechanics** — splitting footage at weld points is a `CoilTraceability` traversal. What
  `OI-60` withholds is the *expected* yield to compare against, not the attribution itself.

**Not buildable, and no factor makes it so:** the cost-standard **values** (`OI-68`, unless the provisional reading is
adopted), the **expected yield per route** (`OI-60`), and the **confirmed** weight basis (`Q10`).

---

## 6. Assumptions and risks

- **The estimate is the softest in the plan.** 177 h priced against four Jira cards, no `FR-` coverage for three of
  four stories, and four open blockers. Treat it as an order-of-magnitude figure until §3's specification gap is closed.
- **Writing the missing specification is not costed** — neither here nor in `CapacityAndEffortModel.md`.
- **The AI-assisted figure inherits that softness.** A retention factor applied to an uncertain base does not reduce
  the uncertainty; `DevelopmentEffortModel.md` §1 rule 2 states the general case — *a phase whose specification is
  unsettled will not hit its factor* — and Phase 12 is the sharpest instance of it in the plan.
- **`OI-60`'s second half is a scope question, not a data gap.** If the flat → flat re-pass route is not real, one of
  the three yield routes does not need building at all. Nobody has costed that either way.
- **The phase reads tables it does not write.** It depends on Phase 9 having produced `CoilTraceability` rows and
  Phase 11 the reporting surface. `REVIEW.md` #13 notes Phase 9 assumes a **skid table** and a **lot-number source**
  that do not exist — if that holds, Phase 12's yield attribution has an incomplete genealogy to traverse.
- **W7 placement is the real risk, not the hours.** Even at the AI-assisted 126 h, Phase 12 needs 5.3 FTE in a
  three-day week that also holds Phase 13 and all of Phase 14. It is deferrable precisely so it does not have to be
  attempted there.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`phases/phase-12-yield-cost-ledger-scrap.md`](phases/phase-12-yield-cost-ledger-scrap.md) | The phase file — deliverable inventory this sheet prices |
| [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) | §2 rate card · §3 the published 177 h · §5 the descope ladder · §8 the provisional-estimate note |
| [`DevelopmentEffortModel.md`](./DevelopmentEffortModel.md) | **The AI-assisted factor card (§1) this sheet applies.** Its per-phase table **excludes Phase 12** — this sheet owns those figures — so its 1,397 h MVP-1 development is net of the 89 h here |
| [05-SprintPlanAndBacklog.md](SprintPlan.md) | **The only requirement text for FW-101/102/110** — acceptance criteria at FW-100/101/102 (Epic 10) and FW-110 (Epic 11) |
| [`../10-requirements/BusinessRequirements.md`](../10-requirements/BusinessRequirements.md) | `FR-332`/`FR-332a` (weight formula) · `FR-063`/`FR-066`/`FR-189`/`FR-273`/`FR-292` (scrap, **not** FW-110) |
| `../10-requirements/MasterSpecification.md` | §11 open-issue register — `OI-45`, `OI-60`, `OI-68`, `OI-83`, `OI-92` |
| [`../90-registers/Questions.md`](../90-registers/Questions.md) | **`Q10`** — Critical, and the one question carrying no recommendation by decision |
