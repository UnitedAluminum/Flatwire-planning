# Flat Wire Mill — Development Sprint Plan

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — initial publication
**Document Type:** Sprint plan, **build streams only** — FE · BE · DB · RT
**Status:** Published — **a derived view, not a new estimate.** Every figure is factored from `[CE]` and `[DE]`
**Owner:** Development leads (FE / BE / DB / RT)
**Audience:** Developers and development leads
**Shortcode:** `[DSP]`
**Part of:** `ProjectPlan/Development/` — index: [README.md](../README.md)

---

> ## What this is, and what it deliberately excludes
>
> **This is the sprint plan a development lead commits against.** It carries **only** the four build streams —
> **FE** Angular · **BE** .NET · **DB** SQL Server · **RT** real-time/PLC — on the sprint cadence
> [`SprintPlan.md`](SprintPlan.md) §4.2 defines.
>
> **QA, BA and contingency are not here**, and the numbers below are therefore **not** a programme total.
> `[SP]` is the programme sprint plan; this is its development slice. Do not compare a figure here against a
> roster line that includes testers.
>
> **Nothing is independently estimated.** Hand-coded hours are the FE+BE+DB+RT columns of
> [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) §3/§3b; AI-assisted hours are
> [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) §2/§3 plus Phase 12 from
> [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md). **If either model changes, this document is
> re-derived — it is not a second opinion.**

---

## 1. The headline

| | Hand-coded | **AI-assisted** |
|---|---|---|
| **MVP-1 development effort** | **2,242 h** (280.3 dev-days) | **1,486 h** (185.8 dev-days) |
| **Sustained developer requirement** over 44 working days | **6.4 FTE** | **4.2 FTE** |
| Peak sprint (**S3**) | **10.5 FTE** | **7.1 FTE** |
| Pre-window gate (**S0**) | **7.8 FTE** | **5.0 FTE** |

**AI-assisted is the planning basis**, per the client decision of 23 July 2026 recorded in
`ClientCall_2026-07-23_SyncPlan.md`. The hand-coded column is retained throughout because the retention factors
are **assumed, not measured on this team** — it is the exposure if they are wrong.

> **For context, not for comparison:** the *programme* requirement including QA, BA and contingency is
> **9.4 FTE sustained** (`[SP §1]`). Development is roughly two-thirds of the hand-coded programme and under half
> of it on the AI-assisted basis. **Staffing to 4.2 developers does not staff the programme.**

---

## 2. The sprints

Cadence, dates and working days are `[SP §4.2]`'s, unchanged. `S0` is the pre-window gate sprint fixed by the hard
**14 Aug Phase-1 gate**; the week of **17–21 Aug sits between S0 and S1 and is deliberately not a sprint**.

| Sprint | Dates | Wk days | Cap/person | Phases | **Hand-coded** | Dev FTE | **AI-assisted** | Dev FTE |
|---|---|---|---|---|---|---|---|---|
| **S0** *(gate)* | Thu 30 Jul – Fri 14 Aug | 12 | 96 h | 1A · 1B · 1C | **744** | **7.8** | **483** | **5.0** |
| *— carry-over —* | *Mon 17 – Fri 21 Aug* | *5* | *40 h* | *Phase 1 completion* | **0** | *0.0* | **0** | *0.0* |
| **S1** | Mon 24 Aug – Fri 4 Sep | 10 | 80 h | 3 | **124** | **1.6** | **87** | **1.1** |
| **S2** | Mon 7 Sep – Fri 18 Sep | 9 | 72 h | 4 · 5 · 6 · 7 · 8 *(start)* | **705** | **9.8** | **461** | **6.4** |
| **S3** | Mon 21 Sep – Wed 30 Sep | 8 | 64 h | 8 *(finish)* · 9 · 10 · 11 · 12 · 13 · 14 | **669** | **10.5** | **455** | **7.1** |
| | | **44** | **352 h** | | **2,242** | **6.4** | **1,486** | **4.2** |

**Phase 8 spans the S2/S3 boundary and is split evenly**, matching `[SP §4.2]`'s treatment of the same phase.
**Labor Day (Mon 7 Sep)** is excluded from S2's working days. Hours sum to the totals with no leakage; verify any
column by hand.

---

## 3. By stream and sprint

The number each lead commits against. **AI-assisted basis** — the planning basis:

| Sprint | FE | BE | DB | RT | **Total** |
|---|---|---|---|---|---|
| **S0** | 134 | 121 | 100 | **128** | **483** |
| **S1** | 40 | 10 | 3 | 34 | **87** |
| **S2** | 213 | 111 | 58 | 79 | **461** |
| **S3** | 185 | 157 | 49 | 64 | **455** |
| **Total** | **572** | **399** | **210** | **305** | **1,486** |
| *Hand-coded* | *928* | *634* | *324* | *356* | *2,242* |
| **Compression** | **38.4 %** | **37.1 %** | **35.2 %** | **14.3 %** | **33.7 %** |

### The stream to staff against is RT, not FE

**FE is the largest stream and RT is the binding one.** FE, BE and DB all compress by 35–38 % under AI assistance;
**RT compresses by 14.3 %** and is the only stream whose *share* rises — from 15.9 % of development hours to
**20.5 %**. The reason is structural, not incidental: OPC ingest, the tag push and PLC commissioning are verified
against a **physical controller**, not against a specification, and no amount of code generation changes that.
`[DE §1]` prices Phase 14's commissioning at factor **1.00** — no saving at all.

**RT's load is front-heavy and back-heavy, with almost nothing between.** 128 h in S0 (the OPC ingest and
`PLCTagService` foundation) and 64 h in S3 (of which 40 h is commissioning), against 34 h and 79 h in the middle
sprints. A single RT developer covers S1 and S2 comfortably and is the critical path in both S0 and S3.

---

## 4. What this plan says about each sprint

**S0 — the gate needs 5.0 developers before the window opens.** 483 h across 12 working days, of which **128 h is
RT** — the least compressible work in the plan, in the sprint with the hardest date. The gate was a headcount
problem on the hand-coded basis and it remains one at two-thirds the size. This is the sprint where being wrong
about the retention factors costs the most.

**S1 is the only sprint with slack, and the carry-over week is the whole recovery budget.** 87 h of development
across ten working days — 1.1 FTE. Phase 3 lands whole in one sprint, so the real-time backbone ships as a single
outcome. **Do not absorb the 17–21 Aug carry-over week into S1**: `[SP §4.2]` keeps it outside every sprint
precisely so the one buffer in the plan stays visible.

**S2 is the full FL1 operator journey — five phases, 461 h, 6.4 developers.** FE dominates at 213 h. Phase 6's
five in-run events parallelise by feature once Phase 5 exists (`[SP §6.4]`), which is what makes the sprint
tractable at all.

**S3 is the risk.** Seven phases in **8 working days** — the sequential `8→9→10` chain, three back-office phases,
and the whole of Phase 14. At **7.1 developers** it is the peak, and Phase 14's 70 h includes **40 h of PLC
commissioning that cannot start until the controller and mill are available**.

> **S3's truncation is a choice.** Its natural two-week boundary is **Fri 2 Oct**; it is cut at **Wed 30 Sep** to
> hit the published M5 feature-complete date. Running it to its natural end costs **two days** and drops the peak
> from 7.1 to **5.7 developers** — `[SP §4.2]` records this as the cheapest schedule relief anywhere in the plan,
> cheaper than any rung of the descope ladder.

---

## 5. Three things this plan does not cover

1. **Phase 12 is fully deferrable and sits entirely in S3.** Its **89 h** (AI) / **128 h** (hand-coded) is
   included above, but it is descope-ladder rungs 1–4 in their entirety — the only phase that is 100 % optional.
   Dropping it takes S3 to **366 h / 5.7 FTE**. See [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) §4,
   which also records that **three of its four stories have no requirement specification at all**.
2. **Two reserves are excluded, and neither compresses.** `G2`/`OI-39` cross-DB check-in recovery on Phase 4
   (**24–64 h**) and `OQ-10`/`OI-45` footage→weight on Phase 9 (**16–32 h**). Both are design decisions, not
   coding problems.
3. **Ramp-up, tooling and review capacity are not costed.** `[DE §7]` names review as the bottleneck risk: 572 h
   of FE output still needs reviewing by a same-size FE team. If review does not keep pace, the work does not get
   faster — it queues.

---

## 6. One figure that does not follow its own rate card

**Phase 5 is understated by 12 h all-in, and the development columns are the reason.** `[CE §2]` sets QA at 20 %
of the development base and contingency at 15 % of (base + QA); **13 of the 16 phases reproduce exactly**, and the
two that do not are documented (Phase 3 carries a discrete 16 h hub load test; Phase 14's QA is direct effort, not
an uplift). Phase 5 is the third:

| | Development base | QA | Contingency | Total |
|---|---|---|---|---|
| `[CE §3]` as published | 120 | 22 | **12** | **154** |
| The rate card applied to that base | 120 | 24 | **22** | **166** |

The cause is visible in the phase file: Phase 5 went **221 → 154 h** on 4 Aug 2026 when DB13/DB14 were descoped,
and the rung's all-in **67 h was subtracted from the total** rather than the base being reduced and the uplifts
re-derived — which is the method `[CE §3b]` insists on for the MVP-2 carves.

**This document is unaffected** — Phase 5's *development* columns (FE 76 · BE 12 · DB 8 · RT 24 = 120 h) are
consistent, and only the QA and contingency uplifts are short. **The programme total is affected**: MVP-1 would be
**3,304 h**, not 3,292. The sustained requirement is 9.4 FTE either way, so no conclusion moves — but roughly
twenty documents cite 3,292, and correcting it is a programme decision, not a documentation edit.

---

## Related Documents

| Document | Why you would open it |
|---|---|
| [`SprintPlan.md`](SprintPlan.md) `[SP]` | **The programme sprint plan** — the same cadence with QA, BA and contingency included, plus DoR/DoD, the dependency chain and the risk register |
| [`CapacityAndEffortModel.md`](CapacityAndEffortModel.md) `[CE]` | **The hours model of record.** §2 rate card · §3/§3b the per-phase columns this document slices |
| [`DevelopmentEffortModel.md`](DevelopmentEffortModel.md) `[DE]` | The AI-assisted basis — §1 retention factors, §4 by-stream, §5 the same hours on a **weekly** rather than sprint grid |
| [`YieldCostAndScrapSheet.md`](YieldCostAndScrapSheet.md) `[YCS]` | Phase 12's figures and its specification gap |
| [`TaskBreakdown.md`](TaskBreakdown.md) `[TB]` | The 116 stories these hours are built from, with a `Rate-card basis:` line on each |
| [`Phases/`](Phases/) | The 15 phase specifications — the deliverable inventories the rate card priced |
