# Flat Wire Mill — Database Gap Analysis

**Project:** Flat Wire Mill Implementation
**Document Type:** Internal gap analysis — database artifacts against requirements
**Last Updated:** August 12, 2026
**Status:** Active — findings raised, not yet dispositioned

---

## Scope and method

Every artifact in [`MVP-1/ProjectPlan/Database`](.) was read in full — the five per-domain schema
documents, the fifteen SQL scripts, [`FlatWire_ERDiagram_Documentation.md`](DatabaseDesign.md)
and [`CommonDB_Insert_WIPStations_FlatWire.sql`](Scripts/CommonDB_Insert_WIPStations_FlatWire.sql) —
and checked against:

- [`MVP-1/ProjectPlan/Business/BusinessRequirements.md`](../Business/BusinessRequirements.md) (`FR-###`) and
  [`03-HLD-and-ERDiagram.md`](DatabaseDesign.md) §6.9;
- all sixteen specifications in [`MVP-1/ProjectPlan/Business/Screens/`](../Business/Screens/),
  including the five issued **11 Aug 2026**;
- [`phase-01c-database-foundation.md`](../Development/Phases/phase-01c-database-foundation.md),
  [`Architecture/PLCCommunication.md`](../Architecture/PLCCommunication.md) §3,
  [`REVIEW.md`](../Development/REVIEW.md) and the Gaps register in
  [`Development/GapsRegister.md`](../Development/GapsRegister.md);
- the `OI-##` register in [`FlatWire_MasterSpecification.md`](../../../LatestDocument/FlatWire_MasterSpecification.md) §11.

**Findings are classified A–E by what has to happen, not by severity alone.** Each finding
records whether it is already carried in a register or is new here. Nothing in this document
creates an `OI-##` or `G##` number — proposed numbers are marked as proposals.

---

## The verified baseline

Counted from the scripts themselves, not from any document that describes them:

| Object | MVP-1 count | Notes |
|---|---|---|
| Tables | **25** | 28 in the full design; the three `PassSchedule*` tables are owned outside MVP-1 |
| Foreign keys | **33** | `06_ForeignKeys.sql`; MVP-2's `06b` adds the other 10 of the design's 43 |
| Indexes | **41** | 39 non-clustered + **2** filtered-unique (`UX_RodStaging_Bay`, `UX_RodStaging_RodActive`) |
| Procedures | **1** | `sp_GetGaugeTrace`. `sp_ShiftSummary` is MVP-2's and `08` correctly refuses to touch it |
| Triggers | **1** | `trg_CoilTraceability_NoOverlap` (DM010) |

**The build itself is sound.** `RunAll` skips `02_Schedule` deliberately and explains why, no
MVP-1 script references an MVP-2 object, every script is idempotent, and the sample data covers
all 25 tables (`PayoffPosition` is seeded in the DDL because the FK depends on the rows). The
findings below sit *around* that build.

> **The 25 / 33 / 41 / 1 / 1 figures above supersede every other count in the repository.**
> `phase-01c` states 24 (§*Target database*, §*Data-access wiring*), 25 (three places) and 28
> (the 30 Jul call note) in one document; the root `CLAUDE.md` says "verified … 24 tables"; the
> ER documentation's footer says 27 against its own header's 28. See **E6**.

---

## Class A — Required artifacts that do not exist

### A1. The FW-001 / FW-002 shared-schema migration has no script `[NEW]`

The largest gap in the folder. [`phase-01c`](../Development/Phases/phase-01c-database-foundation.md)
makes the existing-schema migration a Phase-1C deliverable due **14 Aug 2026**:

- eight slash-dual renames on the shared `coils` / scheduling schema — `CoilNo→Coil/BundleNo`,
  `SlitWidth→Slit/FlatWidth`, `IsCampaingCoil→IsCampaignCoil/Bundle`,
  `CoilLocation→Coil/BundleLocation`, `CoilWeight→Coil/BundleWeight`,
  `CoilStatus→Coil/BundleStatus`, `OutgoingCoilId→OutgoingCoil/BundleId`,
  `OutgoingCoilOd→OutgoingCoil/BundleOd`;
- two new columns — `OutgoingCoil/BundleWidth`, `IncomingWireDia`;
- the new coil status **`INFLAT`** (FW-002, narrowed 30 Jul: set at check-in only, never on the
  pre-check-in path).

FW-001 is **Critical / Sprint 1** and is flagged repo-wide as high blast radius with a discrete
40 h impact audit. [`DBScripts/`](Scripts/) contains only the WIP-stations script. Every
FlatWireDB table has executable, idempotent, guarded DDL; the one change that touches the shared
production schema has none.

**Impact:** FW-002, FW-004 and FW-005–007 all declare FW-001 as a dependency, and the Phase-1
gate is 14 Aug.

### A2. The skid table `[OI-104, G36]`

`CoilOutput.SkidId` is commented "external skid reference (existing skid table; no local FK)" in
[`FlatWire_DDL_05_QualityOutput.sql:135`](Schema/SQL/FlatWire_DDL_05_QualityOutput.sql#L135) and
in [`FlatWireSchema_QualityOutput.md`](Schema/FlatWireSchema_QualityOutput.md). Nothing in the
repository names, creates or verifies that table. `FR-347` (skid slot layout) and `FR-351` (close
skid → staging location, skid label) depend on it, and `phase-09`'s 222 h assumes it exists.

### A3. Lot number `[OI-24, OI-99]`

No column on `CoilOutput`, no generator, no numbering table. `FR-336` prints it on the customer
label and `GET /coil/{alpha}/label` returns it. `OI-99` (which lot, when a coil has several
source rods — the normal case under welded feed) sits on top of a column that does not exist.

### A4. Rework return stage `[OI-22, OI-100]`

`FR-297` requires a Return-to-stage selector when `Rework` is chosen. There is no column, and
`CK_WipRejection_MatStatus` admits only `HOLD` / `SCRAP` — so a `Disposition='Rework'` row cannot
record either a distinct material state or a destination.

### A5. The PLC tag audit log has no sink `[NEW]`

`FR-075` (`Must`, `INT004`) requires the outcome of every tag push to be recorded **and** each
write audit-logged with tag path, value, operator, timestamp and result.
[`Architecture/PLCCommunication.md`](../Architecture/PLCCommunication.md) §3 tables the four
durable flags and cites a DDL file and line for each —

`RodCheckin.PlcTagsPushed` · `SpoolCheckin.PlcTagsPushed` · `RollOverride.PlcTagWritten` · `RodCheckout.PlcTagsCleared`

— then states the audit-log requirement **with no DDL reference at all**. Either it is a Serilog
sink (in which case the escalation policy "*any* failure" needs a retention statement, since a
failed write aborts a check-in) or it is a table that has never been designed. Commissioning
tests `C1`/`C11` are the first point at which a path is confirmed, so the write history is the
only evidence of what was attempted.

### A6. Entities already registered as absent — all confirmed still absent

Verified against the DDL, listed so nobody re-raises them as new:

| Concept | Required by | Register |
|---|---|---|
| Die master / per-physical-die inventory | `FR-233`, `FR-254`, SRS §5.10 | `OI-41` (narrowed 6 Aug, not closed) |
| Alert lifecycle (raise / acknowledge / clear) | `FR-422`–`FR-428` | `OI-28` |
| MMS ID format and generator | `FR-013` | `OI-03` (columns exist, no format) |
| SPC-HOLD as a distinct state | `FR-187`, `FR-188` | `OI-23` |
| Wire-break record | `FR-280`–`FR-282` | `OI-13` |
| Scrap-box entity | `FR-066`, `FR-271` | `OI-15` (`ScrapBoxRef` is free `varchar`) |
| Rod bundle / receiving-lot header | rod bundle receiving workflow | `OI-29` |
| Gap-free `R#####` sequence | rod alpha "no gaps per lot" | `OI-30` |
| Legacy migration deliverable for `FlatLineSetup` / `FlatLineProcessing` | both renamed into the new model | `OI-31` / `G8` |
| Unplanned component bypass | `OQ-63` — a **decided** requirement | `OI-43` |

---

## Class B — Columns the newest specifications need and the schema lacks

The schema documents were last updated **6 Aug 2026**; `ActiveRunMonitor`, `OutputCoilCompletion`
(v1.1–1.2), `WipRejection` and `RollAdjust` were issued **11 Aug 2026**. That seam is where these
sit. All are new to this document unless marked.

| # | Requirement | Schema state | Register |
|---|---|---|---|
| **B1** | `FR-345` "assigned skid **and slot**"; `FR-347` both slots with their alphas and weights | `SkidId`, `SkidStatus`, `StagingLocation` exist — **no slot / position-on-skid column**, so 1-of-2 vs 2-of-2 is unrecordable | `[NEW]` |
| **B2** | `FR-351` "mark both coil labels confirmed"; [`OutputCoilCompletion.md`](../Business/Screens/OutputCoilCompletion.md) §7.3 "a reprint **is recorded**, so that two labels bearing one alpha can be explained" | No `LabelPrintedAt`, no confirmation flag, no reprint audit anywhere | `[NEW]` |
| **B3** | `S-18`–`S-24` — the operator chooses which weight is recorded; an overridden completion is "**marked on the record** — flag, authorising supervisor, reason, both weights and the variance" | `NetWeightOverrideLb` and `ScaleWeightLb` exist, so the three figures are representable — but there is **no `WeightBasis`** (calculated vs scale) and **no approval stamp**. `S-19` makes the basis govern the record, the label and everything downstream | `[NEW]` |
| **B4** | `FR-212` / [`RollAdjust.md`](../Business/Screens/RollAdjust.md) §8 — applying is an operator action, **reverting is Operations Manager only** | `RollOverride` has **no revert columns** (`IsReverted` / `RevertedBy` / `RevertedAt` / reason). A reverted override is indistinguishable from one still in force | endpoint gap is `OI-32`; the **column** gap is `[NEW]` |
| **B5** | [`WipRejection.md`](../Business/Screens/WipRejection.md) §6 audit record — "**triggering event**: the checkpoint, pause or inspection that led here"; §2.2 the failing measurement is carried in | No `SpcCheckpointId`, no `RunPauseEventId`, no trigger-source column. `MeasuredValue`/`TargetMin`/`TargetMax` carry the numbers but not the measurement name or the signed deviation, so "the rejection and the checkpoint cannot disagree" is unenforceable | `[NEW]`, adjacent to `OI-18` |
| **B6** | `RollAdjust` §7.1 — readings are written as a `RollAdjustTrigger` checkpoint, and **no second checkpoint is required** | `SpcCheckpoint.CheckpointType` has the value, but there is no link in either direction between `RollOverride` and the checkpoint it produced | `[NEW]`, adjacent to `OI-18` |
| **B7** | [`SpoolCompletionNotification.md`](../Business/Screens/SpoolCompletionNotification.md) §4.3 state machine (`Idle→Armed→Pending→Completing/Declined`) and `S-12` "both outcomes are audited: prompt raised (stop timestamp, latched weight), the answer, the answering operator, the answer timestamp" | **Nothing.** `Spool` carries `ReceivedAt` and `StagedAt` only — no `CompletedAt`, no latched weight, no prompt/decline audit. `S-9` makes the pending prompt server-owned state that survives a refresh, which requires persistence | `[NEW]` |
| **B8** | §5 short close — an unplanned-stop reason code, grading against the customer min–max weight, supervisor override plus production hold | No columns. `Q18` (the customer weight range) is open, but the reason code and the override evidence are independent of it | `[NEW]` |
| **B9** | `WipRejection` §3.1 — a `[CONFIRMED]` vocabulary of 17 reasons across 5 groups | `RejectionGroup` has a CHECK; `RejectionReason` is unconstrained `varchar(50)`, unlike `RollOverride.ReasonCode` and `DieChangeEvent.ReasonCode` which both carry CHECKs | `[NEW]` |

---

## Class C — Referential integrity inside FlatWireDB

### C1. `AlloyProperty` is orphaned in MVP-1 `[NEW]`

Its only child was `PassSchedule.Alloy`, which left with MVP-2. `Rod.Alloy` and
`FlatWireRun.Alloy` are free `varchar(10)` with **no FK**, so the per-alloy tolerance lookup that
`CHK007` / `FR-065` depend on can silently find no row — on a rod whose alloy is a typo, at
check-in, with no error. The table is described in both the DDL and the schema doc as "the
**authoritative** alloy list", which is no longer enforced by anything. Compounds `OI-93`
(`AlloyProperty` shadows `united_db..alloys`).

### C2. Payoff-position FKs are inconsistent `[NEW]`

`RodStaging.PayoffPosition` and `FlatWireRunDetail.PayoffPositionId` have real FKs to
`PayoffPosition`. `RodCheckin`, `SpoolCheckin`, `RodCheckout` and `WeldEvent` (both
`OutgoingPayoffPosition` and `IncomingPayoffPosition`) carry the same value with a `CHECK (1,2)`
and no FK. One value, two enforcement models, in one script.

### C3. `DieChangeEvent` has no `DrawerId` FK `[OI-41]`

Flagged in the DDL's own comment at
[`FlatWire_DDL_01_Lookup.sql:71`](Schema/SQL/FlatWire_DDL_01_Lookup.sql#L71). The event names its
dies by `OldDieSizeIn` / `NewDieSizeIn` decimals, so **no run event can attribute footage to a
`Drawer` row** — meaning `Drawer.LastGrindingFeet` and `TotalFeetAllowed`, added 6 Aug to give
die life its first home, can only ever be maintained by hand.

### C4. `ComponentName` is a CHECK string, not a reference `[NEW]`

`RollOverride.ComponentName` (and `PassScheduleComponent.ComponentName` in MVP-2) enumerate
`DB1, DB2, FM1, EdgeSet, FM2_S1, FM2_S2, FM2_S3` in a CHECK rather than referencing `Stand` /
`Drawer` / `Edger`. Adding or re-rolling a stand is a DDL change in two scopes — which is the
same coupling the 4 Aug position-only rename was meant to remove.

### C5. `PassScheduleId NOT NULL` asserts what MVP-1 cannot verify `[open in phase-01c]`

It is `NOT NULL` on `FlatWireRun`, `RodCheckin` and `SpoolCheckin`, and nullable on `CoilOutput`.
`phase-01c` raises this explicitly — *"leaving it is defensible … relaxing it is also
defensible. **Decide once and record it here**"* — and it is still undecided. Left as it is, the
first check-in against a schedule the external track has not published fails on a constraint
rather than on a validation message.

---

## Class D — Semantic gaps that will produce wrong answers

### D1. The asymmetric-tolerance decision was applied to one table only `[NEW — proposed G37]`

**This is a correctness defect, not drift, and it appears in no register.**

The 30 Jul 2026 client decision (`Q22`) replaced single-± tolerances with four min/max pairs, and
[`FlatWireSchema_Lookup.md`](Schema/FlatWireSchema_Lookup.md) records the reason: an asymmetric
band must be expressible as `nominal − Minus .. nominal + Plus`. `AlloyProperty` implements it.
`SpcMeasurement` does not:

```sql
[ToleranceValue] DECIMAL(8,4) NOT NULL,   -- ± tolerance band
[InSpec] AS (CASE WHEN ABS([ActualValue] - [TargetValue]) <= [ToleranceValue]
             THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END) PERSISTED
```

`ABS(actual − target) <= tolerance` **cannot represent an asymmetric band**. Every SPC evaluation
therefore silently re-symmetrises the tolerances the client confirmed, and because `InSpec` is
`PERSISTED` the wrong answer is stored, not merely computed. `SpcCheckpoint.AllInSpec`,
`CoilOutput.GaugeInSpec` / `WidthInSpec` and the §3.2 print-target-or-measured rule all descend
from it. `FlatWireRunDetail.GaugeTolerance` / `WidthTolerance` have the same single-± shape.

`WipRejection.TargetMin` / `TargetMax` is the correct pattern and is already in the schema — the
fix is to follow it.

### D2. `SpringbackFactor` is still documented as a material property `[master spec §10.5]`

The DDL and the schema doc both describe `AlloyProperty.SpringbackFactor` as a "roll-gap
springback multiplier". Master spec §10.5 has arbitrated this as **machine stiffness misfiled as
a material property** — the roll gap sits *below* gauge by a load-dependent mill-spring term, not
above it by a fixed alloy multiplier. The alloy reference table in `Analysis/` carries the flag;
these two artifacts do not. Generation is MVP-2, so the column is harmless where it stands — but
it is seeded with five values that will be read as authoritative.

---

## Class E — The documents contradict the build they describe

### E1. `FlatWire_ERDiagram_Documentation.md` is pre-MVP-split

This is the file the reader is told to open first — *"Read `SQL/FlatWire_ERDiagram_Documentation.md`
first — it describes the as-built schema."* It currently misdescribes the deploy in six ways:

| Statement | Actual |
|---|---|
| §2 documents `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` and the PassSchedule cascade as built here; no MVP-1 figure appears anywhere | All three are MVP-2; `RunAll` builds 25 of the 28 |
| Build/Run Order lists **`DDL_02`** and **`FlatWire_SampleData_Schedule.sql`** | Neither is in this folder |
| Lists **`sp_ShiftSummary`** as a DDL_08 read proc | `08` carries a 12-line comment explaining why it must never create, drop or grant on it |
| Lists **`UX_PassSchedule_OneActivePerLineAlloy`** under "Implemented Indexes (DDL_07)" | Not present. MVP-1's two filtered-uniques are `UX_RodStaging_Bay` and `UX_RodStaging_RodActive` |
| "40 non-clustered + 1 filtered-unique" | **39 + 2** |
| Header says 28 tables; footer says "Table count unchanged at **27**" | 28 in the design, 25 built |

`Dancer` is also in the Lookup table but missing from the Build/Run Order appendix and from the
natural-unique-keys list (as is `PayoffPosition.Code`).

### E2. `FlatWireSchema_Mapping.md` inventory is incomplete and its FK total is misattributed

- **`RodStaging` and `PayoffPosition` are absent from the Table Inventory entirely.** Both are
  MVP-1 tables; `RodStaging` is the newest one in the design.
- "**Total: 25 tables**" is wrong twice over: the *New Tables* heading says 16 while the
  arithmetic uses 15, and `7 + 16 + 3 = 26` — plus the two missing rows gives the real **28**.
- "**43 FK constraints** as built … added in `FlatWire_DDL_06_ForeignKeys.sql`" — 43 is the full
  design (33 here + MVP-2's 10). This script builds 33.
- The FK reference table lists the ten MVP-2 `PassSchedule` FKs with no scope marker, so a reader
  implementing from it will expect constraints that cannot exist.
- `RodCheckout` is still described as "(Mode A and B)" — **Mode P** is missing.
- The Enumeration Reference omits `RodStaging.Status` / `UnstageKind`, `RodCheckout.Mode`,
  `WipRejection.RejectionGroup` / `Disposition`, `RunPauseEvent.Outcome`, `MmsStatus`,
  `SkidStatus` and all three `Dancer` vocabularies.

### E3. Stale DDL and seed-script headers

| File | Stale statement |
|---|---|
| `01_Lookup` | "Tables:" list omits **`Dancer`**, which it creates |
| `03_Materials`, `04_Runs`, `05_QualityOutput` | all three declare "Dependencies: … **`02_Schedule` (PassSchedule)**" |
| `07_Indexes` | header claims it "**Includes the filtered-unique rule enforcing ONE Active PassSchedule per (LineId, Alloy)**" — it does not |
| `SampleData_Lookup` | "Tables:" omits `Dancer`; run order says "**BEFORE `FlatWire_SampleData_Schedule`**"; explains `AlloyProperty` as the FK target of `PassSchedule.Alloy` |
| `SampleData_Materials` | "Run order: after DDL 06, and after Lookup **+ Schedule** seeds" |

### E4. `PassScheduleId` column comments contradict `RunAll`

Every declaration in `03`, `04` and `05` reads `-- FK → PassSchedule.ScheduleId`, while
`RunAll`'s header spends thirteen lines insisting it is a **documented external reference with no
local FK**, in the same class as `PlanId` and `SkidId`. The comment is what a developer reads
first.

### E5. `Dancer` uses a deprecated existence guard

`IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Dancer' AND xtype = 'U')` — every other
table in the folder uses `sys.objects` with `OBJECT_ID(N'[dbo].[…]')`, which is also
schema-qualified where `sysobjects` is not.

### E6. The table count is stated four different ways

Actual MVP-1 is **25**. `phase-01c` says 24 (§*Target database*, §*Data-access wiring*), 25
(§*Verified*, and both acceptance lists) and 28 (the 30 Jul call note) — in one document. The
root `CLAUDE.md` says "verified … **24** tables" while stating 25 MVP-1 / 28 full elsewhere. The
ER documentation footer says **27**.

### E7. The documented deployment path no longer exists

The root `CLAUDE.md` deployment block still reads
`cd "c:\UAL\Flatwire-planning\LatestDocument\DBChanges\Schema\SQL"`. The folder moved to
`MVP-1\DBChanges\Schema\SQL` on 11 Aug 2026. `RunAll`'s own header carries the correct path.

---

## Register status

| Finding | Already registered as | Action |
|---|---|---|
| A2, A3, A4, A6 | `OI-104`, `OI-24`/`OI-99`, `OI-22`/`OI-100`, and the §6.9 set · `G36` | none — cited, not re-raised |
| C3, C5, D2 | `OI-41`, `phase-01c` open decision, master spec §10.5 | none |
| **A1** | — | **Register.** Proposed `OI-107` — the FW-001/FW-002 migration has no artifact against a 14 Aug gate |
| **A5** | — | **Register.** Proposed `OI-108` — `FR-075`'s per-write audit log has no named sink |
| **D1** | — | **Register as a gap.** Proposed `G37` — the asymmetric-tolerance decision reached `AlloyProperty` only, and `SpcMeasurement.InSpec` stores the symmetrised answer |
| **B1, B2, B3, B4, B5, B6, B7, B8, B9** | — | **Register.** Nine decided requirements with no column to land in — the same class of defect as `G24`, which was found and fixed on `RodCheckout` on 1 Aug 2026 |
| **C1, C2, C4** | — | **Register** as a single integrity item, or fix directly in `06_ForeignKeys` |
| **E1–E7** | — | Documentation correction, no register entry needed |

---

## Recommended sequence

1. **A1 — write the FW-001/FW-002 migration script.** It is Critical, it gates FW-002 and
   FW-004–007, and the Phase-1 gate is 14 Aug 2026. It is the only Phase-1C deliverable with no
   artifact at all.
2. **D1 — fix the tolerance model.** It silently stores wrong pass/fail results, it is
   unregistered, and the correct pattern already exists in the same script.
3. **B3 and B4 — add the `CoilOutput` weight-basis and approval columns, and the `RollOverride`
   revert columns.** Both are decided requirements with nowhere to be recorded, and both are
   cheap now and retro-enforcing later (adding `RodCheckout`'s approval stamp on 1 Aug broke an
   existing sample row, which is the gap demonstrating itself).
4. **E1 and E2 — reissue the ER documentation and the Mapping document** against 25 / 33 / 41 /
   1 / 1. The ER document is the designated first read.
5. **Register the `[NEW]` findings** so they stop being rediscovered, then disposition B1, B2,
   B5–B9 and C1, C2, C4 against Phase 9, Phase 6 and Phase 1C respectively.

---

## Checked and found sound — do not re-raise

| Area | Verified |
|---|---|
| MVP split mechanics | No MVP-1 script references an MVP-2 object; `RunAll` skips `02` deliberately and documents why; `08` refuses to create, drop or grant on `sp_ShiftSummary` |
| Idempotency | Every `CREATE` / FK / index is guarded; teardown is scope-agnostic |
| Sample data | All 25 tables seeded, in dependency order, with computed columns and `ROWVERSION` correctly omitted; `PayoffPosition` seeded from the DDL because the FK needs the rows |
| FM2 three-stand model | `Stand`, `RollOverride.CK_..._Component`, the seed and all five schema documents carry `FM2_S1/S2/S3` with diameter in `RollDiameterIn`. The only `FM2_8in` strings left are in old→new mapping notes, which is their purpose |
| `RodStaging` invariants | Two filtered-unique indexes genuinely enforce one-rod-per-bay and one-bay-per-rod; the all-or-nothing stamps use `ISNULL`/explicit `IS NOT NULL` pairs, having been corrected for CHECK-accepts-UNKNOWN |
| `CoilTraceability.SpoolAlpha` | Correctly placed on the footage-range row rather than on `CoilOutput`, nullable, FK-constrained only when present, filtered index to match |
| `RodCheckout` approvals | `G24` is genuinely closed — Mode B and welded Mode P both retro-enforced at the database |
