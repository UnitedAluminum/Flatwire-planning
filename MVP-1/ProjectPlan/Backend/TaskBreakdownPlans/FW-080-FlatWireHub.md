# FW-080 · `FlatWireHub` — strongly-typed, MessagePack, line groups

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — `G10` dated to the pre-T2 provisioning check; handoff cross-linked to the new trial plans *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **two blockers, and one event that is not fire-and-forget (§3.3)**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-080`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Four things here are decided, non-obvious, and each one
> produces a working-looking hub that is wrong.
>
> **(1) No existing hub is a template.** `CoilDataHub`, `OPCManagerHub` and
> `supervisor-monitor-hub` were *"reviewed and rejected for this workload"* (`D-05`).
> **(2) Reconnect is a deliverable, not a test** — a client must render cached state behind
> a banner, never a blank screen. **(3) One of the twelve events is durable** and survives a
> reconnect via five database columns that only landed on 15 Aug 2026. **(4)
> `PayoffStateChanged` must never enter the ~100 ms batch** — batching it is the single
> easiest way to make the pre-check-in screen feel broken.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-080 · `FlatWireHub` — strongly-typed, MessagePack, line groups
> **Hours:** **28 h RT** *(was 32)* · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> > **Restated 15 Aug 2026: 32 → 28 h** — the automated hub smoke harness is withdrawn (`[TS §1.2]`); the behaviour moves to the QA0 manual walkthrough.
>
> **As an** operator,
> **I want** a purpose-built hub streaming per-line telemetry,
> **So that** three lines can be watched live without a page refresh.
>
> **Acceptance Criteria:**
> - [ ] `FlatWire.API/Hubs/FlatWireHub.cs` as a **strongly-typed `Hub<IFlatWireClient>`**
> - [ ] **MessagePack** via `AddSignalR().AddMessagePackProtocol()`; WebSockets-first with `SkipNegotiation` where topology allows
> - [ ] `[Authorize]`; `JoinLineGroup` / `LeaveLineGroup` over groups `FL1Data` / `FL2Data` / `FL3Data`
> - [ ] **Hosted only inside `FlatWire.API`** — the shared `Notification` service is not extended, and `CoilDataHub` / `OPCManagerHub` / `supervisor-monitor-hub` are **not** templates (Foundations §0.4, decision 4)
> - [ ] Stateless hub; Redis / Azure SignalR backplane is a **config-only** path if the API goes multi-instance
> - [ ] ⚠ **The automated smoke test is withdrawn** (15 Aug 2026, `[TS §1.2]`). The behaviour it covered — a client joining `FL1Data` receiving simulated batched `GaugeReading[]` at cadence, and re-joining after a reconnect — moves into the **manual contract walkthrough** at QA0 (`[TS §4.2]`, obligation 5). It is still verified; it is no longer verified by a harness
>
> **Rate-card basis:** hub infrastructure priced against `[SIG §4]`'s stated design (32 h), **less the withdrawn smoke harness → 28 h** (15 Aug 2026)
> **Dependencies:** FW-N04, FW-145
> **Blockers:** **G10** (deploy prereqs — IIS WebSockets feature) · **G9 / OI-34** (NFRs undefined; the load test in FW-156 has no pass criteria)

*("Foundations §0.4, decision 4" is `00-foundations.md`, dissolved 13 Aug 2026 — the rule now
lives at `[SIG §4]`/`[SIG §5]` and `[ARC §13.1]` `D-05`.)*

### 1.1 Out of scope

| Concern | Story |
|---|---|
| `IFlatWireClient`'s twelve events + six markers | `FW-149` — but this story cannot compile without it (§5, `P-22`) |
| The OPC ingest feeding the channel | `FW-N05` / `FW-211` |
| The broadcast loop's data source | `FW-151`, `FW-N05` |
| JWT and the `?access_token=` handler | [`FW-145`](FW-145-JWT-And-Role-Policies.md) — a hard dependency |
| SignalR settings binding | [`FW-144`](FW-144-Configuration-Binding.md) |

---

## 2. Precedence

| Question | Authority |
|---|---|
| Transport, protocol, groups, cadence | `[SIG §4]` |
| The event set | `[SIG §5.2]`, `[SIG §5.4]` |
| Where the hub and the interface live | `[SVC §3.1]`, `[ARC §1.2]` |
| That existing hubs are not templates | `[ARC §13.1]` `D-05` |

**`IFlatWireClient` lives in `FlatWire.Domain`; `FlatWireHub` lives in
`FlatWire.API/Hubs/`.** Counter-intuitive, and all three of `[ARC §1.2]`, `[SVC §3.2]` and
`phase-01b` L104 agree on it.

---

## 3. The design

### 3.1 Transport and protocol — `[SIG §4.1]`

- **WebSockets-first** with `SkipNegotiation` where topology allows; SSE and long-poll only
  as a last resort. **IIS WebSockets must be enabled on the target** — `[DEP §4.4]`, gap
  `G10`.
- **MessagePack** on both ends — `AddSignalR().AddMessagePackProtocol()` server-side,
  `@microsoft/signalr-protocol-msgpack` client-side.
- **Strongly-typed** `FlatWireHub : Hub<IFlatWireClient>` — a compile-time contract, **no
  magic-string method names**.

> ⚠ `[SIG]` treats MessagePack as **measure-first** — *"batching and decimation are the real
> win"* — and it is a client dependency the repository does not otherwise use. See `P-21`.

### 3.2 The broadcast loop — `[SIG §4.2]`

A bounded channel decouples the poll rate from fan-out. The loop drains on a **fixed ~100 ms
/ 10 Hz cadence**, sending **batched arrays per line group**, with decimation.

| Traffic | Treatment |
|---|---|
| Gauge, width, speed, payoff weight, footage | **Batched** arrays at ~100 ms |
| `ComponentStatus`, `LineStatus` | **On-change only** |
| Rare domain events (weld, die change, pause, SPC) | **Immediate, unbatched** |
| **`PayoffStateChanged`** | ⚠ **Never enters the ~100 ms batch** |
| FL2 standalone | **Suppresses batched gauge and width** — FL2 broadcasts `null` live gauge/width |

### 3.3 ⚠ One event is durable — and it is the only one

`SpoolCompletionPromptDue` is *"the only event in this contract that is not
fire-and-forget"* (`phase-01b` L105):

- **server-owned persisted state**, re-delivered on group re-join (`TC-173`)
- raised on the **`RUNNING → STOPPED` edge exactly once per stop**
- weight **latched at the PLC stop timestamp**
- persisted to `FlatWireRun`'s **five prompt columns** — `PromptDueAt`, `PromptPlcStopTs`,
  `PromptLatchedWeightLb`, `PromptResolvedAt`, `PromptAnswer` + its `CHECK` — **which landed
  15 Aug 2026 as `G38`**. Before that this was unbuildable. **Persist to them; never hold the
  prompt in memory.**

> ⚠ **`enum LineState` has no `Stopped` member.** Resolve the edge through the configurable
> **`LineStateMap`** (`[PLC §6]`), **never by adding an enum value** — the absence is
> deliberate (`PLC-Q01`).

### 3.4 Groups and reconnect — `[SIG §4.3]`

Groups `FL1Data` / `FL2Data` / `FL3Data`; `JoinLineGroup` / `LeaveLineGroup`; tuned
`KeepAliveInterval` and `ClientTimeoutInterval`; `[Authorize]` on hub methods; JWT via
`?access_token=`.

> **Reconnect is a deliverable, not just a test** (`phase-01b` L103): automatic reconnect
> with exponential backoff **plus line-group re-join**, so a client renders cached
> last-known state behind a *"Reconnecting…"* banner and **never a blank screen**. The
> server half is the re-join and the durable-prompt re-delivery; the client half is 1A's.

**Stateless hub.** A Redis or Azure SignalR backplane is a **config-only** path if
`FlatWire.API` goes multi-instance — no code change. Single instance is fine for the trial.

---

## 4. Build order

1. **Confirm `FW-145`** — hub auth via `?access_token=` is a hard dependency.
2. **Add the MessagePack package** — `P-21`.
3. **`IFlatWireClient` in `FlatWire.Domain`** — `FW-149`'s deliverable; see `P-22`.
4. **`FlatWire.API/Hubs/FlatWireHub.cs`** — `Hub<IFlatWireClient>`, `[Authorize]`,
   `JoinLineGroup` / `LeaveLineGroup`.
5. **`AddSignalR(o => o.EnableDetailedErrors = true).AddMessagePackProtocol()`** and map at
   **`/hubs/flatwire`**. Bind keep-alive, timeout and cadence from `FW-144`.
6. **The bounded channel and the drain loop** at ~100 ms, batching per §3.2.
7. **The durable prompt** per §3.3 — persisted, re-delivered on re-join.
8. **Simulated telemetry** so the hub is demonstrable before OPC ingest exists — this is
   `[API §7.2]` obligation 5 and `phase-01b` acceptance criterion 4.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-20` precede this story.

### `P-21` — add `Microsoft.AspNetCore.SignalR.Protocols.MessagePack`, and measure before committing

**The package is named in no specification.** `[SIG §4.1]` prescribes
`AddSignalR().AddMessagePackProtocol()` without naming what supplies it, and it is **not** in
`API/Directory.Packages.props`. It must be added there — the repo uses central package
management, so a `Version=` in the `.csproj` is wrong (`FW-N04` step 5).

**And treat it as measure-first, per `[SIG §4.1]` and `G10`.** MessagePack is a new
dependency on **both** ends — the Angular side needs `@microsoft/signalr-protocol-msgpack`,
which the repository does not otherwise use — and `[SIG]`'s own judgement is that *"batching
and decimation are the real win."* **Build the batching and decimation first; enable
MessagePack behind the `FW-144` configuration switch and measure.** If it does not pay, the
switch is how it is turned off without a rebuild.

### `P-22` — `IFlatWireClient` lands with this story even though it is `FW-149`'s

**Sequencing, not scope.** `Hub<IFlatWireClient>` does not compile without the interface,
and `FW-149` lists `FW-080` as *its* dependency — so taken literally neither can start.

**Resolution:** define `IFlatWireClient` in `FlatWire.Domain` with the **full** published
set as part of this story's first commit — `[SIG §5.2]`'s twelve events plus `[SIG §5.4]`'s
six run-event markers — and let `FW-149` own the payload types, the shape review and the
match against `FW-136`'s client-side set. The interface is a compile-time contract on both
ends; a partial one built here and widened there would be a breaking change by `[API §8]`.

**Naming, and it is deliberate:** the aggregate, table, endpoint and story all say
**`WeldEvent`**; **`WeldJoinEvent` survives only as the SignalR method name** and is
documented as such (`[SIG §5.4]`).

---

## 6. Verification

**No automated harness** — withdrawn 15 Aug 2026 (`[TS §1.2]`). The behaviour moves to the
QA0 manual contract walkthrough (`[TS §4.2]`, obligation 5). **It is still verified; it is no
longer verified by a harness.**

| Check | Expected |
|---|---|
| Typed hub | `Hub<IFlatWireClient>`; **no magic-string** `SendAsync("…")` anywhere |
| Groups | Joining `FL1Data` receives FL1 batches only |
| Cadence and batching | ~100 ms, arrays per group, decimated |
| **`PayoffStateChanged`** | Delivered **immediately**, never inside a batch |
| FL2 | Batched gauge and width **suppressed**; live values `null` |
| **Durable prompt** | Raise `SpoolCompletionPromptDue`, drop the connection, re-join — **the prompt is re-delivered** (`TC-173`), read from the five `FlatWireRun` columns and not from memory |
| Once per stop | One prompt per `RUNNING → STOPPED` edge, weight latched at the PLC stop timestamp |
| Reconnect | Exponential backoff **and** group re-join; cached state behind a banner, **never blank** |
| Auth | Connection without `?access_token=` is refused |
| Statelessness | No per-connection server state that a backplane would have to replicate |

---

## 7. Handoff

[`FW-149`](FW-149-IFlatWireClient.md) completes the typed contract.
[`FW-150`](FW-150-Broadcast-Loop.md) is the drain loop that feeds it.
[`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) / `FW-211` replace simulated telemetry
with real ingest through `IReadingSource`, with
[`FW-203`](FW-203-OPC-Feed-Simulator.md) standing in for the trial.
[`FW-208`](FW-208-Domain-Events-Post-Commit-Dispatch.md) translates domain events onto this
interface — **and that is what keeps SignalR out of `FlatWire.Application`**
(`[SVC §3.2c]`). ⚠ **Hub connection count is this story's instrument, not `FW-148`'s** —
corrected 27 Aug 2026 (`P-86`). `[MON §7.1]` gives it its own row sourced from
**`FlatWireHub`**, separate from the `/health` row, and `[API §4.19]`'s body has **five
members and no hub member**, so it cannot be published through the health endpoint without
changing that contract. *(This paragraph read "`FW-148` adds hub connection count and
broadcast-cadence deviation to the health surface"; that claim originated in
[`FW-148`](FW-148-Health-Checks.md) and is withdrawn there. Cadence deviation is
[`FW-150`](FW-150-Broadcast-Loop.md)'s.)*

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G10`** *(blocker)* | **IIS WebSockets must be enabled** on the target, and MessagePack is measure-first. ⚠ **`[TRP §6]` dates it: pre-check the environment *before T2* — "it is a provisioning task, not a build one."** The trial leans on the hub for `[TRP §8]` steps 3, 7, 9 and **10 (reconnect and group re-join on staging)**; if `devual-uadev001` lacks the feature **the transport silently falls back to long-poll and the cadence assertions change character** |
| **`G9` / `OI-34`** *(blocker)* | **Real-time NFRs are undefined — the channel cannot be sized and the load test cannot fail.** `FW-156`'s load test has no pass criteria. Build to the stated cadence and record what it achieves; do not invent a target |
| **`G3`** | `RunReading` is the store the broadcast loop depends on |
| **`PLC-Q01`** | `LineState` has no `Stopped` member — resolve the edge via `LineStateMap`, never by adding a value |
| **Pending renames** | `LineState` → `LineOperatingState`; `LineStatus` → `LineStateChanged` (`[PLCC §6.3]`). **Build to `[API]`/`[SIG]`**; rename in one pass across all three |
| **`[API §8]`** | **Changing a hub payload shape is a breaking change**, not merely an endpoint signature change |

| Stale | Correct | Source |
|---|---|---|
| AC 4 cites *"Foundations §0.4, decision 4"* | `00-foundations.md` was dissolved 13 Aug 2026 — the rule is `[SIG §4]`/`[SIG §5]` and `[ARC §13.1]` `D-05` | The `ProjectPlan/` restructure |
| *"9 hub events"* wherever it appears | **Ten** in `[API §10.3]`'s count, and **twelve** on `IFlatWireClient` per `[SIG §5.2]` — the "9" predates `PayoffStateChanged` | `[API §10.3]` `PP-04`, `phase-01b` L104 |
