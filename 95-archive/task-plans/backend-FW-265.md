---
id: FW-265
legacy_id:
title: PLCTagService — the simulate branch and FW-236's FR-074 outcome branch
status: done
status_confirmed: true
status_note: "✅ **EXECUTED 6 Sep 2026 — ALL 11 FW-151 SCENARIOS NOW COMMITTED; 11 of 12 criteria met, 1 half.** Suite **279 → 293**, full rebuild **0 errors / 22 warnings, unchanged**. ⛔ **NOT committed** — in the `ual-api` working tree on `feature/UADEV-23146`. ⭐ **FALSIFIABILITY PROVEN BY MUTATION, NOT ASSERTED (`P-340`): five mutations, each reddening EXACTLY ONE test, and the right one every time** — pre-populating the confirm probe → the sentinel; removing the cache lookup → `P-104`; disabling the read-only guard → scenario 7; giving `SetITInhibit` a confirm read → scenario 8; compensating analogues too → the flags-only safety rule. ⛔ **Writing the sentinel exposed a flaw in the first draft of my own test**: a stub answering a FIXED body cannot catch pre-population, so `ReadTag` now **echoes the request back unchanged**, as a real controller does — the dependency on what was sent IS the mechanism. ✅ **Both overclaiming doc comments corrected and all three weak assertions strengthened** (`P-339`, `P-342`); the `AuditTrail` recorder the fixture promised now exists and records the SINK, which is what makes the compensation trail assertable. ⚠ **AC 8 stays HALF and cannot be closed here** — detecting `OPCConnection` switching to string enums needs the contract level `D-50` left withdrawn (`P-341`), so `[TS §1.2]` owns the residual. ⚠ **Hours unchanged at 16**; `PLCTagService.cs` still byte-identical."
owner:
jira:
mvp: 1
phase: "1B"
stream: BE
streams: [BE]
priority: high
hours: 16
sprint: S3
depends_on: [FW-263, FW-151]
blocked_by: []
has_plan: true
started:
completed:
---

# FW-265 · `PLCTagService` — the simulate branch and `FW-236`'s `FR-074` outcome branch

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 6, 2026 (EXECUTED) — ✅ **The nine missing scenarios are built: all 11 of `FW-151` §5.1 are now committed, 279 → 293 tests.** Reconciliation had found the delivered half was the one the card did *not* price; §2 keeps that record, §3 is what was executed against it. Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** ✅ **DONE — 11 of 12 criteria met; the twelfth is half and cannot be closed at this level.** The sentinel is built and **proven falsifiable by mutation**. ⚠ **AC 8's residual belongs to `[TS §1.2]`'s withdrawn contract row** (`P-341`), not to this card. ⛔ **The work is UNCOMMITTED**, in the `ual-api` working tree
**Owner:** Backend (BE)
**Audience:** Whoever reviews `FW-265`, and whoever picks up `FW-264`, `FW-266` or `FW-267`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `40-backend/tasks/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** ⛔ **The card's premise was inverted, and that was the finding.**
> It reads *"mostly conversion, not authorship — `FW-151` §5.1 already enumerates ten scenarios and
> 53 passing assertions … this story commits them."* **The authorship was what got done. The
> conversion was what got skipped** (§2.1). ✅ **§3 executed the missing nine.**
>
> ⭐ **The one thing worth carrying to every other card in the set:** falsifiability here is
> **proven by mutation, not asserted**. Five deliberate breakages, each reddening **exactly one**
> test, and the right one every time (§5.2).
> ⛔ **And the pass caught a flaw in the first draft of the sentinel itself.** A stub that answers a
> **fixed** body cannot detect pre-population of the confirm probe — the very thing the sentinel
> exists to catch — because what comes back does not depend on what was sent. `ReadTag` now
> **echoes the request back unchanged**, as a real controller does. **A test written against the
> sentinel that could not fail would have been the worst outcome available** (§3 step 2).
> ⚠ **One criterion stays half and honestly so:** no unit test can detect `OPCConnection` switching
> to string enums; that needs the contract level `D-50` left withdrawn (`P-341`).

---

## 1. What to build

**Hours:** 16 h BE · **Priority:** High · **Sprint:** S3 · **Phase:** 1B · **Stream:** BE

⭐ **This is the card that closes the hole `FW-236` opened.** That story added an `FR-074` branch
failing a push when any tag returns not-`Written`, and left it **compiled but untested** — the
finding that became `G101`.

⛔ **Do NOT extract an `IRestClient`.** `CallService`/`WithRoute`/`PostJsonAsync` are extension
methods on a concrete type in a package we do not own (~60 call sites) — and decisively,
`TagWriteOutcome` and `OpcWriteStatus` are **private nested types**
(`PLCTagService.cs:1036`, `:1049` — ✅ **both anchors still resolve exactly**), so a mocked
`IRestClient` **cannot construct them and cannot reach the `FR-074` branch at all**. ✅ **The build
proved this rather than assumed it:** the tests exist only over a JSON body.

**Acceptance criteria — 11 met, 1 half.** ✅ **EXECUTED 6 Sep 2026**; state measured against the
working tree after the build.

| # | Criterion | State |
|---|---|---|
| 1 | `FW-151` §5.1's **ten scenarios** committed as tests | ✅ **ALL 11 DELIVERED** (§2.2). Scenario 2 also strengthened — it now asserts the reason names both the logical name and the config section, and that the failure is audited |
| 2 | **Simulate mode makes ZERO outbound requests, `GetOPCInfo` included** — asserted on the recorded request list | ✅ **MET** — `A_simulated_push_makes_no_outbound_call_at_all`, asserted on `Opc.Requests`, not inferred |
| 3 | ⛔ **The sentinel (scenario 5): a silently dropped write answering `200` reports `Unconfirmed`, NEVER `Confirmed`**, trail records `0.0325 (unconfirmed)` | ✅ **MET — `The_sentinel_a_silently_dropped_write_is_never_Confirmed`.** ⭐ **Falsifiability PROVEN**: pre-populating the confirm probe turns all four `Confirmed` and this is the ONLY test that goes red (§5.2) |
| 4 | A failed confirm read is **not** a failed write — `Unconfirmed` with `Success == true` | ✅ **MET** — `A_confirm_read_that_does_not_complete_leaves_the_write_successful`: `Success == true`, every tag `Unconfirmed` |
| 5 | ⭐ **`FR-074`: a refused or faulted tag fails the operation**, reason naming count, tag and status | ✅ **MET** — `A_refused_tag_fails_the_push`, `A_faulted_tag_fails_the_push`, and ✅ **falsifiability checked** (§2.5) |
| 6 | ⭐ **A partial batch names only the failures** — 4 outcomes, 2 refused → `"2 of 4 tags were not written"` | ✅ **MET** — `A_partial_batch_names_only_the_failures` |
| 7 | ⛔ **A bare tag echo from an older `OPCConnection` must NOT fail the push** (`PLCTagService.cs:402`, ✅ anchor resolves) | ✅ **MET** — `A_bare_tag_echo_…` plus `A_null_payload_falls_through_to_the_confirm_read` |
| 8 | ⚠ **The status crosses the wire as a NUMBER** — pin it | ⚠ **HALF, and the test's own `<remarks>` overclaims.** The numeric form **is** exercised ✅ (the refused/faulted tests send `1`/`2`) — but **nothing detects `OPCConnection` switching to strings**, which is the hazard the criterion names (§2.4) |
| 9 | The **three-record compensation trail** in order — attempt, failure, compensating clear — **flags only, no analogue zeroed** | ✅ **MET** — `A_mismatch_fails_the_push_and_re_clears_only_the_flags`. ⭐ **Flags-only asserted on the SENT BODY**, not on a request count: the compensation carries `ITInhibit` and no `RollGap` or `TargetGauge` |
| 10 | The `P-104` cache holds: a second push issues **no second `GetOPCInfo`**. ⚠ Use a **real** `MemoryCache` | ✅ **MET** — `A_second_push_reuses_the_cached_OPCInfo`, both pushes through **one** service instance. ⭐ Removing the cache lookup reddens exactly this test |
| 11 | ⚠ **`G59`: with a null `HttpContext` the call fails at `GetOPCInfo`, is audited, no exception escapes** | ✅ **MET** — `With_no_HttpContext_the_push_fails_in_band_and_is_audited`: fails before any write, audited, **no exception escapes** |
| 12 | ⚠ **`G33` is NOT closed by this** | ✅ **MET** — correctly left as a standing caveat, closable only by `C1`/`C11` |

**Rate-card basis (§2):** lower-middle of the *non-trivial business service* 12–24 h band,
deliberately — the work is **conversion of an enumerated 53-assertion scenario table**, not
authorship, and `FW-263` supplies the stub the original harness needed a loopback `HttpListener`
for = **16 h**
⚠ **Hours NOT re-derived.** The residual is **~6 h inside the existing 16 h**, not additional — the
`FR-074` family delivered instead was unpriced authorship, so the story traded scope rather than
overrunning. ⛔ **Do not re-price**: the `Hours` cell feeds three client `.xlsx` generators and the
set total of 98 h is unchanged.
**Dependencies:** [`FW-263`](FW-263.md) ✅ `done` · [`FW-151`](FW-151.md) ✅ `done`
**Blockers:** —

---

## 2. Context you need

### 2.1 ⛔ The card priced conversion and got authorship — the delivery is inverted

`33bab507f` is **5 files, 853 insertions, zero production files touched.** `PLCTagService.cs` is
byte-identical and last changed by `FW-236` ✅. Of the 13 tests:

| Family | Tests | Priced by the card as | Actually |
|---|---:|---|---|
| **`FW-151` §5.1 conversion** | **5** | the bulk of the 16 h | ⛔ **1 full + 1 partial, of 11** |
| **`FR-074` outcome branch** | **8** | one acceptance criterion | ✅ **Complete, and falsifiability-checked** |

⚠ **This is not an overrun and not a shortfall in quality** — the eight `FR-074` tests are the ones
that close `G101`'s actual finding, and they are the harder half to author because
`FW-151` never enumerated them. **What it is, is a scope trade nobody recorded**, and the card still
reads as though the conversion happened.

### 2.2 ✅ The nine scenarios that were missing — now built

Measured against [`FW-151 §5.1`](FW-151.md)'s own table. **All 11 are committed.**

| # | Scenario | Test |
|---|---|---|
| 1 | Simulate mode, flag as bound | ✅ 4 tests — zero calls, `Simulated` flags, resolved paths, the 5+5 audit *(pre-existing)* |
| 2 | An unconfigured logical name | ✅ `An_unconfigured_logical_name_fails_the_push` — ⭐ **strengthened**: the reason must name both `TargetGauge` and `FlatWireOpc:Lines:FL1:Tags`, and the failure must be audited |
| 3 | `G60` — ids at their shipped default | ✅ `At_the_shipped_default_module_id_the_push_fails_naming_G60` — fails **by name**, `Requests` empty |
| 4 | Real write path + `P-104` cache | ✅ `The_real_write_path_sends_one_write_and_one_confirm_read_for_four_tags` + `A_second_push_reuses_the_cached_OPCInfo` |
| **5** | ⛔ **The sentinel** | ✅ `The_sentinel_a_silently_dropped_write_is_never_Confirmed` — ⭐ **the one that proves the mechanism** |
| 5b | The **read** swallows | ✅ `A_confirm_read_that_does_not_complete_leaves_the_write_successful` |
| 6 | Genuine mismatch → compensating re-clear | ✅ `A_mismatch_fails_the_push_and_re_clears_only_the_flags` — three-record trail, sink change, **flags only** |
| 7 | `IsReadonly = true` | ✅ `A_read_only_module_fails_the_push_without_attempting_a_write` |
| 8 | `SetITInhibit` | ✅ `SetITInhibit_writes_once_and_issues_no_confirm_read` + `FL2_resolves_a_different_interlock_path_from_FL1` (`TC-017a`) |
| 9 | `G59` — no `HttpContext` | ✅ `With_no_HttpContext_the_push_fails_in_band_and_is_audited` |
| 10 | The other four operations | ✅ `Each_remaining_operation_audits_to_its_own_sink_under_its_own_label`, a 4-case `[Theory]` |

✅ **All six public operations are now exercised.** `PushPassScheduleAsync` was the only one any
test called; `ClearPayoffTagsAsync`, `WriteComponentAsync`, `HoldAsync`, `RestoreAsync` and
`SetITInhibitAsync` each now have coverage of the two fields that decide their failure behaviour —
`Confirm` and `CompensateOnFailure`.

### 2.3 ✅ Two defects in the delivered fixture — both fixed

⚠ **Kept as the record of what was found.** Each is marked with what was done.

**(a) ✅ FIXED — `<see cref="AuditTrail"/>` named a member that did not exist.**
`Fixture/PLCTagServiceFixture.cs:19` reads *"`AuditTrail` records every audit call in order, which is
what makes … the three-record compensation trail assertable in one line rather than through six
separate `Verify` calls."* **There is no `AuditTrail` member.** The fixture exposes `Audit`, a bare
`Mock<IAuditLog>` with no callback — so it cannot do what its own documentation promises, and the
one test that needs a trail builds its own four-line capture inline
(`PLCTagServiceSimulateTests.cs:144`).

⚠ **Why nothing caught it:** `GenerateDocumentationFile` is **not set anywhere** in the solution, so
`CS1574` never fires, and `FW-263`'s `.editorconfig` blanket-disables analyzer diagnostics for this
project. ⛔ **This is `CLAUDE.md`'s *"a CSS class that does not exist looks exactly like one that
does"* in C# form** — a doc-comment asserting a capability, compiling clean, and being wrong.

✅ **The recorder now exists** and the promise is kept rather than deleted — the missing scenarios
needed it anyway. ⭐ **It records the SINK alongside the entry**, which turned out to be the load-bearing
part: a compensating re-clear leaves the pushed sink for the cleared one, and *"which sink"* is the
only thing distinguishing it from an operator's checkout clear. The duplicated inline capture in the
simulate test is gone.

**(b) ✅ FIXED — three fixture members were dead, all built for scenarios never written.**

| Member | Callers | Built for |
|---|---:|---|
| `PLCTagServiceFixture(withHttpContext: false)` | **0** | `G59`, scenario 9 |
| `FlatWireOpcOptionsBuilder.WithoutModule()` | **0** | `G60`, scenario 3 |
| `FlatWireOpcOptionsBuilder.WithoutTag(line, name)` | **0** | the unconfigured-tag variants |

✅ **All three are now used** — `withHttpContext: false` by scenario 9, `WithoutModule()` by scenario 3.
⚠ `WithoutTag` remains unused and is **kept deliberately**: it is the seam for the unconfigured-tag
variants, and scenario 2 drives that case through the resolver instead.

### 2.4 ✅ A second doc comment overclaimed, and three assertions under-asserted — all fixed

**(a) ✅ CORRECTED — the string-status test did not do what its `<remarks>` said.**
`PLCTagServiceWriteOutcomeTests.cs:236` ends *"This test is what turns that into a visible failure
rather than a silent one."* ⛔ **It does not.** The test drives the stub with a hand-written string
body and asserts the push **does not fail**. If `OPCConnection` ever added a string-enum converter,
this test would be **unchanged and still green** while production silently stopped failing refused
tags. It **records** the hazard; it does not **detect** it.

⚠ **And the hazard is not detectable at this level at all** — catching a wire-format change needs a
contract test against the real `OPCConnection`, the level `D-50` left **withdrawn**. ✅ **The test is kept** — pinning the current tolerance is worth having — and **the sentence now says
what it actually does**: it records the tolerance, states that no unit test can detect the hazard, and
names `[TS §1.2]` as the owner of the residual. **This was the second doc comment in this story
asserting a capability that does not exist** (`P-339`); the first is §2.3a.

**(b) ✅ FIXED — three assertions were weaker than the criteria they claimed to satisfy** (`P-342`).
Only one test in the whole set had asserted `result.Success` is true.

| Test | Asserts | Misses |
|---|---|---|
| `An_unconfigured_logical_name_fails_the_push` | `NotNull(FailureReason)` | the reason's **content**, and the **audit** — both required by scenario 2 |
| `A_written_tag_does_not_fail_the_push` | `DoesNotContain("were not written")` | **`Success == true`.** A push failing for an unrelated reason passes |
| `A_status_that_arrives_as_a_string_does_not_fail_the_push` | `DoesNotContain("were not written")` | same |

⚠ **The two `DoesNotContain` tests are the *positive halves*** — the ones whose own remarks say they
exist so *"a rule that failed on every outcome"* is caught. **A positive half that never asserts
success is not a positive half.**

✅ **All three strengthened, and all three still passed** — which is the honest outcome to report:
the assertions were true all along, they were simply not being made, so nothing was hiding behind
them. That is why this is a robustness fix and not a bug fix.

### 2.5 ✅ The one thing here that should become the rule for the whole set

⭐ **This story checked that its tests can FAIL, and counted.** From the commit: disabling the
`FR-074` branch locally fails **exactly three** tests — refused, faulted, partial batch — and
**correctly leaves the other four passing, because those assert the branch does *not* fire.** The
production file was then restored and the suite re-run green.

⛔ **No other card in the set did this**, and it is the difference between a suite and decoration.
**A test that passes either way is the exact failure mode `G101` exists to prevent.** Carry the
method into `FW-264`, `FW-266` and `FW-267`: break the thing on purpose, count what goes red,
restore.

### 2.6 ⚠ Two behaviours pinned as *observed*, not endorsed — do not "fix" either

Both are places the build found production right and the expectation wrong:

- **The audit trail is five `Attempted` then five `Succeeded` for four tags** — 1 group + 4 tags,
  and **the attempts are all written before anything is tried**, so a push that dies mid-flight
  still leaves evidence it started. Exactly as `FW-151 §5.1` says.
- ⚠ **`Attempted` records carry `Simulated = false` while only the outcomes carry `true`.** An
  attempt is logged identically on both paths, so **a reviewer reading attempts alone cannot tell a
  simulated push from a real one.** Pinned with a comment saying so — current behaviour, not
  obviously a defect, but now visible if it becomes one.
- ⚠ **A status arriving as a *string* is recorded as observed, not endorsed.** The **numeric** form
  is the contract because `AddControllers()` registers no string-enum converter. ⛔ **If anyone adds
  one to `OPCConnection` — an innocuous-looking change — every refused tag deserializes to `Written`
  and `FR-074` silently stops working.**

### 2.7 ⚠ A bare `DefaultHttpContext` is not enough for `RestClient`

It reads its token through `HttpContext.GetTokenAsync`, which resolves `IAuthenticationService` off
`RequestServices`. Without one, **every test fails at `GetOPCInfo` with `"Value cannot be null"`** —
a message that reads like a service fault rather than missing scaffolding.
`OpcConnectionStub.NewContextWithBearer()` already solves this; reuse it, do not re-derive it.

### 2.8 Out of scope

⛔ **No production change.** This story touches no file under `FlatWire.Infrastructure` and must not.
⛔ **`G33` is not closable here** — a wrong path reads back consistently wrong (`[PLC §10.3]`).
⛔ **No coverage percentage** (`D-50`, `[TS §4.1]`).

---

## 3. Build order — as executed, 6 Sep 2026

✅ **Additive only. No production file changed**, and the suite was green at every step.

1. ✅ **`Fixture/PLCTagServiceFixture.AuditTrail`** — the recorder the docs already promised, now
   capturing **all three sinks** with the sink recorded (`Fixture/AuditRecord.cs`). The simulate
   test's duplicated inline capture is gone.
2. ✅ **Scenario 5 — the sentinel**, and ⛔ **the first draft of it was wrong.** Written against a
   **fixed** `ReadTag` body, it could not have caught pre-population of the confirm probe — the exact
   thing it exists to catch — because what came back did not depend on what was sent. `ReadTag` now
   **echoes the request back unchanged** (`OpcConnectionStub.EchoUnchanged`), which is what both
   managers do when they cannot read. ⭐ **Only after that change does the mutation redden it.**
3. ✅ **Scenario 5b** — the confirm read fails outright: still `Unconfirmed`, `Success == true`.
4. ✅ **Scenario 4** — one `WriteTag` for four tags, one `ReadTag`, all `Confirmed`, the audit
   carrying the **read-back** value; then `P-104`, both pushes through **one** service instance.
5. ✅ **Scenario 6** — mismatch, three-record trail across the sink change, and ⛔ **flags-only
   asserted on the SENT BODY**: a request count cannot express *"no analogue was zeroed"*.
6. ✅ **Scenarios 7 and 8** — read-only fails with `WriteTag` never called; `SetITInhibit` writes once
   with **zero** confirm reads, and FL2 resolves a different path (`TC-017a`).
7. ✅ **Scenario 9 (`G59`)** — no `HttpContext`: fails before any write, audited, no exception escapes.
8. ✅ **Scenario 3 (`G60`)** and **scenario 10** — fails by name with nothing sent; the other four
   operations as a 4-case `[Theory]` over sink and label.
9. ⭐ **Falsifiability pass** — five mutations, counted and restored (§5.2).

➕ **Also done, from §7's open items:** both overclaiming doc comments corrected, all three weak
assertions strengthened, and `OpcConnectionStub` gained body recording (`Sent`, `BodiesFor`) because
step 5 needs to assert *what* was sent, not merely that something was.

---

## 4. Decisions made here

⚠ **The series is `P-01`–`P-337`; this card mints `P-338`–`P-342`, so the next story mints at
`P-343`+.**

| id | Decision |
|---|---|
| **`P-338`** | **The delivery is a scope trade, not a shortfall — and it is recorded rather than silently re-priced.** The `FR-074` family (8 tests, unpriced authorship) landed in place of nine `FW-151` conversion scenarios. ⛔ **The `Hours` cell stays at 16**: the residual is ~6 h *inside* it, and the cell feeds three client `.xlsx` generators |
| **`P-339`** | **Doc comments here assert capabilities that do not exist, and nothing catches them — TWICE in one story.** ⛔ **(a)** `<see cref="AuditTrail"/>` names a **non-existent member**: `GenerateDocumentationFile` is unset solution-wide and `FW-263`'s `.editorconfig` disables analyzers for the test project, so `CS1574` cannot fire. ⛔ **(b)** The string-status test's `<remarks>` claims it *"turns that into a visible failure"* — **it would stay green if the hazard occurred** (§2.4a). **Fix (a) by BUILDING the promised recorder** (the missing scenarios need it) and **(b) by correcting the sentence**, since the hazard is not detectable below the withdrawn contract level |
| **`P-340`** | ⭐ **Falsifiability must be CHECKED and COUNTED, not asserted — the standing rule for `FW-264`–`FW-267`.** Disable the branch, count what goes red, restore, re-run, and put the count in the commit message. `33bab507f` is the worked example: exactly three red, four correctly still green |
| **`P-341`** | **The numeric enum form is the wire contract, it is load-bearing, and NO UNIT TEST CAN PROTECT IT.** ⛔ **Adding a string-enum converter to `OPCConnection` would make every refused tag deserialize to `Written` and `FR-074` would stop working with no error.** ⚠ **The delivered test does not catch this and cannot** — it drives the stub by hand, so it is unaffected by what the real service emits. **Detecting it needs a contract test against `OPCConnection`, the level `D-50` left withdrawn** — so this is a residual `[TS §1.2]` owns, not a gap in this card |
| **`P-342`** | ⛔ **An assertion must be as strong as the criterion it claims to satisfy — three here are not.** Only **one** test in the `PLCTagService` set asserts `result.Success` is true; the two `FR-074` *positive halves* assert merely `DoesNotContain("were not written")`, so a push failing for an unrelated reason passes both — and the scenario-2 test asserts `NotNull(FailureReason)`, proving nothing about content or audit. **A positive half that never asserts success is not a positive half.** Each fix is one line, and this pairs with `P-340`: falsifiability is checked by *counting what goes red*, which a too-weak assertion silently defeats |

---

## 5. Verification

### 5.1 Measured 6 Sep 2026

Run from `c:\UAL\Second-Branch\ual-api\API\Domain\FlatWire`:

```powershell
dotnet build FlatWire.sln --no-incremental     # ⛔ --no-incremental, or the count is wrong
dotnet test  FlatWire.UnitTests/FlatWire.UnitTests.csproj --no-build
```

| Check | Result |
|---|---|
| Suite | ✅ **293 passed · 0 failed · 0 skipped** — **279 → 293**, 14 new |
| Full rebuild | ✅ **0 errors · 22 warnings** — **unchanged**; no production project gained a warning |
| Production untouched | ✅ `PLCTagService.cs` **byte-identical**, git-clean after the mutation pass |
| Line anchors `:402`, `:1036`, `:1049` | ✅ All three still resolve exactly |
| All six public operations exercised | ✅ was **1 of 6** |
| `FW-151` §5.1 scenarios | ✅ **11 of 11** — was 1 full + 1 partial |

### 5.2 ⭐ Falsifiability — proven by mutation, not asserted (`P-340`)

Each production behaviour was broken **on purpose**, the suite run, and the file restored. ⛔ **Every
mutation reddened EXACTLY ONE test, and the right one** — which is the evidence that these tests
assert the behaviour they claim to and not something adjacent.

| Mutation | Red | The test that caught it |
|---|---:|---|
| Confirm probe **pre-populated** with the written values | **1** | `The_sentinel_a_silently_dropped_write_is_never_Confirmed` — all four turn `Confirmed` |
| `OPCInfo` **cache lookup removed** | **1** | `A_second_push_reuses_the_cached_OPCInfo` |
| **`IsReadonly` guard disabled** | **1** | `A_read_only_module_fails_the_push_without_attempting_a_write` |
| `SetITInhibit` given **`Confirm: true`** | **1** | `SetITInhibit_writes_once_and_issues_no_confirm_read` |
| Compensation **zeroes analogues too** | **1** | `A_mismatch_fails_the_push_and_re_clears_only_the_flags` |

⛔ **The first mutation is the one that matters most**, because pre-populating the confirm request is
the plausible-looking optimisation that would turn this service into one that always reports success.
It is now impossible to make it without a red test.

⚠ **What 293 green still does not mean.** ⛔ **`G33` is untouched** — a wrong path reads back
consistently wrong, and `[PLC §10.3]` puts that beyond any unit test. ⛔ **Nothing here detects
`OPCConnection` changing its wire format** (`P-341`). ⛔ **No coverage percentage** was measured or
gated (`D-50`). ⛔ **Nothing has been proven against a real controller** — `C1`/`C11` remain the only
things that can.

---

## 6. Handoff

### 6.1 ✅ What `G101` can now claim from this card

✅ **`FW-236`'s untested `FR-074` branch — the specific finding that minted `G101` — is covered, and
provably so** (§5.2). ✅ **`PLCTagService` can now be cited as covered at the unit level**: all six
public operations are exercised, all 11 of `FW-151` §5.1's scenarios are committed, and the five
behaviours a reviewer would most want protected are each proven to redden a test when broken.

⛔ **What `G101` still cannot claim from it.** The suite is **unit level only** — `D-50` reinstated
nothing else. `G33`, the wire-format hazard (`P-341`) and *"a tag push configures the machine"* are
all outside it, and `G101` closes for the set only when `FW-264`, `FW-266` and `FW-267` are also done.

### 6.2 For whoever reviews this, and for the rest of the set

| | |
|---|---|
| ⭐ **Copy the method** | §5.2's mutation pass into `FW-264`, `FW-266` and `FW-267`. **Break it, count what goes red, restore, and put the count in the commit message.** It is the only thing that distinguishes a suite from decoration |
| ⛔ **The trap it caught** | A stub answering a **fixed** body cannot detect a change to what the SUT *sends*. Where the assertion is about the request, the double must **depend on the request** — see `OpcConnectionStub.EchoUnchanged` |
| **Reuse, do not re-derive** | `PLCTagServiceFixture.RealWrite()`, the `AuditTrail` recorder, `OpcConnectionStub.BodiesFor()` and `NewContextWithBearer()` (§2.7) |
| ⛔ **Do not touch** | `PLCTagService.cs`. This story never needed a production change and did not make one |

### 6.3 ⛔ One detail of `FW-151 §5.1` is falsified by converting it

Scenario 1's row says the audit is *"5 `Attempted` then 5 `Succeeded` … **with `Simulated=true`**,
operator and run on every record."* ⛔ **It is not true of the `Attempted` records.** The build
measured `Simulated = false` on all five attempts and `true` only on the five outcomes, and pinned
it (§2.6).

⚠ **`FW-151` is `done` and is NOT reopened for this** — the harness it describes was never
committed, so the row records an uncommitted observation that the committed test now corrects.
**Read the test, not the row, for this detail.** ✅ Everything else in scenario 1 held exactly.

### 6.4 Owed to the planning repository

- ⚠ **`[TB §7.2]`'s `FW-265` card still describes the story as *"mostly conversion"*.** Not edited
  there — a card records what was true when written, per the `FW-236` → `FW-238` precedent. ✅ It is
  now *true in outcome*, if not in how it got there: all 11 scenarios are converted.
- ⚠ **`FW-263`–`FW-267` still have no rows in [`Orchestration.md`](Orchestration.md)** — a five-row
  block belonging to whoever closes the set.
- ⚠ **`[TS §1.2]`'s withdrawn Contract row now owns a named residual** — the string-enum hazard
  (`P-341`), which no unit test can reach.

---

## 7. Open items

| # | Item | Owner |
|---|---|---|
| 1 | ✅ **CLOSED** — the sentinel and scenario 5b (§3 steps 2–3) | ~~BE~~ done |
| 2 | ✅ **CLOSED** — scenarios 3, 4, 6, 7, 8, 9, 10 (§3 steps 4–8) | ~~BE~~ done |
| 3 | ✅ **CLOSED** — the `AuditTrail` recorder, now sink-aware (`P-339a`) | ~~BE~~ done |
| 4 | ✅ **CLOSED** — the three weak assertions strengthened (`P-342`) | ~~BE~~ done |
| 5 | ✅ **CLOSED** — the string-status `<remarks>` corrected (`P-339b`) | ~~BE~~ done |
| 6 | ⛔ **The work is UNCOMMITTED** — in the `ual-api` working tree on `feature/UADEV-23146`, alongside changes this pass did not make | BE / review |
| 7 | ⚠ **AC 8's residual** — no unit test can detect `OPCConnection` switching to string enums (`P-341`) | `[TS §1.2]`, withdrawn contract level |
| 8 | ⚠ `FW-263`–`FW-267` `Orchestration.md` rows (§6.4) | Whoever closes the set |

⛔ **Items 6–8 are open by ownership, not oversight. Nothing is owed by this card.**

---
