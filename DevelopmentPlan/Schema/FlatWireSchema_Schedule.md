# Flat Wire Mill — Pass Schedule Tables

**Project:** Flat Wire Mill Implementation
**Last Updated:** July 26, 2026
**Document Type:** Final Schema — Pass Schedule Tables
**Source:** Derived from `FlatWireTables.md` recommendations
**Target DB:** `FlatWireDB` (schema `dbo`) — DDL: `SQL/FlatWire_DDL_02_Schedule.sql`

Pass schedules define the complete tooling configuration and dimensional targets for a flat wire production run. A schedule header (`PassSchedule`) specifies alloy, line, targets, and speed ranges. Its component rows (`PassScheduleComponent`) define each tool station in the pass sequence.

---

## `PassSchedule`

Header record for a pass schedule. One schedule can be used across many runs. Schedules progress through Draft → Active → Inactive. Only `Active` schedules may be selected at run check-in.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `ScheduleId` | varchar(30) | NOT NULL | — | Human-readable primary key; recommended format `PS-{Alloy}-{Line}-{Seq}` (e.g. `PS-1100-FL1-003`) |
| `Description` | varchar(200) | NULL | — | Free-text description for operator reference |
| `Alloy` | varchar(10) | NOT NULL | `AlloyProperty.Alloy` | Aluminum alloy designation (e.g. `1100`, `3003`, `1350`); FK to the authoritative alloy list |
| `LineId` | varchar(5) | NOT NULL | — | Target flat wire line: `FL1`, `FL2`, or `FL3` |
| `RouteMode` | varchar(15) | NOT NULL | — | `Standalone` = single-line processing; `Hybrid` = FL1 produces spools that feed FL2 or FL3 |
| `Status` | varchar(10) | NOT NULL | — | Lifecycle state: `Draft` = in progress; `Active` = approved for production; `Inactive` = retired |
| `TargetGauge` | decimal(8,4) | NOT NULL | — | Target output gauge in inches |
| `GaugeTolerance` | decimal(8,4) | NOT NULL | — | Acceptable gauge deviation (±) in inches |
| `TargetWidth` | decimal(8,4) | NOT NULL | — | Target output width in inches |
| `WidthTolerance` | decimal(8,4) | NOT NULL | — | Acceptable width deviation (±) in inches |
| `InputRodDiameterIn` | decimal(8,4) | NULL | — | Expected input rod diameter in inches (e.g. `0.375`); used for schedule generation and rod check-in validation |
| `InputTemper` | varchar(10) | NULL | — | Rod temper designation (e.g. `H19`, `H14`, `H18`, `H34`, `T8`) |
| `InputCondition` | varchar(50) | NULL | — | Rod condition description (e.g. `Hard drawn`, `Strain hardened`, `Solution treated`) |
| `LineSpeedMinFpm` | int | NOT NULL | — | Minimum operating line speed in feet per minute |
| `LineSpeedMaxFpm` | int | NOT NULL | — | Maximum operating line speed in feet per minute |
| `ActiveJobId` | varchar(20) | NULL | — | Order/job currently using this schedule ("in-use" chip); NULL when idle |
| `CreatedBy` | varchar(50) | NOT NULL | — | User ID of the person who created this schedule |
| `CreatedAt` | datetimeoffset | NOT NULL | — | Timestamp when this schedule was created |
| `ModifiedBy` | varchar(50) | NULL | — | User ID of the person who last modified this schedule; NULL if never modified |
| `ModifiedAt` | datetimeoffset | NULL | — | Timestamp of the last modification; NULL if never modified |
| `RowVersion` | rowversion | NOT NULL | — | Optimistic-concurrency token |

**Allowed values:**
- `RouteMode`: `Standalone`, `Hybrid`
- `Status`: `Draft`, `Active`, `Inactive`

**Constraints:**
- `LineSpeedMinFpm < LineSpeedMaxFpm`
- `GaugeTolerance > 0`, `WidthTolerance > 0`
- **Enforced:** filtered unique index `UX_PassSchedule_OneActivePerLineAlloy (LineId, Alloy) WHERE Status='Active'` — at most one `Active` schedule per line + alloy (DDL_07)

---

## `PassScheduleComponent`

*(Renamed and restructured from `FlatLineSetup`)*

Per-component rows belonging to a pass schedule. Each row defines one tool station in the pass sequence — its name, operating state, and parameter value (die size or roll gap). A full schedule has one row per component slot relevant to the line and route mode.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `PassScheduleId` | varchar(30) | NOT NULL | `PassSchedule.ScheduleId` | FK to the parent pass schedule |
| `ComponentName` | varchar(20) | NOT NULL | — | Named component slot — see allowed values |
| `State` | varchar(10) | NOT NULL | — | Operating state: `Active` = component is engaged; `Bypass` = component is present but bypassed in-line; `Skip` = component is not part of this schedule |
| `ParameterValue` | decimal(8,4) | NULL | — | Primary operating parameter — die diameter (inches) for draw boxes (DB1/DB2); roll gap (inches) for finishing mills (FM variants); NULL when `State` is `Bypass` or `Skip` |
| `EdgeType` | varchar(10) | NULL | — | Edge profile for edger components only: `Round` or `Square`; NULL for all other components |
| `Sequence` | int | NOT NULL | — | Processing order of this component within the pass schedule; unique per `PassScheduleId` |
| `IsMandatory` | bit | NOT NULL | — | UI lock: `1` = component cannot be toggled off in the editor; default `0` |
| `StandId` | int | NULL | `Stand.Id` | FK to the specific stand used — FM components only; NULL for DB and EdgeSet components |
| `DrawerId` | int | NULL | `Drawer.Id` | FK to the specific die used — DB components only; NULL for FM and EdgeSet components |
| `EdgerId` | int | NULL | `Edger.Id` | FK to the specific edger used — EdgeSet component only; NULL for all other components |
| `EntryGauge` | decimal(8,4) | NULL | — | Calculated entry gauge for this component in inches; informational only |
| `ExitGauge` | decimal(8,4) | NULL | — | Calculated exit gauge for this component in inches; informational only |
| `SetupNo` | varchar(20) | NULL | — | Legacy setup number from `FlatLineSetup`; retained for historical traceability |

**Allowed values — `ComponentName`:**

| Value | Type | Description |
|---|---|---|
| `DB1` | Draw box | First draw box — primary die reduction |
| `DB2` | Draw box | Second draw box — secondary die reduction |
| `FM1` | Finishing mill | First finishing mill stand |
| `EdgeSet` | Edger | Edge profile tooling station |
| `FM2_8in` | Finishing mill | FM2 with 8-inch roll (legacy; retained for pre-May-21 schedules) |
| `FM2_6inS1` | Finishing mill | FM2 6-inch stand S1 |
| `FM2_6inS2` | Finishing mill | FM2 6-inch stand S2 (edger position) |
| `FM2_6inS3` | Finishing mill | FM2 6-inch stand S3, final (edger position) |

> **May-21-2026 machine revision:** FL1 has no edger; FM2 is three 6" stands (S1/S2/S3) with edgers at **S2 and S3**. `FM2_6inS3` added; `FM2_8in` kept for legacy schedules.

**Allowed values — `State`:** `Active`, `Bypass`, `Skip`

**Allowed values — `EdgeType`:** `Round`, `Square` (edger components only; NULL otherwise)

**Constraints:**
- `ParameterValue` must be NULL when `State` is `Bypass` or `Skip`
- `EdgeType` must be non-null when `ComponentName = 'EdgeSet'` and `State = 'Active'`
- `Sequence` must be unique within a `PassScheduleId`
- `CK_PSC_FM1NotBypassable` — `FM1` must be `Active` (the 12" flattening mill is not bypassable)

---

## `PassScheduleChangeLog`

Immutable audit trail of every post-`Active` pass-schedule action — overrides, edits, and check-in acknowledgments (who / when / old→new / reason). Satisfies OQ-28 and the Dashboard 9 "Change History" tabs. One row per change.

| Column | Data Type | Nullable | FK Reference | Description |
|---|---|---|---|---|
| `Id` | int | NOT NULL | — | Surrogate primary key |
| `PassScheduleId` | varchar(30) | NOT NULL | `PassSchedule.ScheduleId` | Parent schedule |
| `ChangeType` | varchar(20) | NOT NULL | — | `Override`, `Edit`, or `Acknowledgment` |
| `ParameterName` | varchar(50) | NULL | — | Component/target changed; NULL for whole-schedule acknowledgments |
| `OldValue` | varchar(100) | NULL | — | Prior value (text, unit-agnostic) |
| `NewValue` | varchar(100) | NULL | — | New value applied |
| `ReasonCode` | varchar(50) | NULL | — | e.g. `DieWear`, `SpcDrift`, `OrderSpec`, `ProcessUpdate`, `CampaignStart` |
| `ReasonNotes` | varchar(500) | NULL | — | Free-text detail |
| `RunId` | varchar(20) | NULL | — | Run context when the change was made (nullable) |
| `OperatorId` | varchar(50) | NOT NULL | — | User who made the change |
| `Timestamp` | datetimeoffset | NOT NULL | — | When the change was made; defaults to `SYSDATETIMEOFFSET()` |

**Allowed values — `ChangeType`:** `Override`, `Edit`, `Acknowledgment`

---

## Change Log

| Date | Change |
|---|---|
| July 26, 2026 | Added `PassScheduleChangeLog` (OQ-28); added `PassSchedule.ActiveJobId` + `RowVersion`; `PassSchedule.Alloy` FK → `AlloyProperty`; enforced one-Active-per-line+alloy via filtered unique index; added component `FM2_6inS3` + `IsMandatory` + FM1-not-bypassable CHECK (May-21 revision). Retargeted to `FlatWireDB`. |
