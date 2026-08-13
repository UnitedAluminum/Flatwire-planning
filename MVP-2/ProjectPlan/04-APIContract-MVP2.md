# Flat Wire Mill — API Contract, MVP-2 Deferred Endpoints

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Extracted from:** [`../../MVP-1/ProjectPlan/04-APIContract.md`](../../MVP-1/ProjectPlan/04-APIContract.md), 11 Aug 2026

---

> **⚠ MVP-2 — deferred scope.** Nothing in this document is part of MVP-1 or of MVP-1 planning. It was **lifted verbatim** on 11 Aug 2026 from the MVP-1 document named below; **no requirement, endpoint, test case or identifier was altered, renumbered or reworded.** See [`../README.md`](../README.md).
>
> **This document is not self-contained, by design.** All the cross-cutting context it depends on stayed in MVP-1 and is *cited, never copied* — the repository has a long, documented history of duplicated sections drifting apart, and a second copy of a domain model or a response envelope is exactly how that starts.

Endpoint detail for the deferred screens: **`POST /passschedule/generate`** · **`GET /shiftsummary`**.

> **Two endpoints returned to MVP-1 on 11 Aug 2026** — ~~`POST /coil/complete`~~ and ~~`GET /coil/{alpha}/label`~~ — with Phase 9, which is **wholly MVP-1**. They are the only writers of `CoilOutput` and `CoilTraceability`, and those tables carry the welding-wire certificate genealogy. See [`../../MVP-1/ProjectPlan/04-APIContract.md`](../../MVP-1/ProjectPlan/04-APIContract.md) §4.15–§4.16.

## What stayed in MVP-1 and applies here

Read alongside [`../../MVP-1/ProjectPlan/04-APIContract.md`](../../MVP-1/ProjectPlan/04-APIContract.md):

| Section | Content |
|---|---|
| `§1` | conventions — service addressing, the `Data`/`Success`/`Errors` response envelope, status codes, headers, pagination, date/time, units and the error-code catalogue |
| `§2` | the canonical enums, including the single edge-type vocabulary and the five `CheckpointType` values |
| `§3` | controllers and the endpoint index |

---

### 4.2 `POST /passschedule/generate`

**Purpose:** run the physics-based draft generator. **Nothing is persisted** — the client then calls `POST /passschedule` if Operations accepts the draft.
**Role:** Operations Manager, Engineering. **Idempotent** (pure function of its inputs). **No PLC write ever occurs here** (`FR-391`).

**Request**

```json
{ "alloy": "1100", "rodDiameterInches": 0.375,
  "targetGaugeInches": 0.125, "targetWidthInches": 0.875,
  "edgeType": "Round" }
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `alloy` | string | ✓ | Must exist in `AlloyProperty`; else `AlloyNotConfigured` error |
| `rodDiameterInches` | number | ✓ | 0.100 – 0.750 |
| `targetGaugeInches` | number | ✓ | 0.010 – 0.500 |
| `targetWidthInches` | number | ✓ | 0.050 – 3.000 |
| `edgeType` | enum | ✓ | `Round` \| `Square`. **`Bevel` is rejected** — OI-05 |

**Response — the corrected worked example**

For alloy 1100, rod 0.375″, gauge 0.125″, width 0.875″:

```json
{ "data": {
    "preflattenDiameterIn": 0.3732,
    "areaReductionPct": 0.95,
    "drawPasses": 0,
    "aspectRatio": 7.0,
    "routeMode": "Hybrid",
    "warnings": [
      { "code": "FM2Activated",     "message": "FM2 activated — aspect ratio 7.0 exceeds 5.5" },
      { "code": "RouteSetToHybrid", "message": "Route set to Hybrid FL3" } ],
    "errors": [],
    "components": [
      { "componentName": "DB1",       "state": "Bypass", "parameterValue": null,   "edgeType": null },
      { "componentName": "DB2",       "state": "Bypass", "parameterValue": null,   "edgeType": null },
      { "componentName": "FM1",       "state": "Active", "parameterValue": 0.1225, "edgeType": null },
      { "componentName": "FM2_S1",    "state": "Active", "parameterValue": 0.1325, "edgeType": null },
      { "componentName": "FM2_S2",    "state": "Active", "parameterValue": 0.1275, "edgeType": "Round" },
      { "componentName": "FM2_S3",    "state": "Active", "parameterValue": 0.1225, "edgeType": "Round" } ] },
  "success": true }
```

**Derivation:** `D_pre = sqrt(4 × 0.125 × 0.875 / π) = 0.3732″` · `areaRed = 1 − (0.3732² / 0.375²) = 0.95 %`, which is **≤ 2 %, so both draw boxes bypass** · `aspectRatio = 0.875 / 0.125 = 7.0 > 5.5`, so **FM2 activates and the route is Hybrid** · `FM1 gap = 0.125 × 0.98 = 0.1225` · FM2 gaps per `FR-387`: `S1 = 0.125 × 1.06 = 0.1325`, `S2 = 0.125 × 1.02 = 0.1275`, `S3 = 0.125 × springback = 0.1225`.

> **Correction 1 of 4 — this is the defect.** `MVP-1/ProjectPlan/APIContracts.md` publishes this same example returning `preflattenDiameterIn: 0.265`, `areaReductionPct: 50.1`, `drawPasses: 2` and `routeMode: "Standalone"` with FM2 bypassed and no warnings. **All four are wrong.** The published `areaReductionPct` of 50.1 is internally consistent with its own wrong 0.265 diameter, not with the stated formula; and an aspect ratio of 7.0 must, by the algorithm's own step 6, force `Hybrid`. **Implementers must build to the formula in `[SRS §5.18]` `FR-381`–`FR-387`, not to any published example.**

**Warning and error codes**

| Code | Kind | Condition |
|---|---|---|
| `FM2Activated` | warning | aspect ratio > 5.5 |
| `RouteSetToHybrid` | warning | route forced to Hybrid |
| `PrecisionMode1350` | warning | alloy is 1350 (welding wire) |
| `HighAspectRatioWarning` | warning | aspect ratio > 10 — verify FM2 capability |
| `DieSizeSnapped` | warning | a calculated die size was snapped to the nearest 0.005″ |
| `NoDieInInventory` | warning | no die within 0.005″ of the calculated size |
| `TooManyDrawPasses` | **error** | area reduction > 2× alloy max |
| `GaugeBelowMachineMinimum` | **error** | target gauge below machine minimum |
| `AlloyNotConfigured` | **error** | alloy absent from `AlloyProperty` |

**Apply remains enabled for all results including errors** (`FR-389`) — Operations inspects and adjusts manually before deciding.

> **The generator's "alloy max" input is contested.** It must read `united_db..alloys.Draw_max_reduction`, not the provisional `AlloyProperty.MaxReductionPerPass` seed — and **whether that upstream column is per-pass or cumulative is unconfirmed.** The algorithm needs per-pass. **OI-93.**


### 4.18 `GET /shiftsummary`

**Query:** `lineId` (or `All`), `shiftStart`, `shiftEnd`. Backed by `sp_ShiftSummary`. Returns per-line footage, weight out, coils out, SPC pass rate, WIP rejection count, suspended-coil count, weld events, pause minutes with a category breakdown, utilisation, and the **flagged-exception list** for runs that resumed without a completed SPC checkpoint.
