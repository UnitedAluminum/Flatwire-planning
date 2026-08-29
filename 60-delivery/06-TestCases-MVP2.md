# Flat Wire Mill — Test Cases, MVP-2 Deferred Screens

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Extracted from:** [`../70-testing/TestCases.md`](../70-testing/TestStrategy.md), 11 Aug 2026

---

> **⚠ MVP-2 — deferred scope.** Nothing in this document is part of MVP-1 or of MVP-1 planning. It was **lifted verbatim** on 11 Aug 2026 from the MVP-1 document named below; **no requirement, endpoint, test case or identifier was altered, renumbered or reworded.** See [`../95-archive/design-notes/MVP-2-scope-note.md`](../95-archive/design-notes/MVP-2-scope-note.md).
>
> **This document is not self-contained, by design.** All the cross-cutting context it depends on stayed in MVP-1 and is *cited, never copied* — the repository has a long, documented history of duplicated sections drifting apart, and a second copy of a domain model or a response envelope is exactly how that starts.

Test-case blocks for the deferred screens: **TC-295–309** die management · **TC-450–484** pass schedule · **TC-545–564** shift summary and OEE.

> **Two blocks returned to MVP-1 on 11 Aug 2026** — ~~TC-405–429 coil completion~~ and ~~TC-435–444 packing~~ — with Phase 9. They are in [`../70-testing/TestCases.md`](../70-testing/TestCases.md) §5.16–§5.17, unrenumbered.

## What stayed in MVP-1 and applies here

Read alongside [`../70-testing/TestCases.md`](../70-testing/TestStrategy.md):

| Section | Content |
|---|---|
| `§1` | test strategy, the pyramid mapped onto the UAL stack, and the `TC-###` identifier scheme |
| `§2` | test scope and risk-based prioritisation |
| `§3` | environments, database build/teardown, seed data and PLC simulation |
| `§4` | entry/exit criteria and the programme gates |

---

### 5.10 Die management — TC-295 … TC-309

| TC | Title | Lvl | Pri | FR / Source | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-295** | Maintenance-only access | I | P2 | FR-240 / `DMG001` | Open as Operator → **denied**. Not reachable from any shopfloor dashboard | ✓ |
| **TC-296** | Line filter narrows list **and** stats | C | P3 | FR-241 | Select FL1 → both the inventory list and the stats strip narrow | ✓ |
| **TC-297** | Register New Die creates a Spare | I | P2 | FR-247 / `DMG010` | Register → status `Spare`, alpha in `D-[size×1000]-[seq]` form, all capture fields present | ✓ |
| **TC-298** | Reset Counter zeroes footage and logs | I | P2 | FR-248 | Reset as Reconditioned → footage 0, threshold defaults to ~80–85 % of the original, Replacement log entry written | ✓ |
| **TC-299** | Edit Threshold — this die vs all of type/size | I | P2 | FR-249 | Apply to all → future registrations of that type/size inherit the new default; reason required | ✓ |
| **TC-300** | Retire requires a reason and excludes from counts | I | P2 | FR-250 | Retire → reason required; die retained in history; removed from active and spare counts | ✓ |
| **TC-301** | Actions disabled for a retired die | C | P2 | FR-251 | Select a retired die → Reset, Edit Threshold and Retire all disabled | ✓ |
| **TC-302** | **Life-status bands applied consistently across all six surfaces** | C | P2 | FR-253 | Die at 70 % used → stats strip, filter count, list badge, inline bar, detail bar and banner **all read "Nearing end"** | ✓ |
| **TC-303** | **Die Management is the runtime source of truth for Die Change** | I | **P1** | FR-254 / `DMG017` | Scan a die at DB Die Change → size, type, condition, accumulated footage and threshold all resolve from this inventory | ✓ |
| **TC-304** | Footage increments from the PLC counter, no new sensor | I | P2 | FR-255 | Complete a run → the installed die's cumulative footage rises by the run footage | ✓ |


### 5.18 / 5.19 Pass schedule — TC-450 … TC-484

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-450** | **Only Ops Manager / Maintenance may create, edit or activate** | I | **P1** | FR-361, FR-410 | Attempt each as Operator | All blocked; **read access permitted** | ✓ |
| **TC-451** | **Generation never auto-applies** | I | **P1** | FR-362 | Generate → the result is a **`Draft` requiring explicit approval**; nothing becomes Active automatically | ✓ |
| **TC-452** | **No PLC write during generation or apply** | I | **P1** | FR-391 | Generate and apply with the PLC path instrumented | **Zero tag writes** | ✓ |
| **TC-453** | One Active schedule per line + alloy | I | **P1** | `[DBD §6.5]` | Activate a second for the same pair | Rejected by `UX_PassSchedule_OneActivePerLineAlloy` | ✓ |
| **TC-454** | **Component state is a three-value enum** | K | **P1** | FR-371 | Set each of Active / Bypass / Skip | All three persist and round-trip. **A boolean cannot express Bypass vs Skip** | ✓ |
| **TC-455** | Mandatory final stand locked on | C | **P1** | FR-371 | Attempt to bypass **`FM2_S3`** | Toggle locked; `Bypass` and `Skip` rejected. **`FM2_S1` and `FM2_S2` remain bypassable.** *(`OI-04` closed 4 Aug 2026 — the two "contested" names were the same physical stand.)* | ✓ |
| **TC-456** | `ParameterValue` null unless Active | I | P2 | `CK_PSC_ParamValue` | Set a value on a Bypass row | Rejected | ✓ |
| **TC-457** | `FM1` cannot be bypassed | I | P2 | `CK_PSC_FM1NotBypassable` | Set FM1 to Bypass | Rejected | ✓ |
| **TC-458** | Edge type required when an EdgeSet component is Active | I | P2 | `CK_PSC_EdgeTypeReq` | Active EdgeSet with null edge type | Rejected | ✓ |
| **TC-459** | **Tension is excluded** | C | P2 | FR-365 | Inspect the editor | **No tension field anywhere** — it derives from speed control | ✓ |
| **TC-460** | **FL1 schedules carry no edger** | C | **P1** | FR-364 | Create an FL1 schedule | No edger row offered — **FL1 has no edger** | ✓ |
| **TC-461** | Hybrid FL3 is a single unified record | I | P2 | FR-363 | Create an FL3 schedule | One record covering both drawing and finishing components | ✓ |
| **TC-462** | **Generator — the corrected worked example** | U | **P1** | FR-380–387 | 1100, 0.375, 0.125, 0.875, Round | `preflattenDiameterIn` **0.3732** · `areaReductionPct` **0.95** · `drawPasses` **0** · `aspectRatio` **7.0** · `routeMode` **Hybrid** with `FM2Activated` and `RouteSetToHybrid`. **Not 0.265 / 50.1 / Standalone** | ✓ |
| **TC-463** | Draw-pass branches | U | P2 | FR-383 | areaRed at 1.5 %, at 1× alloy max, at 2× alloy max, above | Both bypass · DB1 only · both active · **error flag while still returning a result** | ✓ |
| **TC-464** | Die sizes snapped to 0.005″ | U | P2 | FR-384 | Generate | DB1 = geometric mean, DB2 = D_pre, both snapped, with a `DieSizeSnapped` warning | ✓ |
| **TC-465** | 1350 forces Hybrid regardless of aspect ratio | U | P2 | FR-386 | Alloy 1350, aspect ratio 3.0 | FM2 activated, route Hybrid, `PrecisionMode1350` warning | ✓ |
| **TC-466** | Aspect ratio boundary at 5.5 | U | P2 | FR-386 | 5.49 then 5.51 | Standalone, then Hybrid | ✓ |
| **TC-467** | **Apply enabled even on error results** | C | **P1** | FR-389 | Generate a `TooManyDrawPasses` error | **Apply remains enabled** so Operations can inspect and adjust | ✓ |
| **TC-468** | Applied values highlighted as generated | C | P3 | FR-390 | Apply → values highlighted, status `Draft`, "Save Changes" becomes **"Save as Active"**; highlight clears on save | ✓ |
| **TC-469** | `Bevel` rejected | K | P2 | OI-05 | Submit `edgeType: "Bevel"` | Rejected — **no domain value exists** | ✓ |
| **TC-470** | **Mid-run override alert cannot be passively dismissed** | C | **P1** | FR-369 / `NFR009` | Save a mid-run override → on DB3, press Escape, click outside, navigate away | **None dismisses it.** Only Acknowledge or Stop Run | ✓ |
| **TC-471** | **The line runs on the previous PLC values until acknowledged** | I | **P1** | FR-369 | Save a mid-run override | PLC still holds the **previous** values until the operator acknowledges | ✓ |
| **TC-472** | Mid-run change sets an SPC checkpoint as required | I | **P1** | FR-370 | Change a die size mid-run | "Awaiting SPC checkpoint" set and **not clearable until SPC completes** | ✓ |
| **TC-473** | Override log contents | I | **P1** | FR-368 | Save an override | Parameter, old → new, user ID, timestamp and reason code or free text all recorded | ✓ |
| **TC-474** | Operator may only do a one-for-one same-size die swap mid-run | I | P2 | FR-367 | Attempt any other mid-run change as Operator | Blocked; requires an Operations Manager | ✓ |
| **TC-475** | Change-history tabs | C | P3 | FR-374 | Open DB9 → Overrides · Schedule edits · Acknowledgments, last 5 each, with a View-all link | ✓ |
| **TC-476** | DB9A filters apply simultaneously | C | P2 | FR-402 | Search + alloy + line + status together | Rows match **all** active criteria | ✓ |
| **TC-477** | Active filters render amber | C | P3 | FR-403 | Set a non-"All" filter | Amber background | ✓ |
| **TC-478** | Stats strip updates and survives zero matches | C | P2 | FR-404 | Filter to no matches | Strip visible showing zeros | ✓ |
| **TC-479** | "In use" chip | C | P3 | FR-405 | Schedule linked to an active job → chip shows `In use: FW-XXXXX` in subdued text | ✓ |
| **TC-480** | Stable sort | C | P3 | FR-407 | Sort by a column with ties | Tied rows retain their prior relative order | ✓ |


### 5.23 / 5.24 Shift summary and OEE — TC-545 … TC-564

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-545** | Machine tab drives the KPI tiles | C | P3 | FR-480 | Switch FL1 → FL2 → All Lines | Footage, weight out, coils and downtime all reflect the selection | ✓ |
| **TC-546** | Utilisation timeline scope | C | P3 | FR-481 | Single tab vs All Lines | One line; then three stacked | ✓ |
| **TC-547** | Metric derivations | I | P3 | FR-482 | Known shift data | Footage from the line's counter filtered to the shift; weight out from summed net weights; coils out from completed alphas | ✓ |
| **TC-548** | Pause downtime by category | I | P3 | FR-487 | Pauses across categories | Total minutes per line plus a breakdown by Equipment, Material, Quality, Operational, Safety | ✓ |
| **TC-549** | **SPC-skipped runs flagged as exceptions** | I | **P1** | FR-488 / `SHS012` | Resume after a Gauge-drift die change without completing SPC | Run appears as a **flagged exception** | ✓ |
| **TC-550** | Supervisor-only access | I | P2 | FR-490 | Open as Operator | Denied | ✓ |
| **TC-560** | OEE renders A·P·Q with the configurable target | C | P3 | FR-500–507 | Open the OEE dashboard | Per-line tiles, MTBF/MTTR, 7-shift trend, Six Big Losses, thresholds green ≥ 85 / amber 70–84 / red < 70 | ✗ |

> **TC-560 is not scheduled.** The OEE dashboard has **no story, no phase and no owner** (**PP-03**, story `FW-N09`). The case exists so the gap is visible in §10.
