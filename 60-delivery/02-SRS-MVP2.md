# Flat Wire Mill — Software Requirements, MVP-2 Deferred Screens

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 11, 2026
**Status:** **MVP-2 — deferred scope**
**Extracted from:** [`../10-requirements/BusinessRequirements.md`](../10-requirements/BusinessRequirements.md), 11 Aug 2026

---

> **⚠ MVP-2 — deferred scope.** Nothing in this document is part of MVP-1 or of MVP-1 planning. It was **lifted verbatim** on 11 Aug 2026 from the MVP-1 document named below; **no requirement, endpoint, test case or identifier was altered, renumbered or reworded.** See [`../95-archive/design-notes/MVP-2-scope-note.md`](../95-archive/design-notes/MVP-2-scope-note.md).
>
> **This document is not self-contained, by design.** All the cross-cutting context it depends on stayed in MVP-1 and is *cited, never copied* — the repository has a long, documented history of duplicated sections drifting apart, and a second copy of a domain model or a response envelope is exactly how that starts.

Functional requirements for the five deferred screens: **§5.10** Die Management · **§5.18** Pass Schedule Management (DB9) · **§5.19** Pass Schedule List (DB9A) · **§5.23** Shift Summary (DB10) · **§5.24** OEE Dashboard.

> **Two sections left on 11 Aug 2026 and are no longer here:** ~~§5.16 Output Coil Completion (DB7)~~ and ~~§5.17 Packing Station (DB7b)~~ **returned to [`../10-requirements/BusinessRequirements.md`](../10-requirements/BusinessRequirements.md)** when Phase 9 was confirmed wholly MVP-1. `FR-330`–`FR-340` and `FR-345`–`FR-352` live there, unrenumbered.

## What stayed in MVP-1 and applies here

Read alongside [`../10-requirements/BusinessRequirements.md`](../10-requirements/BusinessRequirements.md):

| Section | Content |
|---|---|
| `§1–4` | introduction, overall description, the domain model and glossary, and the process flows |
| `§5.0` | cross-cutting requirements that apply to every screen |
| `§6` | non-functional requirements |
| `§7` | user interface requirements |
| `§8` | security, roles and permissions — including the permission matrix that uses the Operations Manager role whose *definition* is in `../10-requirements/screens/PassScheduleManagement.md` §3.3–§3.4 |
| `§9` | external interface requirements |
| `§10` | the traceability appendix |
| `§11` | open requirements issues |

---

### 5.10 Die Management — Maintenance screen

**Screen:** [`dashboard_die_management.html`](../50-frontend/mockups/dashboard_die_management.html)
**Source IDs:** `DMG001`–`DMG017`
**Actors:** Maintenance only
**Access:** Machines Application → Tooling Inventory tab. **Not reachable from the shopfloor dashboards.**
**Priority:** **`Should`** *(derived — a Phase 13 non-critical deliverable and descope-ladder rung 5; but `FR-254` is `Must` because Die Change reads it)*

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-240** | Die Management shall be provided to the **Maintenance role** and shall not be exposed from the shopfloor dashboards. | Should | `DMG001` |
| **FR-241** | Line filter pills (**All lines / FL1 / FL3**) shall narrow both the inventory list and the stats. | Should | `DMG002` |
| **FR-242** | A stats strip shall show **Active on line · Overdue for replacement · Nearing end of life · Spare/ready** counts. | Should | `DMG003` |
| **FR-243** | Inventory filter tabs (**All · Active · Nearing end · Overdue · Spare · Retired**) shall each carry a count badge. | Should | `DMG004` |
| **FR-244** | Inventory rows shall show **Alpha · Block · Size · Line · Status · Life used (bar + %) · Footage (run/threshold) · Last reset**, sorted **Overdue → Nearing → Active → Spare → Retired**, with retired rows at reduced opacity. | Should | `DMG005`, `DMG006` |
| **FR-245** | Selecting a row shall populate a detail panel with the die header, a life bar, a six-field grid (footage on die, life threshold, remaining, die size, die type, last reset by), status alert banners, action buttons and a history section. | Should | `DMG007`, `DMG008` |
| **FR-246** | A **red danger banner** shall show when a die is Overdue and an **amber warning banner** when Nearing end of life. | Should | `DMG009` |
| **FR-247** | **Register New Die** shall create a record with status **Spare**, capturing alpha (`D-[size×1000]-[seq]`), compatible block (DB1/DB2/Both), hole size, die type/material (TC Mono · TC Poly · Natural diamond), life threshold, source, condition, inspection date and optional notes. | Must | `DMG010` |
| **FR-248** | **Reset Counter** shall reset footage to zero, support **Reconditioned** or **New spare** disposition, update the life threshold when Reconditioned (defaulting to ~80–85 % of the original), and write the event to the Replacement log. | Should | `DMG011` |
| **FR-249** | **Edit Threshold** shall change the footage limit for **this die only or all dies of the same type/size**, require a reason, and update the default threshold for future registrations when applied to all. | Should | `DMG012` |
| **FR-250** | **Retire Die** shall permanently retire a die, requiring a reason (end of life · physical damage · bore out of tolerance · size discontinued · other), retaining it in history and excluding it from active and spare counts. | Should | `DMG013` |
| **FR-251** | Reset, Edit Threshold and Retire shall be **disabled for an already-retired die**. | Should | `DMG014` |
| **FR-252** | A history section shall provide a **Run history** tab (order, line, footage added, date, operator) and a **Replacement log** tab (install, reset and retirement events). | Should | `DMG015` |
| **FR-253** | Life-status thresholds shall be applied **consistently** across the stats strip, filter counts, list badge, inline bar, detail life bar and alert banners: **Active < 65 % used · Nearing end 65–79 % · Overdue ≥ 80 % · Spare (0 footage, not installed) · Retired**. | Should | Mockup DM |
| **FR-254** | Die Management shall be the **source of truth** the Die Change screen reads at runtime for alpha→size/type/condition lookup, accumulated footage counter and scheduled-life threshold. | **Must** | `DMG017` |
| **FR-255** | Cumulative footage per die shall be incremented from the **PLC footage counter** on each completed or partial run — **no new sensor is required**. On a mid-run swap the system closes accumulation on the outgoing die and starts a new counter on the incoming die. | Must | OQ-83 |

**Open:** the die-life **threshold value** is deferred until production failure data exists (OQ-83). There is **no die master table** in the schema — raised in `[DBD §6.9]`.

---


### 5.18 Pass Schedule Management — Dashboard 9

**Screen:** [`dashboard_9_pass_schedule.html`](../50-frontend/mockups/dashboard_9_pass_schedule.html)
**Source IDs:** `PSM001`–`PSM024`
**Actors:** Operations Manager (full, including activation); Engineering/Maintenance (create/edit/generate); all operators (read-only)
**Priority:** **`Must`** *(derived — FW-012 is Critical; this gates every check-in phase)*

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-360** | The system shall maintain a **central Pass Schedule table accessible from both the shopfloor and the web applications**. | Must | `PSM001` |
| **FR-361** | Pass schedules shall be **created, edited and maintained only by authorised Maintenance / Engineering (Operations) users** and shall be **read-only to floor operators**. | Must | `PSM002` |
| **FR-362** | The system shall **never silently auto-apply a pass schedule.** It may provide a human-in-the-loop **"Generate & Review"** physics-based draft algorithm producing a `Draft` that requires explicit Operations approval (Save as Active). **No schedule — generated or manual — reaches the PLC except through operator acknowledgement at check-in.** | Must | `PSM003`, `PSM019` |
| **FR-363** | Each schedule shall support **machine-specific routing** covering FL1 standalone, FL2 standalone and Hybrid FL3, with a routing flag; a **Hybrid FL3 schedule is a single unified record** covering both drawing and finishing components. | Must | `PSM004`, `PSM011` |
| **FR-364** | Each schedule shall represent **which components are active and which bypassed**, define **DB1 and DB2 die sizes**, **FL1 and FL2 roll clearances / gap settings**, **target gauge and width at each processing stage**, **line speed and reduction percentages**, and **edger configuration (edge type and stand position) for the applicable FL2 stands S2 and S3** — FL1 has no edger. | Must | `PSM005`–`PSM010` |
| **FR-365** | **Tension shall be excluded** from the pass schedule; it is derived automatically from speed control. | Must | `PSM012` |
| **FR-366** | Schedules shall be associable with specific production orders or with gauge/width combinations, and **only schedules compatible with the current order and routing shall be selectable at runtime**. | Must | `PSM013`, `PSM014` |
| **FR-367** | The pass schedule shall stay **read-only to floor operators mid-run**, permitting an operator-initiated change only for a **one-for-one same-size die swap**; any other change requires an Operations Manager. | Must | `PSM020` |
| **FR-368** | Every mid-run override shall record **parameter changed, old value → new value, user ID, timestamp and a reason code or free-text reason**. | Must | `PSM021` |
| **FR-369** | Saving a mid-run override shall raise a **real-time alert on the Active Run Monitor** of the affected line requiring an explicit **Acknowledge** (continue under the new configuration) or **Stop Run** (supervisor review). **Passive dismissal shall not be permitted**, and the line shall **continue running under the previous PLC values until the operator acknowledges**. | Must | `PSM022`, **`NFR009`** |
| **[NFR]** | **`NFR009` — overrides block passive dismissal.** No supervisor override or mid-run configuration alert may be dismissed by clicking outside, pressing Escape, or navigating away. The measurable form is `FR-369` and `FR-149`. Verification: `[NFR §6]`. | Must | `NFR009` |
| **FR-370** | A mid-run pass schedule change — particularly a die-size or roll-gap change — shall **automatically set an SPC checkpoint as required**, and the "awaiting SPC checkpoint" status shall not be clearable until SPC is completed. | Must | `PSM023` |
| **FR-371** | The component-configuration editor shall present per-component **toggles** and parameter inputs, with the **mandatory final stand locked on**, bypassed rows showing "Bypassed · no parameters", and edger rows offering an edge-type selector. | Must | Mockup DB9 |
| **FR-372** | A **Targets & tolerances** panel shall carry output gauge ±, output width ±, and a line-speed min–max range, with helper text naming the measurement point (post-FM1 for gauge, post-edger for width). | Must | Mockup DB9 |
| **FR-373** | An **Input rod specification** panel shall show diameter, temper and condition as read-only. | Must | Mockup DB9 |
| **FR-374** | A **Change history** panel shall provide three tabs — **Overrides · Schedule edits · Acknowledgments** — showing the last 5 with time, user, parameter, old → new and reason code, and a "View all" link. | Must | `PSM021`, OQ-62 |
| **FR-375** | Footer actions shall be **Generate from Specs · Copy schedule · Deactivate · Discard changes · Save changes / Save as active**, with a status strip showing unsaved-changes and generated-draft states and the last-saved stamp. | Must | Mockup DB9 |

**Generate from Specs — algorithm (corrected)**

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-380** | The generate modal shall take **alloy · incoming rod diameter · target gauge · target width · edge type** and produce a draft, showing the selected alloy's max reduction per pass, spring-back factor and default tolerances live. Input ranges: rod diameter 0.100–0.750″, gauge 0.010–0.500″, width 0.050–3.000″. | Must | `PSM003` |
| **FR-381** | **Step 1 — pre-flatten diameter:** `D_pre = sqrt(4 × target_gauge × target_width / π)`. | Must | Analysis |
| **FR-382** | **Step 2 — total area reduction:** `areaRed = 1 − (D_pre² / rodDia²)`. | Must | Analysis |
| **FR-383** | **Step 3 — draw passes:** `areaRed ≤ 2 %` → DB1 and DB2 both **Bypass**; `≤ 1× alloy max` → DB1 Active, DB2 Bypass; `≤ 2× alloy max` → both Active; `> 2× alloy max` → **error flag** while still returning the result. **"Alloy max" shall be read from `united_db..alloys.Draw_max_reduction`**, not from the provisional `AlloyProperty.MaxReductionPerPass` seed. Whether that upstream column is **per pass or cumulative** must be confirmed before use; the algorithm needs per-pass. | Must | Analysis; **OI-93** |
| **FR-384** | **Step 4 — die sizes:** `DB1 = geometric_mean(rodDia, D_pre)` and `DB2 = D_pre`, each **snapped to the nearest 0.005″**, with an informational warning naming the snap. | Must | Analysis |
| **FR-385** | **Step 5 — FM1 roll gap:** `gauge × alloy springback factor`. | Must | Analysis |
| **FR-386** | **Step 6 — FM2 requirement:** `aspectRatio = width / gauge`. If `aspectRatio > 5.5` **or** alloy is `1350` (welding wire) → **activate FM2 and set `routeMode = Hybrid`**. Otherwise `FM2_S1` and `FM2_S2` are bypassed and the route is Standalone. **`FM2_S3`, the final stand, is always Active.** | Must | Analysis |
| **FR-387** | **Step 7 — FM2 roll gaps**, one per stand: `FM2_S1 = gauge × 1.06`, `FM2_S2 = gauge × 1.02`, `FM2_S3 = gauge × springback factor`. *(Aug 4 2026: multipliers unchanged; relabelled from diameter to position, which fixes the earlier defect of three formulas for four stands leaving the final stand without one.)* | Must | Analysis |
| **FR-388** | Warnings shall be raised for: FM2 activated (aspect ratio > 5.5) · route set to Hybrid · 1350 precision mode · very high aspect ratio (> 10) · die size snapped · target gauge below machine minimum (error) · alloy not configured (error) · no die in inventory within 0.005″ of the calculated size. | Must | Analysis |
| **FR-389** | **Apply shall remain enabled for all results including error cases**, so Operations can inspect and adjust the draft manually before deciding whether to proceed. | Must | Analysis |
| **FR-390** | Applying shall populate the DB9 form with the calculated values **highlighted to indicate algorithm-generated origin**, set the status to `Draft`, and replace "Save Changes" with **"Save as Active"**. The highlight clears on save. | Must | Mockup DB9 |
| **FR-391** | **PLC tags shall never be pushed during generation or apply.** The generate workflow writes only to the pass schedule record. | Must | `PSM003` |

> **The published worked example is wrong on three counts and must not be copied.** For alloy 1100, rod 0.375″, gauge 0.125″, width 0.875″ the correct values are `preflattenDiameterIn` **0.3732** (not 0.265), `areaReductionPct` **≈ 0.95 %** (not 50.1), `drawPasses` **0 — both bypassed** (not 2), and `routeMode` **`Hybrid` with FM2 activated** (not `Standalone`), because `aspectRatio` 7.0 > 5.5. **Implementers must build to the formula, not the example.** Corrected response in `[API §4.2]`.

**Alloy lookup table — must be an editable admin table, never hardcoded:**

| Alloy | Max reduction / pass | Spring-back factor | Gauge tol. default | Width tol. default | Speed range (FPM) |
|---|---|---|---|---|---|
| 1100 | 26 % | 0.98 | ± 0.003″ | ± 0.010″ | 800 – 2,000 |
| 1350 | 22 % | 0.97 | ± 0.002″ | ± 0.008″ | 600 – 1,600 |
| 3003 | 24 % | 0.98 | ± 0.004″ | ± 0.012″ | 700 – 1,800 |
| 5052 | 20 % | 0.97 | ± 0.003″ | ± 0.010″ | 500 – 1,400 |
| 6061 | 18 % | 0.96 | ± 0.003″ | ± 0.010″ | 400 – 1,200 |

These values require Process Engineering sign-off. **They also duplicate columns already maintained upstream in `united_db..alloys` — OI-93**, and there is **no CRUD endpoint** for them — **OI-32**.

---


### 5.19 Pass Schedule List — Dashboard 9A

**Screen:** [`dashboard_9a_schedule_list.html`](../50-frontend/mockups/dashboard_9a_schedule_list.html)
**Source IDs:** `PSL001`–`PSL020`
**Priority:** **`Must`** *(derived — FW-011 is High)*

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-400** | The system shall present an index listing **all** pass schedule records. | Must | `PSL001` |
| **FR-401** | A **live search** shall filter rows by Schedule ID, Description and Alloy as the user types, clearing on the × control. | Must | `PSL002` |
| **FR-402** | **Alloy**, **Line** (All / FL1 / FL2 / FL3) and **Status** (All / Active / Draft / Inactive) dropdown filters shall be provided, applied **simultaneously** with the search so displayed rows match all active criteria. | Must | `PSL003`–`PSL006` |
| **FR-403** | Any active (non-"All") filter control shall display with an **amber background** to signal the list is restricted. | Should | `PSL007` |
| **FR-404** | A stats strip shall show **total · Active · Draft · Inactive** counts, updating dynamically as filters change, and shall remain visible showing zero counts when no rows match. | Must | `PSL008`, `PSL019` |
| **FR-405** | Columns shall be **Schedule ID · Description · Alloy · Line · Route · Status · Last Modified · Open**, with an **"In use: FW-XXXXX" chip** in subdued text below the description when the schedule is linked to an active job. | Must | `PSL009`, `PSL010` |
| **FR-406** | The **FL3 line tag shall render in purple** to indicate the Hybrid route, and status badges as **Active (green) · Draft (purple) · Inactive (grey)**. | Should | `PSL011`, `PSL012` |
| **FR-407** | Column sorting shall be supported — first click ascending, second reversing, an arrow marking the active column — and results shall be **stable-sorted**. | Should | `PSL013`, `PSL014` |
| **FR-408** | Clicking a row or the Open button shall open DB9 for that schedule. | Must | `PSL015` |
| **FR-409** | **+ New Schedule** shall open a choice popup offering **Enter Manually** (a blank DB9 in `Draft`) or **Generate from Specs** (the modal; on Apply navigates to DB9 pre-populated in `Draft`). A **Generate from Specs** toolbar shortcut shall do the same. | Must | `PSL016`–`PSL018` |
| **FR-410** | Creation, generation and activation shall be **restricted to Operations Manager / Maintenance**; all operators may view. | Must | `PSL020` |

---


### 5.23 Shift Summary — Dashboard 10

**Screen:** [`dashboard_10_shift_summary.html`](../50-frontend/mockups/dashboard_10_shift_summary.html)
**Source IDs:** `SHS001`–`SHS015`
**Actors:** Supervisor / Shift Manager (primary)
**Priority:** **`Should`** *(derived — FW-069 is Medium)*

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-480** | A **machine tab selector (FL1 / FL2 / FL3 / All Lines)** shall control which machine's data is shown; the KPI tiles (footage, weight out, coils, downtime) shall update to reflect the selection. | Should | `SHS001`, `SHS002` |
| **FR-481** | The utilisation timeline shall show the **selected machine only** on a single-machine tab, and **all three stacked** on All Lines. | Should | `SHS003` |
| **FR-482** | Per-machine footage shall come from that line's footage counter filtered to the shift window; weight out from the sum of net weights of coils completed on that line during the shift; coils out from the count of output alphas completed. | Should | `SHS004`–`SHS006` |
| **FR-483** | Quality metrics shall include **SPC pass rate, WIP rejection count and suspended-coil count** for the shift window. | Should | `SHS007` |
| **FR-484** | **Weld events per line** shall be shown from the weld event log filtered to the shift, with an event log listing time, rod pair, footage, weld type and quality result. | Should | `SHS008` |
| **FR-485** | **Material status** shall show rod in storage, spools on floor, coils in packing and WIP-held items. | Should | `SHS009` |
| **FR-486** | **Line utilisation** shall be calculated as run-timer time versus available shift hours per line. | Should | `SHS010` |
| **FR-487** | **Pause downtime** shall roll up as total pause minutes per line per shift with a breakdown grouped by pause category (Equipment, Material, Quality, Operational, Safety). | Should | `SHS011` |
| **FR-488** | Any run that **resumed without a completed SPC checkpoint** following a Gauge-drift or Size-change die change shall be flagged as an **exception**. | Must | `SHS012`, `DCH028` |
| **FR-489** | **Export Shift Report**, **Print** and **View WIP Rejections** actions shall be provided. | Should | `SHS013`, `SHS014` |
| **FR-490** | The Shift Summary shall be restricted to the **Supervisor / Shift Manager** role as its primary screen. | Must | `SHS015` |

---


### 5.24 OEE Dashboard

**Screen:** [`dashboard_oee.html`](../50-frontend/mockups/dashboard_oee.html)
**Source IDs:** `OEE001`–`OEE017`
**Note:** requirements are derived from the mockup — **it is the only source for this screen.**
**Priority:** **`Could`** *(derived — no backlog story delivers it; it has no phase owner)*

| ID | Requirement | Priority | Source |
|---|---|---|---|
| **FR-500** | The system shall present an **Availability / Performance / Quality** dashboard with OEE per machine and a combined view, with a machine detail selector (FL1/FL2/FL3) and a shift selector (Day / Night / Previous). | Could | `OEE001`–`OEE003` |
| **FR-501** | An OEE strip shall show one tile per line with **OEE percent, the A·P·Q breakdown, a donut gauge and a variance-vs-target chip**; an offline line renders in an offline state with no donut arc. | Could | `OEE004`, `OEE005` |
| **FR-502** | **MTBF** and **MTTR** tiles shall each show a 7-shift average value and a trend chip. | Could | `OEE006`, `OEE007` |
| **FR-503** | An OEE breakdown panel shall show the **Availability split (running / planned / unplanned)**, a Performance bar, a Quality bar and the result as `Availability × Performance × Quality`. | Could | `OEE008` |
| **FR-504** | A **7-shift OEE trend chart** shall show a target line, colour-coded bars and a 3-shift moving average. | Could | `OEE009` |
| **FR-505** | A **Six Big Losses** panel shall categorise by Availability, Performance and Quality with time lost and estimated footage per loss. | Could | `OEE010` |
| **FR-506** | A **line comparison table** shall show Availability, Performance, Quality, Day OEE, Night OEE and variance versus the 85 % target per line, and a **Top Loss Events** list ranked by duration with loss category and acknowledgement status. | Could | `OEE011`, `OEE012` |
| **FR-507** | OEE colour thresholds shall be **green ≥ 85 %, amber 70–84 %, red < 70 %**, with offline placeholders for a machine that did not run. | Could | `OEE013`, `OEE014` |
| **FR-508** | **Export PDF** and **Print Report** actions shall be provided; data shall be sourced from **OPC + the Planning DB**; the target OEE shall be configurable, defaulting to **85.0 %**. | Could | `OEE015`–`OEE017` |

> **No backlog story covers the OEE dashboard.** It has a mockup, 17 source requirements and no phase, owner or story. Recorded as **PP-03** in §11.3.
