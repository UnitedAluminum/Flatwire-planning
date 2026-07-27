# Pass Schedule Management — Integration with Shopfloor Dashboards

**Document Purpose:** Detailed analysis of how Pass Schedule Management (Dashboard 9) integrates with the shopfloor dashboards and system behavior.

**Last Updated:** May 4, 2026

**Status:** Reference — Integration Design Analysis

---

## Overview

Pass Schedule Management is the central control mechanism for flat wire manufacturing operations. It defines component activation, die configurations, roll clearances, gauge/width targets, and route modes. Understanding how it integrates with the shopfloor traveler dashboards is critical to ensure correct machine behavior, traceability, and quality control.

---

## Integration Flow & Dependencies

### Creation → Acknowledgment → Execution Cycle

**Pass Schedule Management (Dashboard 9)** — Where Operations/Maintenance:
- Creates/edits pass schedules with component configs, dies, roll gaps, gauge targets, edge types
- Views override history and change reasons
- Deactivates old schedules

**Check-in Dashboards (2 & 5)** — Operator interface:
- Operator reads the pass schedule (read-only to floor operators)
- Must explicitly **acknowledge** the pass schedule before starting
- This acknowledgment **triggers the system to push PLC tags** to the machine

**Active Run Monitor (Dashboard 3)** — Real-time execution:
- Displays which components are ON/OFF per the acknowledged pass schedule
- Shows die sizes, roll gaps, target gauge/width
- Live gauge and width traces are compared against pass schedule targets

---

## Key Integration Points

| Dashboard | Role | Integration with Pass Schedule |
|-----------|------|--------|
| **Dashboard 9** | Create/Edit/Manage | Operations maintains the pass schedule database; no floor operator access |
| **Dashboard 2** (FL1 Check-in) | Acknowledge | Operator views and acknowledges pass schedule; system pushes PLC tags on acknowledgment |
| **Dashboard 5** (FL2 Check-in) | Acknowledge | Same as Dashboard 2 — spool check-in also requires pass schedule acknowledgment |
| **Dashboard 3** (Active Run) | Execute & Monitor | Shows real-time machine state driven by acknowledged pass schedule settings |
| **Dashboard 1** (Line Overview) | Supervise | Supervisor sees current pass schedule configuration on each line; alerts triggered by pass schedule settings |
| **Dashboard 6** (SPC Checkpoint) | Control | Post-die-change checkpoint may be triggered if pass schedule component settings changed |
| **Dashboard 4** (Weld Event) | Trace | Weld event must record source/incoming rod alphas; traceability tied to pass schedule route mode |
| **Dashboard 7** (Output Completion) | Output Tracking | Final coil record should include pass schedule ID/version for audit trail and customer certs |
| **Dashboard 8** (WIP Rejection) | Quality Control | Rejection reasons may indicate pass schedule misconfiguration; feedback mechanism needed |

---

## System Behavior Sequence

```
1. Operations Manager creates Pass Schedule (Dashboard 9)
   ↓
2. Job scheduled for FL1 / FL2 / FL3
   ↓
3. Operator arrives at line with incoming material (rod or spool)
   ↓
4. Operator logs into Floor Station → selects order
   ↓
5. System displays Rod Check-in (Dashboard 2) or Spool Check-in (Dashboard 5)
   with Pass Schedule pre-loaded for that order/product
   ↓
6. Operator reads Pass Schedule (DIE CONFIG, ROLL GAPS, EDGE SET, TARGETS)
   ↓
7. Operator performs Visual Inspection (Dashboard 2) or loads spool (Dashboard 5)
   ↓
8. Operator clicks "ACKNOWLEDGE PASS SCHEDULE & BEGIN CHECK-IN"
   ↓
9. System validates all required fields complete
   ↓
10. System READS Pass Schedule and PUSHES PLC TAG VALUES to machine
    (component activation, speed ranges, gap settings, etc.)
   ↓
11. Machine runs according to PLC tags (operator not manually configuring machine)
   ↓
12. Active Run Monitor (Dashboard 3) displays real-time state
    (gauge trace, width trace, component status — all reflecting passed PLC config)
   ↓
13. If die change happens mid-run → SPC checkpoint (Dashboard 6)
    → new post-die measurements
    → pass schedule may be updated (operations logs override)
    ↓
14. When Payoff 1 nears end → Weld Event (Dashboard 4)
    → operator records incoming rod alpha
    → traceability chain updated
    ↓
15. Run completion → final gauge/width SPC recorded
    ↓
16. Output coil completion (Dashboard 7)
    → coil alpha generated
    → source rod alphas linked (from weld traceability)
    → pass schedule ID should be recorded for audit
```

---

## Critical Dependencies & Gaps

### ✓ Well-Defined Integrations

#### 1. Check-in → PLC Push Gate
**Status: CORRECT**
- Plan clearly states: "PLC tags only pushed **after** operator explicitly acknowledges the pass schedule. No automatic push occurs."
- Dashboard 2/5 show the acknowledgment step as a prerequisite to "BEGIN CHECK-IN."
- **Implication:** Operator cannot accidentally bypass pass schedule confirmation.

#### 2. Read-Only Operator View
**Status: CORRECT**
- Floor operators can only **view and acknowledge** the pass schedule (Dashboard 2/5), not edit it.
- Only Operations/Maintenance can edit (Dashboard 9).
- **Implication:** Separation of concerns enforced; operators cannot modify critical configuration.

#### 3. Component Active/Bypass Display
**Status: CORRECT**
- Dashboards 2 and 5 show the pass schedule component table with Active/Bypass status.
- Allows operators to visually confirm the configuration before acknowledging.
- **Implication:** Operator awareness of which machine components are active for the run.

#### 4. Override Logging
**Status: CORRECT**
- Dashboard 9 shows "OVERRIDE LOG (last 5)" with dates, user, parameter changed, and reason.
- Plan states all changes are logged.
- **Implication:** Traceability of configuration changes for audit purposes.

---

### ⚠️ Potential Integration Gaps

#### GAP 1: Pass Schedule Selection at Check-in — Mechanism Defined; No-Match Path Still Open

**Status Update (Apr 28, 2026):** The updated dashboards now show the selection mechanism. **This gap is partially resolved.**

**What dashboards now show (Dashboards 2, 5, and FL3 check-in):**
- System performs an attribute-based lookup: matched on alloy + rod diameter + target gauge × width + route mode
- Recommended schedule is surfaced in a confirm bar: "System recommends PS-1100-FL1-003 — matched on Alloy 1100, Rod 0.375″, Target 0.110″ × 0.625″"
- Operator must explicitly click "Confirm Schedule" before the "Acknowledge & Begin Check-in" button enables
- A "Change" dropdown shows all available alternatives; selecting a non-recommended schedule is flagged for Operations review with warning: "Selecting a different schedule will be flagged for Operations review"
- The schedule is not stored on the order record at planning time — it is resolved at check-in

**Remaining gap — No-Match Notification Path:**
- The dashboard does not show what happens when the attribute lookup returns **no match** — no active pass schedule exists for the order's attribute combination
- Must the check-in be blocked (operator cannot proceed) and an alert sent to Operations to create the missing schedule?
- Or can the operator continue by manually selecting from a schedule that doesn't match?
- Without this, an operator starting a new product variant could arrive at check-in with no schedule available and have no clear path forward

**Impact:** **MEDIUM** (selection mechanism resolved; residual risk only for first-run-on-new-product-variant scenarios)

**Recommendation:**
- Define and mockup the empty-match state: show a warning banner "No matching pass schedule found for this order's attributes. Operations must create a schedule before check-in can proceed."
- Block the "Acknowledge" button and display a link to Dashboard 9 for Operations to create the schedule
- Optionally show a "No schedule — proceed manually" override path requiring Operations Manager credentials and reason logging

---

#### GAP 2: Mid-Run Pass Schedule Changes — DECIDED May 4, 2026

**Status:** Decided. The four-step Mid-Run Configuration Change flow is confirmed. The design below is the required behavior.

**Confirmed operator access rule:**
- Floor operators have **read-only** access to the pass schedule at check-in. They cannot edit it unless it is a one-for-one same-size die swap (e.g., replace DB1 die 0.285" with new DB1 die 0.285"). Any other change must be made by an Operations Manager in Dashboard 9.

**Confirmed four-step flow:**

**Step 1 — Operations Manager logs the override in Dashboard 9**
- System records: which parameter changed, old value → new value, user ID, timestamp, reason code or free-text reason.
- Dashboard 9 Override Log shows the last 5 changes with date, user, parameter, and reason.

**Step 2 — Active Run Monitor (Dashboard 3) shows a real-time alert requiring operator acknowledgment**
- As soon as the override is saved, the system pushes a notification to the Active Run Monitor on the active line.
- Operator must explicitly either:
  - **Acknowledge** — they have read and understood the change; production continues under the new configuration.
  - **Stop Run** — they are not comfortable continuing; supervisor review required before proceeding.
- Passive dismissal is not permitted.
- The new configuration is in the database at this point, but the machine is still running under the **old PLC values** until the operator acknowledges. The acknowledgment step bridges that gap.

**Step 3 — System records material before and after the change under their respective configurations**
- The system captures the footage counter value at the moment of the change.
- **Same-product change (within-spec tooling, AGC adjustment):** Configuration event recorded on the existing alpha at the footage position. No new alpha.
- **Product specification change (die size, edge type, roll gap to new target):** Existing alpha closes at that footage; new child alpha opens with the updated pass schedule. See Q27 for the five-case alpha-handling rules.

**Step 4 — Automatic SPC checkpoint triggered post-change**
- When pass schedule changes mid-run (especially die size or roll gap), the system sets `spcCheckpointRequired: true`.
- Active Run Monitor shows "Configuration Change Logged — Awaiting SPC Checkpoint."
- Operator cannot close that status without completing SPC.

---

#### GAP 3: SPC Checkpoint Triggering After Die Change — Explicit Rule Missing

**Description:**
- Plan says "Post Die Change" is a checkpoint type, and Dashboard 9 override log shows die changes being logged.
- But Dashboards do not show how a die change on Dashboard 3 (Active Run Monitor) **automatically triggers or prompts** Dashboard 6 (SPC Checkpoint).

**Missing Detail:**
- Is there a button on Dashboard 3 called "Die Change" that opens Dashboard 6, or does the operator need to manually navigate?
- Looking at Dashboard 3: Shows button "[ DIE CHANGE ]" — but the exact flow is not documented.

**Current Design (from Dashboard 3):**
```
[ LOG WELD EVENT ]  [ DIE CHANGE ]  [ SPC CHECKPOINT ]
[ PAUSE RUN     ]   [ WIP REJECT ]  [ COMPLETE RUN   ]
```

**Missing:** What happens when operator clicks [DIE CHANGE]?

**Impact:** **MEDIUM**
- If the flow is ambiguous, operators may skip the SPC checkpoint, reducing quality control.
- Gauge drift post-die-change may go undetected.

**Recommendation:**
- Explicitly document: "Clicking '[DIE CHANGE]' on Dashboard 3 opens Dashboard 6 with checkpoint type pre-set to 'Post Die Change' and previous measurements pre-populated for comparison."
- System should require SPC measurements before operator can resume run after die change.
- Dashboard 3 should show a status indicator: "Die Change Logged — Awaiting SPC Checkpoint" (blocking until completed).

---

#### GAP 4: FL3 Hybrid Pass Schedule — Unified Approach Implied; FL2 Hybrid Validation Still Open

**Status Update (Apr 28, 2026):** The updated FL3 rod check-in dashboard implies Option A (unified). **This gap is partially resolved.**

**What dashboards now show (dashboard_2_rod_checkin_fl3.html, dashboard_9a_schedule_list.html):**
- The FL3 check-in shows a single pass schedule ID (PS-1350-FL3-001) covering all components — the component table shows both the Drawing stage (DB1, DB2, FM1, Edge set) and the Finishing stage (FM2 8″ roller, FM2 6″ S1, FM2 6″ S2) in one unified record
- The schedule list tags this record as Line "FL3" with Route "Hybrid"
- The attribute-based lookup includes "Hybrid route" as a match criterion, so the system will only recommend this schedule to operators starting a hybrid FL3 run
- **Option A (single unified pass schedule) is the implicit design decision**

**Remaining gap — FL2 Check-in Validation for Hybrid-Origin Spools:**
- The current Dashboard 5 (spool check-in) mockup only shows standalone FL2 schedules (e.g., PS-1100-FL2-007) with attribute matching on spool gauge/width/edge
- It is not shown how Dashboard 5 handles a spool that was produced as the *output* of a hybrid FL3 run — i.e., a spool that carries a hybrid PS in its traceability chain
- If a hybrid spool is later loaded onto FL2 for a standalone re-pass job, the system must either: (a) prevent applying a standalone FL2 schedule to hybrid-origin material without an explicit re-classification event, or (b) treat the spool identically to any other spool input and apply a standard standalone FL2 schedule
- This validation rule for Dashboard 5 must be defined

**Impact:** **MEDIUM** (data model resolved; residual risk in FL2 check-in handling of hybrid-origin spools)

**Recommendation:**
- Confirm in writing: "FL3 hybrid mode uses a single unified pass schedule record containing both FL1 and FL2 component configurations."
- Define the FL2 spool check-in behaviour for hybrid-origin spools: should Dashboard 5 detect that the input spool came from a hybrid FL3 run (via its SP-series alpha traceability chain) and show a specific warning or override path?
- Document: "Standalone FL1 and FL2 runs use distinct pass schedules. FL3 hybrid runs use a single pass schedule tagged Route = Hybrid."

---

#### GAP 5: Pass Schedule Availability in Planning & Scheduling — Not Shown

**Description:**
- Dashboards and Plan do not show **how a pass schedule ID is selected during job planning/scheduling.**
- Is it auto-assigned based on product type, manually selected by the planner, or determined at machine check-in time?

**Plan Statement:**
- "Pass schedule is applied after planning, when a job is actually being set up on the line."
- **This suggests:** Pass schedules are **not** assigned during planning — they are selected **at check-in time.**

**Missing:**
- Should the planning system warn if a job is scheduled for FL1 but no pass schedule exists for that product/alloy combination?
- What if multiple pass schedules exist for the same product? Which one is recommended?
- Can different operators select different pass schedules for the same order?

**Impact:** **MEDIUM**
- If planning and pass schedule are decoupled, the floor may receive a scheduled job with no corresponding pass schedule, blocking the line.
- Without guidance, operators may select an outdated or incorrect pass schedule.

**Recommendation:**
- **Define the pass schedule lookup workflow:**
  1. Order is planned with product attributes (alloy, gauge, width, edge type).
  2. System queries for available pass schedules matching those attributes.
  3. At check-in (Dashboard 2/5), system displays the recommended pass schedule.
  4. Operator can override if needed (with a confirmation warning).
- **Add validation rule:** "If no active pass schedule matches the order's product attributes, flag the order as 'Cannot Schedule — Pass Schedule Missing' and alert Operations."
- **Recommendation:** Store the selected pass schedule ID in the order record after check-in acknowledgment for full traceability.

---

#### GAP 6: WIP Rejection & Pass Schedule — Connection Not Clear

**Description:**
- Dashboard 8 (WIP Rejection) logs a rejection reason (e.g., "Gauge Out of Spec") and disposition (Suspend/Scrap/Rework).
- But how does the system prevent the same rejection from recurring in the next run if the pass schedule was the root cause?

**Example:**
- If material fails because "Gauge Out of Spec," was the pass schedule's gauge target incorrect, or was the machine not following the pass schedule settings?

**Missing:**
- Should WIP rejections trigger a pass schedule review?
- Is there a feedback loop from quality failures to operations?
- How do supervisors know if a pattern of rejections indicates a pass schedule problem vs. a machine problem?

**Impact:** **LOW-MEDIUM**
- Without a feedback mechanism, recurring quality failures may not be traced back to pass schedule misconfiguration.
- Operations may not discover that a pass schedule's targets are unachievable on the machine.

**Recommendation:**
- **Add dashboard or report showing "Rejection Pattern Analysis":**
  - Counts rejections by reason, by pass schedule, by time window.
  - Identifies pass schedules with >N rejections of the same reason in Y days.
  - Alerts: "Pass Schedule PS-1100-FL1-003 has 4 'Gauge Out of Spec' rejections in 7 days — review target settings."
- **Link WIP rejection (Dashboard 8) to Pass Schedule (Dashboard 9):**
  - When rejection is logged, display the pass schedule ID in use.
  - Provide a hyperlink: "[View Pass Schedule]" → Dashboard 9.

---

#### GAP 7: Coil Completion & Pass Schedule Traceability — DECIDED May 4, 2026

**Decision:**
- **Label:** Pass schedule data (ID, version, die sizes, roll gap values) should **not** appear on the coil label.
- **Technical traceability:** Pass schedule ID and relevant configuration data **must** be logged against the coil record at coil creation time for technical traceability and quality audits.

**Rationale:** If the pass schedule is subsequently edited after the run, the configuration in effect at run time cannot be reconstructed unless it was captured at coil creation. This data must be stored at the time the coil alpha is generated.

**Required system behavior:**
- At run completion (Dashboard 7), the system writes the pass schedule ID, version, and effective configuration snapshot to the coil record.
- Data is accessible to quality auditors and engineering through internal screens — not exposed on customer labels.
- Any query about "what exact die sizes / edge config / roll gaps were used for this coil" resolves from this stored snapshot, not from the current (possibly edited) live pass schedule.

---

#### GAP 8: Line Overview (Dashboard 1) & Pass Schedule Display — Incomplete

**Description:**
- Dashboard 1 (Line Status Overview) shows current order, speed, gauge, width, and alerts.
- But it does **not show the active pass schedule ID** for each line.

**Missing:**
- Supervisors need to know which pass schedule is running on each line for quick situational awareness.
- If an alert is triggered, tying it to the pass schedule helps with root cause analysis.

**Current Dashboard 1 Shows:**
```
│  FL1             │
│  ● RUNNING       │
│  Order: FW-00421 │
│  Speed: 1,620FPM │
│  Gauge: 0.110"   │
```

**Missing:** Pass Schedule ID.

**Impact:** **LOW-MEDIUM**
- Supervisors cannot quickly verify the configuration without navigating to Dashboard 2/3.
- Alert context is incomplete.

**Recommendation:**
- **Add pass schedule display to Dashboard 1:**
  ```
  │  FL1             │
  │  ● RUNNING       │
  │  Order: FW-00421 │
  │  Schedule: PS-1100-FL1-003
  │  Speed: 1,620FPM │
  │  Gauge: 0.110"   │
  ```

---

## Alignment Between Plan & Dashboards

| Aspect | Plan Statement | Dashboard Representation | Status |
|--------|----------------|-------------------------|--------|
| **Pass Schedule Database** | Required; manually maintained by Operations/Maintenance | Dashboard 9 provides create/edit/deactivate UI | ✓ Aligned |
| **Operator View** | Read-only for floor operators | Dashboards 2/5 show read-only pass schedule table | ✓ Aligned |
| **Acknowledgment Gate** | Must acknowledge before PLC tags pushed | Dashboards 2/5 require "ACKNOWLEDGE PASS SCHEDULE & BEGIN CHECK-IN" button | ✓ Aligned |
| **Override Logging** | All mid-run changes logged with reason, operator, timestamp | Dashboard 9 shows override log with date, user, parameter, reason | ✓ Aligned |
| **Component Active/Bypass** | Pass schedule defines which components ON/OFF | Dashboards 2/5/9 display component ON/OFF status | ✓ Aligned |
| **Die Configuration** | Pass schedule defines die sizes per DB1, DB2 | Dashboards 2/5/9 show die sizes; Dashboard 4 captures weld point | ✓ Aligned |
| **Gauge/Width Targets** | Pass schedule defines gauge and width targets | Dashboard 3 compares live trace to "[TARGET: 0.110 ± 0.002]" | ✓ Aligned |
| **SPC Post Die Change** | SPC checkpoint required after die changes | Dashboard 6 has "Post Die Change" checkpoint type; Dashboard 3 has [DIE CHANGE] button | ✓ Aligned (but flow unclear) |
| **Weld Traceability** | System tracks source rods through weld points | Dashboard 4 captures incoming/outgoing rod alphas; Dashboard 7 shows source chain | ✓ Aligned |
| **Pass Schedule Lookup at Check-in** | Pass schedule applied "when job is set up on the line" | Updated dashboards 2/5/FL3 now show attribute-based lookup (alloy + rod + gauge × width + route mode) with confirm bar and Change dropdown | ⚠️ **Partial — no-match path undefined** |
| **Mid-Run Configuration Changes** | Operations can override settings; logged with reason | Four-step flow decided (May 4, 2026): Dashboard 9 override → Dashboard 3 alert → operator acknowledgment → SPC checkpoint. Operator read-only except one-for-one same-size die swap. | ✓ **Decided** |
| **FL3 Hybrid Pass Schedule** | Route mode defines standalone vs. hybrid | Updated FL3 check-in shows single unified PS record covering all FL1+FL2 components; "Hybrid route" is a lookup attribute | ⚠️ **Partial — FL2 check-in handling of hybrid-origin spools undefined** |
| **Pass Schedule in Planning** | Applied "after planning, when job is set up on the line" | Planning system does not show pass schedule selection or validation | ⚠️ **GAP** |
| **Coil ↔ Pass Schedule Audit Trail** | Traceability required for welding wire customers | Decided (May 4, 2026): pass schedule metadata logged at coil creation time for technical traceability; not printed on label. | ✓ **Decided** |
| **Dashboard 1 Pass Schedule Display** | Supervisor needs situational awareness | Dashboard 1 does not show active pass schedule ID | ⚠️ **GAP** |

---

## Recommendations for Integration Clarity

### Priority 1: Critical Path Items (Required Before Shopfloor Development)

| Issue | Recommendation |
|-------|-----------------|
| **Pass Schedule Selection Ambiguity** | Add explicit step in Dashboard 2/5: "Confirm Pass Schedule: [PS-1100-FL1-003] — Is this correct? [CONFIRM / CHANGE]" with dropdown fallback. Require operator confirmation before PLC tags are pushed. |
| **Pass Schedule ↔ Planning Link** | Define workflow: Order attributes → system queries pass schedules → recommended schedule shown at check-in → operator can override. Store selected pass schedule ID in order record after acknowledgment. |
| **Mid-Run Pass Schedule Change Response** | Define a new operator event: "Mid-Run Pass Schedule Update" (similar to Weld Event, SPC Checkpoint) that operators must acknowledge. Auto-trigger SPC checkpoint post-change. |
| **FL3 Hybrid Pass Schedule Handling** | Clarify: Single unified pass schedule vs. two coordinated schedules. Document validation rules to ensure FL1 and FL2 are synchronized when running in hybrid mode. |
| **SPC Post-Die-Change Triggering** | Document: "[DIE CHANGE]" button on Dashboard 3 opens Dashboard 6 pre-set to "Post Die Change." System should block run resume until SPC checkpoint is complete. Show status indicator on Dashboard 3. |

### Priority 2: Traceability & Audit Items (Required Before Trials)

| Issue | Recommendation |
|-------|-----------------|
| **Coil ↔ Pass Schedule Audit Trail** | Store pass schedule ID, version, effective date, and die/roll settings with output coil record (Dashboard 7). Enable certificate reports to include configuration metadata. |
| **Dashboard 1 Pass Schedule Display** | Add pass schedule ID to Dashboard 1 (Line Status Overview) for supervisor situational awareness and alert root cause context. |
| **WIP Rejection Feedback Loop** | Create "Rejection Pattern Analysis" report: counts by reason + pass schedule, identifies recurring failures under same schedule, alerts Operations when pattern detected. Link Dashboard 8 (WIP Rejection) to Dashboard 9 (Pass Schedule) via hyperlink. |

### Priority 3: Enhancement Items (Post-Go-Live)

| Issue | Recommendation |
|-------|-----------------|
| **Pass Schedule Version Control** | Implement versioning for pass schedules; track approval workflows; enable "rollback" to previous version if current version causes quality failures. |
| **Automated Pass Schedule Recommendations** | Machine learning / historical analysis: system recommends pass schedule adjustments based on quality results, throughput, and machine capability data. |
| **Cross-Line Pass Schedule Validation** | For FL3 hybrid and future multi-line processes: system validates that linked lines have compatible pass schedules before allowing simultaneous scheduling. |

---

## Pass Schedule Generation Algorithm

### Overview

A pass schedule generation algorithm is feasible and would significantly reduce manual effort for Operations. Given **incoming rod diameter**, **alloy**, **target gauge**, and **target width**, the algorithm can derive component activation, die sizes, roll gaps, and route mode automatically. The result is a **draft schedule** that Operations reviews and approves before it becomes active — humans remain in the loop before anything is pushed to the PLC.

This is a "Generate & Review" workflow, not auto-execution.

---

### Core Physics

#### Wire Drawing (DB1 → DB2)

Each die reduces the wire cross-sectional area. Aluminum has a maximum safe reduction per pass (typically 20–28% depending on alloy). Exceeding this causes wire breakage or excessive work hardening.

```
Area Reduction % = (A_in - A_out) / A_in × 100

A_rod = π × (D_rod / 2)²
A_die = π × (D_die / 2)²
```

The total reduction from rod diameter to pre-flatten diameter drives how many die passes are needed.

#### Flattening Target (FM1)

Volume is conserved when round wire is pressed flat. The required pre-flatten wire diameter is:

```
D_preflatten ≈ sqrt(4 × target_gauge × target_width / π)
```

This is the diameter the drawing stage must deliver to FM1.

#### FM2 Requirement

FM2 stands are needed when:
- Aspect ratio (`target_width / target_gauge`) exceeds ~5.5 — FM1 alone cannot control both dimensions precisely at high ratios
- Tight final tolerance is required (e.g., welding wire customers)
- Width refinement after FM1 is insufficient

---

### Algorithm Steps

```
INPUT:
  rod_diameter   (e.g., 0.375")
  alloy          (e.g., 1100, 1350, 3003)
  target_gauge   (e.g., 0.110")
  target_width   (e.g., 0.625")

─────────────────────────────────────────────────────────────
STEP 1 — Compute required pre-flatten wire diameter
  D_pre = sqrt(4 × target_gauge × target_width / π)
  → sqrt(4 × 0.110 × 0.625 / π) ≈ 0.296"

STEP 2 — Compute total area reduction needed (rod → D_pre)
  A_rod = π × (0.375 / 2)² = 0.1104 in²
  A_pre = π × (0.296 / 2)² = 0.0688 in²
  Total reduction = (0.1104 − 0.0688) / 0.1104 = 37.7%

STEP 3 — Determine number of drawing passes needed
  Lookup alloy max reduction per pass:
    1100 → 26%   |   1350 → 22%   |   3003 → 24%

  If total_reduction ≤ max_per_pass         → DB1 BYPASSED, DB2 BYPASSED (0 draws)
  If total_reduction ≤ max_per_pass × 1.5   → DB1 ACTIVE, DB2 BYPASSED (1 draw)
  If total_reduction ≤ max_per_pass × 2     → DB1 ACTIVE, DB2 ACTIVE (2 draws)
  If total_reduction >  max_per_pass × 2    → FLAG WARNING: pre-drawn wire required as input;
                                               cannot achieve target in 2 die passes

  Example (1100, 37.7%): 37.7% > 26% and ≤ 52% → DB1 ACTIVE, DB2 ACTIVE

STEP 4 — Calculate die sizes
  Equal reduction across passes minimises stress:
  D_intermediate = sqrt(D_rod × D_pre)   ← geometric mean
  → sqrt(0.375 × 0.296) ≈ 0.333"

  DB1 die = 0.333"  →  snap to nearest available die in inventory
  DB2 die = 0.296"  →  snap to nearest available die in inventory

STEP 5 — Calculate FM1 roll gap
  FM1_gap = target_gauge × alloy_springback_factor
  → springback factor for 1100 ≈ 0.98
  → FM1_gap = 0.110 × 0.98 = 0.108"

  FM1 Gauge Target = target_gauge ± alloy_gauge_tolerance
  FM1 Width Target = target_width ± alloy_width_tolerance

STEP 6 — Determine FM2 requirement
  aspect_ratio   = target_width / target_gauge = 0.625 / 0.110 = 5.68
  is_welding_wire = (alloy == 1350 OR customer precision flag set)

  If aspect_ratio > 5.5 OR is_welding_wire:
    FM2 8"   → ACTIVE
    FM2 6"S1 → ACTIVE if aspect_ratio > 7.0 OR is_welding_wire
    FM2 6"S2 → ACTIVE (mandatory — cannot bypass)
    Route    → FL3 Hybrid

  Else:
    FM2 8"   → BYPASSED
    FM2 6"S1 → BYPASSED
    FM2 6"S2 → ACTIVE (mandatory)
    Route    → FL1 Standalone

STEP 7 — Calculate FM2 roll gaps (if active)
  Progressive squeeze toward target gauge:
  FM2 8"   gap = target_gauge × 1.06
  FM2 6"S1 gap = target_gauge × 1.02
  FM2 6"S2 gap = target_gauge × 0.98

OUTPUT:
  Draft pass schedule record — status: PENDING OPERATIONS REVIEW
─────────────────────────────────────────────────────────────
```

---

### Sample Algorithm Output

**Input:** Rod 0.375" | Alloy 1100 | Target 0.110" gauge × 0.625" width

| Parameter | Generated Value |
|-----------|----------------|
| Route Mode | FL3 Hybrid *(aspect ratio 5.68 > 5.5)* |
| DB1 | ACTIVE — 0.335" die *(snapped from 0.333")* |
| DB2 | ACTIVE — 0.295" die *(snapped from 0.296")* |
| FM1 Gap | 0.108" |
| FM1 Gauge Target | 0.110" ± 0.003" |
| FM1 Width Target | 0.625" ± 0.010" |
| FM2 8" Gap | 0.117" |
| FM2 6"S1 Gap | 0.112" |
| FM2 6"S2 Gap | 0.108" |
| FM2 8" | ACTIVE |
| FM2 6"S1 | ACTIVE |
| FM2 6"S2 | ACTIVE *(mandatory)* |
| Status | **DRAFT — Pending Operations Review** |

---

### What the Algorithm Can and Cannot Determine

| Parameter | Auto-Calculable | Notes |
|-----------|----------------|-------|
| Draw passes needed (0 / 1 / 2) | **Yes** | Physics-based reduction calculation |
| DB1 / DB2 ACTIVE or BYPASSED | **Yes** | Derived from draw passes |
| DB1 / DB2 die sizes | **Yes\*** | \*Snapped to nearest die in inventory |
| FM1 roll gap | **Yes** | Formula with alloy spring-back factor |
| FM1 gauge & width targets | **Yes** | From input spec + tolerance table |
| FM2 stand activation | **Yes** | Based on aspect ratio threshold |
| FM2 roll gaps | **Yes** | Progressive compression formula |
| Route mode (FL1 / FL3) | **Yes** | Derived from FM2 requirement |
| **Edge type** | **No** | Customer specification — Round or Flat Edge must be provided |
| **Speed range** | **No** | Machine capability + operator experience |
| **Annealing required** | **No** | Metallurgical decision; depends on temper and prior work history |
| **Tolerance bands (±)** | **Partial** | Defaults from alloy table; customer overrides are manual |
| **Final approval** | **No** | Operations must review and activate; never auto-pushed to PLC |

---

### Required Lookup Tables

For the algorithm to function, the following reference data must be maintained in the database:

| Table | Contents | Owner |
|-------|----------|-------|
| **Alloy Reduction Limits** | Max area reduction % per pass per alloy | Process Engineering / Tim O. |
| **Alloy Spring-back Factors** | FM roll gap compression factor per alloy | Process Engineering / Tim O. |
| **Alloy Tolerance Defaults** | Default gauge ± and width ± per alloy | Process Engineering |
| **Die Inventory** | Available die sizes currently on hand | Maintenance / Tim O. |
| **Aspect Ratio Thresholds** | Width/gauge ratio at which FM2 stands activate | Process Engineering |
| **Machine Capability Limits** | Min/max gauge per line (FL1, FL2, FL3) | Maintenance / Bill P. |

---

### Generate & Review Workflow (Dashboard 9 Integration)

```
Operations opens Dashboard 9
    │
    ├─ Option A: Create Manually (existing flow)
    │
    └─ Option B: Generate from Specs
          │
          ├─ Enter: Alloy, Rod Diameter, Target Gauge, Target Width, Edge Type
          │
          ├─ Algorithm runs → draft pass schedule displayed
          │   (all fields pre-populated; warnings shown if spec is at limits)
          │
          ├─ Operations reviews and adjusts any value
          │   (die inventory picker, gap fine-tuning, tolerance overrides)
          │
          └─ Operations clicks "Save as Active"
                → record stored in Pass Schedule database
                → available for operator check-in on Dashboard 2 / 5
```

> PLC tags are **never pushed** as part of generation. The draft schedule only becomes live after Operations saves it as Active and the operator acknowledges it at check-in — same gate as a manually created schedule.

---

### Scenarios Where the Algorithm Will Warn or Fail

| Condition | Algorithm Response |
|-----------|--------------------|
| Total reduction > 2× alloy max per pass | Warning: "Target cannot be achieved in 2 draw passes. Use pre-drawn round wire as input, or adjust target gauge/width." |
| Target gauge below machine minimum | Warning: "Target gauge is below FL1 minimum capability. Cannot generate schedule." |
| No die in inventory within 0.005" of calculated size | Warning: "No matching die found for DB1/DB2. Nearest available die shown — verify before saving." |
| Aspect ratio > 10 | Warning: "Very high aspect ratio — verify FM2 capability with Maintenance before activating." |
| Alloy not found in reduction table | Error: "Alloy not configured. Contact Process Engineering to add reduction parameters." |

---

### Implementation Notes

- The algorithm is a **calculator, not an auto-approver** — it produces a draft that always requires Operations sign-off.
- Edge type must always be provided by the user; it is a customer specification, not derivable from dimensions.
- Die size snapping should show the operator the calculated ideal size alongside the selected inventory size, so they can judge the deviation.
- The spring-back and reduction limit tables should be editable by Process Engineering via an admin screen — they will need tuning as real production data accumulates.
- Post-go-live, actual quality results (SPC, WIP rejections) can be fed back to refine the algorithm's default parameters over time (aligns with Priority 3 "Automated Pass Schedule Recommendations").

---

## Summary

Pass Schedule Management integrates well with shopfloor check-in and real-time monitoring flows. However, **critical gaps exist around:**

1. **Pass schedule selection logic** — unclear how the system determines which pass schedule to display at check-in
2. **Mid-run configuration changes** — no documented operator response protocol
3. **FL3 hybrid coordination** — unclear whether hybrid mode uses one or two pass schedules
4. **Traceability metadata** — coil records don't capture pass schedule used for customer audits
5. **Feedback loops** — no mechanism to connect quality failures to pass schedule misconfiguration

**Resolved gaps (May 4, 2026):** GAP 2 (mid-run configuration changes) and GAP 7 (coil traceability) are now decided. GAP 1 (no-match path) and GAP 4 (FL2 hybrid spool validation) remain partially open. GAP 5 (pass schedule in planning) and GAP 8 (Dashboard 1 display) remain open.

---

## Related Documents

- [FlatWireShopfloorDashboards.md](FlatWireShopfloorDashboards.md) — Complete dashboard design specifications
- [FlatWirePlan.md](FlatWirePlan.md) — Implementation plan and scope
- [FlatWireEndToEndProcess.md](FlatWireEndToEndProcess.md) — End-to-end process reference

---

## Change Log

| Date | Changed By | Description |
|------|----------|-------------|
| Apr 24, 2026 | Analysis Team | Initial integration analysis document created — 8 critical gaps identified, 11 recommendations provided |
| Apr 25, 2026 | Analysis Team | Added Pass Schedule Generation Algorithm section — core physics, algorithm steps, sample output, lookup table requirements, Dashboard 9 Generate & Review workflow, and warning/failure scenarios |
| Apr 28, 2026 | Analysis Team | Updated GAP 1 and GAP 4 to reflect dashboard changes. GAP 1 (selection mechanism): attribute-based lookup + confirm bar now shown in dashboards 2, 5, FL3; residual open point = no-match notification path. GAP 4 (FL3 hybrid): unified single PS record approach now implied by FL3 check-in dashboard; residual open point = FL2 check-in validation for hybrid-origin spools. GAP 5 (planning validation) and GAP 7 (coil traceability) remain fully open. |
| May 4, 2026 | Analysis Team — Tim O. review | **GAP 2 Decided:** Four-step mid-run configuration change flow confirmed. Operator read-only access confirmed except one-for-one same-size die swap. Acknowledgment requirement, alpha-split rules, and automatic SPC checkpoint trigger all confirmed. **GAP 7 Decided:** Pass schedule metadata logged at coil creation time for technical traceability; not on customer label. Alignment table updated. |
