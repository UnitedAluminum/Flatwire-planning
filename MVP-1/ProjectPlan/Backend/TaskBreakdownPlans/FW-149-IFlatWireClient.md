# FW-149 · `IFlatWireClient` typed event contract

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **the interface is minted by `FW-080`; this story completes it**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-149`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Three things that are decided and look like mistakes.
>
> **The interface lives in `FlatWire.Domain`**, not in the API project with the hub. All of
> `[ARC §1.2]`, `[SVC §3.2]` and `phase-01b` L104 agree, and it is what keeps SignalR out of
> the Application layer.
> **`WeldJoinEvent` is deliberately inconsistent with everything else.** The aggregate, the
> table, the endpoint and the story all say **`WeldEvent`**; the SignalR method keeps
> `WeldJoinEvent`. That is a decision, not drift.
> **And the event count is a trap** — the figure "9" is still in circulation, `[API §10.3]`
> counts ten, and this interface carries **twelve plus six markers**.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-149 · `IFlatWireClient` typed event contract
> **Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> **As a** developer,
> **I want** one typed contract covering every event the backend broadcasts,
> **So that** a command side-effect cannot broadcast an event the client has no type for.
>
> **Acceptance Criteria:**
> - [ ] `IFlatWireClient` in `FlatWire.Domain` carries the **full** set: `GaugeReading(GaugeReading[])`, `WidthReading(WidthReading[])`, `SpeedFPM`, `PayoffWeight`, **`PayoffStateChanged`**, `FootageCounter`, `ComponentStatus`, **`LineStatus`, `AlertRaised`, `AlertCleared`**
> - [ ] SCADA markers included: `WeldJoinEvent`, `DieChangeEvent`, `PauseEvent`, `SPCCheckpoint`, `RodCheckoutEvent`
> - [ ] Matches FW-136's client-side typed set exactly
> - [ ] **Naming:** the aggregate, table, endpoint and story all say **`WeldEvent`**; `WeldJoinEvent` survives only as the SignalR method name and is documented as such
>
> **Rate-card basis:** 2 × hub event group @ 8 h = 16 h (§2)
> **Dependencies:** FW-080
> **Blockers:** —

### 1.1 ⚠ The card's list is short by three

The card names **ten** events and **five** markers. `phase-01b` L104 and `[SIG §5.2]`/`[SIG §5.4]`
carry **twelve** and **six**:

| Missing from the card | Where |
|---|---|
| **`SpoolCompletionPromptDue`** | `[SIG §5.2]` — and it is the **durable** one (§2.1) |
| **`SpoolCompletionPromptResolved`** | `[SIG §5.2]` |
| **`AlertEvent`** | `[SIG §5.4]` — the sixth run-event marker |

**Build twelve and six.** `phase-01b` **exit criterion 4** requires *"all twelve events and
six markers typed on `IFlatWireClient`"*.

### 1.2 The split with `FW-080`

[`FW-080`](FW-080-FlatWireHub.md) `P-22` mints the interface in its first commit, because
`Hub<IFlatWireClient>` does not compile without it and this story lists `FW-080` as its
dependency — read literally, neither could start.

| `FW-080` | **This story** |
|---|---|
| The interface exists, with all eighteen members | The **payload types** for each |
| | The **`FW-136` match** — the client-side typed set |
| | The shape review and the `[API §8]` breaking-change discipline |

---

## 2. The eighteen members

**Twelve events** (`[SIG §5.2]`):

`GaugeReading(GaugeReading[])` · `WidthReading(WidthReading[])` · `SpeedFPM` ·
`PayoffWeight` · `FootageCounter` · `ComponentStatus` · `LineStatus` · `AlertRaised` ·
`AlertCleared` · `PayoffStateChanged` · **`SpoolCompletionPromptDue`** ·
**`SpoolCompletionPromptResolved`**

**Six run-event markers** (`[SIG §5.4]`):

`WeldJoinEvent` · `DieChangeEvent` · `PauseEvent` · `SPCCheckpoint` · **`AlertEvent`** ·
`RodCheckoutEvent`

### 2.1 One of the twelve is not fire-and-forget

**`SpoolCompletionPromptDue`** is server-owned persisted state, re-delivered on group
re-join, raised once per `RUNNING → STOPPED` edge, weight latched at the PLC stop timestamp,
persisted to `FlatWireRun`'s five prompt columns (`G38`). **Do not type it as telemetry** —
its payload has to carry what a re-delivery needs, not what a tick needs. Behaviour is
[`FW-080 §3.3`](FW-080-FlatWireHub.md).

### 2.2 The naming rule, stated once

The domain aggregate, the table, the endpoint and the story all say **`WeldEvent`**. The
**SignalR method name** is `WeldJoinEvent`, per `[SIG §5.4]`, and that is the only place the
older name survives. Source documents drift between the two; this is the resolution.

---

## 3. Build order

1. Confirm the interface exists in `FlatWire.Domain` from `FW-080`; **do not move it** to the
   API project to sit beside the hub.
2. Define the payload type per member — `GaugeReading`, `WidthReading` and the rest — as
   plain records in `FlatWire.Domain`.
3. **Array-typed where batched**: `GaugeReading(GaugeReading[])` and
   `WidthReading(WidthReading[])` take arrays because [`FW-150`](FW-150-Broadcast-Loop.md)
   sends batches; the immediate events take single payloads.
4. `SpoolCompletionPromptDue`'s payload per §2.1.
5. **Diff against `FW-136`** member by member (`P-32`).
6. Add **no** member that `[SIG §5.2]`/`[SIG §5.4]` does not list.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-31` precede this story.

### `P-32` — the `FW-136` match is a manual diff with a named owner

AC 3 requires this set to match `FW-136`'s client-side typed set **exactly**, and with
backend tests withdrawn (`[TS §1.2]`) nothing mechanical checks it. It is the same shape of
problem as `TC-020`'s enum mirror, which `phase-01b` resolves as *"a manual three-way diff
… It needs an owner named; it is not a green build."*

**Treat this the same way:** a member-by-member diff of `IFlatWireClient` against `FW-136`,
run at QA0, with a named owner. Add it to [`FW-138`](FW-138-Fifteen-Thin-Controllers.md)'s
QA0 checklist.

The consequence of skipping it is specific and quiet: **a mismatch compiles on both sides**
— the server sends an event the client has no handler for, and nothing fails. That is the
failure `phase-01b` describes for `G38` too: *"the event is typed, everything compiles, the
durability simply never happens."*

### `P-33` — the interface is a published contract from `FW-080`'s first commit

`[API §8]`: **changing a hub payload shape is a breaking change**, not merely a signature
change, *"because the typed client interface is a compile-time contract on both ends."*
Adding an event is non-breaking; changing a payload is not.

So the payload types defined here are **frozen once 1A builds against them**. Get the shapes
right before `FW-136` consumes them, not after.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough.

| Check | Expected |
|---|---|
| Location | `IFlatWireClient` in **`FlatWire.Domain`** |
| Count | **Twelve events + six markers** — not nine, not ten, not the card's fifteen |
| `SpoolCompletionPromptDue` | Payload carries what a **re-delivery** needs (`G38`, `TC-173`) |
| Batched members | `GaugeReading` / `WidthReading` take **arrays** |
| Naming | `WeldJoinEvent` **only** as the SignalR method; everything else says `WeldEvent` |
| **`FW-136` diff** | Member-by-member, signed off by a named owner *(`P-32`)* |
| No magic strings | The hub sends only through this interface |

---

## 6. Handoff

`FW-080` hosts it; `FW-150` sends through it; `FW-208` translates domain events onto it,
which is what keeps SignalR out of `FlatWire.Application` (`[SVC §3.2c]`). `FW-136` is the
client-side twin.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **Pending renames** | `[PLCC §6.3]` records `LineStatus` → **`LineStateChanged`**. **Build to `[API]`/`[SIG]`**; rename across all three in one pass when arbitrated |
| **`[API §8]`** | A payload change is breaking — `P-33` |

| Stale | Correct | Source |
|---|---|---|
| AC 1–2 list **ten** events and **five** markers | **Twelve and six** — the card omits `SpoolCompletionPromptDue`, `SpoolCompletionPromptResolved` and `AlertEvent` | `phase-01b` L104 and **exit criterion 4**; `[SIG §5.2]`, `[SIG §5.4]` |
| *"9 hub events"*, wherever it appears | **Ten** by `[API §10.3]`'s count; **twelve** on this interface. The "9" predates `PayoffStateChanged` | `[API §10.3]` `PP-04` |
