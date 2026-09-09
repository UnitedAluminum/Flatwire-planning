---
id: FW-N18
legacy_id:
title: LineId → MachineName — the FlatWire service
status: done
status_confirmed: true
status_note: "✅ **Done, 8 Sep 2026 — 843 sites across 118 files, and it builds and tests clean.** `CanonicalEnums.cs` now declares `enum MachineName { FL1, FL2, FL3 }`, string-serialised with the value order untouched. Renamed through 11 entities, 15 `*Contracts.cs`, `HubContracts.cs` (20 properties), `RunEvents.cs` (13 records), the 6 `Rules/` files, 8 validators, 11 EF configurations, `ContextRepository`'s raw SQL, the controllers, the hub and broadcaster, and the 5-file `Tools/FlatWireSimConsole`. ⛔ **`LineTagOptions.MachineId` and `appsettings.json`'s 125/126 are untouched** — a different fact. Hub method names keep *Line* (`JoinLineGroup` is a group operation, not a field). `dotnet build FlatWire.sln` **0 errors**, `dotnet test` **299 passed / 0 failed**, `FlatWireSimConsole` builds with 0 warnings. ⚠ Pre-checked before renaming: no class both declares this member and reads `MachineName.FLx`, so C#'s Color-Color trap does not bite."
owner:
jira:
mvp: 1
phase: "1B"
stream: BE
streams: [BE]
priority: high
hours: 6
sprint: S0
depends_on: [FW-N17]
blocked_by: []
has_plan: true
started: 2026-09-08
completed: 2026-09-08
---

# FW-N18 - LineId → MachineName — the FlatWire service

## What to build

Rename `LineId` to `MachineName` through the `FlatWire` microservice, per **`D-56`**, so that the
C# enum, the TypeScript union and the DDL `CHECK` stay one mirror as `[API §2.1]` requires.

The wire field becomes `machineName`. `scheduledLineId` becomes `scheduledMachineName` and
`correctLineId` becomes `correctMachineName`.

## Context you need

- **The enum is the first of three mirrors.** `CanonicalEnums.cs`'s own header states the rule:
  values are **appended, never reordered**, and they **serialise as strings** via
  `JsonStringEnumConverter` registered in `Program.cs`. Both properties are preserved.
- ⛔ **`LineTagOptions.MachineId` is not this.** Its comment is explicit: *"Not derived from the
  line name. FL1/FL2/FL3 are this service's identifiers; the machine id is the shared schema's, and
  inferring one from the other is how a write reaches the wrong machine."* `D-56` makes that
  warning **more** load-bearing, not less, because the two now share a word.
- **`OPCInfo.MachineName` already exists** and is a `string` on the OPC connection's own DTO. It is
  unrelated, and there is no type collision: the new enum lives in `FlatWire.Domain.Enums`.

> ### ⚠ The trap that was checked before a single file was touched
>
> The user's decision was that **type and field are both `MachineName`**, which produces
> `public MachineName MachineName { get; set; }`. That is legal C# — the well-known *Color Color*
> pattern — but inside such a class an unqualified `MachineName.FL1` resolves to the **property**,
> not the type, and fails with CS1061.
>
> ✅ **Verified clear before renaming:** no file in the tree both declares this member and reads
> `LineId.FL1` / `.FL2` / `.FL3`. The static reads all live in validators, factories and the
> simulator, none of which carry the property. Had one existed, the fix is qualification
> (`Enums.MachineName.FL1`), not a different name.

## Build order

1. The enum in `FlatWire.Domain/Enums/CanonicalEnums.cs`; let the compiler drive the rest.
2. Entities → contracts → events → rules.
3. Validators and `ValidationMessages` — **including the message text**, which is operator-visible
   in an API response: `"machineName is required."`
4. EF configurations. The property rename carries the column name;
   `.HasConversion<string>().HasColumnType("VARCHAR(5)")` is unchanged.
5. `ContextRepository`'s raw Dapper SQL — `s.[MachineName]`.
6. Controllers, hub, broadcaster.
7. `Tools/FlatWireSimConsole` — **a separate solution.** It drives the hub and the sim control
   surface, so it stops compiling if left behind.
8. Unit tests.

## Decisions made here

- **Hub method names keep "Line".** `JoinLineGroup`, `LeaveLineGroup` and
  `IFlatWireBroadcaster.Line(...)` name a *group operation*, not a field; only their parameter
  types are retyped. The client's `joinLine` / `leaveLine` match, so the SignalR contract holds.
- ⚠ **`GET /activerun` keeps its query key `line`.** It was already `line`, not `lineId`, on both
  sides. Renaming it to `machineName` is a defensible consistency change but is a **separate
  breaking contract edit** — raised in `D-56`'s open questions, not taken here. The C# parameter
  and the Angular `params: { line }` must continue to match exactly.

## Verification

```bash
cd "c:/UAL/Second-Branch/ual-api/API/Domain/FlatWire"
dotnet build FlatWire.sln
dotnet test FlatWire.UnitTests/FlatWire.UnitTests.csproj --no-build
cd "c:/UAL/Second-Branch/ual-api/Tools/FlatWireSimConsole" && dotnet build
```

**Measured 8 Sep 2026:** build 0 errors (22 warnings, all pre-existing — analyser version,
duplicate `PackageVersion`, Sonar rules); **299 tests passed, 0 failed**; sim console 0 warnings,
0 errors. ⚠ **The test count must not fall.** A rename that silently drops a test file is the
failure mode here, so compare the total, not just the pass/fail split.

## Handoff

- **`FW-N19`** must ship with this. The JSON body, query string and hub payload field names all
  change, so the service and the Angular library **cannot be released apart**.
- ⛔ **`FW-N17` must land first** — the EF configurations name the renamed columns.
