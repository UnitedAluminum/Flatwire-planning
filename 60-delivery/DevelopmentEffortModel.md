# Flat Wire Mill — Development Effort Model (AI-Assisted)

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** The `FW-001` 40 h rename impact audit and its 0.75 AI-assist factor leave this sheet entirely *(previously August 13, 2026 — **Phase 12 removed** to its own sheet; every total re-derived *(initial publication same day)*)*
**Document Type:** Development Effort Model (build-stream hours only, AI-assisted delivery basis)
**Status:** Published — **factors are assumed, not measured**; the Aug-14 Phase-1 gate is the calibration point (§6)
**Estimating unit:** **hours**. Day figures are derived (**1 dev-day = 8 h**) and shown only as a reading aid.
**Delivery basis:** **AI-assisted development using claude.ai**, per the client decision of 23 July 2026.
**Scope:** the four **build streams** — FE, BE, DB, RT — across **15 of the 16 phase specs**. **Phase 12 is excluded** and priced in [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md); **QA, BA and contingency are out of scope** (§0).
**Shortcode:** `[DE]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../DOCUMENTS.md)

> ### ⚠ Headline
> On an AI-assisted basis, **MVP-1 development effort is 1,397 hours** (174.6 dev-days) against the hand-coded
> **2,114 h** — a saving of **717 h (33.9%)**, and **4.0 developer-FTE** sustained over the 44-working-day window
> rather than 6.0. Both scopes together fall from **2,368 h to 1,554 h**.
>
> **⚠ Phase 12 (Yield, Cost Ledger & Scrap) is excluded from every figure in this sheet**, including the weekly grid,
> and is priced at story level in [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) — **89 h AI-assisted
> against 128 h hand-coded**. Adding this sheet's 1,397 h to that sheet's 89 h gives **1,486 h** for all of MVP-1
> development. See §0.
>
> **The useful finding is not the saving — it is where the saving is not.** **RT (real-time / OPC / PLC) compresses
> by only 14.3%** against FE's 38.2%, so its share of development effort *rises* from 15.0% to **19.6%**. **Phase 14
> saves 12.5%**, the least of any phase, because PLC commissioning needs the controller and the mill. The parts of
> this build that resist AI assistance are exactly the parts already on the critical path.
>
> **W7 needs 5.5 developers across three working days** (§5) — and that is *before* Phase 12's 89 h, which also falls
> in W7, and before Phase 14's commissioning and UAT, none of which is counted here. The capacity model's finding that
> W7 cannot hold feature work *and* UAT is **unchanged** by AI assistance.

---

## 0. Scope, boundary and authority

### What this sheet is

**Development effort only** — the hours the four build streams spend building, on an AI-assisted basis:

| In scope | Stream | Surface |
|---|---|---|
| **FE** | Angular | `ual-angular` → new library `flat-wire` (prefix `fw`) |
| **BE** | .NET | `ual-api` → new `FlatWire` microservice |
| **DB** | SQL Server | new `FlatWireDB` ~~+ the shared-schema FW-001 renames~~ *(cancelled 18 Aug 2026, `D-32` — see `[CE §3c]`)* |
| **RT** | Real-time / PLC | `FlatWireHub`, OPC ingest, `PLCTagService` |

### What this sheet is not

**Phase 12 — Yield, Cost Ledger & Scrap — is not here.** It is priced at story level in
[`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md), which is the **sole home** of its figures: **89 h
AI-assisted (FE 27 · BE 54 · DB 8 · RT 0) against 128 h hand-coded.** That sheet decomposes it to the four
descope-ladder rungs, which this per-phase view cannot do, and records that three of its four stories carry **no
requirement specification** — so a single row here would have implied a firmness the estimate does not have.

> **⚠ This sheet therefore does not cover all of MVP-1 development.** `1,397 h` is MVP-1 development **excluding
> Phase 12**. The complete figure is **1,397 + 89 = 1,486 h**, and every total below — the §2 column sums, the §3
> roll-up, the §4 stream shares and the §5 weekly grid — is stated **net of Phase 12**. W7 is the week to watch: it
> holds Phase 12, so §5's W7 cell understates that week by 89 h by design.

**QA, BA, contingency, the roster, the weekly capacity decision and the descope ladder are also not here.** They remain
owned by [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md), and three of them behave differently enough
under AI assistance that folding them in would mislead:

- **QA does not scale with development hours.** The capacity model sets QA at +20% of the build base as a proxy for
  **feature volume**. Building the same features faster does not shrink the test surface — so a reader who scales
  QA down by 34% alongside these figures will understate it badly.
- **BA does not compress at all.** The 33 open client questions close at the client's pace, not the team's.
- **Contingency arguably should *rise*.** AI-assisted throughput is unmeasured for this team and carries a failure
  mode hand-coding does not: plausible-but-wrong code that survives review.

> **⚠ `1,397 h` is not the MVP-1 programme total and must never be quoted as one.** The MVP-1 programme, including
> Phase 12, QA, BA and contingency, is **3,186 h / 9.1 FTE** *(re-baselined 18 Aug 2026 by `D-32`; previously 3,292 h / 9.4)* on the hand-coded basis published in
> [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3b — and **that document remains the base of record.**
> This sheet does not restate, supersede or correct any programme figure in it. Every number here is one of its
> published cells multiplied by one factor from §1.

### Authority

AI-assisted development is a **recorded client decision, not an assumption introduced here.**
[`ClientCall_2026-07-23_SyncPlan.md`](../95-archive/source-documents/ClientCall_2026-07-23_SyncPlan.md) §"Decisions recorded on
the call" states: *"**AI-assisted development** to be leveraged wherever practical"*, alongside the direction to build
a modern application rather than copy legacy screens. That decision was filed as **recorded, not actioned**, and its
propagation **wave W8** names `CapacityAndEffortModel.md` as an unexecuted target. This sheet executes the effort-model
half of W8.

Nothing else in the repository carried an AI productivity assumption before this document —
[03-HLD-and-ERDiagram.md §14](../20-architecture/Architecture.md) has none. *(Note: the "AI-assisted generation" in
`PassScheduleGenerationSpec.md` is a **product** feature — ML proposing pass schedules from production history — and
is unrelated to development productivity. Do not conflate the two.)*

---

## 1. Retention factor card

A **retention factor** is the fraction of the hand-coded estimate that **remains** after AI assistance. Factors are
applied to the published discipline columns of [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §3, so every
figure in §2 is reproducible by a single multiplication.

| Work class | Factor | Basis |
|---|---|---|
| FE — screens, dialogs, variants | **0.62** | `MVP-1/ProjectPlan/Frontend/Mockups/` is a **complete, approved HTML visual spec** — the single highest-leverage input available. Conversion to Angular components, SCSS against one existing token system, and specs is largely mechanical |
| FE — shared controls (Phase 1A) | **0.60** | library scaffolding, 6 composite + the primitive controls |
| BE — command / query endpoints | **0.58–0.60** | `API/Domain/CoilCheckin` is an **exact** template (`[ARC §2.2]`); MediatR + FluentValidation is pattern replication. ⚠ *(This rationale read "+ xUnit" until 15 Aug 2026, when **all automated backend tests were withdrawn** — `[TS §1.2]`. The **retention factor is unchanged**: the withdrawn test effort came out of `[CE §2]`'s **base rate**, not out of this model's AI-assist ratio, and applying the withdrawal here as well would deduct it twice.)* |
| BE — non-trivial business services | **0.65–0.75** | domain reasoning, not boilerplate — AI drafts, a human verifies. The **0.75** end of the band applies to Phase 12's yield/cost work, which is priced in [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) and cites this card |
| DB — DDL, EF mapping, repositories | **0.60** | mechanical |
| ~~DB — FW-001 rename impact audit (40 h, 1C)~~ — **CANCELLED, `D-32`, 18 Aug 2026** | ~~**0.75**~~ | ~~the search across `united_db` and the legacy tier is assisted; the verification is not~~ — **the audit does not happen at all**, so both the hand-coded 40 h and its AI-assisted 30 h leave this sheet. See `[CE §3c]` |
| RT — hub events, SignalR plumbing | **0.75–0.85** | typed contracts and publishers assisted |
| RT — OPC ingest, PLC tag push | **0.90** | integration against a real controller; **not verifiable without the hardware** |
| RT — Phase 14 PLC commissioning (40 h) | **1.00** | needs the mill |

### Two rules that must not be "fixed" later

1. **Factors are net of the review tax.** They already absorb the closer code review AI-generated work requires. Do
   **not** add a separate review line, and do **not** re-apply a factor to a figure that already carries one.
2. **A phase whose specification is unsettled will not hit its factor.** These factors assume the unusually complete
   spec surface this repository has — approved mockups, one design-token system, an exact backend template, and a
   no-new-frameworks constraint. Where the design is still being argued, assistance helps least. The exposed phase
   remaining in this sheet is **Phase 4** (`OI-39` / `G2` cross-DB recovery undecided); the sharpest instance in the
   plan is **Phase 12**, which is why it is priced separately — see that sheet's §6.

---

## 2. Per-phase development effort

All figures in **hours**. `Days` is derived (hours ÷ 8) and is a reading aid only. **Every row is the sum of its own
four printed cells, and every column sums to its printed total** — verify any row by hand.

| Phase | FE | BE | DB | RT | **Dev h** | Days | Hand-coded | Saved | % |
|---|---|---|---|---|---|---|---|---|---|
| **1A** Angular Foundation | 134 | — | — | 33 | **167** | 20.9 | 268 | 101 | 37.7% |
| **1B** Backend Foundation | — | 121 | — | 95 | **216** | 27.0 | 320 | 104 | 32.5% |
| **1C** Database Foundation | — | — | 100 | — | **100** | 12.5 | 156 | 56 | 35.9% |
| **2** Pass Schedule Management | 50 | 37 | 8 | — | **95** | 11.9 | 154 | 59 | 38.3% |
| **3** Line Status Board & Real-Time Backbone | 40 | 10 | 3 | 34 | **87** | 10.9 | 124 | 37 | 29.8% |
| **4** Rod Check-In & PLC Config | 37 | 40 | 18 | 25 | **120** | 15.0 | 178 | 58 | 32.6% |
| **5** Active Run Monitoring & Gauge Trace | 47 | 7 | 5 | 20 | **79** | 9.9 | 120 | 41 | 34.2% |
| **6** In-Run Production Events | 74 | 34 | 13 | 17 | **138** | 17.3 | 216 | 78 | 36.1% |
| **7** WIP Rejection & Rod Checkout | 40 | 24 | 18 | 14 | **96** | 12.0 | 148 | 52 | 35.1% |
| **8** FL2 Spool Check-In & Finishing Run | 30 | 11 | 8 | 7 | **56** | 7.0 | 86 | 30 | 34.9% |
| **9** Output Coil Completion & Packing | 64 | 18 | 10 | 7 | **99** | 12.4 | 154 | 55 | 35.7% |
| **10** FL3 Hybrid Continuous Operation | 7 | 14 | 3 | 7 | **31** | 3.9 | 44 | 13 | 29.5% |
| **11** Shift Summary, Reporting & Certification | 40 | 47 | 18 | 3 | **108** | 13.5 | 172 | 64 | 37.2% |
| **13** Administration & Reference Data | 50 | 29 | 10 | 3 | **92** | 11.5 | 148 | 56 | 37.8% |
| **14** Integration Testing, PLC Commissioning & Go-Live | 12 | 12 | 6 | 40 | **70** | 8.8 | 80 | 10 | **12.5%** |
| | **625** | **404** | **220** | **305** | **1,554** | **194.3** | **2,368** | **814** | **34.4%** |

**This table is both scopes combined and excludes Phase 12**, whose 89 h AI / 128 h hand-coded is in
[`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md). Add it back for the full both-scopes figure:
**1,554 + 89 = 1,643 h** against **2,368 + 128 = 2,496 h**. For MVP-1 only, see §3.

**Reproducibility spot-check:** Phase 4 FE = 60 × 0.62 = 37.2 → **37**. Rounding is half-up on each cell, and the row
total is the sum of the rounded cells — the same convention the capacity model uses.

### Two observations

- **Phase 14 saves 12.5% — the least of any phase**, because 40 of its 80 development hours are PLC commissioning at
  factor 1.00. It is the phase sitting in the week the arithmetic already could not support. The next-least are
  **Phase 10 (29.5%)** and **Phase 3 (29.8%)**, both RT-weighted. *(Excluded Phase 12 is 30.5% on development hours
  and 28.8% all-in, which makes it the second-least-compressible phase in the plan — see its own sheet.)*
- **Phase 1B remains the largest single block** at 216 h, of which **95 h is RT** — OPC ingest and `PLCTagService`,
  the least-compressible work in the foundation.

> **Note on Phase 5.** The 120 h hand-coded base used here is §3's **post-descope** figure (FE 76 · BE 12 · DB 8 ·
> RT 24), correct since the DB13/DB14 descope of 4 Aug 2026. `../00-overview/Roadmap.md`'s navigation table and
> master spec §9.5 still carry the pre-descope **221 h**; §3 of the capacity model is where all sources agree on 154 h.
> Do not re-derive this row from the navigation table or it will pick up 67 h that was descoped.

---

## 3. MVP-1 development effort

The scope boundary is the capacity model §3b's, unchanged: **Phase 2 is wholly MVP-2** (pass schedule authoring is
owned outside MVP-1), **Phase 9 is wholly MVP-1** (DB7/DB7b and `CoilCompletionService` all returned 11 Aug 2026), and
**only phases 11 and 13 are carved.**

Factors are applied to §3b's published MVP-1 columns, not to a proportional share:

| Phase | FE | BE | DB | RT | **MVP-1 dev h** | Hand-coded | Carved to MVP-2 |
|---|---|---|---|---|---|---|---|
| **11** Reporting & Certification | 25 | 35 | 13 | 3 | **76** | 120 | **32** — DB10 screen · `GET /shiftsummary` · `ShiftSummaryService` · `sp_ShiftSummary` |
| **13** Administration & Reference Data | 35 | 19 | 5 | 3 | **62** | 100 | **30** — Die Management screen · die lifecycle service · die inventory table |

### Roll-up

```
1,554 h   both scopes, excluding Phase 12 (§2)
 −  95    Phase 2 — pass schedule, owned outside MVP-1
 −  32    Phase 11 carve
 −  30    Phase 13 carve
───────
1,397 h   MVP-1 development effort excl. Phase 12   ·   174.6 dev-days   ·   4.0 developer-FTE over 44 working days
 +  89    Phase 12 — YieldCostAndScrapSheet.md
───────
1,486 h   MVP-1 development effort, complete
```

Against the hand-coded MVP-1 development base of `2,368 − 154 − 52 − 48 = **2,114 h**` (264.3 d, **6.0 FTE**), the
saving is **717 h — 33.9%**, and the sustained developer requirement falls by **2.0 FTE**. Phase 12 is MVP-1 in full —
it is not carved — so it adds to both sides: **1,486 h against 2,242 h** complete, a saving of **756 h (33.7%)**.

> **One derived planning line, clearly labelled.** At the capacity model's 15% contingency rate,
> **1,397 × 1.15 = 1,607 h** excluding Phase 12, or **1,486 × 1.15 = 1,709 h** complete. This is offered only because
> a dev-effort sheet is normally read for budgeting. It is **not comparable to any total in the capacity model**, which
> applies contingency to (base + QA) rather than to the build base alone — so neither figure is a programme total nor a
> subtotal of one.

---

## 4. By stream

Excluding Phase 12 throughout, so both columns are on the same basis:

| Stream | Hand-coded | **AI-assisted** | Saved | % saved | Share was | **Share now** |
|---|---|---|---|---|---|---|
| **FE** Angular | 1,012 | **625** | 387 | **38.2%** | 42.7% | **40.2%** |
| **BE** .NET | 660 | **404** | 256 | **38.8%** | 27.9% | **26.0%** |
| **RT** Real-time / PLC | 356 | **305** | 51 | **14.3%** | 15.0% | **19.6%** |
| **DB** SQL Server | 340 | **220** | 120 | **35.3%** | 14.4% | **14.2%** |
| | **2,368** | **1,554** | **814** | **34.4%** | 100% | 100% |

Phase 12 would add FE 44→27 · BE 72→54 · DB 12→8 · RT 0. **It is BE-heavy and RT-free**, so excluding it raises RT's
share and lowers BE's — with it, BE compresses 37.4% rather than 38.8%, because its 0.75 factor is the least
favourable BE factor in the plan.

**FE remains the binding development constraint at ~40% of build hours** — but the composition shifts. FE, BE and DB
all compress by 35–39%; **RT compresses by 14.3% and is the only stream to gain share**, rising from 15.0% to 19.6%.

That is the structural consequence of AI assistance on this programme: it compresses screen, endpoint and schema work
— where the spec is complete and the patterns are established — and leaves the OPC ingest, the tag push and the
commissioning largely untouched, because those are verified against a physical controller rather than against a
specification. **Real-time is the stream to staff against, not FE.**

---

## 5. MVP-1 development effort by week

Week boundaries, working-day counts and the phase→week allocation are taken unchanged from
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §4 — **Labor Day falls Mon 7 Sep 2026** inside W4, and W7
holds only three days. Phases spanning two weeks are split evenly (Phase 3 across W2/W3; Phase 8 across W5/W6), and
Phase 1 is allocated wholly to W0 because the Aug-14 gate is hard.

`required developer FTE = development hours that week ÷ (working days × 8 h)`

| Week | Dates | Wk days | Dev capacity / person | **Dev h** | **Dev FTE** |
|---|---|---|---|---|---|
| **W0** | to **Aug 14** | 12 | 96 h | **483** | **5.0** |
| W1 | Aug 17–21 | 5 | 40 h | 0 | **0.0** ← the only slack in the plan |
| W2 | Aug 24–28 | 5 | 40 h | 44 | **1.1** |
| W3 | Aug 31–Sep 4 | 5 | 40 h | 43 | **1.1** |
| W4 | Sep 8–11 | **4** | **32 h** | 199 | **6.2** |
| W5 | Sep 14–18 | 5 | 40 h | 262 | **6.6** |
| W6 | Sep 21–25 | 5 | 40 h | 234 | **5.9** |
| **W7** | Sep 28–30 | **3** | **24 h** | **132** | **5.5** |

The `Dev h` column sums to **1,397** — the MVP-1 total **excluding Phase 12**, allocated with no leakage.

> **⚠ W7 is understated by 89 h by design.** Phase 12 sits wholly in W7. Adding it back gives **221 h → 9.2
> developer-FTE**, and W7 is the only week affected — every other cell is complete as printed.

### What this grid does and does not say

**These are developer FTEs only.** QA, BA and contingency are additional and live in
[`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) §4. Do not compare a number in this grid against a roster
line that includes testers.

Three readings survive AI assistance intact:

1. **The Aug-14 Phase-1 gate still needs 5.0 developers** across 12 working days — 483 h, of which 128 h is RT. The
   gate was a headcount problem, and it remains one at two-thirds the size.
2. **W7 needs 9.2 developers across three days once Phase 12 is added back** (5.5 on this sheet's figures alone), and
   that is *before* Phase 14's 112 h of QA and 40 h of UAT/BA. The capacity model's conclusion that **UAT cannot share
   W7 with feature work** is untouched — AI assistance compresses the feature work in that week and not the
   commissioning and sign-off it collides with. Phase 12 is the deferrable part of that load; see its own sheet §4.
3. **W1 remains the entire recovery budget**, and it is now smaller in absolute terms: 5 days × 5 developers is
   ~200 development hours of slack against a 1,486 h plan.

---

## 6. Calibration checkpoint

The factors in §1 are **derived from the work's character, not measured on this team.** The
**Aug-14 Phase-1 gate is the calibration point**, and it now calibrates two things — the capacity model's rate card
*and* these factors:

1. Record **actual development hours** for 1A, 1B and 1C against **167 / 216 / 100 h** (483 h total), split by stream.
2. Compute the **realised retention factor per stream** — actual ÷ the hand-coded 268 / 320 / 156.
3. Restate §1 and re-issue §2–§5. If the realised FE factor is materially above 0.62, the largest single assumption
   in this sheet is wrong in the unfavourable direction.
4. Feed the realised factors back to `CapacityAndEffortModel.md` §6, so the rate card and these factors are restated
   **once, together** — never both independently against the same actuals.
5. Record the revision in [`../CHANGELOG.md`](../CHANGELOG.md) under this document's section.

**Early signal, available well before the gate:** Phase 1 development is 483 h across 12 working days ≈ 40 h/day, so a
five-day week should book **~200 development hours**. If it books materially less, the factors are optimistic and the
capacity model's §7 decision cannot wait for the gate.

---

## 7. Assumptions and known risks

- **The factors are the single largest uncertainty in this sheet** — larger than any individual phase estimate. No
  baseline exists for this team on this stack, and a factor error propagates to every figure here simultaneously. The
  hand-coded columns are retained throughout precisely so the exposure is visible.
- **Tooling and ramp-up are not costed.** Seat provisioning, and the time to build effective prompt context over a
  spec surface this large, are both outside these hours — as is onboarding, which the capacity model also excludes.
- **Review capacity becomes the bottleneck risk.** 625 h of FE output still needs reviewing by a same-size FE team;
  the factors assume that review keeps pace. If it does not, the work does not get faster — it gets queued.
- **Reserves are unchanged and remain excluded**, exactly as in the capacity model: **`G2`/`OI-39` on Phase 4
  (24–64 h)** for cross-DB check-in recovery, and **`OQ-10`/`OI-45` on Phase 9 (16–32 h)** for the footage→weight
  dimensional basis. Neither is a coding problem, so neither compresses.
- **What AI assistance does not compress at all:** PLC commissioning (needs the controller), UAT and stakeholder
  sign-off (needs calendars), the Aug-14 gate date, the `OI-39` design decision, the `G9`/`OI-34` load-test NFRs that
  do not yet exist, and the **33 open client questions** in `../90-registers/Questions.md`.
- **Upstream stories** (rod receiving, order planning, line scheduling) are out of scope here as they are in the
  capacity model, and are staffed by their own teams.

---

## Related Documents

| Document | Purpose |
|---|---|
| [`CapacityAndEffortModel.md`](./CapacityAndEffortModel.md) | **The base of record.** §2 rate card · §3/§3b the hand-coded per-phase hours this sheet factors · §4 full capacity model incl. QA/BA · §5 descope ladder · §7 the programme decision |
| [`YieldCostAndScrapSheet.md`](./YieldCostAndScrapSheet.md) | **Phase 12 — excluded from this sheet and owned entirely there.** Story-level effort on both bases (**89 h AI / 128 h hand-coded** development), the descope-ladder role, and the finding that three of its four stories have **no requirement specification**. Add its 89 h to this sheet's 1,397 h for complete MVP-1 development |
| [`../00-overview/Roadmap.md`](Roadmap.md) | Master roadmap index — per-phase Owner/Effort summary (hand-coded basis) |
| [`../90-registers/Gaps.md`](../90-registers/Gaps.md) | Week grid, milestone calendar, gaps register (**G1**) |
| [`ShopfloorPlan/phase-*.md`](Phases/) | Per-phase deliverable inventories — what the rate card priced |
| [`ClientCall_2026-07-23_SyncPlan.md`](../95-archive/source-documents/ClientCall_2026-07-23_SyncPlan.md) | The AI-assisted development decision (§"Decisions recorded on the call") and propagation wave **W8** |
| [03-HLD-and-ERDiagram.md §14](../20-architecture/Architecture.md) | Stack constraints the factors depend on — no new frameworks, team already Angular/.NET |
