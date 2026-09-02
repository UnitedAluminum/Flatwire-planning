# Client e-mail — 31 August 2026 — Machines Application tabs for the flattening lines

**Source:** `RE: New Flat Wire Machine : Impact on .Net Applications` — Tim O'Brien (UA) to Ashwani
Tandon, Ritika Raheja, Srikanth Prabhala, Bob Scott, Shannon Riotte; cc DG UA DEV.
**Sent:** Mon 31 Aug 2026 19:06 UTC. **Analysed:** 1–2 Sep 2026.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and tasks named in §5.

---

## 1. What this closes

The 24 Aug call ledger — [`ClientCall_2026-08-24_SyncPlan.md`](ClientCall_2026-08-24_SyncPlan.md)
§6 row 4 — carries open action **`A12`**: *"Tim's e-mail on the four Planning tabs and the Speed
tab's unexplained block"*, owner Tim O., blocking *"Ashwani's Planning build, in progress now"*.

**This is `A12` arriving, seven days later — and it closes three of its four legs.**

| Leg owed by `A12` | Status |
|---|---|
| Flattening Line Schedule column set | ✅ answered, per line |
| Setup / Handling Times tab | ✅ answered, per line |
| Material Loss tab | ✅ answered, per line |
| **Speed tab** — columns beyond the slitter's, the DB1/DB2 checkboxes, the uninterpretable block | ⛔ **not mentioned at all** |
| *(not owed — volunteered)* Tooling Inventory | ✅ answered, and goes beyond the call's `D3` |

**`A12` stays open on the Speed tab leg.** Do not mark it closed.

⚠ **The substance is not in the message text.** Tim's answers are one-line acknowledgements
(*"Please include the fields pictured below, in the order pictured, all others will be removed"*)
followed by **12 embedded mockup images**, which the plain-text body renders as blank placeholders.
All 17 attachments were extracted and read; §3 is the transcription. See §7 for the file list.

---

## 2. Answers given in the message text

| # | Tim's words |
|---|---|
| 1 | *"Yes, the Qualify Pass Schedule tab should be available for Flat Wire."* |
| 1, 2, 4 | *"This will be different for FL1 & FL2/FL3 as each machine has its own capabilities"* — stated verbatim on **three** of the four tabs |
| 3 | *"They should be replaced with Dies, Edgers, & Straighteners."* — **three** tool types |
| 3 | *"Dies will have fixed measurement, Edgers will have multiple gauge capability, i.e. (.045,.040,.035), being that they have multiple grooves cut into them at specific gauges. Straighteners will have a diameter max/min range, i.e. (.375 - .184) being that they are V-groove and can compensate any diameter within the min/max range."* |

> ⚠ **"Replaced" means replaced *in the Flat Wire copy*.** The Slitter and Mill screens are
> **reference points** — Ashwani copies them to build the equivalent Flat Wire tab, then adjusts
> the copy. Tim's *"all others will be removed"* removes nothing from the Slitter's or Mill's own
> screens. The distinction decides `D8` on the WIP-stations script — see §4.7.

---

## 3. The four field sets, as pictured

### 3.1 Flattening Line Schedule

Filter panel, all lines: `Alloy · Width Range · Start Gauge · Target Gauge · Anneal Gauge`
Header row: `Alloy · Start Dia./Ga. · Target Dia./Ga. · Anneal Gauge · Width Range`

Detail grid, **FL1**: `Component · Operation · Entry Dia./Ga · Target Dia./Ga. · Target Width · Reduction · Target Speed`
Detail grid, **FL2 / FL3**: the same **plus `Entry Width`**.

| Line | Component rows, in processing order |
|---|---|
| FL1 | `D1` DRAW · `D2` DRAW · `FL1-S1` FLAT |
| FL2 | `FL2-S1` FLAT · `E1` EDGE · `FL2-S2` FLAT · `E2` EDGE · `FL2-S3` FLAT |
| FL3 | FL1's three rows then FL2's five — the hybrid is a concatenation |

Operation vocabulary: `DRAW` · `FLAT` · `EDGE`.

**This is the pass schedule.** One row per physical component, in sequence — the shape of
`PassScheduleComponent`. The Mill layout it was copied from is pass-numbered
(`Pass No · Entry/Exit Tension · Fwd Slip · Min/Max Entry Flow · Oil Peak Speed`), and none of that
survives into the Flat Wire grid. `Coil Start Position` and `Total Passes` do not appear.

⚠ The header cell reads **`Annela Gauge`** in all three mockups — a typo; the filter label above it
spells *Anneal* correctly.

### 3.2 Setup / Handling Times — seven categories

| Code | Slitter (the reference) | Flat Wire |
|---|---|---|
| S1 | Setup Before 1st SPC | **Setup Before Run** |
| H1A | Handling Before SPC | **Handling Before Reduction** |
| H1AA | Handling After Loading Payoff/Before Running Machine | *unchanged* |
| R | Slitter Run | **Flattening Line Run** |
| H1B | Handling After Running Stop | *unchanged* |
| S2 | Setup Time Between Stops | *unchanged* |
| H2 | Handling After Removing Stop From **Rewind** | Handling After Removing Stop From **Takeup** |

**FL1** — S1: Lower Payoff: VPS · Raise Payoff: VPS · Die Change: DB1/DB2 · Fill Die Lubricant:
DB1/DB2 · Set Wire Straightener · Straightener Roll Change · Open Stand Rolls · Close Stand Rolls ·
Jog Capstan: DB1 · Jog Capstan: DB2 · Jog: FL1-Stand 1 · Load Spool: Takeup-1 ·
H1A: Load & Prep Bundle: VPS · SPC - Payoff: VPS · Weld/Anneal Rod Ends: VPS · Thread Payoff: VPS ·
H1AA: Pull Point wire Rod: DB1 · Thread Capstan: DB1 · SPC: DB1 · Pull Point wire Rod: DB2 ·
Thread Capstan: DB2 · SPC: DB2 · Thread: FL1-Stand 1 · Thread: Takeup-1 · SPC: Takeup-1 · Torch
Test · Conductivity · R: Run · H1B: Cut and secure coil end · SPC: FL1-Stand 1 · Remove Spool:
Takeup-1 · Thread: Takeup-1 · S2: Load Spool: Takeup-1 · **H2: empty**

**FL2** — S1: Rotate Payoff: TPO · Open Stand Rolls · Close Stand Rolls · Jog: FL2-Stand 1/2/3 ·
Set: Edger-1 · Set: Edger-2 · Open Edgers · Close Edgers · Edger Roll Change · H1A: Load & Prep
Spool: TPO · SPC - Payoff: TPO · H1AA: Thread: FL2-Stand 1/2/3 · Thread Takeup: Takeup-2 · SPC:
Takeup-2 · Torch Test · Conductivity · R: Run · H1B: Cut and secure coil end · SPC: Takeup-2 ·
Band ID/OD x 4 · Collapse Mandrel · Push Off Stop · S2: Expand Mandrel · H2: Stop to Skid · Band Skid

**FL3** — the union, minus FL1's intermediate-spool steps (no *Remove Spool: Takeup-1*, no *Load
Spool: Takeup-1*, no *Thread: Takeup-1*); S2 is *Expand Mandrel*.

⚠ **FL3 still lists `SPC: Takeup-1` under H1AA** although every other Takeup-1 step was dropped for
FL3. With no intermediate spool there is nothing at Takeup-1 to measure. Almost certainly a
leftover — raised with the client.

Header note carried from the Slitter reference: *"All Standard time should be entered in minutes"*,
plus a **Crew Size** selector.

### 3.3 Tooling Inventory — three tool types

The five options inherited from the Slitter copy — `Knives · Separator · Shim · Spacer · Stripper` —
do not appear on the Flat Wire tab.

| Tool | Columns, in order |
|---|---|
| **Die** | Machine Name · S/N · P/N · Type · Location · ID(") · ID(MM) · Max Imput Dia. · Pitch · Max ID(") · Lubrication Type · In Use |
| **Edger** | Machine Name · Type · Location · Set Number · P/N · Roll Qty · STD Removal From OD(") · Gauge Range(") · OD(") · ID(") · Min OD(") · Date of Change · Date of Last Grind · Status |
| **Straightener** | Machine Name · Type · Location · Set Number · Roll Qty · Min Dia. · Max Dia. · OD(") · ID(") · P/N · Status |

Sample rows answer several standing questions:

- **Line attribution** — dies `Machine Name = FL1`, edgers `FL2`, straighteners `FL1`.
  **No FL3 row appears in any of the three grids.**
- **Edger `Gauge Range` is multi-valued in one cell** — `.045, .040, .035`; three grooves on one roll.
- **Status vocabulary** — `Active` · `In Service` · `In Grinding`. Three values, not a boolean.
- Straightener `Roll Qty = 10`; edger `Roll Qty = 2`; sets lettered `A` / `B` / `C`.
- Die `ID(MM)` is a **derived** display value — `0.343 × 25.4 = 8.712`, shown as `8,700` with a
  comma decimal separator.

⚠ **Tim's prose and his grid disagree on the straightener range.** The text says *"(.375 - .184)"*;
the grid's set A reads **Min Dia. `0.134`, Max `0.375`**. `.184` against `.134` — one digit.

### 3.4 Material Loss — per line

None of the ~36 sleeve/pass scenarios inherited from the Mill copy appear on the Flat Wire tab.

| Line | Fields, all mandatory |
|---|---|
| **FL1** | Threading Drawblock #1 · #2 · Threading FL1-Stand #1 · Die Change Drawingblock #1 · #2 · Straightener Roll Change · Pass Change (Alloy, Rod Dia., Mech Properties, Output Size) |
| **FL2** | OD Buildup Loss Previous Oper Furnace / Flatten / Other · Edger #1 Roll Change · Edger #2 Roll Change · Pass Change (Alloy, Input Ga/Width, Mech Properties, Output Size) · Threading FL2-Stand #1 · #2 · #3 |
| **FL3** | FL1's seven, then FL2's edger and threading rows — no OD Buildup rows |

⚠ **FL1's footer reads `(Values in footage (')`. FL2's and FL3's do not.** The repo asserts footage
for the whole tab (`FW-100` acceptance criteria, `[TB]`).

---

## 4. What this changes in the repository

### 4.1 The Flattening Line Schedule **is** the Pass Schedule — `OI-110`'s owner is named

`D-13` records `FlatLineSetup` → `PassScheduleComponent`; `[MSP §1473]` repeats it; the DDL's
`SetupNo` column is *"legacy setup number carried over from `FlatLineSetup`"*; `FW-003` says the tab
**was** the Mill template's *Pass Schedule* tab with only the button renamed. And the source
workbook's sheet is named **`FlatLinePassSchedule`** outright.

So the *"owning track"* `OI-110` has referred to anonymously since 15 Aug is **Ashwani's build in
`ual-dot-net`**.

⛔ **`OI-110` does not close.** Its question is not *who authors* but *where it lands*: *"it needs the
owning track to confirm it is writing to `FlatWireDB` rather than exposing an API, because `D-31`
has already committed the schema to that shape."* **The mail never names a database.** `D-31` made
`PassScheduleId` a real enforced FK on `FlatWireRun`, `RodCheckin`, `SpoolCheckin` and `CoilOutput`,
so empty schedule tables mean check-in cannot run in production — and the trial will not catch it.

### 4.2 It answers three of `FlatWire_DDL_02_Schedule.sql`'s six OPEN POINTS

That script is **v1.1, 27 Aug, "ISSUED FOR CLIENT REVIEW"**; this mail is four days later and reads
as partial review feedback on it.

| OPEN POINT | Answer |
|---|---|
| **1** — who populates these tables | **Half.** System named (§4.1); write target still open |
| **2** — change reason codes complete? | untouched |
| **3** — may an FL2 schedule mark FM1 not-applicable? | **Answered, and the premise is wrong** — §4.3 |
| **4a** — FL1 has no edger, yet an FL1 schedule may carry an Active `EdgeSet` | ✅ **Closed.** FL1's schedule is `D1 · D2 · FL1-S1`. No edger row |
| **4b** — are FM2's two edgers set together or separately? | ✅ **Separately** — `E1` `0.749→0.740`, `E2` `0.746→0.743` |
| **5** — one Active schedule per line and alloy | **Challenged** — §4.4 |
| **6** — what identifier is `ActiveJobId`? | untouched |

### 4.3 OPEN POINT 3 misreads its own constraint

`CK_PSC_FM1NotBypassable` is `CHECK ([ComponentName] <> 'FM1' OR [State] = 'Active')` — **row-level**.
With no FM1 row present nothing is violated, and nothing requires one. An FL2 schedule of five rows
is already legal. The real conflict is with `State = 'Skip'` (*"not part of this schedule at all"*),
which invites an FM1/`Skip` row that the constraint rejects.

**The mail settles the model:** a schedule lists only the components in that line's material path —
FL1 three rows, FL2 five, FL3 eight. **Omission, not `Skip`.** Which raises a question the script
does not ask: *if components are omitted rather than skipped, what is `Skip` for?*

### 4.4 OPEN POINT 5's one-Active-per-line-alloy rule looks wrong

`UX_PassSchedule_OneActivePerLineAlloy` permits one Active schedule per `LineId` + `Alloy`. Tim's
filter offers **Alloy · Width Range · Start Gauge · Target Gauge · Anneal Gauge** — four dimensions
beyond alloy, which only makes sense if many Active schedules share a line and alloy. **Do not
confirm that `[PROPOSED]` rule.**

### 4.5 Columns the schedule tables do not carry

`PassScheduleComponent` has no `Operation`, `EntryWidth`, `TargetWidth`, `Reduction` or
`TargetSpeed` — all five are on Tim's grid, and the edger rows exist *to change width*.
`PassSchedule` has **no anneal-gauge column**; `Width Range` is a min/max against
`TargetWidth` + `WidthTolerance` (an asymmetric range cannot be stored); `Target Speed` is
per-component for Tim and per-header in the DDL. `Status` is `Draft | Active | Inactive` with **no
qualified state**, yet Tim confirms a *Qualify Pass Schedule* button.

⚠ **`ParameterValue` — the set-point — is not on Tim's screen.** The DDL defines it as die hole
diameter / roll gap / edger clearance and pushes the PLC tag set *from this schedule*. His grid
shows dimensional outcomes only. Either it is derived, or it lives in the unpictured Edit dialog,
or the push has no source.

⚠ **Edge-type vocabulary conflict.** `CK_PSC_EdgeType` and `CK_Edger_EdgeType` allow
**`Round` / `Square`**; the Web Changes document puts Edge Type on the *order* with **Round Edge /
Flat Edge**. `Flat` is not `Square`.

### 4.6 Tooling — three types, and one of them does not exist here

The 24 Aug call's `D3` recorded the dropdown changing *"for dies and edgers / edging rolls only"*.
**It is three.** `FW-003`'s acceptance criterion carried the same two.

⚠ **`Straightener` appears nowhere in this repository** — zero matches across every file type. The
mail establishes it on three surfaces at once: a Tooling Inventory type, two FL1/FL3 setup elements,
and an FL1/FL3 Material Loss field.

`Drawer` and `Edger` are both short of Tim's model, and `Drawer` is short in a structural way: it is
a catalogue of die **sizes** (13 rows, `DIE-0210` = 0.2100") while Tim's grid is a register of
physical **dies** with serials. See the die-split plan, which restructures `Drawer` to the two draw
boxes and adds `ToolingInventoryDie`.

### 4.7 Evidence against `machine_type = 1`

`10_CommonDB_Insert_WIPStations_FlatWire.sql` `D8` is *"THE OPEN ITEM ON THIS SCRIPT"* and leaves
both sides balanced. The mail is evidence **against** type 1: the Flat Wire field sets are disjoint
from both parents, and Tim says the tabs differ **between FL1 and FL2/FL3**, which no single
inherited mill type expresses. ⚠ Whether tab configuration is actually keyed on `machine_type` is
**not verified** — `ual-dot-net` was not read. `D8` stays open; this is evidence for it, not a
decision.

### 4.8 Component identifiers are named four ways

| Thing | Repo schema | `FW-003` AC | Line Schedule | Setup Handling |
|---|---|---|---|---|
| Drawing dies | `DB1` / `DB2` | `DB1` / `DB2` | `D1` / `D2` | `DB1` / `DB2` |
| FM1 stand | `FM1` | `FM1-S1` | `FL1-S1` | `FL1-Stand 1` |
| FM2 stands | `FM2_S1/S2/S3` | `FM2-S1/S2/S3` | `FL2-S1/S2/S3` | `FL2-Stand 1/2/3` |
| Edgers | `EdgeSet` (one) | — | `E1` / `E2` | `Edger-1` / `Edger-2` |

**Two of the four are ours.** A fifth spelling sits on Material Loss: *Drawblock* beside
*Drawingblock*, four rows apart. ⚠ **Do not reconcile yet** — the `FW-003` strings are Speed-tab
labels and the Speed tab is the leg still owed. One pass, after it lands.

### 4.9 `PayoffPosition` does not carry `TPO`

`CK_PayoffPosition_Equip` allows `VPS | TraversingTakeup`. FL1/FL3 use **`VPS`** — clean. **FL2 uses
`TPO`**, in neither CHECK. And the lists distinguish `Takeup-1` from `Takeup-2` where the lookup has
one `TraversingTakeup` row.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`Decisions.md`](../../90-registers/Decisions.md) | Tooling Inventory carries exactly **three** tool types — supersedes the 24 Aug `D3`'s two |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | `OI-110` updated — owning track **named**, **stays open** · `OI-31` re-examined · new `OI` for the Die Management ↔ Tooling Inventory field conflict |
| [`Gaps.md`](../../90-registers/Gaps.md) | Two `EdgeSet` positions · `PayoffPosition`/`TPO` · edge-type `Square` vs `Flat` · edger and straightener inventory |
| [`FW-003.md`](../../50-frontend/tasks/FW-003.md) + [`TaskBreakdown.md`](../../60-delivery/TaskBreakdown.md) | *"Dies and Edgers"* → **three** tool types; per-line configuration |
| `FlatWire_DDL_02_Schedule.sql` | OPEN POINT 4a closed · OPEN POINT 3 corrected · OPEN POINT 5 reopened |

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The Speed tab** — the fourth `A12` leg | Blocks Ashwani's build today |
| 2 | ⛔ **Which database the Flattening Line Schedule saves to** | `OI-110`; a pre-production blocker the trial cannot surface |
| 3 | What *Qualify* sets, and whether an unqualified schedule is usable at check-in | No qualified state exists in `CK_PassSchedule_Status` |
| 4 | How many schedules may be Active at once for one line and alloy | Decides `UX_PassSchedule_OneActivePerLineAlloy` |
| 5 | Where the machine set-points come from | The PLC push has no visible source |
| 6 | `Round`/`Square` or `Round`/`Flat` for edge type | Two CHECK constraints against the order screen |
| 7 | One edger set or two independently scheduled positions | `CK_PSC_ComponentName` |
| 8 | Component naming — one canonical set | §4.8 |
| 9 | Straightener purpose; FL1/FL3-only, position, not-in-schedule — all read from the images, to confirm | `Straightener` has no home in the repo yet |
| 10 | Stand / Dancer / Spool — tooling or not; and whether FL3 holds its own tooling | No FL3 row appears in any grid |
| 11 | Material Loss units on FL2/FL3; edger `Gauge Range` semantics; the `.134`/`.184` discrepancy; FL3's stray `SPC: Takeup-1` | |

---

## 7. Attachments

17 in total; **12 carry the field sets**. Extracted and read in full.

| File | Content |
|---|---|
| `image001–004.png` | Ashwani's **"before"** screens — Line Schedule (Mill copy), Setup/Handling (Slitter copy), Tooling Inventory (Slitter copy, 5 options), Material Loss (Mill copy) |
| `image015–017.jpg` | Flattening Line Schedule — FL1 · FL2 · FL3 |
| `image021–023.jpg` | Setup / Handling Times — FL1 · FL2 · FL3 |
| `image024–026.jpg` | Tooling Inventory — Die · Edger · Straightener |
| `image027–029.jpg` | Material Loss — FL1 · FL2 · FL3 |
| `image005.png` | Sender signature graphic — not content |

⚠ `image018`–`image020` are absent from the message; the numbering jumps `017 → 021`. Nothing in the
body text appears to be missing as a result, but confirm in Outlook before treating the
transcription as complete.

---

## Related Documents

| Document | Why |
|---|---|
| [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) | Raises `A12`, which this mail partly closes; its `D2` and `D3` are corroborated and corrected here |
| [FlatWire_DDL_02_Schedule.sql](../../30-database/sql/FlatWire_DDL_02_Schedule.sql) | Three of its six OPEN POINTS are answered — §4.2 |
| [MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `OI-110`, `OI-31` and the Die Management requirements `FR-240`–`FR-255` |
| [FW-003.md](../../50-frontend/tasks/FW-003.md) | The machine-template story this corrects |
| [10_CommonDB_Insert_WIPStations_FlatWire.sql](../../30-database/scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql) | `D8`, the `machine_type` open item — §4.7 |
