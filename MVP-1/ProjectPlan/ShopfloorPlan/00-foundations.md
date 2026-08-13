# Foundations — Shared Context for All Phases

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 13, 2026
**Status:** Reference — **binding on every phase**
**Layer:** Cross-cutting (Angular · .NET · SQL Server · OPC)
**Scope:** MVP-1

> **Part of the [Flat Wire Mill — Master Implementation Roadmap](../ShopfloorAndRealTimePlan.md).**
> This file holds the cross-cutting reference material every phase depends on: the reference codebase map (§0.2), the domain cheat-sheet (§0.3), the real-time architecture (§0.4), and the stub-first delivery contract (§0.5). Phase files refer back to these sections by number.
>
> **Do not restate this content in a phase file — cite the section number.** That rule is what keeps §0.2's reference-code prohibitions in one place; a phase that paraphrases them will eventually paraphrase them wrong.

*(Header block added 13 Aug 2026. This file and `back-matter.md` were the only two in `ShopfloorPlan/` without one, though all 17 phase files carry it.)*

---

## 0.2 Reference Codebase Map (build against these — do not invent)

The actual implementation lands in the two sibling repos. Use these real roots:

- **Angular frontend:** `c:\UAL\ual-angular`
- **.NET backend:** `c:\UAL\ual-api`

### Angular — all-new UI; consume only the foundational shared services

`ual-angular` is a library-first workspace (`projects/*`). The Flat Wire UI is a **brand-new, standalone library** built with **all-new screens and all-new controls**. It does **not** reuse, copy, or take structural/UI/CSS templates from any existing feature library — `checkin-precheckin`, `shop-floor`/`shop-floor-common`, `statistical-process-control`, `wip-rejection`, `slitter-*`, `coil-receiving`, `common-grid`/`multi-grid-layout`, `opc`, `label-printing`, `print-traveler`, etc. are **not** references. Every control (grids, gauge trace, banners, action/confirm bars) is built fresh from the approved `MVP-1/Mockups/`.

The **only** reuse is the foundational, app-wide **shared services** below, so the new library plugs into the existing app shell (auth, HTTP, config, logging) instead of re-inventing plumbing. This is infrastructure consumption, not UI reuse.

**`shared` services to consume (do not re-build):** `api-gateway.service.ts` (HTTP client/base), `app-config.service.ts` (config), `login.service.ts` + `login-api.service.ts` (auth), `token-interceptor.service.ts` (JWT), `correlation-id-interceptor.service.ts` + `correlation-id.service.ts`, `error-handler.service.ts` + `global-error-handler-api.service.ts`, `ui-log.service.ts` (logging), `notification.service.ts`, `subscription.service.ts`, `print-export.service.ts`, `util.service.ts`. The Flat Wire real-time client is purpose-built per §0.4 — existing SignalR hub clients (`supervisor-monitor-hub.service.ts`, etc.) are **not** copied.

The shopfloor build chain is a real npm script (`build:shop-floor`). **The new `flat-wire-shopfloor` library joins this chain for build ordering only** — that is a build-sequencing concern and implies **no** UI or code reuse from the other libraries in the chain.

### .NET — existing microservices and framework to reuse

`ual-api` is a Clean-Architecture, per-domain workspace (`API/Domain/<Name>/`). Each domain is a 4-project solution (`.API` / `.Application` / `.Domain` / `.Infrastructure`) plus `<Name>.sln`.

| Existing domain | Why it is a reference for Flat Wire |
|---|---|
| `API/Domain/CoilCheckin` | **Primary reference** for the new `FlatWire` service — copy controller, MediatR command, `Program.cs`, `.csproj`, and NuGet patterns (`CoilCheckin.API/Api.csproj`, `CoilCheckin.Application/Application.csproj`, `CoilCheckin.Domain/Domain.csproj`, `CoilCheckin.Infrastructure/Infrastructure.csproj`) |
| `API/Domain/OPCConnection` | The OPC/PLC tag read/write layer the Flat Wire service integrates with for tag ingest + push. (`OPCManagerHub.cs` is **not** a template — the real-time layer is purpose-built per §0.4) |
| ~~`API/Domain/SlitterInterface`~~ | **Explicitly NOT a reference** (neither UI nor real-time / `CoilDataHub`) — per confirmed decision 5 |
| `API/Domain/WipRejection` | Existing WIP rejection service to extend for flat-wire outlets |
| `API/Domain/Notification`, `Login`, `Common`, `Shared`, `Reports`, `Planning`, `Scheduling`, `CoilReceiving`, `CoilYield`, `CoilCosting` | Cross-cutting + upstream services touched by later phases |
| `API/Framework/UA.Framework.API/UAController.cs` | The base controller all new controllers extend; standard response envelope (`Data` / `Success` / `Errors`) |

> **Confirmed design decisions (July 26, 2026):**
> 1. **Separate Angular library** — the Flat Wire UI is a brand-new, standalone library `flat-wire-shopfloor`, not folded into any existing library.
> 2. **New database** — the Flat Wire tables live in a **new `FlatWireDB`** database (not `united_db`). Only the FW-001 column renames touch the existing shared scheduling schema, which is **not** moved.
> 3. ~~**Rod uses the existing `coils` table** — the designed `Rod` table is **dropped** … `FlatWireDB` drops to **21 tables**.~~ **SUPERSEDED by master-spec `D-04` (29 Jul 2026, the "Hybrid foundation" decision).** `Rod` **is retained** as a `FlatWireDB`-local master mirroring the shared `coils` record, with **enforced** rod-alpha FKs, and the schema is **28 tables in the full design — 25 of them MVP-1**, the other three being the MVP-2 pass-schedule group. Counted from the scripts on 13 Aug 2026: **25 tables / 33 FKs / 41 index statements / 1 procedure / 1 trigger**. *(This line said 27/24 until then, which `[HLD §6.3]` had flagged as the stale side.)* `coils` remains the source of truth for the rod *lifecycle* (receipt, status incl. `INFLAT`, chemistry/heat, lot); `Rod` mirrors it locally so the FKs can be enforced. **Anything still saying "21 tables" or "`Rod` is dropped" is stale** — that was gap `G12`, and this is its resolution.
> 4. **Self-contained, purpose-built real-time layer** — `FlatWireHub` is hosted **only** inside `FlatWire.API`; the shared `Notification` service is not extended. It is a fresh, industry-standard, high-throughput streaming design (see **§0.4**).
> 5. **`SlitterInterface` / `slitter-*` are explicitly NOT references** — neither for UI/structure nor for the real-time/hub pattern. On the **backend**, use `CoilCheckin` (Clean-Architecture) as the template. On the **frontend there is NO Angular structural/UI template** — the Flat Wire UI is all-new screens and controls built from the mockups; no existing feature library (including `checkin-precheckin`) is copied. Only the foundational `shared` services are consumed (see the Angular note in §0.2).
> 6. **UI is built from the approved mockups in `MVP-1/Mockups/` — retired DB2 controls dropped.** All dashboard mockups already share **one semantic design-token system** — `--color-background-*`, `--color-text-*`, `--color-blue/green/red/gray/purple/amber`, `--color-border-*`, `--border-radius-md/lg`, `--font-sans/mono` — defined in `flat-wire-shopfloor.styles.scss/.css` and used by **every** dashboard. *(The `--fw-*` prefix in older source docs is **stale** — no mockup or the stylesheet uses it; see G18.)* The approved set is the current `MVP-1/Mockups/dashboard_*.html`; **Dashboard 2 uses its revised `dashboard_2_rod_checkin.html`** (the `- New.html` wizard, renamed to the plain filename 11 Aug 2026 once both earlier layouts were deleted) — a **guided 6-step tab-wizard** (progressive unlock) with standard inputs + inline validation, `payoff-option` selector cards, pass/fail + OK/NG/NA inspection buttons, an SPC **tolerance-band visualization**, the pass-schedule **confirm-bar gate** (retained), and a **supervisor-override** path for deviations — replacing DB2's retired `- Old.html` (old inline-SVG progress ring / single-grid layout). Each dashboard's UI spec is derived from its file in `MVP-1/Mockups/`. **Dashboard 2A** (`dashboard_2a_rod_precheckin.html`) is the FL1/FL3 **Rod Pre-Check-in Station** (SRS §4.2 `PCI001`–`PCI008`) — payoff bay cards, Mark-as-Welded, Traveler Queue, and a 3-step staging wizard. Note that Dashboard 2's `- New.html` **inlines its own app bar and omits `flat-wire-topbar.js`**; clone Dashboard 12's skeleton, not Dashboard 2's, when starting a new screen.

---

## 0.3 Domain Cheat-Sheet (used throughout)

**Three operating routes** (`FlatWireEndToEndProcess.md`):

| Route | Lines | Flow | Gauge trace | Intermediate spool |
|---|---|---|---|---|
| **FL1 Standalone** | FL1 | Rod → DB1/DB2 → FM1 → TKUP-1 spool | Real-time | Yes (SP alpha) |
| **FL2 Standalone** | FL2 | Spool → FM2 (**8" S1 → 6" S2 → 6" S3**; **edgers at S2 and S3 only**) → TKUP-2 coreless coil | Historical/profile | N/A |
| **FL3 Hybrid** | FL1+FL2 continuous | Rod → both mills, no stop, no intermediate anneal | Real-time | No |

**Equipment corrections (client feedback — authoritative):** FL1 has **no Edger** (Edge Set removed from FL1 check-in / active run / FL1 pass schedule) *(May 21 2026)*. Weld is **Induction only** (Laser removed — not viable). Traveler is **fully digital** (no printing; coil/skid labels are separate and still printed). Shift Summary is **per-machine** (FL1/FL2/FL3 tabs + All Lines).

**FM2 has three stands: `S1` = 8", `S2` = 6", `S3` = 6". Edgers sit at S2 and S3 only, and S3 is the final, non-bypassable stand.** `[CONFIRMED — Aug 4 2026]`

| Stand | Roller | Edger | Bypassable |
|---|---|---|---|
| **S1** | **8"** | No | Yes |
| **S2** | **6"** | Yes | Yes |
| **S3** | **6"** | Yes | **No — final gauge control** |

FL3 drives the same FM2, so it inherits this. FL1's FM1 is a **12"** mill and is unaffected.

> **What changed, and why the old shape is everywhere (Aug 4 2026).** The May 21 2026 note was recorded here as *"FM2 has **three** 6" stands (S1, S2, S3)"*, which was read as **a separate 8" roller upstream of three 6" stands — four components**. That is wrong: the 8" roller **is S1**, and there is no fourth stand. The four-slot reading propagated from this paragraph into ~50 files, the `Stand` seed data, two SQL `CHECK` constraints, the `ComponentName` enum, the PLC tag grammar and eight mockups. Three pieces of evidence pin the correction: the client's **published PLC map has exactly three FM2 stations**, **every seeded pass schedule has exactly three FM2 component rows** with a descending gap chain, and the invented `FM2_6inS3` **never had a tag path or a seed row**. Anything showing four FM2 stands, a separate `8" Roller` component, or a stand named `6" S1` is superseded.

**Component rename (Aug 4 2026).** Diameter has left the identifier — it is now data (`Stand.RollDiameterIn`), so a re-roll is a one-row update instead of a repo-wide rename.

| Old | New | `RollDiameterIn` | Notes |
|---|---|---|---|
| `FM2_8in` | **`FM2_S1`** | 8.000 | `Stand.Id` 2 unchanged; bypassable |
| `FM2_6inS1` | **`FM2_S2`** | 6.000 | `Stand.Id` 3 unchanged; bypassable; edger |
| `FM2_6inS2` | **`FM2_S3`** | 6.000 | `Stand.Id` 4 unchanged; edger; **final, non-bypassable** |
| `FM2_6inS3` | *(withdrawn)* | — | Never existed; `Stand.Id` 5 removed |

PLC tag stations follow the same rule — `FL2.FM2.S1`, `FL2.FM2.S2`, `FL2.FM2.S3` (was `Stand8` / `Stand6S1` / `Stand6S2`). Tag paths live only in [`PLCTagSpecification.md`](../../RequirementDocuments/PLCTagSpecification.md); the as-published → as-specified mapping is in its §2.5, and the rename awaits controls-engineer sign-off as **`PLC-Q04`**.

**This closes `OI-04`** ("is the mandatory stand `FM2_6inS2` or `6" S3`?"). Old `FM2_6inS2` **is** new `FM2_S3` — the DDL/API and the SRS were naming the same physical stand, and only the phantom fourth stand made them look contradictory. It also closes **`OI-36`**: the final stand's tag path is the observed one, now `FL2.FM2.S3`.

**Alpha / ID formats** (`MVP-1/DBChanges/Schema/FlatWireSchema_Mapping.md`): Rod `R#####` (R00041) · Spool `SP-#####` (SP-00021) · Run `RUN-####` · Pass schedule `PS-{alloy}-{line}-{seq}` (PS-1100-FL1-003) · Weld `WLD-###` · Roll override `OVR-####` · Die change `DC-####` · SPC `SPC-####` · WIP rejection `REJ-####` · Rod checkout `CO-####` · Output coil `FW-#####-C##` (FW-00421-C01) · mid-run child alpha `FW-00421-C01-A` · Skid `SK-#####` · Die tooling `D-{size×1000}-{seq}` (D-310-034).

**Status vocabularies:**
- **Material (Rod / Spool / Coil):** `RECEIVED → STAGED → INFLAT → COMPLETE`, plus `HOLD`, `SCRAP` (and `SUSPENDED` at receiving). Spool working states `ACTIVE / IN-PLAN / IN-USE / COMPLETED` (full state machine is **OQ-17**, open).
- **Run (`FlatWireRun.Status`):** `Running / Paused / Complete / Aborted`.
- **Pass schedule (`PassSchedule.Status`):** `Draft / Active / Inactive`.
- **Line-state (Dashboard 1 / PLC display):** `RUNNING / IDLE / SETUP / OFFLINE / FAULT / PAUSED`.

**`FlatWireHub` SignalR events** (`APIContracts.md` + `RequirementDocuments/PLCTagSpecification.md`): `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, **`PayoffStateChanged`** (bay occupancy — rare domain event, sent immediately and unbatched, never inside the 10 Hz telemetry batch), `ComponentStatus`, `LineStatus`, `AlertRaised`, `AlertCleared`, `FootageCounter`; run event markers `WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, `AlertEvent`, `RodCheckoutEvent`. Groups: `FL1Data`, `FL2Data`, `FL3Data`. FL2 standalone broadcasts `null` gauge/width (historical only).

---

## 0.4 Real-Time Architecture — Industry-Standard, Optimized (NOT a copy of existing hubs)

Per the July 26 decision, the Flat Wire live layer is **designed fresh** for high-frequency AGC telemetry — it deliberately does **not** reuse the older `CoilDataHub`/`OPCManagerHub`/`supervisor-monitor-hub` patterns. Design goals: low latency, minimal payload, no operator-screen change-detection storms, graceful degradation under burst load, and horizontal-scale readiness. Every workflow phase's "Real-Time Functionality" section builds on this backbone.

**Transport & protocol**
- **WebSockets-first** (`SkipNegotiation` where topology allows); SSE / long-poll only as last-resort fallback.
- **MessagePack** hub protocol on both ends — server `AddSignalR().AddMessagePackProtocol()`, client `@microsoft/signalr-protocol-msgpack`. Binary + compact + fast (de)serialization for dense numeric telemetry vs JSON.
- **Strongly-typed hub**: `FlatWireHub : Hub<IFlatWireClient>` with a typed client interface — compile-time contract, no magic-string method names.

**Ingest → broadcast pipeline (backpressure-safe)**
- OPC/PLC tags are ingested by a hosted `IHostedService` into a **bounded `System.Threading.Channels.Channel<Reading>`** with a drop-oldest / coalesce policy — decouples PLC poll rate from client fan-out and caps memory under bursts.
- A broadcast loop drains the channel on a **fixed cadence (configurable, default ~100 ms / 10 Hz)** and sends **batched arrays** (`GaugeReading[]`) per line group — collapsing thousands of AGC samples/sec into a steady, bounded message rate instead of one message per reading.
- **Coalesce/delta:** `ComponentStatus`/`LineStatus` sent only on change; hot numeric channels decimated to the cadence.
- **Split by frequency:** hot telemetry (gauge/width/speed/payoff/footage) is batched; rare domain events (LineStatus, AlertRaised/Cleared, weld/die/pause markers) are sent immediately, unbatched.

**Groups, reliability & scale**
- Per-line groups `FL1Data/FL2Data/FL3Data`; clients `JoinLineGroup` on the screens they open, `LeaveLineGroup` on teardown — server fan-out only to interested clients. FL2 standalone suppresses the batched gauge/width channels (historical profile is a REST query); status/marker events still flow.
- Tuned `KeepAliveInterval`/`ClientTimeoutInterval`; **automatic reconnect with exponential backoff** + line-group re-join on reconnect.
- **Scale-out ready:** stateless hub; if `FlatWire.API` runs multi-instance, add a **Redis backplane or Azure SignalR Service** — config only, no code change. Single instance is fine for trial.
- Auth: JWT via `?access_token=`; hub methods `[Authorize]`.

**Client rendering (Angular) — no change-detection storms**
- SignalR callbacks run **outside the Angular zone** (`NgZone.runOutsideAngular`); incoming batches land in a **ring buffer** in `flat-wire-signalr.service`.
- Charts/gauges refresh on a **`requestAnimationFrame` throttle** (coalesced to ~60 fps), re-entering the zone once per frame; Chart.js updated in-place (`update('none')`); `ChangeDetectionStrategy.OnPush` everywhere; trace components keep a fixed window (e.g. last 500 points) to bound DOM/GPU work.

---

## 0.5 Stub-First Delivery Contract

*Rehomed here on 13 Aug 2026 from `CheckinImplementationPlan.md`, which was deleted that day. It was the only statement of the model, and `ProjectPlanPrompt.md` cites it as **the** model.*

**The shopfloor UI is built against dummy data first.** The Angular library and its mock data service come up behind an environment flag; `FlatWire.API` runs in **stub mode** returning schema-valid fixtures with **no database and no PLC**; the screens are built and reviewed against that before either is wired. Contracts are published as stubs so the UI can develop in parallel with the backend — which is why [04-APIContract.md](../04-APIContract.md) exists as an elaboration rather than as a record of something already built.

- **The stub/real swap is DI-level, not a code branch** — `useStub` + environment swap of the service implementation, as in `CoilCheckin` (§0.2). Applies on both ends: `MockSignalRService` is the hub's counterpart.
- **One canonical fixture set, aligned to the DB seed** in [`../../DBChanges/Schema/SQL/`](../../DBChanges/Schema/SQL/) — `R00041`–`R00043`, `SP-00021`, `PS-1100-FL1-003`, `RUN-0042`/`RUN-0043`. Fixtures that disagree with the seed were a live defect (`REVIEW.md` Tier 5 #44); do not invent a second set.
- **Switchover criterion:** a stub endpoint is retired when its real repository returns the same schema-valid shape against `FlatWireDB` and its phase's acceptance tests pass. Phase 1B ships stubs first precisely so 1A is unblocked before 1C's schema lands.
- **Stubs also route around open questions, and that debt is tracked** — the check-in stub assumes a single active pass schedule to get past `OQ-3`/`OQ-14`/`OQ-15`; `back-matter.md` schedules a **de-stub pass** when they close. A stub standing in for an undecided rule is not the same as a stub standing in for unwritten code.
