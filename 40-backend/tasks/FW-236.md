---
id: FW-236
legacy_id:
title: Per-tag write status from OPCConnection
status: in-progress
status_confirmed: true
status_note: "✅ **EXECUTED 5 Sep 2026 — the `G58` half is BUILT and GREEN.** `OPCConnection.sln` **0 errors**, `FlatWire.sln` **0 errors**, **23/23 tests pass** (17 `G94` regressions + 6 new), no new compiler warning. **11 of 13 acceptance criteria delivered**; the two left are a standing caveat (`G33`) and a deferred follow-up (`DefaultNamespaceIndex`). Per-tag outcome is `TagWriteResult`/`TagWriteStatus` in `OPCConnection.Domain.Writes` — ⛔ **`UA.APIDTO` untouched** (`P-329`); the `==` read-back check is `.Equals`; both catches log at `LogError` and return `Faulted` **without rethrowing**; `IsGood` is set on the UA read; `PLCTagService` implements `FR-074` off the outcome with `ConfirmAsync` left in place. ⛔ **NOT committed, NOT pushed, and step 1 (the merge) is deliberately NOT done** — the change set sits in the working tree on `feature/UADEV-23146` for `OPCConnection`'s owner. ⚠ **FlatWire has no test project**, so step 6 is compiled but uncovered; and no module is on `21317`, so the UA path executes nowhere yet. *(previously: ✅ **The `G94` half is BUILT, GREEN and STAGED in `ual-api` — measured 5 Sep 2026, `dotnet test` 17/17 passed, 0 failed.** The `IUaClient` seam, `EasyUaClientAdapter`, the two result records, the DI construction delegate and all five call sites are in; `OPCConnection` has its first unit tests. ⛔ **Staged, NOT committed — `FW-238` gates on the MERGE, not on the code existing.** ⛔ **The `G58` half — the card's actual title — is untouched:** `OPCUAManager.cs:380` still compares two boxed `object`s with `==`, both catch blocks still swallow at `LogInformation`, and `WriteTag` still returns a bare tag echo. **5 of 13 acceptance criteria are delivered, 6 remain, 1 is a standing caveat (`G33`) and 1 a deferred follow-up (`DefaultNamespaceIndex`).** ✅ **The acceptance gate collapsed and did not have to be argued:** all four write consumers call `.ReceiveStringAsync()` and read only `IsSuccess` — **not one deserializes the `WriteTag` body** — so an additive body on an unchanged `200` is invisible to them (`P-325`). ⛔ **`IsGood` must NOT be removed** — `Alarms` filters on it (`P-326`). ✅ **Executability checked 5 Sep 2026: all seven build-order steps can be run** — `OPCConnection.sln` and `FlatWire.sln` both build **0 errors**. ⛔ **One step was rewritten by that check:** `OPCTag` ships in the **`UA.APIDTO` NuGet package** (`1.0.0`, 23 consumers, project not in the solution), so the per-tag outcome goes on a type `OPCConnection` owns instead (`P-329`). ⚠ **The `G94` change is staged on `feature/UADEV-23146`, a FlatWire branch** — the merge is where cross-team ownership gets settled.)*"
owner:
jira:
mvp: 1
phase: "14"
stream: BE
streams: [BE]
priority: critical
hours: 16
sprint: S3
depends_on: [FW-151]
blocked_by: []
has_plan: true
started:
completed:
---

# FW-236 · Per-tag write status from `OPCConnection`

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 5, 2026 (EXECUTED) — ✅ **STEPS 2–7 ARE BUILT AND GREEN.** `OPCConnection.sln` **0 errors**, `FlatWire.sln` **0 errors**, **23/23 tests** (17 `G94` regressions unchanged + 6 new), no new compiler warning; **11 of 13 acceptance criteria delivered**, the remaining two being `G33` (a standing caveat) and `DefaultNamespaceIndex` (a deferred follow-up). ⛔ **Step 1 — the merge — is deliberately NOT done, and nothing was committed or pushed**: the change set sits in the working tree of `../ual-api` on `feature/UADEV-23146`, a FlatWire branch, for `OPCConnection`'s owner (§5.3). ⚠ **Two things a green build does not mean:** **FlatWire has no test project**, so step 6 is compiled but **uncovered**; and no `CommonDB` module is on `21317`, so the UA path this card fixes **executes nowhere yet**. §5.2 is what actually landed. *(previously: executability-checked — ✅ **ALL SEVEN STEPS ARE EXECUTABLE**, and checking that rewrote one of them: `OPCConnection.sln` and `FlatWire.sln` both build **0 errors** and the tests are **17/17**, but ⛔ **step 4 as first written would not have built at all** — `OPCTag` ships in the **`UA.APIDTO` NuGet package** (pinned `1.0.0`, 23 consumers, project not in the solution), so editing it changes nothing that compiles and fails **silently** three separate ways. The outcome now goes on a type `OPCConnection` owns, which §2.3 already made free (`P-329`, new §2.8). ⚠ **`OPCTag.cs` is NOT among the `G94` changes** — `TryGetOpcUaTagName` and `DefaultNamespaceIndex` pre-date them; §2.2's attribution is corrected. ✅ **`G94`'s half is built and green, so the card's own ordering rule is now SATISFIED and this plan is the `G58` half alone.**)* Verified against the working tree of `../ual-api`, not read from the card: the seam and all five call sites are in, `dotnet test` returns **17/17**, and every line anchor the card quoted has **moved** (§2.2). ➕ **Two findings from measuring the consumers, and both make the work smaller.** **(a)** ✅ **No consumer reads the `WriteTag` response body** — `Alarms`, `FurnaceScheduler` and `CoolingChamber` all `.ReceiveStringAsync()` and test `IsSuccess` only, so the body is free to change and the "regression-test four consumers" gate is discharged by inspection plus one rule: **the HTTP status must not move** (`P-325`). **(b)** ⛔ **`IsGood` cannot be removed** — `Alarms` deserializes `List<OPCTag>` on the *read* route and filters on `x.IsGood ?? false`, so acceptance criterion 2's second option is unsafe and is struck (`P-326`).
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **Both halves are built and green** — `G94` and `G58` (§5.2). ⛔ **Awaiting the merge, which is the one step this card cannot take for itself**: `OPCConnection` sits on four consumers' paths and the change is its owner's to accept. ✅ **What they are being asked to accept is now small and provable** — no route moves, no status code moves, no shared package changes, and the service gains its first 23 tests (§2.3, `P-325`, `P-329`).
**Owner:** Backend (BE) — one card, and `OPCConnection`'s owner must accept the merge
**Audience:** The developer executing `FW-236`, and whoever owns `OPCConnection`
**Shortcode:** — *(implementation plan, derived from the specifications and the built service; **not citable as a requirement**)*
**Part of:** `40-backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** The card it replaces was written on 4 Sep, before the `G94` work
> existed. Three things about it are now wrong in a way that would cost the next developer a day.
>
> **The ordering instruction has already been obeyed.** The card says *"`G94` first — canonicalise
> tag identity BEFORE lifting the swallow"*. That happened. Reading the card as written would send
> someone to re-do work that is finished, tested and sitting in the index.
>
> **Every line anchor it quotes is stale.** `:207` `:247` `:359` `:362` `:554` `:670` `:702` were
> pre-fix positions. All seven have moved, one of them by 61 lines (§2.2).
>
> **And the acceptance gate it describes as the hard part is not hard.** *"The four existing
> consumers are identified and regression-tested — this is the acceptance gate, not an afterthought"*
> assumed the four read the response. **They do not.** Measuring that took ten minutes and removed
> the largest risk on the card (§2.3).

---

## 1. What to build

**Hours:** 16 h BE · **Priority:** Critical · **Sprint:** S3 · **Phase:** 14 · **Stream:** BE

`FR-074` — *"raise an exception when any individual tag write fails"* — is unimplementable from
`OPCConnection`'s response (`G58`). `WriteTag` returns `200` with a bare tag echo whatever happened.
This card makes the outcome of each tag write **visible in the response**, so `FW-151`'s
`PLCTagService` can stop inferring a write from a status code.

**Acceptance criteria — 11 of 13 are delivered.** The card's list is unchanged in substance; this is
its state after execution on 5 Sep 2026. One is a standing caveat that cannot be closed here (`G33`)
and one is a deferred follow-up (`DefaultNamespaceIndex`), so **every criterion this card can close
is closed** — subject to the merge in §5.3.

| # | Criterion | State |
|---|---|---|
| 1 | `WriteTag`'s response carries a **per-tag outcome**, not a bare tag echo — written / refused / faulted, with a reason | ✅ **BUILT** — `TagWriteResult` / `TagWriteStatus` (§5.2) |
| 2 | `OPCTag.IsGood` is set by **both** managers ~~or the field is removed~~ | ✅ **BUILT** — one line on the UA read · ⚠ **removal option STRUCK** (`P-326`) |
| 3 | The reference-equality verification is corrected to `.Equals` and **no longer swallowed** | ✅ **BUILT** — `VerifyWriteOperation`, mirroring `OPCDAManager` |
| 4 | Exceptions in the write path stop being logged at `LogInformation` and surface to the caller | ✅ **BUILT** — `LogError` + `Faulted`, **no rethrow** (`P-327`) |
| 5 | The four existing consumers are identified and regression-tested | ✅ **Measured** (§2.3), and ✅ **no external compile dependency exists** (§5.2) |
| 6 | `FW-151`'s `PLCTagService` consumes the per-tag outcome; `P-105`'s confirm read may be reduced to a commissioning check | ✅ **BUILT** — `FR-074` implemented; ⚠ `ConfirmAsync` **left in place**, as the plan requires |
| 7 | ⚠ **`G33` is NOT closed by this** — a wrong tag path can read back consistently wrong (`[PLC §10.3]`) | ⚠ **Standing caveat** — not closable here |
| 8 | ⛔ `G94` first — canonicalise tag identity before lifting the swallow | ✅ **DONE** |
| 9 | `ReadTag` / `WriteTag` address namespace **2**; `:554`'s literal collapsed to the shared formatter; `UpdateOPCInfoTags` matches case-insensitively | ✅ **DONE** |
| 10 | Notifications correlate on the **`object state`** overload of `SubscribeDataChange`, never on `NodeDescriptor.ToString()` | ✅ **DONE** |
| 11 | ⚠ `OPCConnection` gets its first unit tests, and a seam is required to have them | ✅ **DONE** — `IUaClient` + 17 tests |
| 12 | ⚠ `:554` is treated as its own commit — it is the connectivity probe | ✅ **DONE**, and **test-pinned** (§2.1) |
| 13 | ⚠ `DefaultNamespaceIndex = 2` is a compile-time constant — per-`OPCServer` config or record the follow-up | ⛔ **STILL OPEN** — verified still `const` at `OPCTag.cs:14` (§7) |

**Rate-card basis (§2):** non-trivial change to an existing integration service, at the upper half of
the 12–24 h band because it is cross-consumer and needs regression on four callers = **16 h**
**⚠ Hours NOT re-derived, and the reason has changed.** The card left 16 h standing because `G94`
had inflated the scope. `G94` is now **spent**, and §2.3 removed most of the regression cost — so
the figure is arguably now generous rather than tight. It is still left at **16 h deliberately**:
the `Hours` cell is parsed into three client `.xlsx` generators and the capacity totals are quoted
in ~20 files, so a re-price belongs in an additive pass that owns the arithmetic, not in this edit.
**Dependencies:** FW-151
**Blockers:** ⚠ **Owned by `OPCConnection`, not by FlatWire.** Needs that service's owner to accept
the merge — ✅ but the response-shape change is now **provably additive** (`P-325`)

---

## 2. Context you need

### 2.1 ✅ The `G94` half is built, green and staged — and this is what "done" means for it

Measured on the working tree of `../ual-api`, 5 Sep 2026 — `git status` shows these **staged and
uncommitted**:

| Artefact | What it is |
|---|---|
| `OPCConnection.Domain/Interfaces/IUaClient.cs` | ⭐ **The seam.** QuickOPC's `Read` / `WriteValue` / `SubscribeDataChange` are **extension methods** on `IEasyUAClient`, which declares only `ReadMultiple` / `WriteMultiple` / `SubscribeMultipleMonitoredItems` — so `Mock<IEasyUAClient>` can intercept none of them. This first-party interface is the only route to a test, exactly as `G94` predicted |
| `OPCConnection.Domain/UaClient/UaReadResult.cs` · `UaDataChangeNotification.cs` | The two records the seam returns. ⭐ `UaReadResult` already carries **`HasGoodStatus`** — which is what criterion 2 needs (§2.4) |
| `OPCConnection.OPCUA/EasyUaClientAdapter.cs` | The QuickOPC boundary. Deliberately logic-free |
| `OPCConnection.API/Program.cs:172` · `Infrastructure/Factory/OPCManagerFactory.cs:39` | A **construction delegate**, not a container-resolved service — the manager owns and disposes its client |
| `OPCConnection.UnitTests/` | ⭐ **The service's first tests** — `TagIdentityTests.cs` (16 `[Fact]`/`[Theory]`) + `OPCUAManagerFixture.cs` |

```
dotnet test OPCConnection.UnitTests/OPCConnection.UnitTests.csproj
Passed!  -  Failed: 0, Passed: 17, Skipped: 0, Total: 17
```

**What those 17 pin** — the identity contract, in both directions: the formatted node id is used on
read, write and subscribe; the **bare** name is what comes back and what is published; state wins
over the node identifier when they disagree; a published name is *never* decorated; the lookup
matches case-insensitively; and — ⭐ the one worth knowing about — **`The_connectivity_probe_node_id_is_unchanged_from_the_old_literal`**,
which proves criterion 12's refactor of `GetSystemErrorTagValue` changed the *source* and not the
*string*. That probe drives `CheckConnectivityAndChannelStatus`, where a false negative costs an
operations email and a server failover, so "identical output" is the only acceptable result.

> ⛔ **Staged is not merged.** `FW-238` §2.7 and `[TB]` both gate activation of a `21317` module on
> `G94` **merging**. The code existing in a working tree discharges nothing. ⚠ `FW-238`'s §7 still
> reads *"`FW-236` is `not-started`"* — true when written, stale now (§6).

### 2.2 ⛔ Every line anchor the card quoted has moved

The card's anchors were captured before the `G94` edit. **Do not navigate by them.**

| Card said | Now at | What is there |
|---|---|---|
| `ReadTag` `:207` | **`:204`** (read at `:211`) | ✅ fixed — formatted node id |
| `Subscribe` `:247` | **`:245`** (state at `:252`) | ✅ fixed — carries `TagName` as correlation state |
| `WriteTag` `:359` | **`:364`** (write at `:372`) | ✅ identity fixed — ⛔ **outcome still missing** |
| ⛔ **the `==` check `:362`** | ⛔ **`:380`** | ⛔ **UNCHANGED — this is the work** |
| `GetSystemErrorTagValue` `:554` | **`:565`** (formatter at `:571`) | ✅ fixed and test-pinned |
| notification handler `:670` | **`:685`** (+ `ResolveTagName` `:742`) | ✅ fixed — correlates on state |
| `UpdateOPCInfoTags` `:702` | **`:763`** (comment `:765`) | ✅ fixed — case-insensitive |
| `OPCTag.Equals` `:125-175` | **`:153`** | unchanged behaviour |
| `OPCTag.cs:14` | **`:14`** | ⛔ `DefaultNamespaceIndex = 2` **still a `const`** |

⚠ **`OPCTag.cs` is NOT among the `G94` changes** — `git status` shows it unmodified. `GetOpcUaTagName`
(`:86`), the non-throwing `TryGetOpcUaTagName` (`:100`) and `DefaultNamespaceIndex` (`:14`) all
**pre-date** this work. That matters for more than attribution: `OPCTag` is not this solution's to
edit at all (§2.8).

### 2.3 ⭐ No consumer reads the `WriteTag` body — the acceptance gate, discharged by measurement

Criterion 5 called this *"the acceptance gate, not an afterthought"*. Measured, it is nearly free.
**All four write consumers post an `OPCInfo` and read the response as a string they never parse:**

| Consumer | Call site | What it reads |
|---|---|---|
| **Alarms** | `SilenceAlarmCommandHandler.cs:73-79` | `.ReceiveStringAsync()` → `successFlag = …IsSuccess` |
| **FurnaceScheduler** | `WriteOPCTagCommandHandler.cs:75-80` | `.ReceiveStringAsync()` → `successFlag = …IsSuccess` |
| **CoolingChamber** | `OpcHelper.cs:133-135` | `.ReceiveStringAsync()` — result not deserialized |
| **FlatWire** | `PLCTagService` | ⭐ **ours** — the one consumer that *will* read the outcome |

⛔ **The consequence is the single most important design rule on this card.** What the four depend
on is **not** the body — it is the **HTTP status**. So:

- **Adding fields to the response body is invisible to them.** No regression is possible.
- **Moving the status code off `200` breaks all four at once**, silently flipping `successFlag`
  to `false` on every partial failure. That is the *only* way this card can break them (`P-325`).

⚠ **One consumer does deserialize `List<OPCTag>` — on the *read* route.** `Alarms`'
`InsertAlarmOnHistoryCommandHandler.cs:102-108` parses `ActionResultBase<List<OPCTag>>` and filters
`x.IsGood ?? false`. That is why the outcome must be **additive** to `OPCTag` and why §2.4 exists.

### 2.4 ⛔ `IsGood` must NOT be removed — criterion 2's second option is unsafe

The card offered *"or the field is removed and replaced by the per-tag outcome"*. **It cannot be.**
`Alarms` filters live burner tags on `x.IsGood ?? false` (`InsertAlarmOnHistoryCommandHandler.cs:108`)
— removing the field makes that predicate silently `false` for every tag and empties the failed-burner
list with no error anywhere.

✅ **The remaining half is one line.** `OPCDAManager.cs:255` already sets `opcTag.IsGood` from
`tagValue.Quality.IsGood`. `OPCUAManager.ReadTag` (`:204-238`) sets `Value` and `ValueDataType` and
**never touches `IsGood`** — while the seam already hands it `UaReadResult.HasGoodStatus`, and
`:584` already logs that very field. Set it in the `HasValue` branch and the two managers agree.

### 2.5 The four defects that are actually left

All in `OPCConnection.OPCUA/OPCUAManager.cs` unless noted.

| # | Anchor | Defect |
|---|---|---|
| **a** | **`:380`** | `Convert.ChangeType(opcTag.Value, …) == Convert.ChangeType(tag.Value, …)` — two **freshly boxed `object`s** compared with `==`, i.e. reference equality, **false for every numeric tag**. ✅ `OPCDAManager.cs:233` already does it right: `requestedValue.Equals(actualValue)` |
| **b** | `:383` | The `else` throws `"Cannot write to tag …"` — into its own `catch`, three lines down |
| **c** | **`:389-400`** | Both `catch` blocks — `OpcException` and `Exception` — log at **`LogInformation`** and return normally. This is what swallows (b), and what kept `G94` invisible for as long as it was |
| **d** | `WriteTagCommandHandler.cs:66-72` | Loops the tags, collects `opcManager.WriteTag(opcTag)`, returns `List<OPCTag>` — **no outcome anywhere in the shape** |

### 2.6 ⛔ "Surface to the caller" must not mean "throw"

Criterion 4 says exceptions *"surface to the caller"*. ⚠ **Read literally — rethrow, or let the
handler throw — that is the one change §2.3 forbids.** `WriteTagCommandHandler` already throws on an
empty tag list and on connectivity, and `UAController` turns a throw into a non-2xx; every one of the
four consumers reads that as `IsSuccess == false`. A single refused tag in a batch of forty would
fail the whole operation for `CoolingChamber` and `FurnaceScheduler`, which today succeed.

✅ **Surface means: in the response, and in the log at the right level.** Per-tag outcome in the
body, `LogError`/`LogWarning` instead of `LogInformation`, HTTP status unchanged (`P-327`).

### 2.7 Out of scope

- **`G33`** — a wrong tag path reads back consistently wrong. Only `[PLC]`'s `C1`/`C11` settle it.
- **`G59`** — a background OPC call still has no service identity.
- **Turning the write path on.** `SimulatePLCTagPush` stays `true`; that is `FW-238` `P-320`.
- **`DefaultNamespaceIndex`** — recorded as a follow-up, not built here (§7).
- **The `WriteTag` batch shape.** It is already a batch endpoint and stays one.

---

### 2.8 ⛔ `OPCTag` is a NuGet package, not a source file this solution can edit

⚠ **Found by testing whether this plan could actually be run, and it changed the design.** The
obvious reading of criterion 1 — *"add two fields to `OPCTag`"* — **does not build**.

| Fact | Consequence |
|---|---|
| `OPCTag` lives in `API/Common/UA.APIDTO/OPC/OPCTag.cs`, but every consumer takes it as `<PackageReference Include="UA.APIDTO" />` — **23 projects** | Editing the `.cs` file changes nothing anyone compiles against |
| `API/Directory.Packages.props:12` pins `UA.APIDTO` at **`Version="1.0.0"`** | The version is central and shared |
| ⛔ **`OPCConnection.sln` does not contain the `UA.APIDTO` project** | The edit is invisible to this solution's build — **no error, no warning** |
| Republishing runs `GeneratePackageOnBuild` + the `PostPackNugetDeploy` target, which is `Condition="'$(Configuration)' == 'Release'"` and pushes to the file feed **`C:\Nuget\Repo`** | A **Release** build is required; a Debug build silently skips the push |
| ⛔ The version stays `1.0.0` and the push is `-Force`, while `~/.nuget/packages/ua.apidto/1.0.0/` is **already extracted** | NuGet will **not re-extract** an existing version. The developer builds against the **stale** DTO and sees nothing change — again with no error |

✅ **So the outcome does not go on `OPCTag`.** §2.3 already proved the thing that makes this free:
**no consumer deserializes the `WriteTag` response body.** The per-tag outcome therefore goes on a
response type **`OPCConnection` owns**, and `UA.APIDTO` is not touched at all (`P-329`).

⚠ **Criterion 2 is unaffected and still cheap** — `IsGood` is an **existing** field on the shipped
`1.0.0` package. Setting it in `OPCUAManager.ReadTag` is a one-line change inside `OPCConnection`
with no DTO edit and no package release.

## 3. Build order

Seven commits. **Steps 1–2 are ordered against each other and against everything else**: the
`.Equals` fix must land *before* the swallow is lifted, or every numeric write reports a failure it
did not have.

| # | Commit | Content |
|---|---|---|
| **1** | ⛔ **Merge the `G94` half** | Not new work — the staged change in §2.1. **Nothing below is safe before it**: with the `ns=0` write still in place, lifting the swallow reports a genuine-but-unexplained failure on every UA tag. Run the 17 tests on the merge commit |
| **2** | **Fix the comparison** — `:380` | `.Equals` in place of `==`, mirroring `OPCDAManager.cs:233`. ⚠ **Still swallowed at this point, deliberately** — this commit changes what the check *decides*, not what the caller *sees*, and is the one place to confirm against a real server that correct writes still pass |
| **3** | **`IsGood` on the UA read** — `:216` | One line in the `HasValue` branch: `opcTag.IsGood = tagValue.HasGoodStatus;` (§2.4). Closes criterion 2 |
| **4** | **The outcome type** — inside `OPCConnection`, ⛔ **NOT `UA.APIDTO`** | ⭐ **A response type this service owns**: the tag plus a status (`written` / `refused` / `faulted`) and a reason. `WriteTag`'s action result changes to carry it; `ReadTag`'s does **not** move. ⛔ **`OPCTag` is a NuGet package pinned at `1.0.0` and consumed by 23 projects — editing it does not even affect this solution's build** (§2.8). ✅ Safe precisely because §2.3 proved nobody deserializes the write body (`P-329`) |
| **5** | **Populate it in both managers** | `OPCUAManager.WriteTag` and `OPCDAManager`'s equivalent set the outcome on every path — verified-good, verify-failed, exception. ⛔ **The two `catch` blocks stop returning silently**: record `faulted` + the message, log at **`LogError`**, and **do not rethrow** (§2.6). The `else` at `:383` records `refused` instead of throwing into its own catch |
| **6** | **Consume it** — `FlatWire.Infrastructure/Services/PLCTagService.cs` | Audit `Succeeded` from the per-tag outcome instead of the status code. ✅ `FR-074` becomes implementable. ⚠ **Leave `ConfirmAsync` in place** — reduce it to a commissioning check only once `C1`/`C11` have run; it is the only thing narrowing `G33` (§2.7) |
| **7** | **Tests** | Extend `OPCConnection.UnitTests` on the seam built in step 1: a numeric write that verifies equal is `written`; one that verifies unequal is `refused`; a throwing `WriteValue` is `faulted` and **does not** escape; and ⭐ **the status-code assertion — a batch with one refused tag still answers `200`** (`P-325`) |

⚠ **Performance:** no step adds a round trip. `WriteTag` already reads back twice per tag
(`ReadTag` at `:370` and `:378`); this card adds no third read, no new endpoint and no new call.
Step 4 adds two members to a payload already being serialized.

✅ **All seven steps are executable today — measured 5 Sep 2026**, and this is the check that
rewrote step 4:

| Step | Evidence |
|---|---|
| 1 | `dotnet build OPCConnection.sln` → **0 errors**, 12 warnings · `dotnet test` → **17/17** |
| 2 · 3 · 5 · 7 | Same solution; all four touch only `OPCConnection.OPCUA` / `.OPCDA` / `.UnitTests` |
| 4 | ⛔ **Would NOT have built as first written** — rewritten to stay inside `OPCConnection` (§2.8) |
| 6 | `dotnet build FlatWire.sln` → **0 errors**, 14 warnings |

⚠ **The one thing that is not a build problem:** the `G94` change is staged on branch
**`feature/UADEV-23146`** — a *FlatWire* feature branch, one commit ahead of its origin. Merging
`OPCConnection` changes through a FlatWire branch is the cross-team ownership question made
concrete, and it is a conversation, not a task (§6).

---

## 4. Decisions made here

> `P-##` is continuous across this folder. `FW-238` minted `P-315`–`P-323` and directed that **the
> next story mints at `P-324`+**; this plan mints `P-324`–`P-329`, and the next story mints at
> `P-330`+.

| Id | Decision |
|---|---|
| **`P-324`** | ⭐ **The `G94` half is treated as DONE and merged as its own change, not re-planned.** It is built, green (17/17) and staged. The card's *"`G94` first"* instruction is discharged by **merging** step 1, not by re-deriving it. ⚠ Anyone reading the pre-5-Sep card will re-do finished work — that is why §2.2 exists |
| **`P-325`** | ⭐ **The response body is additive and the HTTP status does not move.** Measured: all four write consumers `.ReceiveStringAsync()` and read only `IsSuccess`; none deserializes the `WriteTag` body (§2.3). So the outcome rides on `OPCTag` inside the existing `List<OPCTag>`, and **a partial failure still answers `200`**. ⛔ **This is the whole compatibility argument** — it is what lets `OPCConnection`'s owner accept the change cheaply, and the one rule whose breach breaks four services at once. Step 7 asserts it |
| **`P-326`** | ⛔ **`IsGood` is set, never removed.** Criterion 2's *"or the field is removed"* is **struck**: `Alarms` filters on `x.IsGood ?? false` (`InsertAlarmOnHistoryCommandHandler.cs:108`) and removal empties the failed-burner list **with no error**. The UA manager sets it from `UaReadResult.HasGoodStatus`, which the seam already returns (§2.4) |
| **`P-327`** | ⛔ **"Surface to the caller" means the response and the log level — NOT a throw.** A rethrow reaches `UAController` as a non-2xx and flips `IsSuccess` for `CoolingChamber` and `FurnaceScheduler`, failing whole batches that succeed today. Exceptions become `faulted` + reason, logged at `LogError` (§2.6). ⚠ **This resolves a genuine tension in the card's own criteria** — 4 read literally contradicts 5 |
| **`P-328`** | **`.Equals` lands before the swallow is lifted, as its own commit** (steps 2 then 5). The same entanglement `G94` had with `G58`, one level down: lift the swallow while `:380` still compares references and **every numeric write reports a failure that is not real**. Step 2 is also the only commit whose effect is safely observable against a live server |
| **`P-329`** | ⛔ **The per-tag outcome goes on a type `OPCConnection` owns, NOT on `OPCTag`.** ⚠ **This reverses the obvious reading of criterion 1, and only testing executability caught it**: `OPCTag` ships in the **`UA.APIDTO` NuGet package**, pinned at `1.0.0`, consumed by **23 projects**, and `OPCConnection.sln` does not even contain the project — so the edit changes nothing that compiles, with **no error** (§2.8). Republishing needs a **Release** build to reach `C:\Nuget\Repo`, and because the version stays `1.0.0` over an already-extracted cache, consumers would **not pick it up** — three silent failures for two fields. ✅ **§2.3 makes the alternative free**: nobody deserializes the write body, so a service-owned response type costs nothing and touches no other team. ⚠ **`IsGood` is unaffected** — it already exists on the shipped package (`P-326`) |

---

## 5. Verification

### 5.1 Verifiable now — measured 5 Sep 2026

| Check | Result |
|---|---|
| `G94`'s half builds and passes | ✅ **17/17, 0 failed** — `dotnet test OPCConnection.UnitTests` |
| The seam exists and is mockable | ✅ `IUaClient` declares `Read` / `WriteValue` / `SubscribeDataChange` / `Unsubscribe*` as **instance** methods |
| The `==` defect is still present | ✅ Confirmed at **`:380`** — reference comparison of two boxed values |
| The swallow is still present | ✅ Confirmed at **`:389-400`** — both catches at `LogInformation` |
| `IsGood` is unset on the UA read path | ✅ Confirmed — `:204-238` never assigns it; `OPCDAManager.cs:255` does |
| Consumers do not read the write body | ✅ Confirmed at all four call sites (§2.3) |
| `Alarms` reads `IsGood` on the read body | ✅ Confirmed — `InsertAlarmOnHistoryCommandHandler.cs:108` |
| `DefaultNamespaceIndex` is still a constant | ✅ Confirmed — `OPCTag.cs:14`, `public const int … = 2` |
| ⭐ **The whole plan is executable** | ✅ `OPCConnection.sln` **0 errors** · `FlatWire.sln` **0 errors** · tests **17/17** (§3) |
| ⛔ **`OPCTag` is not editable from this solution** | ✅ Confirmed — `PackageReference` at `1.0.0` in `Directory.Packages.props:12`, 23 consumers, project absent from `OPCConnection.sln` (§2.8) |

### 5.2 ✅ EXECUTED — 5 Sep 2026

**Built:** `OPCConnection.sln` **0 errors** · `FlatWire.sln` **0 errors** · **23/23 tests pass**
(17 `G94` regressions, unchanged, plus 6 new). ⚠ **No new compiler warning** — every warning in
both solutions pre-dates this work.

| Step | What landed |
|---|---|
| **1** | ⚠ **NOT done here — it is not mine to do.** See §5.3 |
| **2** | `OPCUAManager.VerifyWriteOperation` — converts both values to the **requested** type and compares with `.Equals`, mirroring `OPCDAManager`. ➕ **A null read-back is guarded first**, so a missing read-back is `Refused` rather than an exception from `Convert.ChangeType` |
| **3** | `opcTag.IsGood = tagValue.HasGoodStatus` on the UA read. `UaReadResult.None` reports `false`, so an unread tag is correctly not-good |
| **4** | `OPCConnection.Domain/Writes/` — `TagWriteStatus` (`Written`/`Refused`/`Faulted`) and `TagWriteResult`. ⛔ **`UA.APIDTO` untouched** (`P-329`) |
| **5** | Both managers return the outcome on every path. Catches log at **`LogError`** and return `Faulted` — **no rethrow**. The UA `else` that threw `"Cannot write to tag"` into its own catch now returns `Refused` with both values in the reason. ➕ **A read-only module is now `Refused`** in the controller, where it used to echo the tags back indistinguishably from success |
| **6** | `PLCTagService` fails the operation when any tag is not `Written` — **`FR-074`, implemented**. `Attempt<T>` is now generic so the confirm read still gets `List<OPCTag>`. ⚠ **`ConfirmAsync` left in place**, per the plan |
| **7** | `WriteOutcomeTests` — 6 tests: written / refused / unreadable / faulted-and-not-escaping / `IsGood` set / ⭐ **a mixed batch returns one result per tag and does not throw** (the `P-325` guarantee) |

⚠ **The blast radius is provably contained.** No project outside `OPCConnection.sln` carries a
project reference to it, and the only two files elsewhere that name `IOPCManager` or
`WriteTagCommand` do so **in documentation comments**. The other three consumers reach this service
over HTTP only, so they cannot fail to compile — and by `P-325` they cannot fail at runtime either.

⛔ **What is NOT verified, and cannot be here:**
- **FlatWire has no test project** — `FlatWire.sln` is four projects and none of them is a test
  project, so step 6 is **built and compiled but not covered**. `FW-151`'s "53/53 assertions" was a
  harness, and no harness exists in the tree today. ⚠ **Minted as `G101` and carded 5 Sep 2026**
  (`D-50`): `FW-263` creates the project and **`FW-265` covers this step's `FR-074` branch**. ⛔ Until
  `FW-265` runs, *"built and compiled but not covered"* still holds.
- **No live server.** All four `CommonDB.OPCModules` rows are still `21316`, so the UA path this
  card fixes **executes nowhere yet** (§7).

### 5.3 Not verifiable before commissioning

⛔ **`G33` stands.** A write can be confirmed *and wrong* if the path addresses the wrong node.
`[PLC §10.3]` is explicit that "a tag push actually configures the machine" cannot be proven before
`C1`/`C11`. **A per-tag `written` is evidence of a write, never of a correct destination.**

⛔ **And step 1 — the merge — is deliberately NOT done.** The code sits in the working tree of
`../ual-api` on `feature/UADEV-23146`, a **FlatWire** branch. Merging a change to `OPCConnection`,
a service on four consumers' paths, is the cross-team decision this card has flagged from the start
(§6). ⚠ **Nothing here was committed or pushed** — the change set is left in the working tree for
that owner to review.

---

## 6. Handoff

`FW-151`'s `PLCTagService` gets a real signal and `FR-074` becomes implementable. `FW-238`'s last
gate is discharged the moment step 1 merges.

| To | Item |
|---|---|
| **`OPCConnection`'s owner** | ⛔ **THE CHANGE SET IS WRITTEN, BUILT AND GREEN, AND IS WAITING FOR YOU** — in the working tree of `../ual-api` on `feature/UADEV-23146`, uncommitted (§5.2). ✅ **The ask is small and provable:** a service-owned result type, a corrected comparison, a log level, one line for `IsGood` — and **no change to any route, any status code, or any shared package** (`P-325`, `P-329`). The service gains its first **23** tests. ⚠ Four consumers, only one of which (`FlatWire`) reads the new fields; the other three cannot even fail to compile, since nothing outside the solution references it |
| **A FlatWire test project** | ⚠ **Step 6 is compiled but uncovered.** `FlatWire.sln` has four projects and none is a test project, so `PLCTagService`'s new `FR-074` branch has no automated proof. Not this card's scope to create one, but it is the gap that would catch a regression here. ✅ **DISCHARGED 5 Sep 2026** — the gap this row named without an id is now **`G101`**, the decision that forbade the project is reversed (`D-50`, `[TS §1.2]`), and it is carded as `FW-263`–`FW-267`: **`FW-263`** creates the project and **`FW-265`** covers this branch specifically. ⚠ **Carded is not built** — until `FW-265` runs the branch is still uncovered |
| **`FW-238`** | ⛔ **Its §7 and `status_note` still say `FW-236` is `not-started`** — true on 4 Sep, stale now. The `G94` half is built and green; what it waits on is the **merge**. ⚠ Its gating statement is otherwise correct and should not be relaxed: staged code activates nothing |
| **`90-registers/Gaps.md`** | ⚠ **`G94` is still `Open` and should move to resolved-pending-merge**, with `G58` narrowed to the four defects in §2.5. ⛔ **Not swept here** — a register status is a claim about merged code, and this is staged |
| **`[TB]`** | The row is unchanged in substance; hours **left at 16 h and not re-derived** (§1). ⚠ The `Hours` cell feeds three client `.xlsx` generators and the capacity totals are quoted in ~20 files |
| **`P-105` / `[PLC]`** | `ConfirmAsync` stays until `C1`/`C11` run. It is the only thing narrowing `G33`, and a per-tag outcome does not replace it |

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`DefaultNamespaceIndex = 2` — orphaned, and verified still open** | A compile-time constant (`OPCTag.cs:14`) that no repository can prove holds for every deployed server. ⚠ **`FW-238` §6 handed this to `FW-236` explicitly** after `G97` closed without it — it is recorded here so it stops travelling. **Not built on this card**: making it per-`OPCServer` configuration is the fix, and only `[PLC]`'s `C1`/`C11` settle whether it is needed. ⚠ `G94`'s work made it *more* load-bearing, not less — five call sites now depend on the one formatter |
| ⛔ **`G94` is merged, not just written** | Step 1. Everything else in this plan is unsafe before it, and `FW-238` cannot activate a `21317` module without it. ⚠ **It is staged on `feature/UADEV-23146`, a FlatWire branch** — so the merge is also the moment the cross-team ownership question has to be answered (§3) |
| ⚠ **`UA.APIDTO` is a shared package with a same-version release habit** | Not this card's to fix, and this card now avoids it (`P-329`). But it is a live trap for anyone who *does* need a DTO change: `1.0.0` is overwritten in place with `-Force`, so an already-extracted global cache silently wins. **Bumping the version is the only safe way to ship a DTO change**, and nothing in the repository says so |
| ⚠ **`G94` is latent until a module moves to `21317`** | Measured 4 Sep on `DEV00164-001`: all four `CommonDB.OPCModules` rows are `21316` (`OPCDA`), and 0 of 496 `OPCTags` rows carry a prefix — so `OPCUAManager` is selected by nothing today and there is no config to migrate. ⛔ **`D-44` puts the 72 flat wire tag paths into that same registration**, and `FW-238` sets module 6 to `21317` — flat wire is the **first module ever to select `OPCUAManager`** |
| ⚠ **The `G58` fix is not verifiable against a live UA server before commissioning** | No module runs UA today (above), so steps 2–5 can be proven by unit test and by `OPCDA` parity, **not** end-to-end. `[PLC]`'s `C1`/`C11` are the first real exercise |
| ⚠ **`G33`** | Untouched, and not closable by this card (§5.3) |
| ⚠ **`G59` / `FW-237`** | A background OPC write still has no service identity. Per-tag status does not change that |
