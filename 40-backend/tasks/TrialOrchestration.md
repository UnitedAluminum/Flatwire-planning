# Six-Screen Trial Run — Execution Orchestration (30 Sep 2026)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — **§9 added: what is actually built, measured against `ual-api`, `ual-angular` and the deployed `FlatWireDB`, and grouped by phase × stream in §9.6, and §2's three sprint grids re-cut with `BE`/`FE`/`RT`/`DB` columns **and a status glyph on every story**, stamped from the front-matter by `tools/stamp_trial_status.py`.** The backend spine is committed and green; ⛔ **six Phase-4–8 services are de-stubbed but uncommitted (§9.2), the frontend is a scaffold (§9.4), and the deployed database predates the `Q60` spool swap and is unseeded (§9.5)**. **`1B` holds 16 of the trial's 17 `done` stories; phases 3–8 hold 30 and none is `done`.** Change history is in [`CHANGELOG.md`](../../CHANGELOG.md)
**Document Type:** Execution index and story map for the 30 Sep trial run
**Status:** Active — **the trial-scope companion to [Orchestration.md](Orchestration.md)**
**Owner:** Delivery lead, across all four streams
**Audience:** Anyone sequencing or building the trial
**Shortcode:** — *(orchestration, derived from `[TRP]` and the plans; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/tasks/` — Phase-1B companion: [Orchestration.md](Orchestration.md)

---

> **What this file is, and how it differs from its sibling.** Two orchestrations over
> overlapping stories, on **different axes**:
>
> | | [Orchestration.md](Orchestration.md) | **this file** |
> |---|---|---|
> | Axis | Phase 1B, by **dependency wave** | the trial, by **sprint** |
> | Covers | 22 stories, one layer, all planned | **66 stories, four streams, three sprints** |
> | Question | *what can start?* | *what ships on 30 Sep?* |
>
> **`[TRP]` is the authority; this is a map of it.** Where they disagree, `[TRP]` wins.
>
> ⚠ **The trial is not MVP-1 feature-complete** — *"30 Sep is a trial-run date, not an MVP-1
> feature-complete date"* (`[RM]`). **330 h of MVP-1 work is deferred out of it**, §5.
>
> **§1–§8 are the plan. [§9](#9-where-the-build-actually-is--measured-29-aug-2026) is the
> measurement** — what exists in `ual-api` / `ual-angular` / `FlatWireDB` today, which is the one
> thing [`STATUS.md`](../../STATUS.md) cannot tell you.

---

## 1. Coverage — 66 stories, 31 with a plan

| | Stories | Planned | Where the rest live |
|---|---|---|---|
| **BE** | 21 | **21** ✅ | — |
| **RT** | 13 | **10** | `FW-135`/`136`/`137` are Angular (§1.2) |
| **FE** | 20 | 0 | `ual-angular`; owning specs in `Business/Screens/` |
| **DB** | 12 | 0 | `Database/Schema/SQL/` |
| | **66** | **31** | |

**This folder is Backend-scoped**, so it holds the 31 server-side plans and maps the other 35
without duplicating their specifications. FE and DB rows below name the owning document
instead of a plan.

### 1.1 The ten added for the trial

Beyond Phase 1B's 22, these ten are trial-path server stories:

| Plan | h | Phase | Why it matters here |
|---|---|---|---|
| [FW-157](FW-157.md) | 36 | 4 | The largest BE story; ⚠ **trial runs it without `RodStaging`** |
| [FW-082](FW-082.md) | 16 | 4 | The moment software configures a machine |
| [FW-164](FW-164.md) | 12 | 5 | ⚠ **`GET /run/active` is the trial's landing route** |
| [FW-168](FW-168.md) | 12 | 6 | Server-side verdict; five `CheckpointType` values |
| [FW-170](FW-170.md) | 8 | 6 | Four resume outcomes; PLC idle/restore |
| [FW-172](FW-172.md) | 20 | 6 | Four markers, immediate and unbatched |
| [FW-174](FW-174.md) | 24 | 7 | **The only thing that clears a `Blocked` bay** |
| [FW-177](FW-177.md) | 16 | 7 | The other two markers |
| [FW-179](FW-179.md) | 18 | 8 | FL2 tags only; ⚠ **`[API §4.6a]`'s example is stale** |
| [FW-181](FW-181.md) | 4 | 8 | ⚠ *"the single most likely thing to ship wrong"* |

### 1.2 ⚠ Three RT stories are Angular, not backend

`FW-135` (`flat-wire-signalr.service.ts`, NgZone, ring buffer), `FW-136`
(`MockSignalRService`, Jest) and `FW-137` (service worker, PWA cache) carry the **RT** stream
label but are **`ual-angular` code**. They belong with 1A and are **deliberately not planned
here** — a Backend folder is the wrong home, and `[ARC §2.2]` gives them **no Angular
template** to work from anyway.

---

## 2. The three sprints

`[TRP §4]`. **832 h total**; the four new stories (`FW-202`, `FW-203`, `FW-204`, `FW-218`) plus
`FW-214` are **additive to `[CE §3b]`**.

**Status glyph on every story:** ✅ done · 🔵 in-review · 🟡 in-progress · ⛔ blocked · ⬜ not-started · ⊘ cancelled — `build_status.py`'s
vocabulary, so a glyph means here what it means on [`STATUS.md`](../../STATUS.md).

> ⚠ **The glyphs are STAMPED FROM the task front-matter, never typed.**
> `python tools/stamp_trial_status.py` writes them from each card's `status:`, and `--check` fails
> when they drift. **To change one, change the task file and re-stamp** — a status typed here would
> be a second register to contradict the first, which is what §8 forbids.

> **Sequencing within a sprint is `[TRP §3]`'s, not this file's.** It is not restated here —
> duplicating a sequence is how the six PLC tag-map copies happened. Two ordering constraints
> are load-bearing enough to name, and both are already in the owning plans:
>
> | Constraint | Why | Plan |
> |---|---|---|
> | **`FW-202` before Phase 8 *starts*, not beside it** | It writes the `SpoolProcessing` row DB5 reads. `[TRP §3]`: *"In a five-day sprint that is a real sequencing constraint, not a formality"* | [FW-179 §4](FW-179.md) |
> | **`FW-218` before the acceptance run** | Three of `[TRP §8]`'s ten steps cannot be executed without a control surface (§7) | [FW-218](FW-218.md) |
>
> For the **Phase-1B** stories in T1, the dependency waves and the 134 h critical path are in
> [Orchestration.md §2–§3](Orchestration.md).

### T1 — Phase 1 platform · 409 h

| Phase | BE | FE | RT | DB |
|---|---|---|---|---|
| **1A** | — | ⬜ `FW-N03` · ⬜ `FW-130` · ⛔ `FW-131` · ⬜ `FW-132` · ⬜ **`FW-133` 75** · ⬜ `FW-134` | ⬜ `FW-135` · ⬜ `FW-136` · ⛔ `FW-137` *(Angular, §1.2)* | — |
| **1B** | ✅ [FW-N04](FW-N04.md) · ✅ [FW-138](FW-138.md) *(7 controllers, `P-53`)* · ✅ [FW-139](FW-139.md) · ✅ [FW-140](FW-140.md) · ✅ [FW-141](FW-141.md) · ✅ [FW-142](FW-142.md) · ✅ [FW-143](FW-143.md) · 🔵 [FW-144](FW-144.md) · ⛔ [FW-145](FW-145.md) · ✅ [FW-146](FW-146.md) · ✅ [FW-147](FW-147.md) · ✅ [FW-148](FW-148.md) · 🔵 [FW-207](FW-207.md) · ✅ [FW-208](FW-208.md) | — | 🔵 [FW-080](FW-080.md) · 🔵 [FW-149](FW-149.md) | — |
| **1C** | — | — | — | ⊘ ~~`FW-002`~~ *(cancelled, `D-32`)* · 🔵 `FW-152` · ⬜ `FW-005` · ⬜ `FW-004` · ⬜ `FW-006` · ⬜ **`FW-007` 31** |
| **h** — `[TRP]`'s, **per stream** | **145** | **139** | **60** | **65** *(62 after `D-32`; published figure held — see `[TRP §2.1]`)* |

> ⚠ **T1's hours stay on the axis `[TRP]` published them on — the stream — so they are the footer,
> not the rows.** No per-phase figure exists and none is derived here (§8).

> **`FW-133` (75 h) is the single largest story in the trial and all six screens depend on
> it** — `pass-schedule-table`, `confirm-bar`, `gauge-trace-chart`, `tab-wizard`,
> `action-bar`, `payoff-weight-bar`. **`[TRP]`: "It is not trimmable."**

### T2 — check-in and the run monitor · 280 h

| Group | BE | FE | RT | DB | h |
|---|---|---|---|---|---|
| **1B close-out** | ✅ [FW-218](FW-218.md) | — | ✅ [FW-150](FW-150.md) · ✅ [FW-151](FW-151.md) · ✅ [FW-205](FW-205.md) · ✅ [FW-203](FW-203.md) *(for `FW-N05`)* | — | 53 |
| navigation | — | ⬜ `FW-204` · ⬜ `FW-153` | — | 🔵 `FW-155` | 15 |
| **Phase 4** | 🔵 [FW-157](FW-157.md) | ⬜ `FW-061` | ⬜ [FW-082](FW-082.md) | 🔵 `FW-159` | 74 |
| **Phase 5** | 🔵 [FW-164](FW-164.md) | ⬜ `FW-062` · ⬜ `FW-162` · ⬜ `FW-081` · ⬜ `FW-163` · ⬜ `FW-214` | — | 🔵 `FW-165` | 89 |
| **Phase 6** *(start)* | ⛔ [FW-168](FW-168.md) · ⬜ [FW-170](FW-170.md) | ⬜ `FW-065` · ⬜ `FW-071` | — | 🔵 `FW-171` | 49 |

### T3 — exceptions, completion, FL2 · 143 h

| Group | BE | FE | RT | DB | h |
|---|---|---|---|---|---|
| Phase 6 close | — | — | ⬜ [FW-172](FW-172.md) | — | 7 |
| **Phase 7** | ⬜ [FW-174](FW-174.md) | ⬜ `FW-067` | ⬜ [FW-177](FW-177.md) | 🔵 `FW-176` | 31 |
| **new** | — | ⛔ **`FW-202` 67** — FL1 spool completion, Part B | — | — | 67 |
| **Phase 8** | ⬜ [FW-179](FW-179.md) | ⬜ `FW-064` · ⬜ `FW-178` | ⬜ [FW-181](FW-181.md) | 🔵 `FW-180` | 38 |

> ⚠ **`FW-202` is columned `FE` because that is its card's `stream:`**, while this table files it as
> **new T3 work** and its plan lives in this Backend folder — the `G62` mismatch §9.6 records.

> ⚠ **`FW-202` must land *before* Phase 8 starts, not beside it** — it writes the `SpoolProcessing` row
> DB5 reads. `[TRP §3]`: *"In a five-day sprint that is a real sequencing constraint, not a
> formality."*

---

## 3. What the trial builds differently

Not reduced quality — **reduced surface**. Each has a plan section saying so.

| | Trial | MVP-1 | Where |
|---|---|---|---|
| Controllers | **7**, of which only **5** serve a screen | 14 | [FW-138 §3.0a](FW-138.md) |
| OPC ingest | [FW-203](FW-203.md) simulator | [FW-N05](FW-N05.md) real | [FW-N05 §1.1](FW-N05.md) |
| Check-in | **no `RodStaging`** | staged-row consumption | [FW-157 §2.3](FW-157.md) |
| Resume | 3 of 4 outcomes; *Check out rod* disabled | four | [FW-170 §2.2](FW-170.md) |
| Weld markers | layer built, **renders empty** | populated | [FW-172 §1.1](FW-172.md) |
| Supervisor notify | **transient** — `FW-175` deferred | durable queue | [FW-177 §3](FW-177.md) |
| Broadcast loop · `PLCTagService` | **unreduced, deliberately** | same | [FW-150 §`P-31`](FW-150.md) |

> ⚠ **`P-53` reaches the trial's opening screen — 25 Aug 2026.** `RodReceivingController` and
> all three `/rod/**` endpoints leave the service, and **DB2 rod check-in scans a rod**: the
> scan was served by `GET /rod/{alpha}`, *"everything staging and check-in need in one round
> trip"* (`[API §4.3]`). The trial therefore has no scan validation, no carry-forward gate
> (`FR-043` needs `footageRunToDate`) and no station switching (`Q24` needs `scheduledLineId`)
> until `[API]` re-homes them — `FW-138`'s `P-54`. **Settle it before T1 is scheduled.**

> **`FW-150` and `FW-151` are not reduced** precisely so the real ingest drops in behind them
> unchanged. **If either can tell the feed is simulated, the substitution has failed.**

---

## 4. Trial blockers — `[TRP §6]`

| By | Blocker | Stops | Plan |
|---|---|---|---|
| ~~28 Aug~~ ✅ **Closed 15 Aug** | ~~**`G6`** — roles as JWT claims~~ | ~~🔴 Every role-gated action in the trial~~ — **answered: the six roles exist on `ClaimTypes.Role`**, so DB2 overrides, the SPC skip, WIP disposition and the spool weight-variance override are all reachable | [FW-145](FW-145.md) · [FW-177](FW-177.md) |
| **Before the T1 QA0 walkthrough** | **`G6` residual** — the six claim **values**, coded rather than `[SEC §8]`'s labels | ⚠ Those same role-gated actions **build** fine and cannot be **verified** until the mapping lands. In `FW-177` a wrong value fails *silent* — the supervisor notification reaches an empty group | [FW-145 §5](FW-145.md) · [FW-177 §3.1](FW-177.md) |
| **Before T2** | **`Q22`** — min/max tolerance values | ⛔ Owed by e-mail, **nothing seeded**. `CHK007` is a band check at both stations | [FW-168 §`P-43`](FW-168.md) |
| **Before T2** | **`G2` / `OI-39`** — cross-DB recovery | **Phase 4 is provisional until it closes**; carries the 24–64 h reserve | [FW-157](FW-157.md) · [FW-151](FW-151.md) |
| **Before T2** | **`G10`** — IIS WebSockets on `devual-uadev001` | Transport **silently** falls back to long-poll. **Provisioning, not build** | [FW-080](FW-080.md) |
| **Before T1 closes** | **`G23`** — the 1280×1024 canvas unconfirmed | 1920×1080 is **a re-layout of every screen, not a rescale**. *"Gets more expensive every sprint"* | FE — `[TRP §6]` |
| Before Phase 8 ships | **`Q15` / `OI-47`** — hybrid-origin guard **undefined** | `TC-118` is P1: *"gate fails until specified"*. The trial does not walk into it | [FW-179 §3](FW-179.md) |

✅ **Blocker 1 closed by `D-31`** — the three `PassSchedule*` tables, their seed, 10 FKs and 6
indexes moved into MVP-1. It had blocked **both check-in screens, i.e. the whole trial**.

⚠ **Second-tier, stops no build:** `Q10`/`OI-45` — `AlloyProperty.LbPerFtFactor` is seeded
**NULL, "OQ-10 PENDING"**, so step 7's calculated net weight is NULL and **the ±2 %
scale-vs-calculated variance cannot execute**. Seed a clearly-marked provisional factor or
accept it as untestable.

---

## 5. Deferred — still MVP-1, out of the trial · 330 h

`[TRP §4]`. **Deferred is not cancelled.**

| Deferred | h | Consequence for the plans |
|---|---|---|
| **DB1** `FW-060` + `FW-154` | 42 | [FW-164](FW-164.md)'s `GET /run/active` becomes the landing route; [FW-177](FW-177.md)'s `AlertRaised` **loses its consumer** and is built anyway |
| **DB2A + weld** `FW-N01`, `FW-158`, `FW-160`, `FW-063`, `FW-166` | 70 | [FW-157](FW-157.md) runs without `RodStaging`; [FW-172](FW-172.md)'s weld marker renders empty |
| ~~**`FW-001`**~~ shared-schema renames — **CANCELLED outright, `D-32`, 18 Aug 2026; no longer a descope decision** | 36 | **Highest blast radius in the plan.** *"A trial does not need it; production does"* |
| **[`FW-N05`](FW-N05.md)** real OPC ingest | 22 | *"Not verifiable without the hardware"* — October commissioning |
| **`FW-N06`** alert rules engine | 28 | Its only consumer was DB1's alert bar |
| Spool completion **Part A** | 25 | `Should`, advisory. **Part B (`FW-202`) is `Must` and stays** |
| `FW-073` die change · `FW-167` | 23 | Grey the DB3 button |
| `FW-070` roll adjust · `FW-169` | 26 | FL2/FL3 only; grey on DB3-FL2. ⚠ **`RollAdjustTrigger` must still exist** — [FW-168 §2](FW-168.md) |
| `FW-072` rod checkout · `FW-173` · `FW-175` | 39 | [FW-170](FW-170.md) ships 3 of 4 outcomes; [FW-177](FW-177.md)'s notification is transient |
| `FW-124` DB5A · `FW-N02` | 19 | **`GET /spools` still ships** in [FW-179](FW-179.md) |

**Phases 9–14 are wholly outside the trial.**

> ⚠ **The standing pattern for a deferred feature is *grey the control and state "not in trial
> scope"*, never delete it** (`[TRP §7]`). Deleting is rework when the feature returns.

---

## 6. Build notes that will otherwise cost rework

`[TRP §7]`, the ones with a server-side consequence:

- **FM2 has three stands** — `FM2_S1` (8″) → `FM2_S2` (6″) → `FM2_S3` (6″, non-bypassable),
  **edgers on S2 and S3 only**. Anything showing four or a separate *8″ Roller* is stale
  (`D-26`). `TC-115` asserts three rows.
- ⚠ **FL2 broadcasts `null` live gauge/width** and Live must render an explicit empty state —
  ***"the single most likely thing to ship wrong."*** [FW-181](FW-181.md).
- **Build the weld-marker layer though it renders empty** — *"a legitimate state, not a
  defect."*
- **Never stack two dialogs** — close, then open. The spool notification is the exception:
  `FR-133`/`TC-163` require it **non-blocking**.
- ⚠ **`.NET carries no automated tests`** — struck from the DoD 15 Aug 2026 (`[TS §1.2]`). The
  trial verifies the backend by **manual contract walkthrough, staffed inside the window
  rather than assumed**. Checklist: [FW-138 §6.1](FW-138.md),
  **`reviewer: TBD`**.

---

## 7. The acceptance run needs a control surface

`[TRP §8]`'s ten-step run requires the simulated feed **steered while a run is live** — step 3
forces N consecutive out-of-spec readings, step 7 needs a `RUNNING → STOPPED` edge at a chosen
instant (`TC-171`'s **3 s stop against a 5 s dwell**), and
[FW-205](FW-205.md)'s condition 5 needs **dropped readings**.

**Configuration plus a restart cannot do any of it** — a restart destroys the run being
demonstrated, which is what steps 7 and 10 assert about. That was **`G43`**, and
[FW-218](FW-218.md) resolves it with four endpoints over
[FW-203](FW-203.md).

⚠ **`G39` stands regardless: steering an unverified model does not make it verified.** A
reproducible acceptance run driven by a feed we wrote is exactly the *"convincing simulator"*
that gap warns about.

---

## 8. Keeping this file true

- **A plan changes → check §1.1 and §3.** Nothing else restates plan content.
- **A blocker closes → strike it from §4** and update the owning plan.
- **Never restate an hour figure.** Every number here is `[TRP]`'s, quoted. ⚠ **Never mix a
  `[DE §2]` stream cell with a `[SSP §5]` one** — they re-derive on their own retention
  factors and **disagree on Phase-1B RT by up to 19 h.**
- **FE and DB rows name owning documents, not plans** — this folder is Backend-scoped and
  §1.2 explains the one deliberate exclusion.
- **Story status in §2 is stamped, not typed** — `python tools/stamp_trial_status.py` writes each
  glyph from its card's `status:`, and `--check` fails when the grids drift. ⚠ **Never hand-edit a
  glyph**: change the task file and re-stamp, exactly as [`STATUS.md`](../../STATUS.md) works.
- ⚠ **§9 is a dated measurement, not a second status register.** Re-measure it against the repos
  and re-date it; **never hand-edit a story's status there.** Status lives in the task
  front-matter and renders into [`STATUS.md`](../../STATUS.md) — a status typed here would be
  the next contradiction.
- Changes go in [`CHANGELOG.md`](../../CHANGELOG.md) — **do not add a change log here.**

### 8.1 Two findings carried from `[TRP §1.4]`

Both hours-bearing, reported not fixed — see
[Orchestration.md §8.1](Orchestration.md):

1. **`FW-218` appears nowhere in `phase-01b`**, though it has a full card in `[TB §7]` and a
   row in `[TRP §1.4]`.
2. **`[TRP §1.4]`'s 1B Full column sums to 260 against a stated 268.** *(The Trial column
   reconciles exactly to 231.)*

---

## 9. Where the build actually is — measured 29 Aug 2026

Sections 1–8 describe what the trial **plans**. This one records what **exists in the
implementation repos**: `ual-api` branch `feature/UADEV-23146`, `ual-angular`
`projects/flat-wire/`, and `FlatWireDB` on `DEVUAL-UADEV001\TEST1`.

> **Per-story status is the task front-matter's, and [`STATUS.md`](../../STATUS.md) renders it —
> neither is restated here.** What follows is the one thing no generated page in this repo
> tracks: the state of the **code and the database themselves**. Where a measurement and a
> status field disagree, §9.2 says so rather than quietly resolving it.

### 9.1 Backend — the trial's spine is built and committed

`FlatWire.sln` **builds: 0 errors**, 14 warnings, all pre-existing analyzer noise. Three commits:
the four-project skeleton, fifteen controllers, and *"the real-time spine, complete"*.

| Landed | What is in the repo |
|---|---|
| Clean-Architecture skeleton | `FlatWire.{API,Application,Domain,Infrastructure}`, on `[ARC §2.2]`'s `CoilCheckin` template |
| **15 controllers · 22 actions** | `PassScheduleController` and `ShiftSummaryController` are scaffolded **action-less**. §3's *"7, of which 5 serve a screen"* is the **trial-path** count, not the file count |
| Real-time spine | `OpcFeedSimulator` → `ReadingChannel` → `BroadcastLoopService` → `FlatWireHub` / `FlatWireBroadcaster`, plus `ITInhibitService` and `PLCTagService` |
| **`/sim` control surface** | Four endpoints — `steer`, `DELETE run`, `fault`, `GET state`. §7's `G43` answer **exists**, is auth-gated, and 404s wholesale when `SimulateOpcFeed` is false (`[SIM §2.4]`) |
| Stub/real swap | `useMockData` binds **twelve service pairs** once at startup (`FW-140` `P-11`) |

**All five T2 "1B close-out" stories are `done`** — `FW-150`, `FW-151`, `FW-203`, `FW-205`,
`FW-218`. The simulator → channel → drain → broadcast → `RunReading` path runs end to end.

### 9.2 ⚠ Six services are de-stubbed in the working tree and **not committed**

Staged on the same branch, compiling, and **reflected in no status field**. Front-matter still
reads `not-started` for every story below except `FW-168`, which reads `blocked`:

| Service | in `HEAD` | staged | Stories |
|---|---|---|---|
| `CheckInService` | 38 L, 2 throws | **1165 L, 0** | `FW-157` rod · `FW-179` spool |
| `RunService` | 86 L, 6 throws | **841 L, 1** | `FW-164` reads · `FW-170` pause/resume |
| `CheckOutService` | 32 L, 1 throw | **526 L, 0** | `FW-174` Mode P/A/B |
| `SpcService` | 32 L, 1 throw | **479 L, 0** | `FW-168` — ⛔ card reports a **blocking mapping defect**, so compiling is not passing |
| `SpoolService` | 38 L, 2 throws | **364 L, 1** | `FW-179` `GET /spools` |
| `WipRejectionService` | 32 L, 1 throw | **285 L, 0** | `FW-174` |

⚠ **Uncommitted work is not delivered work.** It sits on one machine, has had no review, and
`[TS §1.2]` struck automated tests from the DoD — so the only evidence it behaves is §6's
**manual contract walkthrough, whose `reviewer:` is still `TBD`**.

### 9.3 Still throwing — and six of the seven correctly

A `NotImplementedException` naming its owner is the **designed** state (`FW-140` `P-64`). These
are §5's deferrals working as intended, not gaps:

| Throws | Owner | Trial position |
|---|---|---|
| `LineStatusService` | `FW-154` | ✅ deferred — DB1, §5 |
| `PayoffStagingService` ×4 | `FW-158` | ✅ deferred — DB2A, §5; check-in runs without `RodStaging` |
| `WeldEventService` · `RunService.GetRunWeldEventsAsync` | `FW-166` | ✅ deferred — the weld marker layer renders empty, §3 |
| `DieChangeService` | `FW-167` | ✅ deferred — grey the DB3 button, §5 |
| `RollAdjustService` | `FW-169` | ✅ deferred — FL2/FL3 only, §5 |
| `CoilService` ×2 | `FW-185` | ✅ Phase 9, wholly outside the trial |
| **`SpoolService.CompleteSpoolAsync`** | **`FW-202`** | ⛔ **in the trial, and `blocked` on `Q10`** |

⛔ **`FW-202` is the one throw that is not a descope.** It is §2's *"before Phase 8 starts, not
beside it"* story, it writes the `SpoolProcessing` row DB5 reads, and it is the **only T3 story
carrying `status: blocked`**. §5 keeps Part B as `Must`.

### 9.4 Frontend — nothing built, zero of six screens

⛔ **Updated 31 Aug 2026.** `projects/flat-wire/` **no longer exists.** `FW-N03` was built on
28 Aug 2026 and **reverted on 31 Aug 2026**, taking the library and all eleven host integration
points with it, so `ual-angular` is back to **30 libraries and no flat wire**. The scaffold card
`FW-N03` is `not-started` again.

⚠ **Nothing downstream of the scaffold has started either** — including `FW-130` (the shell and the
1280×1024 canvas, blocked on the scaffold again), **`FW-133`**, which §2 calls *"the
single largest story in the trial and all six screens depend on it… not trimmable"*, and the
three Angular stories §1.2 excludes, `FW-135` / `FW-136` / `FW-137`.

The approved visual baseline is still only the static mockups in `50-frontend/mockups/`.

### 9.5 ⛔ The deployed database is pre-`Q60` and unseeded

`FlatWireDB` **is deployed to the shared instance** beside `united_db` / `proddb` / `commondb` —
which is what `[INT §8.0]`'s single-`SqlTransaction` check-in requires, and which LocalDB would
have broken silently. **34 tables · 57 FKs · 126 indexes · 145 check constraints · 1 procedure.**

Two things stop it serving a trial run as it stands.

**1 — It predates the 23 Aug `Spool` / `SpoolProcessing` swap (`Q60`).**

| | DDL and `ual-api` expect | deployed instance has |
|---|---|---|
| the material in process | **`SpoolProcessing`** | ⛔ absent |
| retired the same day | — | ⛔ `SpoolConfiguration` · `SpoolCarrier` still present |
| **`Spool`** | the article — **no `Alpha` at all** | ⛔ carries `Alpha` |

`SpoolProcessingConfiguration` maps `ToTable("SpoolProcessing")`, so **every spool read and write
fails at runtime against this instance**; and the `Spool.Alpha` half is precisely the rename
CLAUDE.md flags as *silently wrong rather than obviously stale*. The fix is a re-run of
`FlatWire_DDL_RunAll.sql` — every script guards its objects, and `99_Teardown` exists.

**2 — Nothing is seeded.** `PayoffPosition` holds 3 rows; **every other table holds 0.** Three of
those are load-bearing for the trial:

| Empty | Consequence |
|---|---|
| `Stand` | `TC-115` asserts **three** `FM2` rows and there are none. Roll diameter is *data* (`D-26`) and the data is absent |
| `AlloyProperty` | ⚠ **Worse than §4 records.** `Q10` / `OI-45` call `LbPerFtFactor` *"seeded NULL"* — the **whole table is empty**, so `Q22`'s min/max band has no row either and `FW-168`'s server-side verdict has nothing to judge against |
| `PassSchedule` | **MVP-1 reads one and never authors one.** With none seeded, check-in has nothing to acknowledge — and that acknowledgement is what pushes the PLC tags |

`30-database/sql/FlatWire_SampleData_*.sql` exists and **has not been run**.

### 9.6 By phase and stream

All 66 trial stories, on the task front-matter's own `phase:` and `stream:` fields. ✅ **The stream
totals reconcile exactly with §1's coverage table** — BE 21 · RT 13 · FE 20 · DB 12.

| Phase | BE | RT | FE | DB | |
|---|---|---|---|---|---:|
| **1A** Angular foundation | — | ⛔ 1 · ⬜ 2 | ✅ 1 · ⛔ 1 · ⬜ 4 | — | 9 |
| **1B** Backend foundation | ✅ 12 · 🔵 2 · ⛔ 1 | ✅ 4 · 🔵 2 | — | — | **21** |
| **1C** Database foundation | — | — | — | 🔵 1 · ⬜ 4 · ⊘ 1 | 6 |
| **3** Line status board | — | — | ⬜ 2 | 🔵 1 | 3 |
| **4** Rod check-in · PLC config | ⬜ 1 | ⬜ 1 | ⬜ 1 | 🔵 1 | 4 |
| **5** Active run monitoring | ⬜ 1 | — | ⛔ 1 · ⬜ 5 | 🔵 1 | 8 |
| **6** In-run production events | ⛔ 1 · ⬜ 1 | ⬜ 1 | ⬜ 2 | 🔵 1 | 6 |
| **7** WIP rejection · rod checkout | ⬜ 1 | ⬜ 1 | ⬜ 1 | 🔵 1 | 4 |
| **8** FL2 spool check-in | ⬜ 1 | ⬜ 1 | ⬜ 2 | 🔵 1 | 5 |
| | **21** | **13** | **20** | **12** | **66** |

✅ done · 🔵 in-review · 🟡 in-progress · ⛔ blocked · ⬜ not-started · ⊘ cancelled — the same glyphs §2 stamps
and [`STATUS.md`](../../STATUS.md) renders.

> **Everything finished sits in two rows.** `1B` holds **16 of the trial's 17 `done` stories** and
> `1A` holds the seventeenth. ⛔ **Phases 3–8 carry 30 stories and not one is `done`** — their six
> 🔵 are **all `DB`**, tables that exist in the DDL, and their two ⛔ are `FW-168` and `FW-202`.

⚠ **`FW-202` sits in the `5` / `FE` cell** because that is what its card says — while §2 files it
under **T3 as new work** and its plan lives in this Backend folder. That is the `G62` mismatch
`check_docs` reports: one story, three labels.

#### What the code says, phase by phase

Overlaying §9.1–§9.5 on the same rows — because a `not-started` card and an empty repository are
not the same claim, and in three of these rows they disagree:

| Phase | Stream | Code state |
|---|---|---|
| **1A** | FE · RT | ⛔ `projects/flat-wire/` **does not exist** — the `FW-N03` scaffold was built 28 Aug and **reverted 31 Aug 2026**. `FW-133` gates five of the six screens |
| **1B** | BE · RT | ✅ **Committed and building** — skeleton, 15 controllers, `FlatWireHub`, broadcast loop, `PLCTagService`, `OpcFeedSimulator`, `ITInhibitService`, `/sim`. **The trial's only finished layer** |
| **1C** | DB | DDL **written**, schema **deployed** — the **four** remaining `not-started` cards **understate what exists** (`FW-152` was corrected to `in-review` on 30 Aug against the DDL and the tools), and ⛔ §9.5 shows the deployment is pre-`Q60` and unseeded, so they **overstate that it is usable**. ⚠ **§9.5 measures `DEVUAL-UADEV001\TEST1`, which is now retired for `FlatWireDB`** — the instance of record is `DEV00164-001`, where `[DEP §4.2]`'s gate passed on 26 Aug; **re-measure before reading §9.5 as owed work** |
| **4** | BE | `CheckInService` **staged, uncommitted** (§9.2). `FW-082` not begun — `PLCTagService`'s five write operations still have **no callers**, which is correct until Phase 4 (`[PLCC §4]`) |
| **5** | BE | `RunService` **staged** — `GET /run/active`, §1.1's *"trial's landing route"*, and 3 of 4 resume outcomes |
| **6** | BE · RT | `SpcService` **staged**, and ⛔ its card reports a **blocking mapping defect**, so compiling is not passing. **6 of the 8 event handlers are also new and staged** |
| **7** | BE | `WipRejectionService` and `CheckOutService` **staged** — *"the only thing that clears a `Blocked` bay"* |
| **8** | BE | `SpoolService`'s `GET /spools` **staged**; `CompleteSpoolAsync` still throws — ⛔ `FW-202` |

⚠ **Phases 4–8's entire BE column is §9.2** — every one of those five services is uncommitted.
Across `ual-api`, **44 files are staged and none is committed**: 11 new, 33 modified, nothing
untracked.

### 9.7 The short answer

| | Built | Pending |
|---|---|---|
| **BE / RT server** | Phase-1B spine, `/sim`, 15 controllers — committed and building | commit + review of §9.2's six services; `FW-082`, `FW-172`, `FW-177`, `FW-181`, `FW-202`; `FW-145`'s claim values |
| **FE** | — **nothing** | the `FW-N03` scaffold *and* **all six screens** — `FW-133` first and largest |
| **DB** | schema deployed, and to the *right* instance | ⛔ re-deploy at `Q60`, then seed |

⚠ **The critical path is no longer the backend.** §4's blockers all still stand, but what now
gates 30 Sep is §9.4 and §9.5 — a frontend with no library at all, and a database
whose spool tables the API cannot bind to.
