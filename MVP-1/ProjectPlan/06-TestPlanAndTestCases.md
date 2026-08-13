# Flat Wire Mill — Test Plan & Test Cases

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026
**Document Type:** Test plan + test case catalogue
**Status:** Baselined — four NFRs are **untestable until their targets are defined** (§6.2)
**Owner:** QA stream
**Audience:** QA, developers, UAT participants, PLC commissioning engineer
**Sources:** `[SRS]` [02-SRS.md](./02-SRS.md) (what to prove) · `[API]` [04-APIContract.md](./04-APIContract.md) (contract shapes) · [`../FlatWire_MasterSpecification.md`](../../LatestDocument/FlatWire_MasterSpecification.md) §4 error paths and §11 (risk-based prioritisation) · [`phase-14-integration-testing-plc-commissioning-golive.md`](ShopfloorPlan/phase-14-integration-testing-plc-commissioning-golive.md)

**Companion documents:** `[VS]` [01-VisionAndScope.md](./01-VisionAndScope.md) · `[HLD]` [03-HLD-and-ERDiagram.md](./03-HLD-and-ERDiagram.md) · `[SP]` [05-SprintPlanAndBacklog.md](./05-SprintPlanAndBacklog.md) · `[DR]` [07-DeploymentRunbookAndRollback.md](./07-DeploymentRunbookAndRollback.md)

---

## 1. Test strategy

### 1.1 Objectives

1. Prove the eleven success criteria in `[VS §9]` — they are the release gates.
2. Prove every `FR-###` in `[SRS §5]` is implemented as specified, including its **error paths**, not only its happy path.
3. Prove the **contractual** obligations: weld genealogy (`NFR012`) and audit (`NFR010`/`NFR011`). These are not internal quality goals — a welding-wire customer's certificate depends on the first, and a quality audit on the second.
4. Establish, before go-live, that a rollback is executable — `[DR §6]`.

### 1.2 The pyramid, mapped onto the UAL stack

| Level | Technology | Owns | Runs |
|---|---|---|---|
| **Unit — Angular** | **Jest 29**, at the repository's **95 % coverage bar** (branches, functions, lines, statements) | Component logic, pipes (including the edge-type display pipe), validators, the SignalR ring buffer, chart data transforms | Every commit |
| **Unit — .NET** | **xUnit + Moq** | MediatR handlers, **every FluentValidation rule**, the generator algorithm, weight derivation, the alert rules engine | Every commit |
| **Component — Angular** | Jest + Testing Library | A screen against a mocked API and a mocked hub, including error and permission states | Every commit |
| **Integration — API** | xUnit against a **seeded `FlatWireDB`** | Command handlers writing real rows; constraint and trigger behaviour; cross-DB compensating writes against a stubbed shared schema | Per PR to `main` |
| **Contract** | Schema assertions against `[API]` | Every endpoint's request/response shape, status codes and error codes; the C# ↔ TypeScript ↔ DB `CHECK` enum mirror | Per PR |
| **Real-time / load** | A hub client harness | Cadence, batching, decimation, group isolation, reconnect and group re-join | QA2, then nightly |
| **E2E** | Playwright or the repository's existing E2E runner | The three route journeys FL1 / FL2 / FL3 end to end | QA3, QA4 |
| **PLC / OPC commissioning** | Manual, on the line, with the commissioning engineer | Tag paths, tag push, `LineState`, footage counter, ITInhibit | On-line trial |
| **UAT** | Manual, operator-run, on staging | The scenario scripts in §7 | QA5 (28–30 Sep) |

**The enum mirror is a first-class contract test.** Three of the four corrections in `[API §2.3]` were a value present in one place and missing from another. `TC-020` asserts C#, TypeScript and the DB `CHECK` agree for **every** enum.

### 1.3 Test-case identifiers

`TC-###`, allocated in blocks that mirror `[SRS §5]`:

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
| 315–329 | Pause/resume (`§5.11`) | **640–659** | **Security and roles (§8 of `[SRS]`)** |
| 335–344 | Stop transaction (`§5.12`) | **700–714** | **Deployment smoke (`[DR §5]`)** |
| 350–352 | Wire break (`§5.13`) | | |

---

## 2. Scope

### 2.1 In test scope

Every screen, endpoint, hub event, database constraint and PLC interaction in `[SRS]`, `[API]` and `[HLD]`; the FW-001 shared-schema rename regression; the deployment and rollback procedures.

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
| **P2** | FW-001 rename regression | High blast radius across other modules |
| **P3** | Shift summary, OEE, reports | Descope-ladder candidates; loss is visibility, not production. *(DB13 and DB14 were the other two and are descoped.)* |

---

## 3. Environments and test data

### 3.1 Environment per level

| Level | Environment | Data |
|---|---|---|
| Unit (both stacks) | Developer machine / CI | In-memory fakes; no database |
| Component (Angular) | Developer machine / CI | The **mock API service** and a **mock hub**, both mirroring the DB seed |
| Integration (API) | `test1` / `test2` (`devual-uadev001` / `002`) | A **freshly built and seeded `FlatWireDB`**, torn down and rebuilt per run |
| Contract | `test1` | Seeded `FlatWireDB`, real API |
| Real-time / load | `dev1` or `staging` | Simulated tag source at the configured cadence |
| E2E | `staging` | Full seed + the E2E fixtures |
| PLC commissioning | The physical line | Live PLC, live OPC — **no simulation** |
| UAT | `staging` (`uanet-staging`, or `devual-uadev001` if staging is unavailable) | A UAT dataset refreshed the morning of each UAT day |

### 3.2 Building and tearing down the database

**SQLCMD mode is required** — `FlatWire_DDL_RunAll.sql` uses `:r` includes and `:on error exit`, and the include paths are **relative to the invocation directory**.

```powershell
# Full build + seed, in order. Run FROM the SQL folder — the :r paths are relative.
cd "c:\UAL\Flatwire-planning\LatestDocument\DBChanges\Schema\SQL"
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_RunAll.sql

# A single script
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_04_Runs.sql

# Drop everything — see the warning below
sqlcmd -S "<server>" -E -C -i FlatWire_DDL_99_Teardown.sql
```

In SSMS, enable **Query → SQLCMD Mode** before executing `RunAll`.

> **Every script guards its objects, so `RunAll` is idempotent and safe to re-run** against an existing `FlatWireDB`. **`FlatWire_DDL_99_Teardown.sql` drops everything** — it is a test-environment tool and must never be run against an environment holding production data. See `[DR §6.2]`.

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

**What cannot be tested before commissioning**, and must therefore be on the commissioning checklist (§8):

- That the configured **tag paths are correct** — they are confirmed with Tim O. and the commissioning engineer, and are config-driven so they can be corrected without a redeploy.
- That `FL{n}.LineState` reports the states the rod-checkout gatekeeper and the spool stop-confirmation depend on.
- That the **footage counter** increments as expected and that die-life accumulation reads it correctly.
- That a **tag push actually configures the machine** — the end of the chain the whole system exists to drive.
- That `ITInhibit` genuinely blocks machine run.

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

### 4.2 Programme gates

| Gate | Date | Contents | Blocks |
|---|---|---|---|
| **QA0** | **14 Aug** | Jest smoke suite (1A) · xUnit + stub-fixture + validator suites (1B) · **DDL/seed idempotency and the 27-table post-run check** (1C) | The Phase-1 hard gate |
| **QA1** | 6 Sep | Pass-schedule and generator unit + contract suites green, **including the corrected worked example** | Phase 4 start |
| **QA2** | 13 Sep | Check-in rollback and real-time integration verified on staging · **hub load test (N clients × 3 lines × cadence)** | Phase 6 confidence |
| **QA3** | 24 Sep | FL1 + FL2 E2E pass (`FW-120`, `FW-121`) | Phase 14 |
| **QA4** | 28 Sep | FL3 hybrid E2E pass (`FW-122`) · **regression on renamed-column reports** | Go-live |
| **QA5** | 30 Sep | Full UAT (`FW-123`); all Critical open issues closed | Release |

> **QA2's hub load test has no pass criteria.** `N`, the latency budget and the AGC sample rate are all undefined (**G9 / OI-34**). **A test that cannot fail is not a gate.** Either the targets are set before 13 Sep or QA2 is recorded as executed-but-not-gating. This is stated so the gap cannot pass silently.

### 4.3 Resumption

Testing resumes when the suspending condition is cleared **and** the affected suite is re-run from a clean environment — not from the point of failure.

---

## 5. Test cases

**Column key:** `Lvl` = U(nit) · C(omponent) · I(ntegration) · K = contract · R = real-time · E2E · M(anual). `Pri` = P1/P2/P3 per §2.3. `Auto` = automatable.

### 5.0 Cross-cutting — TC-001 … TC-030

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Data | Auto |
|---|---|---|---|---|---|---|---|---|
| **TC-001** | Manual login for a punched-in operator | I | P2 | FR-001 / `OL001` | Operator punched in → log in at FL1 station | Login succeeds; operator ID, timestamp and station captured | `john.d` | ✓ |
| **TC-002** | Manual login refused for a not-punched-in operator | I | P2 | FR-001 | Operator not punched in → attempt login | Refused; no session created | — | ✓ |
| **TC-003** | Supervisor override permits a not-punched-in login | I | P2 | FR-003 / `OL003` | As TC-002 → supply valid supervisor credential | Login succeeds; **operator ID, supervisor ID, timestamp and station all recorded** | `SUP-204` | ✓ |
| **TC-004** | Automatic shift-based login/logout | I | P2 | FR-002 | Shift schedule configured → shift boundary passes | Auto login and logout occur and **both are logged** | — | ✓ |
| **TC-005** | Seed distribution assertion | I | P2 | §3.3 | Freshly seeded DB → query schedule route modes | **Standalone 4 / Hybrid 6** — not the 3/7 the header comment claims | seed | ✓ |
| **TC-006** | "Who is running the machine?" prompt at check-in, stop and restart | C | P2 | FR-004 / `OL004` | Active run → trigger each of the three events | Prompt appears each time; **operation cannot continue until an operator is identified** | — | ✓ |
| **TC-007** | Speed > 0 with no identified operator | I | P1 | FR-004 | No operator against the run → mill speed rises above zero | Prompt raised and operation blocked | — | ✓ |
| **TC-008** | FL1 operator selectable at FL2 without re-login | I | P3 | FR-005 / `OL005` | Operator logged in at FL1 → open FL2 | Selectable without re-login; **association tracked per run, not per login** | — | ✓ |
| **TC-009** | Order-instructions popup after check-in | C | P3 | FR-006 / `ORD001` | Check-in completes | Popup shows instructions, hold information and observations | — | ✓ |
| **TC-010** | Order type "Flat" available | I | P3 | FR-007 / `ORD002` | Open the order-type list | "Flat" present alongside Split, Slit, Anneal, Roll | — | ✓ |
| **TC-011** | **ITInhibit — no coil checked in** | I | **P1** | FR-008, FR-009 / `ALT002` | Line idle, nothing checked in | ITInhibit **set**; machine run blocked | — | ✓ |
| **TC-012** | **ITInhibit — no active MMS ID** | I | **P1** | FR-009 / `ALT003` | Rod checked in; MMS ID closed | ITInhibit **set** | — | ✓ |
| **TC-013** | **ITInhibit — PLC feet data unavailable** | I | **P1** | FR-009 / `ALT004` | Suppress the feet tag | ITInhibit **set** | — | ✓ |
| **TC-014** | **ITInhibit — PLC feet data invalid** | I | **P1** | FR-009 / `ALT005` | Feed a non-numeric / out-of-range feet value | ITInhibit **set** | — | ✓ |
| **TC-015** | **ITInhibit — two consecutive recordings missing** | I | **P1** | FR-009, FR-020 / `DAT009` | Suppress two consecutive recording intervals | ITInhibit **set** **and** a prominent data-recording alert displayed | — | ✓ |
| **TC-016** | **ITInhibit clears only automatically** | I | **P1** | FR-008 / `ALT001` | ITInhibit set → attempt an operator clear via every UI surface | **No operator path exists.** Clears only when the condition resolves | — | ✓ |
| **TC-017** | ITInhibit blocks transactions and rolling-data capture | I | **P1** | FR-010 / `ALT006` | ITInhibit set → attempt a run transaction | Blocked; **no rolling data recorded without an active coil** | — | ✓ |
| **TC-017a** | **ITInhibit is line-scoped — a blocked line blocks only itself** | I | **P1** | FR-008 / `[PLC §8.1]` | FL2 running with a valid check-in → set each of the five conditions on FL1 in turn | FL1 **blocked** in every case; **FL2 unaffected throughout** — it keeps running, keeps recording and its own interlock stays clear. One tag per line, not one plant-level tag (`Q84`, decided Aug 4 2026) | — | ✓ |
| **TC-018** | Buildup alerts at 50 % then every 10 % | I | P2 | FR-011 / `ALT007` | Run progresses toward planned length | Alerts at 50, 40, 30, 20, 10 % remaining — **five alerts, in order** | — | ✓ |
| **TC-019** | Remaining-feed threshold alert | I | P2 | FR-012 / `ALT008` | Configure a threshold → cross it | Alert raised at the configured value | — | ✓ |
| **TC-020** | **Enum mirror — C# ↔ TypeScript ↔ DB CHECK** | K | **P1** | `[API §2]` | For every canonical enum, compare all three definitions | **All three agree, value for value**, for all 14 enums. `CheckpointType` has five values including `RollAdjustTrigger`; `ComponentName` includes `FM2_6inS3` and excludes `Edger`; `EdgeType` is `Round`/`Square` only | — | ✓ |
| **TC-021** | **MMS ID generated per input coil at check-in** | I | **P1** | FR-013 / `FRT005` | Check in a rod | Exactly one MMS ID created, status `Open` | — | ✓ |
| **TC-022** | **MMS ID activates when a welded coil becomes active** | I | **P1** | FR-013 / `FRT006` | Weld, then the running rod reaches 0 ft | The incoming coil's MMS ID becomes `Active` | — | ✓ |
| **TC-023** | **Previous MMS ID closes automatically** | I | **P1** | FR-013 / `FRT007` | As TC-022 | The previous MMS ID closes **without operator action** | — | ✓ |
| **TC-024** | **MMS ID closes strictly on consumption — never on operator action** | I | **P1** | FR-013 / `FRT008` | Attempt to close an MMS ID from every operator surface | **No path exists.** Closes only at remaining ft = 0 | — | ✓ |
| **TC-025** | One output spool references multiple MMS IDs | I | P2 | FR-013 / `FRT009` | Run consuming two welded rods → complete the spool | The spool record references both MMS IDs | — | ✓ |
| **TC-026** | Remaining length tracked for active **and** queued coil | R | P2 | FR-014 / `FRT001` | Rod running, second rod welded | Both remaining lengths update live from PLC feet | — | ✓ |
| **TC-027** | Output weight never taken from a scale during rolling | I | **P1** | FR-015 / `FRT010` | Complete a coil | Weight derived from **recorded length, gauge and width**; a scale value can only arrive as an explicit override | — | ✓ |
| **TC-028** | Two independent data-collection instances, used simultaneously in FL3 | R | P2 | FR-016 / `DAT001` | Start FL1 and FL2 independent jobs | Both instances collect concurrently with no cross-talk | — | ✓ |
| **TC-029** | Recording starts automatically at speed > 0 | I | **P1** | FR-017 / `DAT002` | Idle line → raise mill speed above zero | Recording starts; **no manual start action exists** | — | ✓ |
| **TC-030** | Gauge and width captured **simultaneously** at every point | I | **P1** | FR-019 / `DAT006` | Run at cadence | Every `RunReading` row carries both from the **same sample** | — | ✓ |

**Recording-cadence cases are in §6 (`TC-601`–`TC-603`)** because the cadence is `NFR003`/`NFR004`.

### 5.1 Pre-check-in — TC-040 … TC-069

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Data | Auto |
|---|---|---|---|---|---|---|---|---|
| **TC-040** | Stage a rod at an idle bay — happy path | I | P2 | FR-039, FR-048 | FL1, bay 2 empty, rod allocated → run the 3-step wizard, confirm | `RodStaging` written `Status='Staged'` with **server-assigned `RodSeqno`** and snapshotted `PlannedSeqno`; `PayoffStateChanged` broadcast; **no PLC write** | `R00043` | ✓ |
| **TC-041** | **No PLC write occurs at pre-check-in** | I | **P1** | FR-049 | As TC-040, with the PLC write path instrumented | **Zero tag writes** | — | ✓ |
| **TC-042** | Pre-check-in rejected on FL2 | I | P2 | FR-031 / `PCI002` | POST with `lineId = FL2` | `422 LINE_NOT_ELIGIBLE` | — | ✓ |
| **TC-043** | Rod with no allocation refused | I | P2 | FR-044 | Rod with no `planning_routings` row | `422 ROD_NOT_ALLOCATED` | — | ✓ |
| **TC-044** | Rod already `INFLAT` refused | I | P2 | FR-044 | Rod checked in elsewhere | `409 ROD_UNAVAILABLE` | — | ✓ |
| **TC-045** | Rod from a different order refused once an order is established | I | **P1** | FR-044 | Order A established → stage a rod from order B | `409 ROD_WRONG_ORDER` — **welding across orders would break genealogy** | — | ✓ |
| **TC-046** | **Bay occupancy enforced under concurrent staging** | I | **P1** | FR-048 | Two clients stage different rods to the same bay simultaneously | Exactly one succeeds; the other gets `409` **from `UX_RodStaging_Bay`, not a read-then-write race** | — | ✓ |
| **TC-047** | One bay per rod enforced | I | P2 | FR-048 | Stage the same rod to two bays | Second call `409` from `UX_RodStaging_RodActive` | — | ✓ |
| **TC-048** | **Inspection Fail is a hard block with no bypass** | I | **P1** | FR-041 / `CHK010` | Set any inspection item to Fail → confirm | `422 INSPECTION_FAILED` with `{route:"wipRejection"}`. **No override exists anywhere in the flow** | — | ✓ |
| **TC-049** | Exactly three inspection items at staging | C | P2 | FR-040 | Open the wizard step 3 | Three items — oxidation, surface defects, water stains. **No connector-tag item** | — | ✓ |
| **TC-050** | **Carry-forward forced when prior footage exists** | C | **P1** | FR-043 / `PRC008` | Rod with `footageRunToDate > 0` → open the wizard | Prior-run history shown; only *Proceed as partial re-check-in* and *Cancel* offered. **The fresh-start control is absent from the DOM** — assert by DOM query, not by disabled state | — | ✓ |
| **TC-051** | Carry-forward gate at the API | I | **P1** | FR-043 / `PRC007` | POST without `acknowledgedCarryForward` for a rod with prior footage | `422 CARRY_FORWARD_REQUIRED` | — | ✓ |
| **TC-052** | Diameter outside tolerance refused | I | P2 | FR-042 / `CHK007` | Enter a diameter outside nominal ± tolerance | `422 DIAMETER_OUT_OF_TOLERANCE`, valid range shown | — | ✓ |
| **TC-053** | Unknown rod alpha | I | P3 | FR-042 / `CHK006` | Scan an alpha not in `coils` | `404 ROD_NOT_FOUND` | — | ✓ |
| **TC-054** | **Wrong station auto-corrects — no message, no override** *(rewritten 1 Aug 2026)* | I | **P1** | FR-045 | On the FL1 tab, scan a rod whose order is booked on FL3 | The screen **switches to FL3** and the transaction continues. **No** blocking message, **no** supervisor prompt, and **no** `OffScheduleOverride` / `ScheduledLineId` written — those columns no longer exist | — | ✓ |
| **TC-054a** | Server rejects a wrong-station POST rather than writing it | I | **P1** | FR-045 | `POST /staging/rod` with `lineId=FL1` for an FL3-scheduled rod (stale client) | `409 WRONG_STATION` carrying `correctLineId: "FL3"`; **no row written**; the client switches and re-posts | — | ✓ |
| **TC-054b** | **Welded pre-check-out needs a supervisor and ends on HOLD** | I | **P1** | FR-052a | Release a staged rod with `IsWelded=1` | Refused without badge + PIN + reason. With them: `RodCheckout` Mode P, `WasWelded=1`, `NewRodStatus='HOLD'`; the rod does **not** return to the available pool. An **unwelded** release needs no approval | — | ✓ |
| **TC-054c** | **A WIP rejection clears a blocked bay** | I | **P1** | FR-053a | Stage a rod failing inspection (bay reads `BLOCKED`), then submit the rejection | Rod → `HOLD`; `RodStaging.Status='Unstaged'` with `UnstageKind='WipRejection'` and `WipRejectionId` set; `PayoffStateChanged`; **the bay is free and stageable again**. Nothing else clears it | — | ✓ |
| **TC-054d** | Diameter validates against an **asymmetric** min/max band | U | P2 | FR-042, FR-065 | Band −0.001 / +0.003 on nominal 0.375 | 0.3745 rejected, 0.3775 accepted, 0.3785 rejected. **Blocked until the values arrive** — the band is unseeded (OQ-22) | — | ✓ |
| **TC-055** | **Out-of-sequence is notified and authorised, never refused** | I | **P1** | FR-045 | Rod that is not the lowest available `plannedSeqno` | Not refused; override required; `OutOfSequenceOverride=1` and `ExpectedRodAlpha` persisted | — | ✓ |
| **TC-056** | One credential block covers both deviations | I | P2 | FR-046 | Both deviations apply | **One** sign-off satisfies both | — | ✓ |
| **TC-057** | **The PIN is never stored or echoed** | I | **P1** | FR-046 | Authorise with a PIN → inspect the row and the response | **PIN absent from the database and from every response payload**; only the flag, badge, timestamp and reason persist | — | ✓ |
| **TC-058** | Missing/incomplete authorisation rejected | I | P2 | FR-046 | Deviation applies, override omitted or partial | `422 SUPERVISOR_AUTH_REQUIRED`; `CK_RodStaging_Override` all-or-nothing holds | — | ✓ |
| **TC-059** | Bay card keeps showing the authorisation | C | P3 | FR-047 | Authorised staging → view the bay card | Override, supervisor and reason visible for as long as the rod is there | — | ✓ |
| **TC-060** | `rodSeqno` is server-assigned, not client-supplied | K | **P1** | FR-048 | POST including a `rodSeqno` field | Field ignored; server assigns the next actual position | — | ✓ |
| **TC-061** | Order is re-resolved server-side | I | **P1** | `[API §4.5]` | POST with an `orderId` that does not match `planning_routings` | Rejected on the server's own resolution | — | ✓ |
| **TC-062** | Cold line — empty queue and `—` header | C | P2 | FR-038 | No order established → open DB2A | Queue empty, order header reads `—`; the first scan **reveals** the order | — | ✓ |
| **TC-063** | Queue shows both sequence columns | C | P2 | FR-036 | Rods staged out of planned order | `Plan` and `Run` columns both present; deviation marker where they differ; **`rodSeqno < plannedSeqno` renders as normal, not as an error** | — | ✓ |
| **TC-064** | `Available` rows have null `rodSeqno` | K | P2 | `[API §4.7]` | Query the queue | Unprocessed rods carry `rodSeqno: null` and sort after processed rods | — | ✓ |
| **TC-065** | Payoff bar coloured by **absolute pounds** | C | P2 | FR-034 | Weight at 2,900 lb on a large-capacity bay | **Warning colour** (below 3,000 lb) regardless of percent | — | ✓ |
| **TC-066** | Critical when Payoff 2 unstaged and Payoff 1 < 2,000 lb | C | **P1** | FR-034 | Set that state | Critical styling and the "no weld material" alert | — | ✓ |
| **TC-067** | Mark-as-Welded validates against the running coil | I | P2 | FR-050 / `WLD006` | Staged rod with a different alloy → mark as welded | Rejected with a clear validation error, **regardless of the quality result selected** | — | ✓ |
| **TC-068** | **Mark-as-Welded does not switch bays** | I | **P1** | FR-051 / `WLD005` | Mark as welded (**quality Pass**) → inspect bay state | Weld recorded; **bays unchanged**. Transition happens only at 0 ft remaining | — | ✓ |
| **TC-068i** | **Outgoing / incoming resolved from the running bay, not the clicked card** | I | **P1** | FR-050a / `WLD010` | Reach the **transposed** arrangement — **Payoff 2 running, Payoff 1 staged** — then open *Mark as welded* from the Payoff 1 card | Outgoing = Payoff **2**'s rod, incoming = Payoff **1**'s rod, and the labels read *Outgoing — Payoff 2* / *Incoming — Payoff 1*. **Never transposed.** This is the rule the control's move onto the bay cards could most easily have broken | — | ✓ |
| **TC-068a** | **Weld quality is mandatory** | C | **P1** | `PCI022` / `WLD013` | Open Mark as welded | **Neither Pass nor Fail pre-selected**; Confirm disabled until one is chosen | — | ✓ |
| **TC-068b** | **A fail reason is mandatory on Fail** | C | **P1** | `PCI022` / `WLD013` / `CK_WeldEvent_FailReason` | Select **Fail**, leave the reason unset | Confirm **disabled**; enabled only once a reason is chosen; API returns `422` if posted without one | — | ✓ |
| **TC-068c** | **A failed weld does not mark the rod welded** | I | **P1** | `PCI022` (D7) | Record a weld with quality **Fail** + reason | `WeldEvent` row written with `WeldQuality='Fail'`; **`RodStaging.IsWelded` stays `0`**; bay still reads *not yet welded*; the station states the failure and its reason; Mark as welded **stays enabled** | — | ✓ |
| **TC-068d** | **A remade weld keeps both records** | I | P2 | `PCI022` (D7) / OI-59 | After TC-068c, record a second weld with quality **Pass** | Bay now reads **welded**; **two** `WeldEvent` rows exist for the same rod pair; *Welds this run* lists both, the failure in its fail styling with its reason | — | ✓ |
| **TC-068e** | **Welds this run is read-only and run-scoped** | C | P2 | `PCI021` / FR-051a | Open *Welds this run* **on the active bay card** | Lists only welds for the **active `RunId`**; **no confirm, edit or delete control**; a run with no welds shows the empty state, not an error, and the control stays **enabled at count 0** | — | ✓ |
| **TC-068f** | **Welds this run is absent at cold start** | C | P2 | FR-051a / OI-108 | Cold start — no rod running on either payoff | There is no active bay card, so **the control is not rendered at all**. *(Revised 1 Aug 2026 — it was previously a station-level control shown disabled with "no run in progress". Retest against OI-108 once the client confirms.)* | — | ✓ |
| **TC-068g** | **Mark as welded lives on the staged card and states why it is unavailable** | C | P2 | FR-050 | Cycle the staged card through: nothing running · other bay blocked · already welded · previous weld failed | Control is present on the **staged** card in every case; disabled for the first three with the matching explanation, enabled for the fourth reading *"Remake the failed weld"* | — | ✓ |
| **TC-068h** | **The active bay card offers no run link and no primary** | C | P3 | FR-051b | Inspect the active bay card | Actions are **Check out rod** and **Welds this run · N** only — **no *Open active run*** and **no emphasised (primary) action** | — | ✓ |
| **TC-069** | Pre-check-out reverses the WIP queue entry | I | P2 | FR-053 | Staged rod → pre-check-out | `Status='Unstaged'` with the audit stamp; `RodCheckout` Mode P written with null `RunId`, footage 0, `PlcTagsCleared` false; **the `wip_coil_orders` entry created at staging is reversed**; `PayoffStateChanged{NotStaged}` broadcast; **no line-state gate applied** | — | ✓ |

### 5.2 Rod check-in — TC-070 … TC-109

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Data | Auto |
|---|---|---|---|---|---|---|---|---|
| **TC-070** | FL1-only vs FL1+FL2 popup and station naming | C | P2 | FR-060, FR-061 / `CHK001` | Click Check-In at FL1 | Popup with two buttons; station becomes **"FL1 Station"** or **"FL3 Station" (Hybrid FL1 + FL2)** | — | ✓ |
| **TC-071** | FL2 opens check-in directly | C | P3 | FR-062 / `CHK003` | Click Check-In at FL2 | No line-selection popup | — | ✓ |
| **TC-072** | Mandatory fields enforced | C | P2 | FR-063 / `CHK004` | Leave rod number or diameter blank | Cannot proceed; Scrap Box remains optional | — | ✓ |
| **TC-073** | Diameter tolerance boundary — inside | I | P2 | FR-065 / `CHK007` | Nominal 0.30, tolerance ±0.01 → enter 0.29 and 0.31 | **Both accepted** (inclusive bounds) | — | ✓ |
| **TC-074** | Diameter tolerance boundary — outside | I | P2 | FR-065 | Enter 0.289 and 0.311 | Both rejected `422` | — | ✓ |
| **TC-075** | Scrap box auto-selects on matching alloy | C | P3 | FR-066 / `CHK008` | Previous rod same alloy → open check-in | Previously used scrap box pre-selected, still changeable or blank | — | ✓ |
| **TC-076** | Done-time validation battery | I | P2 | FR-067 / `CHK009` | Each of: order closed · plan closed · missing field · out-of-tolerance diameter · rod checked in elsewhere | Each blocks with its own error; **none proceeds** | — | ✓ |
| **TC-077** | Inspection failure routes to WIP Rejection | C | **P1** | FR-068 / `CHK010` | Fail a visual inspection item | Hard block; routed to DB8; **no bypass** | — | ✓ |
| **TC-078** | Pre-run SPC ovality derived and gated | C | **P1** | FR-069 / `CHK011` | Enter M1 0.375, M2 0.374 | Ovality shows **0.001**; Acknowledge stays disabled until it is within tolerance | — | ✓ |
| **TC-079** | **Acknowledge disabled until all six wizard steps clear** | C | **P1** | FR-079 | Complete five of six steps | Footer **Acknowledge & Begin Check-in** disabled; `n/6` progress accurate | — | ✓ |
| **TC-079a** | **Acknowledge returns the operator to DB2A** | C | P2 | FR-079a / OI-109 | Clear all six steps and press **Acknowledge & Begin Check-in** | Run opens and the operator lands on **DB2A — Rod Pre-Check-in**, *not* DB3. *(Revised 1 Aug 2026 — previously DB3. Retest against OI-109 once the client confirms.)* | — | ✓ |
| **TC-080** | Supervisor override unlocks a failed machine inspection | C | P2 | FR-081 | Mark an OK/NG/NA item NG → authorise override | Rod on hold; override requires badge, password **and a reason**; then Acknowledge enables | — | ✓ |
| **TC-081** | Attribute lookup recommends a schedule | I | P2 | FR-070 / `CHK014` | Alloy + diameter + target + route match one Active schedule | Confirm bar surfaces the recommendation; component table shows Active vs Bypassed | — | ✓ |
| **TC-082** | Non-recommended selection requires a reason and is flagged | I | P2 | FR-071 / `PSM018` | Choose an alternate schedule | Free-text reason required; selection flagged for Operations review | — | ✓ |
| **TC-083** | **Explicit confirmation gates the PLC push** | I | **P1** | FR-071 / `CHK015` | Load a schedule but do not confirm → attempt acknowledge | Blocked; **zero tag writes** | — | ✓ |
| **TC-084** | **Records are written before the PLC push** | I | **P1** | FR-072 / `CHK016` | Instrument the write order | Inspection, pre-run SPC, run, check-in and the acknowledgement event all commit **before** the first tag write | — | ✓ |
| **TC-085** | **Tag push is one batch; failure aborts with compensating writes** | I | **P1** | FR-073, FR-074 | Force a mid-batch tag failure | Check-in aborted `500 PLC_PUSH_FAILED`; tags re-cleared; shared status reverted; `wip_coil_orders` reversed; run marked aborted; **`PlcTagsPushed = 0`** | — | ✓ |
| **TC-086** | Incomplete-push marker survives for recovery | I | **P1** | FR-072 | Kill the process between the record write and the push | A recoverable marker exists on restart | — | ✓ |
| **TC-087** | Every tag write is audit-logged | I | **P1** | FR-075 / `INT004` | Successful check-in | One audit entry per tag with **path, value, operator, timestamp and result** | — | ✓ |
| **TC-088** | SPC prompt initiated automatically after the traveler loads | C | P2 | FR-076 / `CHK018` | Complete check-in | SPC prompt appears with no operator action | — | ✓ |
| **TC-089** | Legacy writes on successful check-in | I | **P1** | FR-077 / `CHK019` | Successful check-in | `wip_stations.coilno` updated · `coils.coil_status = INFLAT` · reqsum + `wip_coil_orders` inserted if not yet reqsummed · `actual_start_date` set on `planning_routings` **and** `routings` | — | ✓ |
| **TC-090** | Staging row is consumed, not duplicated | I | P2 | FR-078 | Check in a staged rod | `RodStaging.Status → CheckedIn` with `CheckedInAt` and `RodCheckinId`; **no parallel record created** | — | ✓ |
| **TC-091** | Payoff mismatch against a staged row | I | P2 | FR-078 | Rod staged on bay 2, check in requesting bay 1 | `409 PAYOFF_MISMATCH` | — | ✓ |
| **TC-092** | Payoff selector read-only when the rod arrived via pre-check-in | C | P3 | FR-082 | Staged rod → open DB2 | Selector pre-filled and read-only; editable on the direct-check-in fallback | — | ✓ |
| **TC-093** | **FL3 — one acknowledgement pushes FM1 and FM2** | I | **P1** | FR-083 | FL3 hybrid check-in | **One batch** carries both mills' tags; `RouteMode='Hybrid'`; **no `Spool` row created** | — | ✓ |
| **TC-094** | Check Out Rod disabled once footage > 0 | C | P2 | FR-084 / `ARM015` | Run with footage 0 then > 0 | Enabled, then **disabled** | — | ✓ |
| **TC-095** | Second check-in on a line with an active run | I | P2 | `[API §4.6]` | Line already `Running` | `409 RUN_ALREADY_ACTIVE` | — | ✓ |
| **TC-096** | Draft schedule rejected at check-in | I | P2 | `[API §4.6]` | Reference a `Draft` schedule | `422 SCHEDULE_NOT_ACTIVE` | — | ✓ |
| **TC-097** | **Four inspection items at check-in, three at staging** | K | P2 | `[API §4.6]` | Compare both request bodies | Check-in carries `connectorTag`; staging does not. **The asymmetry is deliberate** | — | ✓ |
| **TC-098** | `NOT NULL` columns are all supplied | I | **P1** | `[API §4.6]` | Submit the corrected body | Insert succeeds; `SpcOvalityIn` is **computed by the database**, not sent | — | ✓ |
| **TC-099** | Hub events on successful check-in | R | P2 | `[SRS §5.2]` | Successful check-in | `LineStatus{Running}`, `PayoffStateChanged{Active}` and `ComponentStatus` all emitted | — | ✓ |
| **TC-100** | **No-match schedule path** | I | **P1** | FR-070 | Order attributes match no Active schedule | **Behaviour is undefined — OI-46.** Test **records observed behaviour** and fails the gate until the path is specified | — | ✗ |

### 5.3 Spool check-in — TC-110 … TC-118

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-110** | Scan an FL1-printed spool label | I | P2 | FR-090 / `CHK012` | FL1-produced spool ready → scan | Validated against the FL1/FL3 check-in data; width entry required | ✓ |
| **TC-111** | Historical FL1 profile with weld markers renders | C | **P1** | FR-093 / `GWT005` | Spool from a run with two rods and one weld | Profile, target line, tolerance band, **weld markers**, and min/max/avg/std-dev/count statistics | ✓ |
| **TC-112** | In-spec / out-of-spec badge on the profile | C | P2 | FR-093 | Profile with 3 out-of-spec readings | Badge reads "3 out of spec", not "all in spec" | ✓ |
| **TC-113** | Source traceability read-only | C | P2 | FR-092 | Open DB5 | Contributing rods with footage ranges and weld rows with quality and timestamp; **not editable** | ✓ |
| **TC-114** | **No visual inspection section on DB5** | C | P2 | FR-095 | Open DB5 | Section absent — the spool was inspected at FL1 | ✓ |
| **TC-115** | FM2 component table read-only with the confirm bar | C | P2 | FR-094 | Open DB5 | **Exactly three FM2 rows** — S1 (8″), S2 (6″)+edger, S3 (6″)+edger final — shown read-only; **no separate "8″ Roller" row and no row named 6″ S1**; confirm bar gates acknowledgement | ✓ |
| **TC-116** | Acknowledgement pushes FM2 tags and opens the run | I | **P1** | FR-096 | Acknowledge | FM2 tags pushed (**S1/S2/S3 roll gaps and stand states**, edger activation and edge type at S2 and S3); `Spool.Status = INFLAT`; FL2 run created linked to the spool **and its source rod alphas** | ✓ |
| **TC-117** | Pre-flight validation battery | I | P2 | `[SRS §5.3]` | Each of: invalid spool · missing gauge/width · missing weight · no schedule | Each blocks with its own message | ✓ |
| **TC-118** | Hybrid-origin guard | I | **P1** | FR-091 | Standalone FL2 schedule applied to Hybrid-origin material | **Behaviour undefined — OI-47.** Records observed behaviour; gate fails until specified | ✗ |

### 5.3a Spool queue (DB5A) — TC-119 … TC-126

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-119** | Default list needs no scan | C | **P1** | FR-097 | Open DB5A with spools available | Every spool available for processing is listed **irrespective of order**, with the count / ready / weight rollup. No interaction required | ✓ |
| **TC-120** | Scan resolves the order and its spools in one call | I | **P1** | FR-098 | Enter `SP-00031` | **One** request; the order bar fills with order no, customer, alloy, temper, setup dims and due date, **and** the list narrows to that order's spools together. The scanned spool is marked | ✓ |
| **TC-121** | No submit control; scanner and keyboard both work | C | P2 | FR-098 | Enter via a wedge scanner (terminating Enter) and by typing | Both resolve — Enter immediately, typing after a short debounce. **No Find/Search button exists** | ✓ |
| **TC-122** | **A failed scan does not move the list** | C | **P1** | FR-099 | With a list displayed, scan an unknown alpha | Field marked, message names the alpha, **the displayed list is byte-identical to before the scan** | ✓ |
| **TC-123** | Unallocated spool is a result, not an error | I | **P1** | FR-099 | Scan a spool whose `OrderNo` is null | `200` with a null order and a **single row**; bar states it is unallocated; **check-in is still offered**. Must not be a `404` | ✓ |
| **TC-124** | Eligibility gates the check-in action | C | P2 | FR-099 | List containing `RECEIVED`, `STAGED`, `HOLD`, `INFLAT`, `COMPLETE` | Check-in offered only for `RECEIVED`/`STAGED`; `HOLD` marked and actionless; the rest listed without action | ✓ |
| **TC-125** | Hybrid-origin spools are marked | C | P2 | FR-099 | List containing a `Hybrid` origin spool | Row visibly marked and cites OI-47 | ✓ |
| **TC-126** | Column set is identical in both modes | C | P2 | FR-097, 098 | Compare default and scanned views | Same columns in the same order. **Order column present in both** — it is meaningful in the default view and holds the table steady in the scanned one | ✓ |

> **TC-120 depends on `Spool.OrderNo` being populated from planning.** If allocation is not written
> back to the shopfloor system there is nothing to resolve and the whole screen fails, not just this
> case. Confirm before executing the suite.

### 5.4 Active run — TC-130 … TC-159

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-130** | Live gauge and width traces render against target and tolerance | R | **P1** | FR-101 / `ARM003` | FL1 run, 10 Hz batched feed | Both traces render with target line and tolerance band | ✓ |
| **TC-131** | In-spec green, out-of-spec red with a banner | C | **P1** | FR-102 / `ARM005` | Feed an out-of-spec reading | Line turns red **and** an alert banner appears | ✓ |
| **TC-132** | Auto-prompt after N consecutive out-of-spec readings | I | **P1** | FR-103 / `ARM007` | Configure N=5 → feed 5 consecutive out-of-spec readings | WIP checkpoint auto-prompted at the 5th, not the 4th | ✓ |
| **TC-133** | Weld markers labelled with the rod alpha | C | P2 | FR-104 / `ARM008` | Run with a weld at footage 12,400 | Vertical marker at that footage **labelled with the incoming rod alpha** | ✓ |
| **TC-134** | Payoff colour bands | C | P2 | FR-106 / `ARM011` | Feed 60 %, 40 %, 20 %, 8 % | Green · amber · red + prepare-weld alert · **red-flashing + weld-now critical** | ✓ |
| **TC-135** | **FL1 action bar has six buttons and no Roll Adjust** | C | **P1** | FR-107 / `ARM013` | Open DB3 on FL1 | Exactly six; **no Roll Adjust, no edger controls — FL1 has no edger** | ✓ |
| **TC-136** | FL3 action bar has seven | C | P2 | FR-108 | Open DB3 on FL3 | Six plus Roll Adjust | ✓ |
| **TC-137** | FL2 action bar omits Weld and Die Change | C | P2 | FR-109 | Open DB3 on FL2 | No Weld, no Die Change; includes Roll Adjust and Complete Coil | ✓ |
| ~~**TC-138**~~ | ~~Tab persistence in `localStorage`~~ | — | — | ~~FR-112 / FR-114~~ | **[WITHDRAWN — descoped by client, Aug 4 2026]** — the Machine View tab is descoped. | — |
| **TC-139** | **Machine status and actions stay visible at all times** | C | P2 | FR-113 | Collapse the chart section, then expand it | Grid and buttons remain visible throughout. *(Reworded 4 Aug 2026: was “on both tabs / switch tabs” — the tabs went with the Machine View, the rule did not.)* | ✓ |
| **TC-140** | **FL2 renders the historical profile, not a live trace** | R | **P1** | FR-120 / `INT010` | Subscribe to `FL2Data` | **No `GaugeReading` or `WidthReading` events arrive**; the screen renders from `GET /run/{runId}/gaugetrace`; **absence is not treated as a fault** | ✓ |
| **TC-141** | **`null` live gauge/width for FL2 in `GET /lines/status`** | K | **P1** | `[API §4.1]` | Query with FL2 idle and running | `currentGauge` and `currentWidth` are `null` in both states | ✓ |
| **TC-142** | **Reconnect shows cached state, never a blank screen** | R | **P1** | FR-119 / `NFR006` | Active run → kill the transport | "Reconnecting…" banner over **cached last-known state**; no blank screen at any point | ✓ |
| **TC-143** | **Reconnect re-joins the line group automatically** | R | **P1** | FR-119 | As TC-142 → restore the transport | Client re-joins its group and resumes receiving without user action | ✓ |
| **TC-144** | Reconnect during a modal | R | P2 | FR-119 | Open the pause dialog → kill the transport | Modal state preserved; banner appears behind it | ✓ |
| **TC-145** | Traveler adapts by output type | C | P2 | FR-117 / `TRV007` | FL1 run, then FL2 run | Layout and stop popups differ — intermediate spool versus finished product | ✓ |
| **TC-146** | Main-station traveler shows only relevant welded rods | C | P2 | FR-118 / `TRV009` | Compare DB3 and DB2A travelers | DB3 shows welded rods for the current running rod; DB2A shows pre-checked-in **and** welded; welded distinguished by **colour and explicit text** | ✓ |
| **TC-147** | Order/constraint values used for runtime validation | I | P2 | FR-116 / `TRV006` | Exceed the package OD limit | Validation fires at the constraint | ✓ |
| ~~**TC-148**~~ | ~~Machine View schematic driven by the same stream~~ | — | — | ~~FR-112 / FR-114~~ | **[WITHDRAWN — descoped by client, Aug 4 2026]** — the Machine View tab is descoped. | — |

### 5.5 Spool completion — TC-160 … TC-184

| TC | Title | Lvl | Pri | FR | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-160** | Milestones at 75 / 90 / 100 % | I | P2 | FR-130 | Run to each threshold | One notification per crossing, showing actual, target and percent | ✓ |
| **TC-161** | Acknowledging arms the next and closes lower ones | C | P2 | FR-131 | Acknowledge 90 % without acknowledging 75 % | Both close; 100 % arms | ✓ |
| **TC-162** | Unacknowledged notification updates live and supersedes in place | C | P2 | FR-132 | Leave 75 % unacknowledged → cross 90 % | Card **updates in place**; never a second stacked card | ✓ |
| **TC-163** | **Notification never blocks** | C | P2 | FR-133 | Notification visible | No modal overlay, no backdrop, no focus trap; every control operable; command bar and both trace headers unobscured | ✓ |
| **TC-164** | Milestone state is per spool and re-arms | I | P2 | FR-134 | Complete a spool → start the next on the same run | Ladder re-arms from zero | ✓ |
| **TC-165** | Acknowledgement audited | I | P2 | FR-135 | Acknowledge | Operator, milestone, actual weight and timestamp recorded | ✓ |
| **TC-166** | Thresholds are table-driven | I | P3 | FR-136 | Change a threshold in configuration | New value applies **without a release** | ✓ |
| **TC-167** | **Weight derivation is correct** | U | **P1** | FR-137 | 1100, 0.110″ × 0.625″, square edge | **0.0809 lb/ft**; 900 lb (customer max) ⇒ ≈ 11,100 ft, 1,800 lb spool ⇒ ≈ 22,250 ft. Round edge gives 0.0778. *(The 2,000 lb figure this case used was withdrawn 30 Jul 2026 — the basis is the customer min/max range, FR-130a.)* | ✓ |
| **TC-168** | FL2 uses schedule/order dimensions, not live measurement | U | **P1** | FR-137 | FL2 spool progress | Gauge and width taken from the pass schedule / order, **because FL2 broadcasts `null`** | ✓ |
| **TC-169** | **Prompt armed only at or above target** | I | **P1** | FR-140 | Stop below target | **Nothing raised** | ✓ |
| **TC-170** | **Prompt fires on the edge, once per stop** | I | **P1** | FR-141 | `RUNNING → STOPPED` held, then a second stop without an intervening RUNNING | Fires **once**; re-arms only after RUNNING | ✓ |
| **TC-171** | **Dwell suppresses a jog or thread** | I | **P1** | FR-142 | STOPPED for 3 s with a 5 s dwell | **No prompt**. At 5 s, prompt appears | ✓ |
| **TC-172** | Weight latched at the PLC stop timestamp | I | **P1** | FR-143 | Weight drifts after the stop | Popup, transaction and label all use the **latched** value | ✓ |
| **TC-173** | **Prompt is server-owned and survives a refresh** | R | **P1** | FR-144 | Prompt open → refresh the browser | Prompt **re-delivered** on reconnect | ✓ |
| **TC-174** | Prompt suppressed by an unrelated open pause | I | P2 | FR-145 | Open pause with a non-spool-removal reason → stop | **No prompt** | ✓ |
| **TC-175** | Yes commits, then prints | I | **P1** | FR-146 | Answer Yes | Transaction commits, alpha finalises, **labels print only after commit** | ✓ |
| **TC-176** | No records nothing and is logged | I | P2 | FR-147 | Answer No | No transaction, no alpha, no print, no state change; **decline logged** | ✓ |
| **TC-177** | Auto-dismiss on resume | I | P2 | FR-148 | Line returns to RUNNING with the popup open | Auto-dismisses, logged as `line resumed`, re-arms | ✓ |
| **TC-178** | **Escape and click-outside do not dismiss** | C | **P1** | FR-149 / `NFR009` | Press Escape; click the backdrop | Popup **remains**. `Y`/`N` keys work and are advertised | ✓ |
| **TC-179** | Manual complete-spool path stays available | C | P2 | FR-150 | Decline the prompt with weight ≥ target and line not running | Manual entry point present — **never a dead end** | ✓ |
| **TC-180** | Scale weight entered as gross, net derived | I | P2 | FR-151 | Enter a gross scale weight | `net = gross − spool tare`; variance shown in **lb and % of calculated** | ✓ |
| **TC-181** | Scale pre-selected once entered, still overridable | C | P2 | FR-152 | Enter a scale weight | Scale basis pre-selected; operator can revert to calculated | ✓ |
| **TC-182** | **Variance beyond ±2 % never disables commit** | C | **P1** | FR-153 | Force a 3 % variance | Flagged; override panel appears; button relabels; **commit control stays enabled**; remote-approval action offered | ✓ |
| **TC-183** | Incomplete override flags the missing field | C | P2 | FR-154 | Press complete with a partial override | Missing fields flagged, first focused, **nothing committed** | ✓ |
| **TC-184** | **Both weights and the variance persist regardless of basis** | I | **P1** | FR-155 | Complete with either basis | Both weights, the variance, the override flag, supervisor and reason all persist. **PIN absent from the payload** | ✓ |

### 5.6 Weld genealogy — TC-190 … TC-214 *(the contractual suite)*

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-190** | **End-to-end genealogy: rod → weld → footage attribution → coil → certificate** | E2E | **P1** | FR-170, FR-172 / `NFR012` | FL1 run consuming `R00041` then welded `R00042`, through to a completed coil | The certificate query resolves **every foot** of the coil to a source rod and its supplier heat, with the weld boundary at the recorded footage | ✓ |
| **TC-191** | **Traceability rows cover 100 % of coil footage** | I | **P1** | FR-170 | Complete a coil from two rods | `Σ(FootageTo − FootageFrom)` equals the coil footage exactly — **no gap** | ✓ |
| **TC-192** | **Traceability rows do not overlap** | I | **P1** | FR-170 | Attempt to insert an overlapping range | Rejected by `trg_CoilTraceability_NoOverlap`; ranges are half-open `[From, To)` | ✓ |
| **TC-193** | **Multi-parent genealogy** | I | **P1** | FR-172 / `WLD009` | Three rods across two welds | One output identifier references **all three** parents with weld sequence, operator and timestamp | ✓ |
| **TC-194** | Footage auto-read from the encoder, never typed | I | **P1** | FR-162 / `WLD014` | Open the weld screen | Footage populated from the encoder; **no editable footage field**; outgoing length = `weld point − rod start` | ✓ |
| **TC-195** | Incoming rod defaults to the staged rod | C | P2 | FR-163 / `PCI008` | Rod staged on the idle bay | Pre-filled; operator may override by scanning | ✓ |
| **TC-196** | Alloy / diameter / temper mismatch rejected | I | P2 | FR-164 / `WLD006` | Weld to a rod with a different temper | Clear validation error; weld not recorded | ✓ |
| **TC-197** | Coil not planned for the current order is ineligible | I | P2 | FR-165 / `WLD007` | Weld to a rod on another order | Rejected | ✓ |
| **TC-198** | **Induction is the only selectable weld type** | C | **P1** | FR-166 / `WLD012` | Open the weld-type control | Only `InductionWeld` selectable. **`LaserWeld` exists in the model for historical genealogy and is never offered** | ✓ |
| **TC-199** | Fail requires a reason | I | P2 | FR-167 / `WLD013` | Set quality Fail, omit the reason | `422`; `CK_WeldEvent_FailReason` holds | ✓ |
| **TC-200** | **A failed weld still logs and links the rods** | I | **P1** | FR-168 / `WLD017` | Record a Fail | Event written, rods linked, flagged for supervisor review; **the run is not silently blocked** | ✓ |
| **TC-201** | Confirmed weld event is immutable | I | P2 | FR-168 | Attempt to edit a confirmed event | Rejected; corrections go through the audit flow | ✓ |
| **TC-202** | Payoff transition is driven only by consumption | I | **P1** | FR-169 / `WLD005` | Weld, then run the outgoing rod to 0 ft | Transition occurs at 0 ft, **not at the weld and not on any operator action** | ✓ |
| **TC-203** | A bay cannot be welded to itself | I | P2 | `CK_WeldEvent_PayoffDiff` | Submit with equal payoff positions | Rejected | ✓ |
| **TC-204** | Server-side timestamp, not the client clock | I | P2 | FR-174 | Submit with a skewed client clock | Persisted timestamp is the **server's at receipt** | ✓ |
| **TC-205** | Weld-joint limit validation hook exists | I | P2 | FR-171 / `WLD016` | Configure a limit → exceed it | Validation fires. **The limit itself is TBD — OI-59**; the hook must exist and be configurable | ✓ |
| **TC-206** | Weld removal requires a supervisor override | I | P2 | FR-173 / `WLD011` | Attempt removal as an operator | Blocked; supervisor credentials required and who/when/why logged | ✓ |
| **TC-207** | Side effects on confirm | I | P2 | `[SRS §5.6]` | Confirm a weld | Active-rod pointer advances · weld-pending flag clears · a weld marker is queued for the trace · `PayoffWeight` re-establishes for the new payoff | ✓ |

### 5.7 SPC — TC-220 … TC-244

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-220** | Checkpoint at incoming rod diameter | I | **P1** | FR-180 / `SPC001` | Pre-run checkpoint | Recorded with type `PreRun` and measurement `IncomingRodDiameter` | ✓ |
| **TC-221** | Checkpoint post wire-draw after a die change | I | **P1** | FR-180 | Die change with reason Gauge drift | `PostDieChange` checkpoint with `WireDiameterPostDraw`, `FM1Gauge`, `FM1Width` | ✓ |
| **TC-222** | Checkpoint at FL1 output | I | **P1** | FR-180, FR-181 | Complete an FL1 spool | Gauge **and** width both captured | ✓ |
| **TC-223** | Checkpoint at FL2 output | I | **P1** | FR-180, FR-181 | Complete an FL2 coil | `PostRun` with `FinalGauge`, `FinalWidth` | ✓ |
| **TC-224** | Automatic readings are the primary source | I | P2 | FR-182 / `SPC004` | Normal operation | AGC readings drive SPC; manual entry required **only** at setup and die changes | ✓ |
| **TC-225** | **Five persisted checkpoint types** | K | **P1** | FR-184 | Post each type | All five accepted, including **`RollAdjustTrigger`**. `PostDb1` **rejected** until the enum and CHECK are both extended (OI-10) | ✓ |
| **TC-226** | **SPC-HOLD does not stop the machine** | I | **P1** | FR-187 / `SPC010` | Submit out of spec, choose suspend | Material to SPC-HOLD; **the machine keeps producing footage** | ✓ |
| **TC-227** | SPC-HOLD blocks advancement, shipping and release | I | **P1** | FR-188 / `SPC011` | Attempt each action on held material | All three blocked until QA lifts the hold | ✓ |
| **TC-228** | QA disposition — release with concession or quarantine/scrap | I | P2 | FR-189 / `SPC012` | QA acts on held material | Both paths available and recorded | ✓ |
| **TC-229** | **Force-continue always available** | C | **P1** | FR-186 / `SPC009` | Out-of-spec readings | "Submit · continue run" **remains enabled**; "Submit · suspend material" elevates to danger style | ✓ |
| **TC-230** | Post-die-change SPC is a **hard block** on full production | I | **P1** | FR-185 / `DCH020` | Die change with Gauge drift → attempt full production | Blocked; **thread mode permitted**; released only on an SPC pass | ✓ |
| **TC-231** | CPK excludes unstable start and end regions | U | P2 | FR-190 / `SPC013` | Run with unstable head and tail | CPK computed over the stable window only | ✓ |
| **TC-232** | **Footage captured at open, not at submit** | I | **P1** | FR-191 / `SPC014` | Open a checkpoint at 8,000 ft, submit at 8,600 ft | Recorded footage is **8,000** | ✓ |
| **TC-233** | Operator / footage / timestamp stamp is immutable | I | P2 | FR-191 | Attempt to edit | Rejected | ✓ |
| **TC-234** | SPC gates the stop transaction | I | **P1** | FR-192 / `STP012` | Attempt Update with no checkpoint | Blocked; **completing the checkpoint releases it even if readings are out of spec** | ✓ |
| **TC-235** | Tolerance-band marker position | U | P2 | FR-193 | measured = target + 0.5 × tolerance | `pct = 50 + (0.5/1.67) × 50 ≈ 65 %`, clamped to 4–96 % | ✓ |
| **TC-236** | `toleranceValue` required | K | P2 | `[API §4.9]` | Omit it | `400` — it is `NOT NULL` and drives the computed `InSpec` | ✓ |
| **TC-237** | `InSpec` and `Deviation` are computed by the database | I | P2 | `[API §4.9]` | Submit measurements | Values computed server-side; client-sent values ignored | ✓ |
| **TC-238** | Camber available where specified, never mandatory | C | P3 | FR-197 | Order with camber specs | Field present and optional | ✓ |

### 5.8 Roll adjust — TC-250 … TC-264

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-250** | **Override never modifies the pass schedule** | I | **P1** | FR-200 / `RAJ015` | Apply an override → re-read the schedule | Schedule record **unchanged**; override recorded against run/alpha/footage | ✓ |
| **TC-251** | Only "New gap" is editable | C | P2 | FR-202 | Open DB11 | Component, Scheduled, Current and Delta read-only | ✓ |
| **TC-252** | Bypassed rollers greyed; **edgers excluded entirely** | C | P2 | FR-203 | Schedule with a bypassed roller and edgers | Bypassed row greyed with no input; **no edger row at all** | ✓ |
| **TC-253** | Delta recalculates on every keystroke | C | P3 | FR-204 | Type into New gap | Delta updates per keystroke; colour-coded; non-zero rows highlighted amber | ✓ |
| **TC-254** | Both measurements required before Apply | C | P2 | FR-205 | Enter gauge only | Apply disabled until width is entered too | ✓ |
| **TC-255** | Reason chip required | C | P2 | FR-206 | No chip selected | Apply disabled | ✓ |
| **TC-256** | Each changed gap logged individually | I | **P1** | FR-209 | Change two components | **Two** `RollOverride` rows, each with component, old, new, delta, reason, operator, timestamp and footage | ✓ |
| **TC-257** | PLC tag written immediately, per component | I | **P1** | FR-209 | Apply | One tag write per changed component; `PlcTagWritten` recorded | ✓ |
| **TC-258** | A `RollAdjustTrigger` checkpoint is created | I | **P1** | FR-210 / `RAJ020` | Apply | SPC checkpoint of that type at the footage position, carrying the entered gauge and width | ✓ |
| **TC-259** | **All-zero deltas write nothing** | I | P2 | FR-211 | Open and apply with no changes | Button reads "No changes — return to run"; **no rows, no tag writes, no checkpoint** | ✓ |
| **TC-260** | Operator may apply; only Ops Manager may revert | I | P2 | FR-212 / `RAJ022` | Attempt revert as operator | Blocked. **The revert endpoint does not exist — OI-32**; test records the gap | ✗ |
| **TC-261** | History shows the last 3 against the active schedule | C | P3 | FR-207 | Four prior adjustments across runs | Most recent three shown, across all runs and operators | ✓ |

### 5.9 Die change — TC-270 … TC-289

| TC | Title | Lvl | Pri | FR / Source | Preconditions → Steps | Expected result | Auto |
|---|---|---|---|---|---|---|---|
| **TC-270** | Die Change available on FL1/FL3 only | C | P2 | FR-220 / `DCH001` | Open on FL2 | Not available — FL2 has no drawing dies | ✓ |
| **TC-271** | Run shows paused while the screen is open | C | P2 | FR-221 | Open the screen | Context chip reads paused; must complete or cancel | ✓ |
| **TC-272** | DB2 pre-selected; Both requires two scans | C | P2 | FR-222 | Select Both | Both outgoing alphas shown; incoming cleared; **each new die scanned separately** | ✓ |
| **TC-273** | Life-bar colour bands on this screen | C | P3 | FR-223 | Dies at 55 %, 70 %, 90 % | Green · amber · red. **Note the deliberate divergence from Die Management's bands — OI-12** | ✓ |
| **TC-274** | **Unregistered incoming die rejected** | I | **P1** | FR-233 / `DCH027` | Scan an alpha not in the inventory | Rejected, prompting Maintenance to register it. **Requires the die master — FW-N07 / OI-41** | ✓ |
| **TC-275** | Size must match unless the reason is Size change | I | P2 | FR-225 / `DCH013` | Different size with reason Planned life | Rejected; accepted when the reason is Size change | ✓ |
| **TC-276** | Die failure reveals the Quality Hold section | C | P2 | FR-227 / `DCH015` | Select Die failure | Red section; Hold-from editable defaulted to the rod's die-start footage; Hold-to read-only at the current counter | ✓ |
| **TC-277** | Gauge drift / Size change route to SPC | I | **P1** | FR-228 / `DCH018` | Select either | Blue notice; **"Require SPC on resume" pre-checked ON**; Confirm routes to DB6, not DB3 | ✓ |
| **TC-278** | Planned life / Die failure route to DB3 | I | P2 | FR-229 | Select either | Confirm returns to DB3 and resumes | ✓ |
| **TC-279** | SPC fail offers disposition options | C | P2 | FR-229 / `DCH022` | Fail the checkpoint | Hold, re-adjust or re-run SPC offered | ✓ |
| **TC-280** | Cancel writes nothing and unpauses | I | P2 | FR-231 / `DCH024` | Cancel | No record; run unpaused | ✓ |
| **TC-281** | Confirmed event is immutable | I | P2 | FR-231 | Attempt to edit | Rejected | ✓ |
| **TC-282** | **Auto-created linked `RollOverride`** | I | **P1** | FR-232 / `DCH026` | Confirm a size change | A `RollOverride` is created and referenced by `LinkedOverrideId` | ✓ |
| **TC-283** | **SPC toggle-off is audited and flagged** | I | **P1** | FR-234 / `DCH028` | Toggle "Require SPC on resume" off | Audit entry with user, role, timestamp, event ID and reason; the run appears as a **flagged exception** on Shift Summary | ✓ |
| **TC-284** | Only the five screen reason codes are offered | C | P2 | `[API §4.12]` | Open the reason list | Five values. The DB CHECK tolerates three legacy values; **they must not appear in the UI** | ✓ |
| **TC-285** | Die footage accumulation switches on a mid-run swap | I | P2 | FR-255 | Swap mid-run | Outgoing die's counter closes; incoming die's counter starts | ✓ |

### 5.10 · 5.18 / 5.19 · 5.23 / 5.24 — moved to MVP-2

> **Three test-case blocks sit in [`../../MVP-2/ProjectPlan/06-TestCases-MVP2.md`](../../MVP-2/ProjectPlan/06-TestCases-MVP2.md)** — TC-295–309, TC-450–484 and TC-545–564. **Copied verbatim; no `TC-###` was renumbered.**
>
> **Five were extracted on 11 Aug 2026; two came back the same day** — **TC-405–429** (coil completion) and **TC-435–444** (packing), with Phase 9 confirmed **wholly MVP-1**. They are restored below in place.
>
> The `TC-###` ranges are therefore **discontinuous in this document**. That is the intended reading: a gap means deferred, not missing.

### 5.11 Pause / resume — TC-315 … TC-329

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-315** | Exactly one reason required | C | P2 | FR-260 | No reason selected → Confirm Pause disabled | ✓ |
| **TC-316** | All six reason categories present | C | P3 | FR-261 | Open the dialog → Equipment/Mechanical, Material Handling, Quality/Measurement, Operational, Safety, Rod Checkout, Other | ✓ |
| **TC-317** | **Rod Checkout reason navigates instead of pausing** | I | **P1** | FR-262 / `PRN011` | Select Rod Checkout → navigates to DB12; **no `RunPauseEvent` is written** | ✓ |
| **TC-318** | `Other` requires notes | I | P2 | FR-261 | Select Other, omit notes → rejected by `CK_RunPauseEvent_NotesOther` | ✓ |
| **TC-319** | Pause side effects | I | **P1** | FR-263 | Confirm a pause → timer pauses and pause time tracks separately · **footage freezes** and the position is recorded · reason logged · PLC tags to hold/idle · DB1 shows **PAUSED with the reason visible to the supervisor** | ✓ |
| **TC-320** | Pause start auto-stamped, not editable | C | P2 | FR-264 | Attempt to edit → not editable; badges switch to paused presentation; action becomes Resume Run | ✓ |
| **TC-321** | Resume confirmation shows reason and elapsed duration | C | P2 | FR-265 | Open resume → both shown; Confirm disabled until an outcome is selected | ✓ |
| **TC-322** | Resume — Yes | I | P2 | FR-266 | Choose "Yes — resume run" → timer restarts, PLC tags restored, DB3 active, pause event closed with end time and duration | ✓ |
| **TC-323** | Resume — log WIP rejection | I | P2 | FR-266 | Choose it → pause event closes **and** DB8 opens | ✓ |
| **TC-324** | Resume — continue pause | I | P2 | FR-266 | Choose it → dialog dismisses, line stays paused, **timer keeps running** | ✓ |
| **TC-325** | **Fourth outcome — CheckOutRod** | K | **P1** | FR-266 / OI-14 | POST resume with `CheckOutRod` → **accepted by the contract.** The shared script implements only three outcomes; records the divergence | ✓ |
| **TC-326** | Pause rolls into the Shift Summary | I | P3 | FR-267 | Pause, resume, open DB10 → total downtime minutes, category breakdown, utilisation and WIP rejection count reflect it | ✓ |

### 5.12 Stop transaction — TC-335 … TC-344

| TC | Title | Lvl | Pri | FR / Source | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-335** | Stop popup invoked by the OPC speed tag | I | **P1** | FR-270 / `STP001` | Mill speed reaches 0 → "Reason for Flatwire Stop" appears first; on Stop Completed the STOP popup opens with the specified title | ✓ |
| **TC-336** | Rod Buildup validation | C | P2 | FR-271 / `STP003` | Enter 0, 40, 41 → 0 and 40 accepted (positive, up to 40); 41 rejected; virtual keyboard available | ✓ |
| **TC-337** | Spool ID source differs by line | C | P2 | FR-271 / `STP004` | FL3/FL2 → auto-populated from the ID range; FL1 → fixed | ✓ |
| **TC-338** | Length and Spool OD read-only and derived | C | P2 | FR-271 | Change Rod Buildup → Spool OD recalculates; both remain read-only | ✓ |
| **TC-339** | **Update disabled until an SPC checkpoint exists** | I | **P1** | FR-274 / `STP012` | No checkpoint → red banner on beige, **Update disabled**. Complete a checkpoint **with out-of-spec readings** → Update **enables** | ✓ |
| **TC-340** | Balance-of-coil action states | C | P2 | FR-273 / `STP009` | Open the popup → three enabled, **"Continue Rolling For Different Order" disabled** | ✓ |
| **TC-341** | Footer actions present | C | P3 | FR-275 | Open the popup → WIP Reject · SPC · Show Traveler · Back · Update | ✓ |

### 5.13 Wire break — TC-350 … TC-352

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-350** | Wire-break prompt | C | P2 | FR-280 | Trigger → "Has the wire break happened?" with Yes/No | ✗ |
| **TC-351** | Yes prompts OD verification | C | P2 | FR-281 | Answer Yes → OD verification prompted. No → dismissed with no recovery workflow | ✗ |
| **TC-352** | Defect inspection before resuming | C | P2 | FR-282 | After a break → defect-inspection prompt precedes resumption | ✗ |

> **TC-350 – TC-352 cannot be executed.** There is **no screen, no table and no persistence target** for wire break — **OI-13**, story `FW-N08` is blocked. The cases are written so they are ready the moment the gap closes, and so the gap is visible in the coverage matrix rather than absent from it.

### 5.14 WIP rejection — TC-355 … TC-369

| TC | Title | Lvl | Pri | FR / Source | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-355** | Rejection with group and reason | I | P2 | FR-290 / `WRJ001` | Submit → recorded consistently with existing coil WIP-rejection behaviour | ✓ |
| **TC-356** | Context auto-populated from the active run | C | P2 | FR-291 / `WRJ002` | Open DB8 from an active run → material/alpha, stage, footage, measured, target range, deviation and operator all pre-filled | ✓ |
| **TC-357** | Suspend disposition | I | **P1** | FR-292 / `WRJ003` | Submit Suspend → alpha → `HOLD`, moved to WIP Held, **supervisor notified and named on screen** | ✓ |
| **TC-358** | Scrap disposition | I | P2 | FR-292 | Submit Scrap → alpha → `SCRAP`, routed to scrap disposition | ✓ |
| **TC-359** | **Rework disposition** | I | **P1** | FR-292, FR-297 | Select Rework and a return stage → **currently unpersistable: `NewMaterialStatus` admits only HOLD/SCRAP and no return-stage column exists (OI-22).** Test records the gap and fails the gate | ✗ |
| **TC-360** | Observation required for Suspend | C | P2 | FR-296 | Suspend with no observation → blocked | ✓ |
| **TC-361** | Rejection linked to the gauge trace at the footage position | I | P2 | FR-293 / `WRJ004` | Submit at 9,120 ft → the trace links at that position | ✓ |
| **TC-362** | All five groups with their reasons | C | P3 | FR-294 | Open the group list → Surface Quality, Dimensional, Weld Quality, Material, Process, each with its reasons | ✓ |
| **TC-363** | Quick-reason chips | C | P3 | FR-295 | Open DB8 → seven chips alongside the full dropdowns | ✓ |
| **TC-364** | `AlertRaised` reaches DB1 | R | P2 | FR-299 | Submit → `AlertRaised` broadcast; DB1 alert panel updates | ✓ |
| **TC-365** | Pre-run rejection with no run | I | P2 | `[API §4.14]` | Submit with null `runId` and null footage → accepted | ✓ |

### 5.15 Rod checkout — TC-375 … TC-399

| TC | Title | Lvl | Pri | FR / Source | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-375** | **Checkout blocked while the line reports Running** | I | **P1** | FR-301 / `RCO003` | `LineState = Running` → open the dialog | Blocked with *"Line is still running. Stop the line before checking out the rod."* | ✓ |
| **TC-376** | **Line state re-checked at confirm** | I | **P1** | FR-301 | Line stops, dialog opens, line restarts → confirm | **Rejected at confirm** — the check runs twice, not once | ✓ |
| **TC-377** | **No stop command is ever sent** | I | **P1** | FR-302 / `RCO007` | Instrument the PLC write path across every checkout path | **Zero stop commands** | ✓ |
| **TC-378** | **Footage locked at dialog open** | I | **P1** | FR-303 / `RCO008` | Open at 6,400 ft, let the counter drift, confirm | Recorded footage is **6,400** | ✓ |
| **TC-379** | Tags cleared only after confirmed stop and operator confirm | I | **P1** | FR-304 | Confirm | Tags cleared **after** both conditions; `PlcTagsCleared` recorded; payoff assignment cleared | ✓ |
| **TC-380** | Full persistence set | I | P2 | FR-305 | Confirm any mode | Rod alpha, payoff, originating check-in identifier, mode, reason, footage, remaining weight, rod disposition, material disposition, operator, timestamp and notes — **linked back to the check-in record** | ✓ |
| **TC-381** | Notes required when the reason is Other | I | P2 | FR-306 / `RCO015` | Reason Other, no notes → rejected | ✓ |
| **TC-382** | **Mode P — no line-state gate** | I | **P1** | `[SRS §4.6]` | Pre-check-out on an idle bay with the line running elsewhere | **Succeeds** — an idle bay is not running. `CK_RodCheckout_ModeP` holds: null `RunId`, footage 0, `PlcTagsCleared` false, both in-process fields null | ✓ |
| **TC-383** | **Mode A — status transitions** | I | **P1** | FR-312 / `RCO022` | Disposition `ReturnToFloorStorage` then `ReturnToWarehouse` | `INFLAT → STAGED` and `INFLAT → RECEIVED` respectively | ✓ |
| **TC-384** | Mode A voids the acknowledgement | I | P2 | FR-313 | Confirm Mode A | Pass-schedule acknowledgement voided; footage recorded as 0; material disposition null; dashboard returns to "Ready for Check-In" | ✓ |
| **TC-385** | **Mode B reachable only through the Pause dialog** | C | **P1** | FR-320 / `RCO029` | Attempt to reach Mode B from DB3 directly | **No direct path exists** | ✓ |
| **TC-386** | **Mode B — three status transitions** | I | **P1** | FR-322 | Dispositions Hold / Scrap / Defer | `INFLAT → HOLD` / `SCRAP` / `STAGED` respectively | ✓ |
| **TC-387** | **Mode B requires supervisor approval** | I | **P1** | FR-323 / `RCO038` | Operator submits | Action reads **"Submit for Supervisor Approval"**; the operator cannot finalise | ✓ |
| **TC-388** | **No alpha until the supervisor approves** | I | **P1** | FR-326 / `RCO048` | Submit Mode B → inspect | Pending Disposition created, **material locked, not plannable, `partialSpoolAlpha` null** | ✓ |
| **TC-389** | Supervisor Accept generates the partial spool alpha | I | **P1** | FR-326 | Approve with Accept | Alpha generated and entered into the spool queue | ✓ |
| **TC-390** | Supervisor Hold requires QC release | I | P2 | FR-326 | Approve with Hold | Alpha generated with Hold status | ✓ |
| **TC-391** | Supervisor Reject routes to WIP Rejection | I | P2 | FR-326 | Approve with Reject | WIP Rejection flow opens; material to scrap | ✓ |
| **TC-392** | Supervisor review from any connected terminal | I | P2 | FR-325 / `RCO043` | Review from a different terminal | Partial-run gauge trace, footage, reason, operator and timestamp all visible | ✓ |
| **TC-393** | **Approval survives no supervisor being connected** | I | **P1** | FR-324 / G7 | Submit Mode B with no supervisor session open | **Currently the notification is transient and the approval is lost.** Records gap **G7** — a durable pending-approval queue is required | ✗ |
| **TC-394** | Disposition record contents | I | P2 | FR-327 | Complete an approval | Supervisor identifier, decision, reason code and timestamp recorded; the resulting disposition value and any alpha land on the checkout record | ✓ |
| **TC-395** | **Carry-forward: partial rod re-check-in** | E2E | **P1** | `[SRS §4.7]` | Mode B Defer at 6,400 ft → re-stage the same rod | Existing rod record **retrieved by alpha, not recreated**; `FootageRunToDate` = 6,400; a **new independent run** opens with its footage counter at zero; the new spool alpha carries `SourceRodAlpha` back to the rod | ✓ |
| **TC-396** | Material left in the mill is scrapped, not carried forward | I | P2 | `[SRS §4.7]` | Mode B removal | In-mill material scrapped; only the undrawn rod portion carries forward | ✓ |

### 5.16 Coil completion — TC-405 … TC-429

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-405** | Coil alpha issued on completion | I | P2 | FR-330 | Complete → `FW-#####-C##` linked to the order, with alloy, temper, footage, lot, gross and calculated net weight | ✓ |
| **TC-406** | Mid-run child alpha | I | P2 | FR-330 | Product-spec change mid-run → `FW-#####-C##-A` minted at the breakpoint | ✓ |
| **TC-407** | **Target shown when in tolerance, measured when out** | C | **P1** | FR-331 | SPC in tolerance, then out | Target value displayed; then the measured value | ✓ |
| **TC-408** | **Net weight derived, never from a scale during rolling** | I | **P1** | FR-332 | Complete | `A × 12ρ` per foot with the round-edge correction; ρ from `united_db..alloys.alloy_density`; derivation shown on screen | ✓ |
| **TC-409** | **The mockup's 0.069 lb/ft is not implemented** | U | **P1** | FR-332a | 1100 at 0.110″ × 0.625″ | **0.0809** square / **0.0778** round. **0.069 implies ρ = 0.0836, which is not aluminium** | ✓ |
| **TC-410** | Round-edge correction magnitude | U | **P1** | `[HLD §6.6]` | 0.110 × 0.625, then 0.0160 × 0.625 | **−3.8 %** and **−0.6 %** respectively | ✓ |
| **TC-411** | Operator override with a scale reading | I | P2 | FR-332 | Override | Lands in `NetWeightOverrideLb`, **not** in `NetWeightLb` | ✓ |
| **TC-412** | **±2 % variance is unreachable from target dimensions** | U | **P1** | FR-153 / OI-45 | Stack gauge ±0.002 on 0.110 with width ±0.005 on 0.625 | Worst case **±2.6 %** — **a fully in-spec coil trips the override.** Documents the arithmetic conflict; the case fails until the basis is decided | ✓ |
| **TC-413** | Source traceability table | C | **P1** | FR-333 | Coil from two rods across one weld | One row per rod with footage-from/to, weld rows with quality, derived weight per rod, and the `rod → spool → coil` chain summary | ✓ |
| **TC-414** | **Exactly two coils per skid** | I | **P1** | FR-335 / `PKG003` | Complete coil 1, then coil 2, then attempt a third on the same skid | Coil 1 opens; coil 2 closes, prints the skid label and queues it; **the third is refused** | ✓ |
| **TC-415** | Label preview before printing | C | P2 | FR-336 | Complete → preview shown with alpha, alloy, temper, gauge, width, gross, net, footage, lot and **all contributing source rod alphas** | ✓ |
| **TC-416** | **Pass-schedule data is not on the customer label** | C | **P1** | FR-338 | Inspect the label | Schedule ID, version and configuration **absent from the label** but **present on the coil record** | ✓ |
| **TC-417** | **Configuration snapshot survives a later schedule edit** | I | **P1** | FR-338 / `NFR013` | Complete a coil → edit the schedule → re-render the coil's technical record | The **snapshot at creation** is returned, not the edited schedule | ✓ |
| **TC-418** | Order-constraint validation at finalisation | I | P2 | FR-337 / `PKG001` | Exceed package OD, width or weight | Transaction does not complete | ✓ |
| **TC-419** | Final SPC panel behaviour | C | P2 | FR-334 | Out-of-spec final SPC | Submit·suspend becomes the primary path | ✓ |
| **TC-420** | `lotNumber` | K | P2 | FR-336 / OI-24 | Call the label endpoint | **No column and no generator exist.** Records the gap; the label cannot be rendered as specified | ✗ |
| **TC-421** | **Multi-coil run footage frames** | I | **P1** | OI-25 | Run producing two coils | Traceability rows for coil 2 must use **coil-local** footage. **The coil-start offset is unstated — this case fails until OI-25 closes**, and it is the highest-consequence open item because `NFR012` is contractual | ✗ |


### 5.17 Packing — TC-435 … TC-444

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-435** | New arrival shows completion context | C | P2 | FR-345 | Coil arrives → alpha, confirmed time, completing operator, alloy, gauge, width, footage, net weight, skid and slot | ✓ |
| **TC-436** | Coil verification captures a scale weight and variance | I | P2 | FR-346 | Weigh → calculated net, its derivation and the variance against the completion gross weight all shown | ✓ |
| **TC-437** | Skid slot layout | C | P3 | FR-347 | Two coils on a skid → both slots with alphas, weights and combined net | ✓ |
| **TC-438** | Closing the skid | I | P2 | FR-351 | Close → staging location assigned, skid label printed, **both coil labels marked confirmed**, return to queue | ✓ |
| **TC-439** | Skids-this-shift and pending arrivals | C | P3 | FR-349, FR-350 | Open DB7b → both tables populate per line | ✓ |

---

### 5.20 Line status — TC-490 … TC-509

| TC | Title | Lvl | Pri | FR | Steps → Expected result | Auto |
|---|---|---|---|---|---|---|
| **TC-490** | Three lines render concurrently | C | P2 | FR-420 | Open DB1 → all three cards, always-visible layout | ✓ |
| **TC-491** | Per-line data set complete | C | P2 | FR-421 | Running FL1 → status, order, alpha, alloy, route, speed, live gauge and width, Payoff 1 weight decrementing, Payoff 2 status, run time since acknowledgement | ✓ |
| **TC-492** | FL2 gauge/width blank when idle | C | **P1** | FR-421 | FL2 idle | Blank, not zero, not an error | ✓ |
| **TC-493** | **Alert rule — Payoff 1 < 3,000 lb** | I | **P1** | FR-423 | Drop to 2,999 lb | Warning: "Prepare weld — Payoff 2 must be ready" | ✓ |
| **TC-494** | **Alert rule — gauge outside tolerance on FL1/FL3** | I | **P1** | FR-423 | Feed an out-of-tolerance gauge | Warning raised | ✓ |
| **TC-495** | **Alert rule — component PLC fault** | I | **P1** | FR-423 | Set a component fault | **Critical**: "Component fault — line stopped" | ✓ |
| **TC-496** | **Alert rule — active WIP rejection** | I | **P1** | FR-423 | Submit a rejection | Warning: "WIP rejection requires disposition" | ✓ |
| **TC-497** | **Alert rule — Payoff 2 not loaded and Payoff 1 < 2,000 lb** | I | **P1** | FR-423 | Unstage Payoff 2, drop Payoff 1 to 1,900 lb | **Critical**: "No weld material available" | ✓ |
| **TC-498** | **"Payoff 2 not loaded" reads `RodStaging`, not weight** | I | **P1** | FR-424 | Empty bay reading 0 lb vs a staged rod whose sensor reads 0 | **Only the first raises the alert** — weight alone cannot distinguish them | ✓ |
| **TC-499** | Alerts individually acknowledgeable | C | P2 | FR-428 | Acknowledge one of two | Acknowledged count increments; the other stays active | ✓ |
| **TC-500** | **Alerts survive a service restart** | I | **P1** | OI-28 | Raise an alert → restart the service | **Currently fails — no table stores alerts.** Records the gap; story `FW-N06` closes it | ✗ |
| **TC-501** | Active pass schedule ID shown per line | C | P3 | FR-427 | Open DB1 → schedule ID visible on the card | ✓ |
| **TC-502** | Shift strip contents | C | P3 | FR-427 | Open DB1 → lines active, lbs this shift vs target, orders completed, average utilisation, shift end and time remaining | ✓ |
| ~~**TC-503**~~ | ~~Drill-downs~~ | — | — | ~~FR-425~~ | **[WITHDRAWN — descoped by client, Aug 4 2026]** — both DB1 drill-down destinations are descoped, so there is nothing to drill into. *(Neither was implemented in the mockup.)* | — |

### 5.21 / 5.22 HMI and SCADA — [WITHDRAWN — descoped by client, Aug 4 2026]

> **`TC-515` – `TC-534` are withdrawn** with Dashboard 13, Dashboard 14 and the Machine View tab (4 Aug 2026). Case numbers are retained and never reused.

| Withdrawn | Was | Note |
|---|---|---|
| `TC-515` – `TC-521` | The HMI schematic: route variants, component nodes, flow animation, bypass rendering, alert bar, no-print | `TC-516` (“FL1 shows no Edge Set node”) was **P1** and is moot — there is no schematic. The underlying fact it defended, **FL1 has no edger**, is unchanged and is asserted in the pass-schedule and tag-map cases |
| `TC-530` – `TC-534` | The trend charts: overlays, control limits, event markers, CSV export, update interval | **`TC-531` (control-limit calculation) tested SPC methodology, not the chart** — that methodology still applies to the SPC checkpoint and the gauge-trace report and is covered in §5.7 |

**Two anchors moved rather than lapsed:**

- **`NFR005`** (1 s default push, configurable) lost `TC-534` as a verification anchor. It is still verified by **`TC-604`**/**`TC-605`** and by the §5.4 real-time cases.
- **The six run event markers** (`TC-532`) still render on the DB3 traces and are verified in §5.4 and §5.6. **No hub event was removed by this descope.**

## 6. NFR verification

### 6.1 Verifiable NFRs

| TC | NFR | Target | Method and tooling | Pass criterion |
|---|---|---|---|---|
| **TC-601** | `NFR003` | 4 ft per data point for **finished** product, configurable without a code change | Set a non-default cadence in configuration; run; count `RunReading` rows against footage | Applied cadence equals the configured value; **no rebuild or redeploy required** |
| **TC-602** | `NFR004` | 20 ft for **intermediate** product | Run FL1 with a subsequent rolling operation on the route | 20 ft cadence applied |
| **TC-603** | `NFR004` | **FL2 always 4 ft; FL3 hybrid both instances 4 ft** | Run FL2 standalone, then FL3 hybrid | 4 ft in all three instances; the rule "subsequent rolling operation exists → 20 ft, none → 4 ft" holds |
| **TC-604** | `NFR005` | **No polling** | Capture a full network trace over a 5-minute run | **Zero periodic GETs for live readings.** Any polling request fails the case |
| **TC-605** | `NFR005` | 1 s default, configurable to 5/10/30 s | Set each value; measure inter-message intervals | Each configured interval observed within tolerance |
| **TC-606** | `NFR006` | Cached state, never blank, auto-reconnect | Kill the transport mid-run; measure time to first painted frame | Cached state painted within one frame; banner shown; backoff observed; **no blank screen at any point** |
| **TC-607** | `NFR006` | Group re-join on reconnect | Restore the transport | Client re-joins its line group and resumes **without user action** |
| **TC-608** | `NFR007` | Two simultaneous dashboards | Two clients on FL1 and FL2 with independent jobs | Both receive only their own group's events; **no cross-talk** |
| **TC-609** | `NFR009` | Override alerts block passive dismissal | Escape, backdrop click, browser back, route change | **None dismisses.** Only Acknowledge or Stop Run |
| **TC-610** | `NFR009` | Spool prompt blocks passive dismissal | Same, on the stop-confirmation modal | Remains until Yes or No |
| **TC-611** | `NFR010` | Audit — supervisor overrides | Perform each of the four override types | Each records operator, supervisor, timestamp, station/line, old→new and reason. **PIN absent everywhere** |
| **TC-612** | `NFR010` | Audit — pass-schedule changes | Edit, override and acknowledge | Three `PassScheduleChangeLog` rows with the correct `ChangeType` |
| **TC-613** | `NFR010` | Audit — PLC tag writes and clears | Check in, roll adjust, check out | One audit entry per tag with path, value, operator, timestamp and result |
| **TC-614** | `NFR010` | Audit — retention | Query audit records for a completed run after 30 days of simulated ageing | All retained and retrievable |
| **TC-615** | `NFR011` | Audit — login/logout | Manual, auto shift-based and supervisor-override logins | All three captured with operator ID, station and timestamp |
| **TC-616** | `NFR012` | Weld genealogy queryable | Reconstruct the chain for a coil made from three rods across two welds | Full chain to supplier heat, with per-rod footage attribution |
| **TC-617** | `NFR012` | Coverage and non-overlap | Assert on the traceability rows | 100 % coverage, zero overlap, half-open ranges |
| **TC-618** | `NFR013` | Snapshot survives a schedule edit | Complete a coil, edit the schedule, re-render the technical record | The snapshot at creation is returned |
| **TC-619** | `NFR013` | R-series retained permanently | Query a historical rod alpha | Present in `coils` |

### 6.2 NFRs that are untestable until their targets are defined

**No threshold has been invented for these.** They are recorded as untestable so the gap is visible rather than silently passed.

| TC | NFR area | Missing target | Consequence | Owner | Needed by |
|---|---|---|---|---|---|
| **TC-620** | **AGC sample rate** | Undefined | The ingest channel size and decimation ratio cannot be sized or validated | Engineering | QA2 |
| **TC-621** | **Concurrent client count** | Undefined | **This is the `N` in "N clients × 3 lines × cadence". Without it there is no load test to run** | Architecture | QA2 |
| **TC-622** | **End-to-end latency budget** (PLC read → operator screen) | Undefined | The only number that says whether the real-time design succeeded | Architecture / Engineering | QA2 |
| **TC-623** | **`RunReading` retention and rollup** | Undefined | Unbounded time-series growth; report queries degrade silently | Architecture / DBA | Phase 1C |

> **The QA2 hub load test is scheduled and budgeted (16 h) with no pass criteria.** It will execute and produce numbers, but **it cannot fail**, which means it is not a gate. Gap **G9** / **OI-34**. Either the four targets above are set before 13 Sep, or QA2 must be recorded as *executed, not gating*.

### 6.3 Non-ID'd non-functional checks

| TC | Check | Pass criterion |
|---|---|---|
| **TC-624** | **Minimum text size** | No rendered text below **14 px** on any screen, **except** axis labels in the four documented vertically-compressed SVG charts. Form controls pinned to 14 px |
| **TC-625** | **Tap targets** | Every interactive element ≥ **48 px** |
| **TC-626** | **No hover dependency** | Every action reachable by touch alone; no action revealed only on hover |
| **TC-627** | **1280 × 1024 at 1:1** | Every screen renders complete with **no horizontal or vertical scrollbar** and no clipping |
| **TC-628** | **Angular coverage bar** | 95 % branches, functions, lines and statements |
| **TC-629** | **The word "strip"** | Absent from every screen, label, report and column heading |

---

## 7. UAT plan

**Window:** 28–30 Sep 2026, on staging. **Story:** `FW-123`.

> **UAT cannot share W7 with feature work.** At no team size can stakeholder sign-off begin on the same day feature work completes — `[SP §1.4]`. This plan assumes UAT runs in a dedicated window whichever date that lands on.

### 7.1 Participants

| Role | Who | Scenarios |
|---|---|---|
| FL1 operator | Line operator, day shift | U1, U2, U3, U6 |
| FL2 operator | Line operator | U4, U5 |
| Supervisor / Foreman | Shift supervisor | U6, U7, U8 |
| Operations Manager | Tim O. or delegate | U9 |
| Maintenance | Die/tooling owner | U10 |
| QA | Quality | U7, U11 |
| Packing | Packing operator | U5 |
| BA / facilitator | BA stream | all |

### 7.2 Scenario scripts — in operator language

| # | Scenario | Script | Sign-off |
|---|---|---|---|
| **U1** | *Start a rod on FL1* | Bring a rod to the free bay. Pre-check it in — scan it, pick the bay, do the visual check. When the running rod is nearly out, weld the new one on and mark it welded. When it is your turn, check the rod in: work through the six steps, confirm the pass schedule, acknowledge. Watch the run start | Operator |
| **U2** | *A rod arrives that planning did not expect next* | Try to stage it. You will be told it is out of sequence. Get a supervisor to authorise it. Confirm the bay card still shows who authorised it | Operator + Supervisor |
| **U3** | *A rod fails inspection* | Fail one of the three visual checks. Confirm your only way forward is WIP Rejection — there is no way to carry on | Operator |
| **U4** | *Finish a spool on FL2* | Scan the spool label FL1 printed. Check the gauge profile FL1 recorded, including the weld marks. Enter your measurements, confirm the schedule, acknowledge, run to a finished coil | Operator |
| **U5** | *Pack a skid* | Take the coil at the packing station, weigh it, compare it to the calculated weight, put a second coil on the skid, close it, print the labels | Packing + Operator |
| **U6** | *Something goes wrong mid-run* | Pause the run and give a reason. Come back, resume. Then pause again and check the rod out mid-run. Confirm you cannot finish it yourself — a supervisor has to approve it | Operator + Supervisor |
| **U7** | *Material out of spec* | Take an SPC reading that is out of spec. Suspend the material. Confirm **the machine keeps running**. As QA, release it with a concession | Operator + QA |
| **U8** | *Watch the floor* | On the Line Status board, confirm you can see all three lines, that the payoff weight counts down, and that you get warned before you run out of weld material. Acknowledge an alert | Supervisor |
| **U9** | *Set up a new product* | Create a pass schedule from specs, look at what it generated, adjust it, save it as active. Then change something mid-run and confirm the operator has to acknowledge it before the machine changes | Ops Manager |
| **U10** | *Change a die* | Change a die for gauge drift. Confirm you are sent to SPC and cannot go back to full production until it passes. Try to scan a die that is not registered | Maintenance + Operator |
| **U11** | *Prove where the metal came from* | Take a finished coil and trace it back — every rod that went into it, every weld, and the supplier heat. This is what a welding-wire customer will ask for | QA |

### 7.3 Sign-off criteria

- Every scenario completes, or its deviation is recorded and accepted.
- **Zero open Severity-1 defects.** No more than three Severity-2 defects, each with an agreed workaround.
- **All Critical open issues closed** — the `[SP §10.3]` "Immediately" and "Before W4" tiers in particular.
- The eleven success criteria in `[VS §9]` are evidenced.

---

## 8. PLC commissioning tests

Executed on the physical line with the commissioning engineer. **This is the only place several behaviours can be proven at all** — see §3.4.

> **C1–C11 are reproduced in [`PLCTagSpecification.md`](../../MVP-1/RequirementDocuments/PLCTagSpecification.md) §11** so the client can read the commissioning plan alongside the tag map they are being asked to sign. **This document remains authoritative for the pass criteria.** **Applied 4 Aug 2026 — the two documents now agree:** `C5` above records *which controller(s) were written*. Without it the test passed whether the FL3 batch reached one controller or two, which is the open question (**`PLC-Q08`** / gap **G30**).

### 8.1 Safety preconditions

- [ ] The line is under the commissioning engineer's control, not production control.
- [ ] Area clear, guards in place, E-stop verified — the same checks the check-in wizard's step 6 makes.
- [ ] **No production order is loaded.** Test material only.
- [ ] Everyone present knows the application **never sends a stop command** — the operator stops the machine physically.

### 8.2 Who must be present

Commissioning engineer (PLC) · Engineering (tag map owner) · one line operator · one developer with `appsettings` write access · QA to record.

### 8.3 Sequence

| # | Test | Method | Pass |
|---|---|---|---|
| **C1** | **Tag paths resolve** | Read every configured tag path in turn | Every path resolves. **Correct any wrong path in `appsettings.json` — no redeploy is required** |
| **C2** | **`FL{n}.LineState` vocabulary** | Drive the line through run, stop, pause, fault, thread and jog, recording the tag value at each | **The observed vocabulary is documented.** This closes **OI-35**, on which both the checkout gatekeeper and the spool prompt depend |
| **C3** | **Footage counter** | Run a measured length | Counter matches within tolerance |
| **C4** | **Tag push configures the machine** | Acknowledge a pass schedule at check-in | Component states, die sizes, roll gaps, edge type and targets **all take effect on the machine** |
| **C5** | **FL3 single-batch push** | Acknowledge an FL3 hybrid check-in | **One** acknowledgement configures FM1 **and** FM2, **and the controller(s) actually written are recorded** — without that step the test passes under either topology and cannot settle whether the FL3 batch crosses a controller boundary (**`PLC-Q08`** / **G30**) |
| **C6** | **Tag clear on checkout** | Stop the line, check the rod out | Tags cleared **only after the confirmed stop**; payoff assignment cleared |
| **C7** | **`ITInhibit` blocks run, on that line only** | Set each of the five conditions on one line, **with a second line running** | Machine run **blocked** in each case and cleared only when the condition resolves — and **the second line is unaffected throughout**. The interlock is line-scoped (`[PLC §8.1]`, **D15**) |
| **C8** | **AGC feed reaches the screen** | Run at speed | Gauge and width stream to DB3 at the configured cadence; **the latency is measured and recorded — this is the number OI-34 needs** |
| **C9** | **Stop-confirmation edge** | Run to target weight, stop, hold past the dwell | Prompt fires once; weight latched at the stop timestamp |
| **C10** | **Checkout gatekeeper** | Attempt a checkout with the line running | Blocked with the specified message; **no stop command observed on the wire** |
| **C11** | **FM2 station names and the three-stand set** | Read the gap and status of **each of the three FM2 stands** and record the **path string the controller actually accepted** | **Exactly three FM2 stands respond, and the accepted station names are recorded.** This settles **`PLC-Q04`**: `S1`/`S2`/`S3` as specified, or the controller's own `Stand8`/`Stand6S1`/`Stand6S2`. **A fourth stand must not respond** — if one does, the three-stand correction is wrong and Phase 2/8 stop. *(Rewritten 4 Aug 2026: this test previously read "FM2 S3 tag path … closes OI-36", which assumed a missing tag. `OI-36` is closed by the correction itself — the published map's three stations are the three real stands — so what commissioning must now confirm is the naming, not the existence.)* |

### 8.4 Abort criteria

Abort and reconvene if: any tag write produces unexpected machine motion · `ITInhibit` fails to block run · the footage counter is wrong by more than the agreed tolerance · or any safety precondition lapses.

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
| **Go-live** | The above, plus a rehearsed rollback (`[DR §6]`) and a green PLC commissioning sequence (§8) |

---

## 10. Coverage matrix

> **⚠ Read this before quoting a coverage figure.** Until 13 Aug 2026 §10.1 mapped SRS
> **section ranges** to TC ranges and a percentage was concluded from it. A range mapping
> cannot show that an *individual* requirement was tested, and when coverage was first
> measured per requirement, **41 had no case at all — 32 of them `Must`**. The percentage
> had been computed from the range table, so nothing in the document contradicted it.
>
> Coverage is now measured per requirement by
> [`build_coverage_matrix.py`](Tools/build_coverage_matrix.py), which
> **exits non-zero** if any requirement has neither a case nor an entry in §10.4. The
> range table below is retained as a **navigation aid only — it is not the evidence.**
> Registered as gap **`G25`**.
>
> **The denominator changed too.** `02-SRS.md` carries **263** MVP-1 requirements;
> §5.10, §5.18, §5.19, §5.23 and §5.24 moved to MVP-2 on 11 Aug 2026 and §5.21/§5.22 were
> withdrawn with the DB13/DB14 descope. The **363** figure quoted here before 13 Aug 2026
> was the pre-split MVP-1 + MVP-2 total.

### 10.1 `FR-###` → `TC-###` — section navigation

**Not the coverage evidence.** Run the checker for that. Rows for sections that have left
MVP-1 are marked and their requirements are no longer in `02-SRS.md`.

| `[SRS]` § | FR range | Test cases | Depth |
|---|---|---|---|
| 5.0 | FR-001 – FR-022 | TC-001 – TC-030, TC-601 – TC-603 | happy · negative · boundary |
| 5.1 | FR-030 – FR-054 | TC-040 – TC-069 | happy · negative · boundary · concurrency · permission |
| 5.2 | FR-060 – FR-084 | TC-070 – TC-100 | happy · negative · boundary · real-time · compensating-write |
| 5.3 | FR-090 – FR-096 | TC-110 – TC-118 | happy · negative |
| 5.4 | FR-100 – FR-120 | TC-130 – TC-137, TC-140 – TC-147, TC-606 – TC-608 *(TC-138, TC-148 withdrawn)* | happy · boundary · real-time · resilience |
| 5.5 | FR-130 – FR-157 | TC-160 – TC-184 | happy · boundary · negative · real-time |
| 5.6 | FR-160 – FR-175 | TC-190 – TC-207, TC-616 – TC-617 | **deepest — contractual** |
| 5.7 | FR-180 – FR-197 | TC-220 – TC-238 | happy · negative · boundary |
| 5.8 | FR-200 – FR-212 | TC-250 – TC-261 | happy · negative · permission |
| 5.9 | FR-220 – FR-234 | TC-270 – TC-285 | happy · negative · routing |
| ~~5.10~~ | ~~FR-240 – FR-255~~ | ~~TC-295 – TC-304~~ | **MVP-2 — moved 11 Aug 2026** |
| 5.11 | FR-260 – FR-267 | TC-315 – TC-326 | happy · negative · contract divergence |
| 5.12 | FR-270 – FR-277 | TC-335 – TC-341 | happy · boundary · gating |
| 5.13 | FR-280 – FR-282 | TC-350 – TC-352 | **not executable — OI-13** |
| 5.14 | FR-290 – FR-299 | TC-355 – TC-365 | happy · negative · real-time |
| 5.15 | FR-300 – FR-327 | TC-375 – TC-396 | **deep — safety-critical gatekeeper** |
| 5.16 | FR-330 – FR-340 | TC-405 – TC-421, TC-618 | **deep — weight and genealogy** |
| 5.17 | FR-345 – FR-352 | TC-435 – TC-439 | happy |
| ~~5.18~~ | ~~FR-360 – FR-391~~ | ~~TC-450 – TC-475~~ | **MVP-2 — moved 11 Aug 2026** |
| ~~5.19~~ | ~~FR-400 – FR-410~~ | ~~TC-476 – TC-480~~ | **MVP-2 — moved 11 Aug 2026** |
| 5.20 | FR-420 – FR-428 | TC-490 – TC-502 *(TC-503 withdrawn)* | happy · **all five alert rules** |
| ~~5.21~~ | ~~FR-440 – FR-451~~ | ~~TC-515 – TC-521~~ | **withdrawn 4 Aug 2026** |
| ~~5.22~~ | ~~FR-460 – FR-470~~ | ~~TC-530 – TC-534~~ | **withdrawn 4 Aug 2026** |
| ~~5.23~~ | ~~FR-480 – FR-490~~ | ~~TC-545 – TC-550~~ | **MVP-2 — moved 11 Aug 2026** |
| ~~5.24~~ | ~~FR-500 – FR-508~~ | ~~TC-560~~ | **MVP-2 — moved 11 Aug 2026** *(was: not scheduled — PP-03)* |
| §6 NFRs | `NFR003`–`NFR013` | TC-601 – TC-629 | measurable targets |
| Security | `[SRS §8]` | TC-640 – TC-659 *(§10.3)* | permission matrix |
| Deployment | `[DR §5]` | TC-700 – TC-714 | smoke |

### 10.2 `TC-###` → `FR-###` — the reverse direction

**Every test case in §5 names the `FR-###` it proves in its own row.** No test case exists without a requirement behind it. The §6 cases name their `NFR###`; the §10.3 cases name the permission matrix row; the §8 cases name the commissioning obligation.

**This direction has been machine-verified and holds** — all 365 case rows name their requirement in the *FR / Source* column, and no case names one anywhere else instead. **It was never the direction in doubt.** A test suite can name a requirement on every case and still leave requirements untested; that is exactly what happened here, and only §10.1's per-requirement check detects it.

### 10.3 Security and role cases — TC-640 … TC-659

One case per contested row of the `[SRS §8]` matrix, each executed as the permitted role and as at least one denied role.

| TC | Action | Permitted | Denied |
|---|---|---|---|
| **TC-640** | Create / edit pass schedule | OpsMgr, Eng | Operator, Supervisor, QA |
| **TC-641** | Activate / deactivate pass schedule | OpsMgr, Eng | Operator, Supervisor, QA |
| **TC-642** | Override a pass-schedule setting mid-run | OpsMgr, Eng | Operator, Supervisor |
| **TC-643** | One-for-one same-size die swap at run | Operator, Supervisor, OpsMgr, Eng | QA |
| **TC-644** | **Revert** a roll-gap override | OpsMgr, Eng | Operator, Supervisor |
| **TC-645** | Approve mid-run rod checkout | Supervisor, OpsMgr | Operator, Eng, QA |
| **TC-646** | Approve partial-run material disposition | Supervisor, OpsMgr | Operator |
| **TC-647** | Supervisor override for weld removal | Supervisor, OpsMgr | Operator |
| **TC-648** | Authorise off-schedule / out-of-sequence staging | Supervisor, OpsMgr | Operator |
| **TC-649** | Authorise an out-of-tolerance spool weight | Supervisor, OpsMgr | Operator |
| **TC-650** | **Dispose** a WIP rejection | Supervisor, OpsMgr, QA | Operator, Eng |
| **TC-651** | Die management / tooling life | OpsMgr, Eng | Operator, Supervisor, QA |
| **TC-652** | Edit the alloy lookup table | Eng (Process Eng / Sys Admin) | all others |
| **TC-653** | View shift summary | Supervisor, OpsMgr | Operator, Eng, QA |
| **TC-654** | Supervisor override for un-punched login | Supervisor, OpsMgr | Operator, Eng, QA |
| **TC-655** | **Every endpoint requires authentication** | — | Unauthenticated → `401` on all 30 |

> **These cases assume the roles exist as JWT claims.** Whether they do **has never been confirmed** — **OI-37**, and it can block the build outright. If provisioning is required, TC-640 – TC-655 cannot run until it lands.

### 10.4 What is **not** covered, and why

**Two kinds of hole, and the difference is the point.** §10.4.1 lists what is knowingly
excluded — each entry is a *decision*, with a blocking open item behind it. §10.4.2 lists
requirements that simply have **no case authored**; those are *accidents*, found on
13 Aug 2026 when coverage was first measured per requirement. Both are listed rather than
omitted, and [`build_coverage_matrix.py`](Tools/build_coverage_matrix.py)
fails the build if a requirement appears in neither this section nor a case.

#### 10.4.1 Knowingly excluded — a decision, with an owner

| Not covered | Reason |
|---|---|
| **FR-280 – FR-282** (wire break, 3 requirements) | **No screen, no table, no persistence target — OI-13.** TC-350–352 are written and blocked. Story `FW-N08` is blocked |
| **FR-500 – FR-508** (OEE, 9 requirements) | **No story, no phase, no owner — PP-03.** TC-560 written, not scheduled |
| **Rework disposition end state** (part of FR-292/FR-297) | **Unpersistable — OI-22.** TC-359 records the gap |
| **`lotNumber` on the coil label** (part of FR-336) | **No column, no generator — OI-24.** TC-420 records the gap |
| **Multi-coil footage-frame mapping** (part of FR-333) | **Coil-start offset unstated — OI-25.** TC-421 fails until it closes. **Highest consequence of the four, because `NFR012` is contractual** |
| **Roll-override revert** (FR-212) | **No endpoint — OI-32.** TC-260 records the gap |
| **Alert persistence across restart** (part of FR-422/FR-428) | **No table — OI-28.** TC-500 records the gap |
| **Mode B approval when no supervisor is connected** (part of FR-324) | **Transient notification — G7.** TC-393 records the gap |
| **No-match schedule path at check-in** (part of FR-070) | **Undefined — OI-46.** TC-100 records observed behaviour only |
| **Hybrid-origin guard at FL2 check-in** (FR-091) | **Undefined — OI-47.** TC-118 records observed behaviour only |
| **Four real-time NFR targets** | **Undefined — G9 / OI-34.** TC-620–623 marked untestable-until-defined; **no threshold invented** |
| Upstream rod receiving, planning, scheduling and web changes | Out of test scope (§2.2) — fixture-supplied |

#### 10.4.2 No case authored — owed work, not an exemption

**Found 13 Aug 2026 by the first per-requirement measurement.** These 41 requirements are
in MVP-1 scope, are not withdrawn, and no case names any of them. **32 are `Must`.** They
are listed so the number in §10.5 is honest; none of these reasons is a justification for
leaving it that way. Tracked as gap **`G25`**.

Three of the four kinds below are cheap to close, and the distinction decides how:

| `FR-###` | Pri | § | Why there is no case | What closes it |
|---|---|---|---|---|
| **FR-030** | Should | 5.1 | Section-opening scope statement — every §5.1 case runs at the Pre-Check-In station, none names the requirement that it exists | Name it on an existing case |
| **FR-100** | Must | 5.4 | Section-opening scope statement — the header run-context fields are visible in every §5.4 case, asserted by none | Name it on an existing case |
| **FR-160** | Must | 5.6 | Section-opening scope statement — mill-stopped and mill-running welds are both exercised in §5.6 | Name it on an existing case |
| **FR-300** | Must | 5.15 | Section-opening scope statement — TC-377 proves no stop command is sent but names `FR-302` | Add `FR-300` to TC-377 |
| **FR-276** | Must | 5.12 | Product-form statement (FL1 → ~3,500 lb reusable spool, system-generated number) — no case asserts the output form | New case, or name it on the spool-completion cases |
| **FR-277** | Must | 5.12 | Product-form statement (FL2 → coreless oscillated ~1,100 lb coil, two per skid) | New case, or name it on TC-435–444 |
| **FR-161** | Must | 5.6 | **Not test-case shaped.** "Event-driven and extensible so future continuous-operation welding needs no redesign" is an architectural quality with no black-box observation | Design review against `00-foundations.md` §0.4 — record the verdict here, do not fake a case |
| **FR-022** | Must | 5.0 | Configuration requirement — tag paths sourced from `appsettings.json`, never hardcoded | Static check or a commissioning step in §8; `C1` already records accepted paths |
| **FR-183** | Should | 5.7 | Configurability requirement — SPC sampling rules per customer and per process stage | New case once the configuration surface exists |
| **FR-340** | Should | 5.16 | Hardware provisioning — two label printers per line (Sato + high-temperature) | Commissioning check in §8, not a §5 case |
| **FR-175** | Should | 5.6 | **No host since 1 Aug 2026** — the traceability chain and the re-sequenceable *Rods In Queue* both lived on the retired Dashboard 4 and neither moved to the DB2A dialog | Gap **`G27`**. Rehome, fold into *Welds this run*, or withdraw `FR-175` — the case follows the decision |
| **FR-021** | Must | 5.0 | Behavioural, no case authored — stop popup on the OPC mill-speed tag reading zero | New case |
| **FR-054** | Should | 5.1 | Behavioural, no case authored — un-staging the last rod on an idle line clears the established order and returns to cold start | New case |
| **FR-064** | Must | 5.2 | Behavioural, no case authored — rod number validated against `coils`, invalid rejected | New case |
| **FR-080** | Must | 5.2 | Behavioural, no case authored — machine-inspection steps 4–6 use OK / NG / N/A with measured values against spec | New case |
| **FR-110** | Must | 5.4 | Behavioural, no case authored — *Check Out Rod* enabled only at footage zero. **Adjacent to TC-375/376, which gate on line state, not footage** | New case |
| **FR-156** | Must | 5.5 | Behavioural, no case authored — variance returning inside tolerance removes the override requirement and the completion records none | New case |
| **FR-157** | Must | 5.5 | Behavioural, no case authored — answering *Yes* does not bypass mandatory per-spool gauge and width SPC | New case — this one is a gate, treat as `P1` |
| **FR-194** | Must | 5.7 | Behavioural, no case authored — *Submit · suspend material* elevates to filled danger style when any measurement is out of spec | New case |
| **FR-195** | Must | 5.7 | Behavioural, no case authored — default measurement sets per checkpoint type | New case per checkpoint type |
| **FR-196** | Must | 5.7 | Behavioural, no case authored — `PostDieChange` trigger banner naming die block, size change and logging context | New case |
| **FR-298** | Must | 5.14 | Behavioural, no case authored — *Suspend* states that supervisor review is required and names the notified supervisor | New case |
| **FR-310** | Must | 5.15 | Behavioural, no case authored — Mode A availability (checked in, footage zero, entered from the DB2 footer or DB3) | New case |
| **FR-339** | Must | 5.16 | Behavioural, no case authored — skid numbering follows existing skid rules. **Depends on `OI-104`** (the skid table nothing names or creates) | Blocked on `G36`; write the case when the skid source is confirmed |
| **FR-426** | Must | 5.20 | Behavioural, no case authored — all live readings and alerts update via the SignalR stream | New case; overlaps the §6 real-time NFRs, which are themselves undefined (`G9`) |
| **FR-032** | Should | 5.1 | UI content/layout — both payoff bays presented as peers, one state machine, one renderer | New case |
| **FR-033** | Should | 5.1 | UI content/layout — the four bay states and their actions | New case |
| **FR-035** | Should | 5.1 | UI content/layout — Traveler Queue row content | New case |
| **FR-037** | Should | 5.1 | UI content/layout — queue header states the order once, with progress | New case |
| **FR-105** | Must | 5.4 | UI content/layout — machine status (speed, footage) and component status (DB1/DB2 state, active die diameter, FM1 gap/width) | New case |
| **FR-115** | Must | 5.4 | UI content/layout — Traveler sections adapted to the active station | New case |
| **FR-201** | Must | 5.8 | UI content/layout — Roll Adjust context strip fields | New case |
| **FR-208** | Must | 5.8 | UI content/layout — operator, timestamp and footage auto-populated and not editable | New case — the *not editable* half is a real assertion |
| **FR-224** | Must | 5.9 | UI content/layout — incoming die scan field pre-focused, lookup populates size and condition | New case |
| **FR-226** | Must | 5.9 | UI content/layout — five mutually exclusive reason codes. **TC-284 proves the list is exactly five but names `[API §4.12]`, not `FR-226`** | Add `FR-226` to TC-284 |
| **FR-230** | Must | 5.9 | UI content/layout — read-only audit stamp (operator, server timestamp, footage, output coil alpha) | New case |
| **FR-272** | Must | 5.12 | UI content/layout — stop popup next-section data | New case |
| **FR-311** | Must | 5.15 | UI content/layout — checkout dialog read-only fields and the reason list | New case |
| **FR-321** | Must | 5.15 | UI content/layout — Mode B dialog fields, footage auto-captured read-only | New case |
| **FR-348** | Must | 5.17 | UI content/layout — coil label panel previews and prints on confirm | New case |
| **FR-352** | Must | 5.17 | UI content/layout — R48-style packaging orientation prompts | New case |

**Two are one-line fixes, not new cases** — `FR-300` on TC-377 and `FR-226` on TC-284. The
case already proves the requirement; only the citation is missing. Look for that pattern
before authoring anything new.

### 10.5 Coverage summary — generated, not asserted

Produced by [`build_coverage_matrix.py`](Tools/build_coverage_matrix.py).
**Do not hand-edit these figures; re-run the checker.**

| Measure | Count |
|---|---|
| MVP-1 requirements (`02-SRS.md` rows) | **263** |
| Withdrawn, not counted | 4 |
| Covered by a case — direct | 220 |
| Covered via the `NFR` table — indirect | 1 |
| Declared not covered (§10.4.1) | 1 |
| **No case authored (§10.4.2)** | **41** |
| **Requirements with a case** | **84.0 %** |

**"With a case" is not "executable."** `TC-350`–`TC-352` name `FR-280`–`FR-282` and cannot
be run (`OI-13`); they count in the 220. The previous figure — *"351 of 363 (96.7 %)"* —
was wrong in both terms: 363 was the pre-split MVP-1 + MVP-2 denominator, and 351 was
derived from the §10.1 range table rather than from the cases.
