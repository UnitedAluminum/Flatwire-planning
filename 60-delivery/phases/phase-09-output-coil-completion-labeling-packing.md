# PHASE 9 — Output Coil Completion, Labeling & Packing

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../../00-overview/Roadmap.md).** See [Foundations](../../20-architecture/Architecture.md) for §0.2–0.4 shared context.
> **Prev:** [Phase 8 — FL2 Spool Check-In & Finishing Run](./phase-08-fl2-spool-checkin-finishing-run.md) · **Next:** [Phase 10 — FL3 Hybrid Continuous Operation](./phase-10-fl3-hybrid-continuous-operation.md)
> **Owning specification:** [`OutputCoilCompletion.md`](../../10-requirements/screens/OutputCoilCompletion.md) — v1.1 owns **DB7 and DB7b** (§8); the owning doc wins on any disagreement.

---

> **Worked numeric traces for the order dimension.** [`RodOrderAllocation_WorkedExamples.md`](../../95-archive/design-notes/RodOrderAllocation_WorkedExamples.md) carries seven end-to-end traces covering {1 order, 1 rod} × {1 order, n rods} × {n orders, n rods}, welded and not, with every footage and weight reconciled. It is **rationale, not a requirement** — the requirements are `[REQ §5.28]`, `FR-541`–`FR-560`. Its client-facing twin is the `.html` of the same name. ⚠ Its §9 is gap **`G48`** made concrete and its §12 raised **`G52`** and **`OI-127`**; the 4,000 lb rod every count scales from is still open as `OI-97`.

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — worked examples cited; `CoilNo` rename completed *(previously 2026-07-30)*
**Status:** Ready to build
**Layer:** Full-stack vertical slice
**Owner:** **FE + BE** (stream) — *named owner TBD, see [Capacity & Effort Model](../CapacityAndEffortModel.md#1-delivery-streams-and-roster) §1*
**Effort:** **222 h** (27.8 d) — FE 104 · BE 26 · DB 16 · RT 8 · QA 31 · BA 8 · cont. 29 · **Window:** W6 (Sep 21–25, 5 working days)
**Scope call:** **Not deferrable.** ⚠ **Estimate provisional:** carries a **16–32 h reserve** (excluded from the total) pending OI-45 / OQ-10 — the footage→weight *dimensional basis* is unsettled, and integrating over `RunReading` is materially more work than a target-derived weight.

*The finish line: confirm the coreless coil, generate its alpha, record source traceability, compute weight, print the coil label, and manage the 2-per-skid packing rule.*

> **This phase is wholly MVP-1, and the 222 h figure above is whole and correct** (11 Aug 2026). DB7, DB7b,
> `POST /coil/complete`, `GET /coil/{alpha}/label`, `CoilCompletionService` and story `FW-066` were briefly
> carved to MVP-2 and **returned the same day** — the partial file has been deleted. The reason the carve did
> not hold: `CoilOutput` and `CoilTraceability` are MVP-1 because the coil genealogy behind the
> **welding-wire customer certificates** is an MVP-1 obligation, but their **only writer** went to MVP-2,
> leaving the DM010 non-overlap trigger guarding rows nothing inserted. `CoilCompletionService` does not
> split: DB7 owns the scale override on weight, 1-of-2 vs 2-of-2 on the skid, and suspend on an out-of-spec
> final SPC — decisions no headless service can make.
>
> **Four dependencies came with it and none is costed in the 222 h** — registered as gap **`G36`**; **`OI-104` closed 18 Aug 2026, so three remain**:
> ~~**`OI-104`** `CoilOutput.SkidId` references a skid table nothing names, creates or verifies~~ — **closed: it is `united_db..wip_skids` + `proddb..wip_skid_coils`, written by `FW-219`, which is itself additive and uncosted here (gap `G44`)**; **`OI-24`** and
> **`OI-99`** — `GET /coil/{alpha}/label` returns a `lotNumber` with no generator at all, and no rule for the
> multi-rod case; **`OI-105`** `FR-346` adds a **physical scale weight at the packing station**, a third weight
> figure after the calculated value and DB7's operator override, with no rule for which governs the coil record;
> **`OI-106`** closure must assign a staging location and none are defined. The **16–32 h `OQ-10`/`OI-45`
> reserve** is live and **understated** — it was scoped before that second capture point was in scope.

## Business Overview
- **Objective:** complete a coil at TKUP-2 — generate output alpha, final SPC, source-rod traceability, footage-based weight, coil label, skid assignment (2 coils/skid), packing queue.
- **Business purpose:** the customer-facing deliverable + the traceability record for the C of C.
- **User roles:** FL2 operator (also FL3 output).
- **Entry conditions:** an active FL2/FL3 run with footage produced.
- **Exit conditions:** coil `COMPLETE`, linked to skid; on 2nd coil, skid closed + label + packing queue; run marked complete; line IDLE.

## User Journey
1. **Dashboard 7**: system-calculated coil details — new alpha `FW-#####-C##`, alloy/temper, **gauge/width shown as target when in tolerance** (not average), footage, **net weight = footage × density factor** (operator can override with scale).
2. **Source Traceability** table: one row per source rod with footage-from/to at each weld boundary.
3. **Final SPC**: gauge/width in-spec badges; out-of-spec → Submit-Suspend primary (supervisor review).
4. **Skid tracking**: Coil 1 of 2 (skid open) / Coil 2 of 2 (close + print skid label); exactly 2 per skid.
5. **Print Coil Label** (physical, NOT traveler); **Confirm & Move to Packing** → coil COMPLETE, skid linked; on 2nd coil skid finalized + packing queue; run complete → Dashboard 3 "Run Complete"; Dashboard 1 → IDLE.
- **Decision points:** weight override; 1-of-2 vs 2-of-2; suspend on out-of-spec.
- **Error scenarios:** out-of-spec final SPC → suspend path; density factor pending (OQ-10) → "pending confirmation" + override.

## UI Implementation (Angular)
- **Screens:** Dashboard 7 (`dashboard_7_coil_completion.html`), Packing Station (`dashboard_7b_packing_station.html`).
- **Components:** `dashboard-7-coil-completion`, `source-traceability-table`, `skid-tracker`, `coil-label`.
- **Services/models:** `flat-wire-api` (`coil/complete`, `coil/{alpha}/label`); `coil-output.model`, `traceability.model`.
- **Validation:** weight override; skid selection; final SPC.
- **Navigation:** → Dashboard 1 (IDLE) after packing; → Dashboard 8 on suspend.

## Backend Implementation (.NET)
- **APIs:** `CoilController POST /coil/complete`, `GET /coil/{alpha}/label`.
- **Request/Response:** complete (weights, final gauge/width, skid assignment) → coil alpha, skid id/status, footage total, `sourceTraceability[]`, finalSpc; label DTO (all label fields incl. source rod alphas + lot).
- **Business services:** `CoilCompletionService` (alpha gen, traceability build from weld boundaries, footage→weight via alloy factor, skid rule, run complete), `LabelService` (coil label).
- **MediatR handlers:** `CompleteCoil`, `GetCoilLabel`.
- **Business rules:** 2 coils/skid enforced; gauge/width target-when-in-tolerance; pass-schedule ID+snapshot written to coil record (OQ-64 decided); footage→weight per alloy (OQ-10).
- **Authz:** Operator+.

## Database Changes
- **Tables (write):** `CoilOutput` (alpha, weights, final gauge/width, `SkidId`, `SkidStatus`, `Status=COMPLETE`, in-spec flags), `CoilTraceability` (footage ranges → rod alphas), `FlatWireRun.Status=Complete`/`CompletedAt`.
- **Reads:** `WeldEvent` (boundaries), alloy factor, `FlatWireRun` footage.
- **Indexes:** `CoilTraceability(CoilAlpha)`, `CoilTraceability(RodAlpha)`.
- **Relationships:** `CoilOutput 1→N CoilTraceability`; `CoilOutput.SharedSkidNo` → `united_db..wip_skids.skid_no` (no DB FK — cross-database).
- **⚠ Shared-schema writes (new 18 Aug 2026, `FW-219`, not in the 222 h):** completion also writes **eight** shared objects through `united_db.dbo.FlatWire_CompleteCoilOnSkid` — `proddb..coils`, `proddb..wip_coil_orders`, `united_db..coil_gen_history`, `coil_cost`, `SlitterDB..coil_slit_cuts` (one row), `united_db..wip_skids`, `proddb..wip_skid_coils`, `proddb..wip_log_view`. Specified in `[INT §8.1]` / `FR-509`–`FR-518`. **`OI-104` is closed by it** — the skid table is `wip_skids` + `wip_skid_coils` — and `FR-339` becomes testable. Two new `CoilOutput` columns carry the shared identity: `CoilNo`, `SharedSkidNo`.
- **Not this phase:** releasing `wip_stations.coilno` at run end (**`OI-112`**) belongs to run completion, and nothing specifies it yet.

## Real-Time Functionality
- **Publisher:** `LineStatus` → IDLE on completion; skid closed → packing queue update.
- **Subscribers:** Dashboard 1; packing station.

## Integration Flow
```mermaid
sequenceDiagram
  participant OP as FL2 Operator
  participant NG as DB7
  participant API as CoilController
  participant SVC as CoilCompletionService
  participant DB as FlatWireDB
  participant HUB as FlatWireHub
  OP->>NG: Complete run → confirm coil
  NG->>API: POST /coil/complete
  API->>SVC: CompleteCoilCommand
  SVC->>DB: CoilOutput(COMPLETE)+CoilTraceability+Run Complete
  SVC-->>API: alpha + skid + traceability + finalSpc
  API-->>NG: 200 → Print label → Confirm & pack
  SVC->>HUB: LineStatus IDLE (+ skid queue on 2nd coil)
```

## Testing
- **Unit:** alpha gen; traceability from weld boundaries; footage→weight + override; 2-per-skid; target-vs-measured display.
- **API:** complete + label contracts.
- **UI:** traceability table; skid 1-of-2/2-of-2; label fields; suspend path.
- **Integration/DB:** COMPLETE + traceability rows; run marked complete; genealogy query returns coil→`coils` R-series→heat (cross-DB join).
- **Acceptance:** a coil completes with correct traceability, weight, label, and skid closure.

## Deliverables
Dashboard 7 + packing station; `CoilController` + completion/label services; traceability build; footage→weight; skid rule.

**OQ blockers:** OQ-10 (footage→weight — Critical), OQ-4 (skid labeling), OI-65 (coil OD/ID limits), OQ-64 (schedule snapshot on coil — decided). **Stories:** FW-066, FW-100 (weight).

---

## Client answers of 30 Jul 2026

**Finished-coil weight is bounded by the customer's range, not by a system default.** The customer specifies a **min/max weight** on the order (example figures: 900 lb max / 800 lb min) and a coil is graded against it **by weight**. The **2,000 lb default target is withdrawn** — it exceeded the TKUP-2 ceiling of 1,100 lb and had no basis (**OQ-18**). Two finished coils are cut from one ~1,800 lb spool, which is where the ~900 lb figure comes from.

**A coil finished outside the customer range must be flagged**, not silently completed: **supervisor override + production hold**, or an **offer to the customer under concession** before a remake is planned — offer first (**OQ-79**). On FL2 the alternative for leftover material is to run it to a finished stop and offer it, or scrap it.

**Mid-run coil break:** the stop is removed and a **new stop starts from zero**; accumulated weight does not resume from the break point. Check this against `CoilOutput` accumulation and `CoilTraceability`'s coil-local footage before building — the two footage coordinate systems are still unreconciled (**OI-25**).

---

## Per-order attribution, and the `CoilNo` rename

**Added 22 Aug 2026.** Story **`FW-229`**; `FR-560`; effort in `[CE §3e]`.

**Produced weight is attributed per (order, rod) by footage share**, published as views —
`vw_OrderFulfillment` and `vw_OrderRodAttribution` — rather than service methods, because the API, the
reports and the certificate all need the same number. ⚠ **A multi-parent coil is rarely a 50/50 split:** the
worked example is 500 lb / 400 lb, and counting parents instead of footage gets it wrong by 50 lb.

**`CoilOutput.SharedCoilNo` is renamed `CoilNo`** (`Q58`), matching `coils.coil_no`, which it feeds. **A
rename only** — `CoilAlpha` is retained, `D5`'s two-identity rule stands, the `CoilTraceability` FK does not
move, and `CoilNo` stays nullable so coil creation is never coupled to a cross-database call. The index
becomes `UX_CoilOutput_CoilNo` and `FlatWire_CompleteCoilOnSkid`'s parameter becomes `@expectedCoilNo`.

**`ORD016` — a coil's parents must all come from one spool.** This is the client's own planner rule, and it
means a single spool reference per coil is **correct by design**. ⚠ `CoilTraceability`'s header used to
justify its row-level grain by *"a spool runs out mid-coil"* — **that cannot happen**, since welding is FL1
and `Q17` made FL2 check-in exclusive. The grain is right for a different reason: many **rods**, one spool.
Corrected in the DDL on 22 Aug.

**Blocker:** **`Q53`** — is fulfilment consumed or produced pounds, and which does the certificate state?
