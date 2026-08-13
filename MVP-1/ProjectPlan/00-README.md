# Flat Wire Mill — Project Plan Document Set

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 4, 2026
**Document Type:** Index
**Status:** Complete — seven documents published
**Owner:** Programme management
**Audience:** Everyone working on the Flat Wire Mill module
**Sources:** Derived from [`../FlatWire_MasterSpecification.md`](../../LatestDocument/FlatWire_MasterSpecification.md) and the artifacts it reconciles

---

## 1. The seven documents

| # | Document | Read it for | Audience |
|---|---|---|---|
| 1 | **[Vision & Scope](./01-VisionAndScope.md)** | Why the project exists, what is in and out of scope, the success criteria, the risks | Sponsors, programme management, business owners |
| 2 | **[SRS](./02-SRS.md)** | **What to build** — **279 numbered requirements (263 in MVP-1 scope)** with NFRs folded in, the domain model, the process flows, the role matrix | Developers, QA, BA |
| 3 | **[HLD + ER Diagram](./03-HLD-and-ERDiagram.md)** | How it is structured — architecture, the real-time pipeline, the 27-table data model, the ER diagrams, the transactional boundary | Architects, developers, DBA |
| 4 | **[API Contract](./04-APIContract.md)** | What to code against — 30 endpoints, 10 hub events, the PLC surface, the enums | Frontend and backend developers, integration testers |
| 5 | **[Sprint Plan & Backlog](./05-SprintPlanAndBacklog.md)** | When it gets built, by whom, in what order — **and why the window does not close** | Delivery lead, scrum team, programme management |
| 6 | **[Test Plan & Test Cases](./06-TestPlanAndTestCases.md)** | How it is proved — ~250 test cases, NFR verification, UAT scripts, commissioning tests | QA, developers, UAT participants |
| 7 | **[Deployment Runbook & Rollback](./07-DeploymentRunbookAndRollback.md)** | How it ships and how to undo it | IT/DevOps, DBA, release manager, on-call |

## 2. Read order

**First time through:** 1 → 2 → 3 → 4 → 5 → 6 → 7. Documents 5–7 cite identifiers minted in 2–4.

**If you are joining the build:**

| Your role | Start here |
|---|---|
| Angular developer | `[HLD §5]`, then `[SRS §5]` for your screen, then `[API]` for its endpoints |
| .NET developer | `[HLD §2.2]` (**the reference rules are binding and non-obvious**), then `[HLD §3]`, then `[API]` |
| DBA | `[HLD §6]`, then `[DR §4.2]` and `[DR §4.3]` |
| QA | `[TP §1]`–`[TP §4]`, then the `[TP §5]` block for your area |
| Delivery lead | `[SP §1]` — **before anything else** |
| Release manager | `[DR]` end to end, then `[TP §4.2]` |

## 3. Which document is authoritative for what

| Question | Authority |
|---|---|
| Why are we doing this? What is in scope? | `[VS]` |
| What must the system do? | `[SRS]` — requirement numbers are stable and must not be renumbered |
| What are the non-functional targets? | `[SRS §6]` — the register; each also appears inline in the group it constrains |
| How is it structured? Where does the code land? | `[HLD]` |
| What are the exact column types and constraints? | **The executable DDL** in [`../DBChanges/Schema/SQL/`](../DBChanges/Schema/SQL/) — `[HLD §6]` describes it, the DDL defines it |
| What does the screen look like? | **The HTML in [`../../MVP-1/Mockups/`](../../MVP-1/Mockups/)** — `[SRS §7]` describes it, the mockups define it |
| What is the request or response shape? | `[API]` |
| When does it get built, and by whom? | `[SP]` |
| How do we know it works? | `[TP]` |
| How do we ship it, and how do we undo it? | `[DR]` |
| **What tag is written to the machine or read from it, and when?** | **`[PLC]`** — [`MVP-1/RequirementDocuments/PLCTagSpecification.md`](../../MVP-1/RequirementDocuments/PLCTagSpecification.md), the single home for the PLC/OPC tag surface. A **client-facing companion** to this set, not an eighth member: it carries a sign-off sheet and the `PLC-Q##` register, because the tag map must be confirmed by the commissioning engineer before go-live |
| Which of two conflicting older documents wins? | [`../FlatWire_MasterSpecification.md`](../../LatestDocument/FlatWire_MasterSpecification.md) §10, and [`../../MVP-1/DevelopmentPlan/REVIEW.md`](REVIEW.md) |

**Precedence when sources disagree:** this document set → the master specification → the DDL (columns) and the mockups (pixels) → the July 26 roadmap and `ShopfloorPlan/*` → the April-dated documents.

> **Four April-dated documents were never reconciled with the July 26 rewrite** — `APIContracts.md`, `FlatWireJiraStories.md`, `FlatWireTables.md`, `TechStackRecommendation.md`. They still print a dead timeline and, in the case of `APIContracts.md`, four correctness defects. **Mine them for detail, never for precedence.**

## 4. The five things a reader most often gets wrong

1. **The date does not work.** **MVP-1 is 3,292 hours** against 44 working days — **9.4 FTE sustained**, with **24.5 FTE needed in W7** — and descoping recovers only ~12 %, less on MVP-1 scope. *(Both scopes: 3,660 h / 10.4 FTE. The **3,727** figure quoted before 11 Aug 2026 was a stale TOTAL row.)* A programme decision is required — `[SP §1]`.
2. **`Rod` is retained**, with enforced FKs, and the schema is **28 tables** — superseding the "drop `Rod`, 21–22 tables" position that two documents in this repository still state. `[HLD §6.3]`.
3. **There is no Angular template.** Every control is built fresh from the mockups; the only reuse is the foundational `shared` services. `[HLD §2.2]`.
4. **FL1 has no edger**, FM2's edgers are at **S2 and S3 only**, and **FL2 broadcasts `null` live gauge and width**. `[SRS §3.1]`.
5. **The product is called flat wire, never "strip."**

## 5. New findings raised by this document set

Numbered `PP-##`. Each is recorded at the point it was found.

| ID | Finding | Where |
|---|---|---|
| **PP-01** | **The index count is 46, not 44.** Counted from `FlatWire_DDL_07_Indexes.sql`: 43 non-clustered + 3 filtered UNIQUE. The master specification says "41 plus 3" | `[HLD §6.8]`, `[DR §4.2]` |
| **PP-02** | **`NFR001`, `NFR002` and `NFR008` are cited nowhere** in any downstream artifact. Either three NFRs exist that nothing consumes, or the numbering has gaps. **No NFR was invented to fill it** | `[SRS §6.4]` |
| **PP-03** | **The OEE dashboard has no story, no phase and no owner** — it has an approved mockup and 17 source requirements | `[SRS §11.3]`, `[SP §7.7]` *(`FW-N09`, listed under B.4 "adopted but uncosted")* |
| **PP-04** | **The hub event count is 10, not 9.** The "9" predates `PayoffStateChanged` | `[API §10.3]` |

## 5a. Changed by the 30 Jul 2026 client call

Applied 1 Aug 2026 across this set. **Three of these reverse decisions the set already documented**, so a reader working from a cached copy will be wrong about them:

| Change | Was | Is |
|---|---|---|
| **Wrong station** | Notified, supervisor override, recorded on `RodStaging` | **Auto-switches to the correct station** — no message, no override; the columns are dropped (OQ-24) |
| **Welded pre-check-out** | No control at all — a welded rod could not be released | **Supervisor override + documented reason + `HOLD`** — it is a rejection, not a return (OQ-69/OQ-72) |
| **`INFLAT` at staging** | Set at pre-check-in per the delivered SRS | Set at **check-in only**; `RECEIVED → STAGED` stands (OQ-68) |
| **Blocked bay** | Enterable but **not clearable** | The **WIP rejection** releases it (OQ-23) |
| **Tolerances** | One ± per dimension, rod diameter missing | **Four min/max pairs** — gauge, width, diameter, ovality. **Values owed by e-mail; nothing seeded** (OQ-22) |
| **Spool target** | 2,000 lb assumed default | **Customer min/max weight range**; short close is an unplanned stop on the 10-90 pattern (OQ-18/OQ-79) |
| **One rod, one order** | Assumed, and enforced by refusal | **A rod may carry two orders** — the refusal is knowingly wrong pending OQ-73 (**G22**) |

Four questions were added: **OQ-25** (order scheduled on neither rod line), **OQ-73** (multi-order sequencing / MVP scope), **OQ-26** (panel resolution — gates Phase 1A against the 14 Aug gate), **OI-97** (rod bundle gross weight). Full propagation record in [`../../BaseDocuments/ClientCall_2026-07-30_SyncPlan.md`](../../BaseDocuments/ClientCall_2026-07-30_SyncPlan.md).

## 6. What these documents deliberately do **not** resolve

Twelve requirements have no executable path, and every one is a decision someone else must make, not a gap in this document set:

- **Wire break** (3 requirements) — no screen, no table, no persistence target (**OI-13**).
- **OEE** (9 requirements) — no owning story or phase (**PP-03**).

And four NFR targets are undefined, which means **the QA2 hub load test as scheduled cannot fail** (**G9 / OI-34**). No threshold was invented for them. `[TP §6.2]`.
