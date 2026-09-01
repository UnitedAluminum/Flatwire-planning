# MVP-2 Project Plan — Index

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**

---

> **⚠ Nothing in this folder is part of MVP-1 or of MVP-1 planning.** These four documents were created on 11 Aug 2026 by extracting the screen-mapped sections of the MVP-1 project plan. **Every section was copied verbatim** — no `FR-###`, `TC-###`, endpoint or `FW-###` was renumbered, reworded or re-estimated.

## What is here

| Document | Contains | Extracted from |
|---|---|---|
| [`02-SRS-MVP2.md`](02-SRS-MVP2.md) | Functional requirements for the seven deferred screens — §5.10, 5.16, 5.17, 5.18, 5.19, 5.23, 5.24 | `02-SRS.md` §5 |
| [`04-APIContract-MVP2.md`](04-APIContract-MVP2.md) | Four endpoints — `POST /passschedule/generate`, `POST /coil/complete`, `GET /coil/{alpha}/label`, `GET /shiftsummary` | `04-APIContract.md` §4 |
| [`05-Backlog-MVP2.md`](05-Backlog-MVP2.md) | Eight deferred stories, plus the two that span both scopes | `05-SprintPlanAndBacklog.md` §7 |
| [`06-TestCases-MVP2.md`](06-TestCases-MVP2.md) | Five test-case blocks — TC-295–309, 405–429, 435–444, 450–484, 545–564 | `06-TestPlanAndTestCases.md` §5 |

## These documents are deliberately not self-contained

Only the **screen-mapped** sections divided. Everything cross-cutting stayed in [`../../MVP-1/ProjectPlan/`](../../MVP-1/ProjectPlan/) and is **cited, never copied**:

| Stayed in MVP-1 | Why it matters here |
|---|---|
| `02-SRS.md` §1–4 | Introduction, overall description, **the domain model and glossary**, process flows |
| `02-SRS.md` §5.0 | **Cross-cutting requirements that apply to every screen**, including these seven |
| `02-SRS.md` §6–9 | Non-functional, UI, security/roles, external interfaces |
| `02-SRS.md` §10 | **The traceability appendix — it still lists the deferred `FR-###` and now traces into this folder** |
| `03-HLD-and-ERDiagram.md` | Architecture and the ER diagram — **one diagram covering every table** (the count is `[DBD §6.2]`'s; this row said "all 34 tables" until 26 Aug 2026), not divided |
| `04-APIContract.md` §1–3 | Conventions, the response envelope, canonical enums, **and the 30-endpoint index which still lists all four deferred endpoints** |
| `05-SprintPlanAndBacklog.md` | Capacity model, sprint calendar, phase table, dependency chain, descope ladder, risk register, **§11 the coverage matrix** |
| `06-TestPlanAndTestCases.md` §1–4 | Test strategy, the `TC-###` scheme, environments, seed data, entry/exit gates |
| `07-DeploymentRunbookAndRollback.md` | Deployment and rollback — not divided |

**This is on purpose.** The repository's documented history is a catalogue of duplicated sections drifting apart — six copies of a PLC tag map that agreed on nothing, four copies of the generation algorithm, a four-stand FM2 belief held across four artifacts for ten weeks. A second copy of the domain model or the response envelope is how that starts.

## Three places where the division is visible and intended

1. **`TC-###` ranges are discontinuous in the MVP-1 test plan.** A gap means deferred, not missing.
2. **The MVP-1 endpoint index still counts 30** and still lists all four deferred endpoints. Four holes in the contract's map would read as four missing endpoints. The MVP-1 service implements **26 of 30**.
3. **The MVP-1 backlog still contains the eight deferred stories**, marked rather than removed, because §11 proves every `FR-###` reaches a story.

## The dependency the scope line did not remove

`FW-010` — the pass-schedule data model and API — is deferred here, while **`FW-061`** (rod check-in) and **`FW-082`** (PLC tag push), both **Critical MVP-1**, depend on it. Rod check-in acknowledges a pass schedule and pushes PLC tags from it. See [`05-Backlog-MVP2.md`](05-Backlog-MVP2.md) and [`../95-archive/design-notes/MVP-2-scope-note.md`](../95-archive/design-notes/MVP-2-scope-note.md).
