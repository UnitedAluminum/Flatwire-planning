# Weld Event — Change Plan: Popup Conversion and Payoff-Card Entry

**Project:** Flat Wire Mill Implementation
**Document Type:** Change plan — **executed; retained as a record, not as instructions**
**Last Updated:** August 13, 2026 — reduced to the record. The change-plan body (design options, work breakdown, sequencing) was **removed as spent**; the full text is recoverable at commit `1964086`
**Status:** **Executed** — applied 1 Aug 2026; `S7`, the last step to land, closed 13 Aug 2026
**Affects:** Dashboard 2A (Rod Pre-Check-In) · ~~Dashboard 4 (Log Weld Event)~~ *(retired 1 Aug 2026)* · Dashboard 3 family

---

> ## ⚠ This plan has been applied. Do not implement from it.
>
> Every change it specified is in the artifacts that own it — the mockups, the requirement documents,
> `02-SRS.md`, the phase files, the backlog and the test plan. **The design narrative and work breakdown were removed
> on 13 Aug 2026** because a change plan that has been executed is instructions for work already done, and leaving them
> invited someone to re-apply them.
>
> **What is retained below is only what other documents still cite:** the decision attribution, the `Q-W#` register with
> dispositions, and the gap-register outcomes. Verified on removal: **`S1`–`S9` all landed**, including `S6`
> (`phase-06` — Dashboard 4 as a dialog, merged `RodStaging` write, DB2A entry points), `S8` (`FW-063` retitled *Weld
> Event capture — DB2A dialog*) and `S9` (`TC-068` rewritten, `TC-068a`–`TC-068i` added), none of which the plan's own
> table had struck through.

## The change, in one paragraph

The weld capture moved off a standalone screen and onto the pre-check-in station. **Dashboard 4 was retired**; the weld
is now a dialog reached from Dashboard 2A's staged payoff card. **`POST /staging/rod/mark-welded` was retired and
`POST /weldevent` became the single weld write** — Dashboard 2A's *Mark as welded* dialog gained the quality check, so
one row is composed by both entry points. That merge is **decision `D-A`**, which is what
[`APIContracts.md`](APIContracts.md) attributes to this document. A read-only **Welds this run** dialog was built on
Dashboard 2A over `GET /run/{runId}/weldevents`. Welds are **induction** only; laser was dropped.

## `Q-W#` register — dispositions

| Ref | Disposition |
|---|---|
| ~~**Q-W1**~~ | **DECIDED 1 Aug 2026 — yes, quality is captured at the weld.** Rather than removing the lightweight flag, Dashboard 2A's *Mark as welded* dialog gained the quality check; it already captured both alphas, weld type and footage, so quality was the only NOT NULL `WeldEvent` column missing. `POST /staging/rod/mark-welded` retired. Closed by `D-A` |
| **Q-W2** | **OPEN · Medium · ⚠ this document is its only home** — see the finding below |
| ~~**Q-W3**~~ | **DECIDED 1 Aug 2026 — yes, a weld-history view is needed.** A read-only **Welds this run** dialog on Dashboard 2A, scoped to the active `RunId`, over `GET /run/{runId}/weldevents`. Built; `G25` withdrawn rather than registered |
| ~~**Q-W4**~~ | **ACTED ON 1 Aug 2026 — the FL2 active-run link to the weld screen was removed**, along with the weld button on all four active-run screens. ⚠ **Decided rather than answered**, which is why it became gap **`G28`**: `dashboard_10_shift_summary.html` fixtures show FL2 welds (`SP-00029 → SP-00030`, induction) while `WeldEvent.md:166` says FL2 *inherits* the spool's weld markers. If FL2 does weld spool-to-spool it now has **no capture path at all** |

> ### ⚠ `Q-W2` is live, unregistered, and was nearly lost
>
> **The question:** should the post-staging weld offer be **gated to the sub-3,000 lb window**, or shown on **every**
> successful staging? It governs `D-G`, the offer's trigger rule.
>
> This document states that its `Q-W#` questions were *"to be added to `Analysis/FlatWireOpenQuestions.md`"*. **Only
> `Q-W1` and `Q-W4` were ever propagated** — `Q-W1` through `APIContracts.md`, `Q-W4` through gap `G28`. `Q-W2` was
> not, and a repository-wide search on 13 Aug 2026 found it **nowhere else**: not in the open-questions register, not
> in the master spec's `OI-##` register, not in `RodPreCheckin.md`. The 3,000 lb *alert* threshold is well specified
> (`FR-034`, `FR-423`, `RodPreCheckin.md` §alerts); **whether the weld offer follows that threshold is not.**
>
> **It needs registering in `Analysis/FlatWireOpenQuestions.md`.** Flagged rather than done, because that register is
> outside the folder this clean-up covered.

## Gap register outcomes

| Gap | Outcome |
|---|---|
| ~~**G25**~~ | **WITHDRAWN 1 Aug 2026 — built rather than deferred** (the *Welds this run* dialog). It was withdrawn before it was ever registered, so nothing cited it, and **the ID was reused on 13 Aug 2026** for the requirement-coverage gap now in [`back-matter.md`](./ShopfloorPlan/back-matter.md) |
| **G26** | **The merged weld write straddles two phases** — Dashboard 2A's weld control ships in **phase 4**, and `POST /weldevent` is a **phase 6** deliverable, so phase 4 ships a button whose target lands later. **Registered 13 Aug 2026, twelve days late**: `phase-06:45` had cited it since 1 Aug against no register entry. That omission was step `S7`, the one step of nine that did not execute on the day |

## Related Documents

| Document | What it owns now |
|---|---|
| [`../RequirementDocuments/WeldEvent.md`](../RequirementDocuments/WeldEvent.md) | The weld capture requirements — the client-facing owner |
| [`../RequirementDocuments/RodPreCheckin.md`](../RequirementDocuments/RodPreCheckin.md) | Dashboard 2A, including the *Mark as welded* and *Welds this run* dialogs |
| [`ShopfloorPlan/phase-04-rod-checkin-plc-config.md`](./ShopfloorPlan/phase-04-rod-checkin-plc-config.md) | The Dashboard 2A build, where the weld control ships |
| [`ShopfloorPlan/phase-06-in-run-production-events.md`](./ShopfloorPlan/phase-06-in-run-production-events.md) | `POST /weldevent`, the single weld write |
| [`ShopfloorPlan/back-matter.md`](./ShopfloorPlan/back-matter.md) | Gaps **G25**, **G26**, **G28** |
| [`APIContracts.md`](APIContracts.md) | The endpoint elaboration that attributes `D-A` here |
