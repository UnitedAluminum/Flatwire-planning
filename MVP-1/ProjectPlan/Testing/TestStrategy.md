# Flat Wire Mill — Test Strategy

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 18, 2026 — **`D-32`: there is no shared-schema migration.** The FW-001 rename regression is struck from scope and **`P2` is retired** *(previously August 15, 2026 — **E2E respecified on Playwright driving real OPC tags** (§1.2, §3.1) and **UAT's entry criterion given a trial-scoped substitution** (§4.1): automated E2E is Phase 14 and out of trial scope, so [TRP §8]'s manual acceptance run satisfies the gate for the trial. Same day: **all automated backend tests withdrawn**: §1.2's *Unit — .NET* and *Integration — API* rows struck, *Contract* demoted to manual inspection, and §4.2's **QA0 row re-specified** as a signed-off manual contract walkthrough for 1B. The Jest 95 % bar on 1A is untouched and the asymmetry is recorded as deliberate *(otherwise August 13, 2026 — split out of `06-TestPlanAndTestCases.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*)*
**Document Type:** Strategy, scope, environments, gates, defect management
**Status:** Baselined
**Owner:** QA stream
**Audience:** QA, developers, release manager
**Shortcode:** `[TS]`
**Part of:** `ProjectPlan/Testing/` — index: [README.md](../README.md)

---

## 1. Test strategy

### 1.1 Objectives

1. Prove the eleven success criteria in `[VS §9]` — they are the release gates.
2. Prove every `FR-###` in `[REQ §5]` is implemented as specified, including its **error paths**, not only its happy path.
3. Prove the **contractual** obligations: weld genealogy (`NFR012`) and audit (`NFR010`/`NFR011`). These are not internal quality goals — a welding-wire customer's certificate depends on the first, and a quality audit on the second.
4. Establish, before go-live, that a rollback is executable — `[RB §6]`.

### 1.2 The pyramid, mapped onto the UAL stack

| Level | Technology | Owns | Runs |
|---|---|---|---|
| **Unit — Angular** | **Jest 29**, at the repository's **95 % coverage bar** (branches, functions, lines, statements) | Component logic, pipes (including the edge-type display pipe), validators, the SignalR ring buffer, chart data transforms | Every commit |
| ~~**Unit — .NET**~~ | — | **Withdrawn 15 Aug 2026 — see the callout below.** There is **no automated backend test level** | — |
| **Component — Angular** | Jest + Testing Library | A screen against a mocked API and a mocked hub, including error and permission states | Every commit |
| ~~**Integration — API**~~ | — | **Withdrawn 15 Aug 2026** — no xUnit suite against a seeded `FlatWireDB` | — |
| **Contract** | **Manual** review against `[API]` | Every endpoint's request/response shape, status codes and error codes; the C# ↔ TypeScript ↔ DB `CHECK` enum mirror | Per PR — **by inspection**, no longer asserted by a suite |
| **Real-time / load** | A hub client harness | Cadence, batching, decimation, group isolation, reconnect and group re-join | QA2, then nightly |
| **E2E** | **Playwright** (`@playwright/test`), driving **real OPC tags** into a test-only server — see §3.1 | The three route journeys FL1 / FL2 / FL3 end to end | QA3, QA4 |
| **PLC / OPC commissioning** | Manual, on the line, with the commissioning engineer | Tag paths, tag push, `LineState`, footage counter, ITInhibit | On-line trial |
| **UAT** | Manual, operator-run, on staging | The scenario scripts in §7 | QA5 (28–30 Sep) |

> ### ⚠ There are no automated backend tests — decision of 15 Aug 2026
>
> **`FlatWire` ships with no xUnit suite of any kind**: no unit tests, no validator tests, no
> stub-fixture/contract suite, and no integration suite against a seeded `FlatWireDB`. Two rows
> above are struck for that reason and the **Contract** row is demoted to manual inspection.
>
> **The asymmetry with Angular is deliberate, not an oversight.** Jest stays at the repository's
> **95 % coverage bar** on the frontend while the backend carries none. Anyone reading this table
> and assuming the .NET rows were forgotten should read this callout instead.
>
> **What this costs, stated once so it is not rediscovered per phase:**
> - **1B's QA0 component becomes manual** — §4.2, and see the walkthrough that replaces it.
> - **`[API §7.3]`'s de-stub switchover has no completion test.** A screen moves off the stub when
>   *"the real endpoint returns the contracted shape … its error cases return the contracted
>   codes"* — now established by review, so the de-stub pass needs a named signer-off per screen.
> - **Regression across Phases 4–14 is manual.** The saving is booked once in Phase 1B; the cost
>   recurs in every later phase and lands hardest in Phase 14, which *is* the QA phase.
> - **Two gap closures lose their evidence** — `G14`'s format half and `G21`'s domain half. Both
>   are restated in `[GAP]` as *closed by design, unverified*.

**The enum mirror is now a manual contract check.** Three of the four corrections in `[API §2.3]`
were a value present in one place and missing from another. `TC-020` still requires C#, TypeScript
and the DB `CHECK` to agree for **every** enum — but with no contract suite it is a **three-way
diff across 14 enums performed by hand, and it needs a named owner** rather than a green build.

### 1.3 Test-case identifiers

`TC-###`, allocated in blocks that mirror `[REQ §5]`:

| Block | Area | Block | Area |
|---|---|---|---|
| 001–030 | Cross-cutting (`§5.0`) | 355–369 | WIP rejection (`§5.14`) |
| 040–069 | Pre-check-in (`§5.1`) | 375–399 | Rod checkout (`§5.15`) |
| 070–109 | Rod check-in (`§5.2`) | 405–429 | Coil completion (`§5.16`) |
| 110–124 | Spool check-in (`§5.3`) | 435–444 | Packing (`§5.17`) |
| 130–159 | Active run (`§5.4`) | 450–484 | Pass schedule (`§5.18`, `§5.19`) |
| 160–184 | Spool completion (`§5.5`) | 490–509 | Line status (`§5.20`) |
| 190–214 | Weld (`§5.6`) | ~~515–524~~ | ~~HMI (`§5.21`)~~ — withdrawn |
| 220–244 | SPC (`§5.7`) | ~~530–539~~ | ~~SCADA (`§5.22`)~~ — withdrawn |
| 250–264 | Roll adjust (`§5.8`) | 545–554 | Shift summary (`§5.23`) |
| 270–289 | Die change (`§5.9`) | 560–564 | OEE (`§5.24`) |
| 295–309 | Die management (`§5.10`) | **600–629** | **NFR verification (§6)** |
| 315–329 | Pause/resume (`§5.11`) | **640–659** | **Security and roles (§8 of `[REQ]`)** |
| 335–344 | Stop transaction (`§5.12`) | **700–714** | **Deployment smoke (`[DEP §5]`)** |
| 350–352 | Wire break (`§5.13`) | | |

---

---

## 2. Scope

### 2.1 In test scope

Every screen, endpoint, hub event, database constraint and PLC interaction in `[REQ]`, `[API]` and `[ARC]`; ~~the FW-001 shared-schema rename regression;~~ *(struck 18 Aug 2026, `D-32` — there is no migration to regress)* the deployment and rollback procedures.

### 2.2 Out of test scope

| Area | Owner | What this plan assumes |
|---|---|---|
| Rod receiving (`R#####` generation, chemistry, weight validation, suspend logic) | CoilReceiving team | A rod row exists in `coils` with valid data. **Fixture-supplied here** |
| Order planning and line scheduling | Planning / Scheduling teams | A `planning_routings` allocation and a line booking exist. **Fixture-supplied here** |
| Web changes (Orders, Quotes, IQR, Item Template, Vendor) | Web team | The order carries the Flat Wire flag, bundle width and edge type |
| Coil Yield and Cost Ledger internals | Its own module | This plan tests only what this module **produces** for it |
| OPC server behaviour | Existing infrastructure | Unchanged; only the PLCs are new |

### 2.3 Risk-based prioritisation — where depth goes

Test depth is not spread evenly. **P1** areas get happy path, boundary, negative, permission, real-time and concurrency coverage. **P3** areas get happy path plus the primary error.

| Priority | Area | Why |
|---|---|---|
| **P1** | **Weld genealogy end to end** | Contractual (`NFR012`). A wrong chain is a wrong certificate |
| **P1** | **Pass-schedule acknowledgement → PLC tag push** | The only path that configures the machine. A wrong push is a wrong product |
| **P1** | **`ITInhibit`** | The safety interlock. All five set conditions, **and that it is line-scoped** — a blocked line must not block the other two (`[PLC §8.1]`, **D15**) |
| **P1** | **Footage → weight** | Every weight, yield and remaining-weight figure. **And the ±2 % threshold is arithmetically unreachable from target dimensions** |
| **P1** | **FL2's `null` live gauge/width** | A client that treats absence as a fault breaks the whole FL2 route |
| **P1** | **The cross-system check-in boundary** | Not one ACID transaction; recovery is undecided (**OI-39**) |
| **P1** | **MMS ID lifecycle** | Closes strictly on consumption, never on operator action — and ITInhibit depends on it |
| **P2** | Check-in gates, the three checkout modes, carry-forward, SPC gating, roll adjust, die change, pause/resume, WIP rejection, skid rule, reconnect, role matrix, audit | Core operator journeys |
| ~~**P2**~~ | ~~FW-001 rename regression~~ — **RETIRED 18 Aug 2026, `D-32`** | ~~High blast radius across other modules~~ — no migration, no regression surface. ⚠ **`OI-111` is not a test target**: it asks which existing reports read `coils.coil_status`, which is an inventory question for IT, not a case in this plan |
| **P3** | Shift summary, OEE, reports | Descope-ladder candidates; loss is visibility, not production. *(DB13 and DB14 were the other two and are descoped.)* |

---

---

## 3. Environments and test data

### 3.1 Environment per level

| Level | Environment | Data |
|---|---|---|
| Unit (both stacks) | Developer machine / CI | In-memory fakes; no database |
| Component (Angular) | Developer machine / CI | The **mock API service** and a **mock hub**, both mirroring the DB seed |
| Integration (API) | `test1` / `test2` (`devual-uadev001` / `002`) | A **freshly built and seeded `FlatWireDB`**, torn down and rebuilt per run |
| Contract | `test1` | Seeded `FlatWireDB`, real API |
| Real-time / load | `dev1` or `staging` | Simulated tag source at the configured cadence — `FW-203` for the trial, `[SIM]`'s in-process adapter (`FW-211`) thereafter |
| E2E | `staging` | Full seed (five seeds, 33 tables) + a **test-only OPC server sidecar** the suite writes tags into — **owned by `FW-217`** (`[SIM §3.3]`), which re-hosts the same line models behind a real OPC endpoint so `FW-N05`'s ingest is exercised rather than bypassed. ⚠ **Never the production OPC servers** — they are unchanged infrastructure (`[PLC §5.3]` A5) |
| PLC commissioning | The physical line | Live PLC, live OPC — **no simulation** |
| UAT | `staging` (`uanet-staging`, or `devual-uadev001` if staging is unavailable) | A UAT dataset refreshed the morning of each UAT day |

### 3.2 Building and tearing down the database

**SQLCMD mode is required** — `FlatWire_DDL_RunAll.sql` uses `:r` includes and `:on error exit`, and the include paths are **relative to the invocation directory**.

```powershell
# Full build + seed, in order. Run FROM the SQL folder — the :r paths are relative.
cd "c:\UAL\Flatwire-planning\MVP-1\ProjectPlan\Database\Schema\SQL"
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql

# A single script
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_04_Runs.sql

# Drop everything — see the warning below
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql
```

In SSMS, enable **Query → SQLCMD Mode** before executing `RunAll`.

> **Every script guards its objects, so `RunAll` is idempotent and safe to re-run** against an existing `FlatWireDB`. **`FlatWire_DDL_99_Teardown.sql` drops everything** — it is a test-environment tool and must never be run against an environment holding production data. See `[RB §6.2]`.

### 3.3 Seed data — a coherent dataset, not disconnected fixtures

Seed order is strict — **Lookup → Schedule → Materials → Runs → Quality/Output** — because the schedule seed depends on the lookup IDENTITY values.

| Seed file | Content |
|---|---|
| `FlatWire_SampleData_Lookup.sql` | `Stand` with **fixed IDENTITY** 1=FM1 (12″), 2=FM2_S1 (8″), 3=FM2_S2 (6″), 4=FM2_S3 (6″, final) — **four rows; the former Id 5 is withdrawn** · `Drawer` 1–13 (`DIE-0210`…`DIE-0340`) · `Edger` 1=`EDGE-ROUND-A`, 2=`EDGE-SQUARE-B` · `SpoolConfiguration` · `AlloyProperty` for 1100 / 1350 / 3003 / 5052 / 6061 |
| `FlatWire_SampleData_Schedule.sql` | 10 `PassSchedule` + 70 `PassScheduleComponent` (7 per schedule) + change-log rows. Coverage: Draft 3 / Active 6 / Inactive 1 · FL1 8 / FL2 1 / FL3 1 · Round 6 / Square 4 |
| `FlatWire_SampleData_Materials.sql` | 8 rods, 5 runs, 3 spools — `RUN-0001` FL1 standalone → coil `FW-00421-C01` from `R00041` + welded `R00042` · `RUN-0002` FL3 hybrid → coil, no spool · `RUN-0003` FL1 hybrid → spools `SP-00031/32` · `RUN-0004` FL2 finishing, **Paused**, consuming `SP-00031` · `RUN-0005` FL1 **aborted** with a mid-run checkout producing partial spool `SP-00033` |
| `FlatWire_SampleData_Runs.sql` | `RodCheckin`, `RodStaging`, `SpoolCheckin`, `FlatWireRunDetail`, `RunPauseEvent`, `WeldEvent`, `RollOverride`, `DieChangeEvent`, `RunReading` |
| `FlatWire_SampleData_QualityOutput.sql` | `SpcCheckpoint`, `SpcMeasurement`, `WipRejection`, `CoilOutput`, `CoilTraceability`, `RodCheckout` |

Every block is guarded by `IF NOT EXISTS`; computed columns and `ROWVERSION` are never inserted; `CoilTraceability` ranges are seeded **non-overlapping** so the trigger passes.

**The Angular mock service and the .NET stubs must mirror this seed.** Canonical alphas: `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042` / `RUN-0043`.

> **Known seed defect.** `FlatWire_SampleData_Schedule.sql`'s header comment claims Standalone 3 / Hybrid 7 coverage; **the actual content is 4 / 6**. The data is correct; the comment is wrong. `TC-005` asserts the actual distribution so the comment cannot mislead a tester.

### 3.4 PLC simulation versus the real line

| Until commissioning | At commissioning |
|---|---|
| `SimulatePLCTagPush` logs intended writes with **no live connection** | Real tag writes to the real PLC |
| A mock SignalR stream feeds gauge/width/speed/weight/footage at the configured cadence | Live OPC subscription |
| `FL{n}.LineState` is a test double the harness drives | The real tag — **whose vocabulary is undocumented (OI-35)** |

The machine model behind that stream is specified in [`MachineSimulator.md`](../Architecture/MachineSimulator.md) `[SIM]` — the scenario and fault catalogue a tester drives it with is `[SIM §7]`, and every behaviour it models is listed as an individually confirmable row in `[SIM §5.6]`.

**What cannot be tested before commissioning**, and must therefore be on the commissioning checklist (§8):

- That the configured **tag paths are correct** — they are confirmed with Tim O. and the commissioning engineer, and are config-driven so they can be corrected without a redeploy.
- That `FL{n}.LineState` reports the states the rod-checkout gatekeeper and the spool stop-confirmation depend on.
- That the **footage counter** increments as expected and that die-life accumulation reads it correctly.
- That a **tag push actually configures the machine** — the end of the chain the whole system exists to drive.
- That `ITInhibit` genuinely blocks machine run.
- ⚠ **That the simulator's own model matches the machine.** Every channel it drives rests on an unconfirmed reading, and a convincing simulator makes that easier to forget rather than harder — gap **`G39`**. `[SIM §5.6]` lists the ten assumptions individually so each can be checked; the proposed act that checks them is **`C13`**, and it is **not yet written into `[COM]`**.

---

---

## 4. Entry / exit criteria and gates

### 4.1 Per level

| Level | Entry | Exit | Suspension |
|---|---|---|---|
| **Unit** | Code compiles | 95 % coverage bar met (Angular); all validator rules covered (.NET) | Coverage below bar → PR blocked |
| **Component** | Mock API and mock hub return contracted shapes | Every screen renders its happy, error and permission states | Mock diverges from `[API]` → suspend until realigned |
| **Integration** | `FlatWireDB` built and seeded; API running | Every command writes the specified rows; every constraint rejects what it should | Seed fails or is stale → suspend, rebuild |
| **Contract** | `[API]` published for the endpoint | Shapes, status codes, error codes and the enum mirror all match | A contract change without a document update → suspend |
| **Real-time** | Hub reachable; simulated source running | Cadence, batching, group isolation and reconnect verified | **Pass criteria for load are undefined — see §6.2** |
| **E2E** | All phases in the route complete; staging seeded | Three green route runs (FL1, FL2, FL3) | Any Critical defect open → suspend |
| **UAT** | Three green E2E runs; Critical open issues closed | Sign-off recorded per scenario | > 2 Severity-1 defects → suspend and re-plan |

> ### ⚠ UAT's entry criterion — one trial-scoped substitution
>
> **For MVP-1 go-live the criterion above is unchanged: three green *automated* E2E runs.**
>
> **For the 30 Sep trial run it cannot be met, and is substituted rather than waived.** Automated E2E is
> **Phase 14 work and deliberately out of trial scope** (`[TRP]`), so no automated run will exist by
> 30 Sep — while `[TRP]` commits to UAT signed off inside that window. Left alone, the trial's UAT would
> start with its stated gate unmet and nobody would notice.
>
> **The substitute is `[TRP §8]`'s ten-step FL1 → FL2 acceptance run**, executed manually. That is not a
> concession — it *is* an end-to-end journey, written as a numbered script, and it is what UAT executes
> anyway. It covers check-in → active run → SPC → WIP rejection → spool completion → FL2 check-in → FL2
> run → reconnect, with the negative cases named.
>
> **What the substitution does not cover, stated so it is not assumed:** FL3 hybrid (`FW-122`) is not in
> the trial at all; weld traceability is out with the 14 Aug removal; and a manual run proves the journey
> **once**, on one operator's path, with no regression value for the next change. Automated runs remain
> the criterion for go-live precisely because of that last point.

### 4.2 Programme gates

| Gate | Date | Contents | Blocks |
|---|---|---|---|
| **QA0** | **14 Aug** | Jest smoke suite (1A) · **signed-off manual contract walkthrough + `/health` shape (1B)** · **DDL/seed idempotency and the 25-table post-run check** (1C) | The Phase-1 hard gate |
| **QA1** | 6 Sep | Pass-schedule and generator unit + contract suites green, **including the corrected worked example** | Phase 4 start |
| **QA2** | 13 Sep | Check-in rollback and real-time integration verified on staging · **hub load test (N clients × 3 lines × cadence)** | Phase 6 confidence |
| **QA3** | 24 Sep | FL1 + FL2 E2E pass (`FW-120`, `FW-121`) | Phase 14 |
| **QA4** | 28 Sep | FL3 hybrid E2E pass (`FW-122`) · **regression on renamed-column reports** | Go-live |
| **QA5** | 30 Sep | Full UAT (`FW-123`); all Critical open issues closed | Release |

> **QA0's 1B component, in full.** With no backend suite to run, 1B's gate contribution is a
> **manual contract walkthrough, signed off by a named reviewer**, covering `[API §7.2]`'s five
> stub obligations against every stub endpoint:
>
> 1. the **exact envelope**, including `success` and `errors`;
> 2. the **canonical fixture alphas** — `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`,
>    `RUN-0042`/`RUN-0043` — matching the DB seed;
> 3. **at least one failing case per endpoint**;
> 4. **`null` live gauge and width for FL2**;
> 5. a **mock hub stream** at the real cadence with real batch shapes.
>
> Plus `GET /health` returning the full documented shape, and **`TC-020`'s three-way enum diff**
> with its owner named. **This is the whole of 1B's automated-to-manual substitution** — if the
> walkthrough is not scheduled and staffed, the Phase-1 gate has no 1B criterion at all.

> **QA2's hub load test has no pass criteria.** `N`, the latency budget and the AGC sample rate are all undefined (**G9 / OI-34**). **A test that cannot fail is not a gate.** Either the targets are set before 13 Sep or QA2 is recorded as executed-but-not-gating. This is stated so the gap cannot pass silently.

### 4.3 Resumption

Testing resumes when the suspending condition is cleared **and** the affected suite is re-run from a clean environment — not from the point of failure.

---

---

## 9. Defect management

### 9.1 Severity

| Severity | Definition | Examples | SLA |
|---|---|---|---|
| **S1 — Critical** | Production cannot run, material is mis-tracked, or a certificate would be wrong | Tag push configures the wrong values · traceability rows wrong or overlapping · ITInhibit fails to block · a checkout while the line runs · data loss | **Fix immediately**; blocks the release |
| **S2 — High** | A core workflow is blocked with no workaround | Check-in cannot complete · a screen cannot load · an approval is lost | Fix within the sprint; blocks the gate |
| **S3 — Medium** | A workflow is degraded but has a workaround | A filter misbehaves · a badge shows the wrong colour · a report column is wrong | Fix before UAT |
| **S4 — Low** | Cosmetic or convenience | Label wording · sort order on a non-critical column | Backlog |

### 9.2 Priority

Independent of severity, set by risk area (§2.3). A P1-area S3 outranks a P3-area S2.

### 9.3 Release gate

| Gate | Rule |
|---|---|
| **QA0 – QA4** | Zero open S1. No more than two open S2 in the gate's scope, each with an accepted workaround |
| **QA5 / UAT** | **Zero open S1. No more than three open S2**, each with an agreed workaround. All Critical open issues closed |
| **Go-live** | The above, plus a rehearsed rollback (`[RB §6]`) and a green PLC commissioning sequence (§8) |

---
