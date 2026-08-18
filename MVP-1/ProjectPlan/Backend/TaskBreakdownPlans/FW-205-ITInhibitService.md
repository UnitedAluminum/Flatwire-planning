# FW-205 · `ITInhibitService` — the run-block interlock

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **this story alone closes `phase-01b` exit criterion 5**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-205`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** `ITInhibit` blocks the machine. It is the one thing in
> Phase 1B whose *correct* implementation is defined largely by what must **not** exist:
>
> **There is no operator clear path, and there must not be one.** `TC-016` attempts a clear
> *via every UI surface* and must find none. The rule is enforced by the **absence** of any
> endpoint, command or hub method — so a developer who "helpfully" adds a reset button has
> broken a P1 test by writing code, not by omitting it.
>
> Two more inversions: the tag is **written, never read**, so it is a `PLCTagService`
> operation and not a subscription; and the config key sits **inside each line's `Tags`
> block, never at the root**, because a root key surfaces the first time an idle line blocks
> a running one.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-205 · `ITInhibitService` — the run-block interlock
> **Hours:** 16 h RT · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** RT
>
> > **New 14 Aug 2026.** `ITInhibit` is specified in full at `[PLC §8]`, carries **seven P1 test cases** (`TC-011`–`TC-017a`) and `FR-008`–`FR-010`/`FR-020`, and had **no phase home and no costed story** — it was bundled into `FW-N11` *"Operator session / `ITInhibit`"*, which is uncosted and cited against Phase 6. **This story is the split.** `FW-N11` keeps its id for the operator-session remainder.
>
> **As a** production system,
> **I want** the machine blocked whenever the prerequisites for recording a run are not met,
> **So that** it is impossible to produce material the system cannot account for.
>
> **Acceptance Criteria:**
> - [ ] **One tag per line** — `FL1.ITInhibit`, `FL2.ITInhibit` — **written, never read**, so it is a `PLCTagService` operation and not a subscription
> - [ ] **Line-scoped**: a blocked line blocks **only itself** — an idle FL1 does not stop a scheduled FL2 (`TC-017a`)
> - [ ] Sets on **conditions 3, 4 and 5** — feet data **unavailable**, feet data **invalid**, and **two or more consecutive recordings missing** — one shared watchdog over the footage tag the OPC ingest delivers
> - [ ] Condition 5 additionally raises the **prominent data-recording alert** via the existing `AlertRaised` event — no new hub event
> - [ ] **While set, no rolling data is recorded without an active coil** — the interlock gates `FW-150`'s broadcast loop before it persists `RunReading`
> - [ ] **Clears automatically only.** `TC-016` attempts an operator clear *via every UI surface* and must find none — **enforced by the absence** of any endpoint, command or hub method
> - [ ] Config key sits **inside each line's `Tags` block, never at the root** — a root key would surface the first time an idle line blocked a running one
> - [ ] Honours `SimulatePLCTagPush`; every set and clear is audit-logged with tag path, value, timestamp and result
>
> **Rate-card basis:** non-trivial business service, mid-band **16 h** (§2, *12–24 h priced individually*)
> **Dependencies:** FW-144 (config), FW-151 (`PLCTagService`), FW-N05 (the footage feed)
> **Blockers:** **`G30`**

### 1.1 ⚠ Two lines or three — build **three**

The card's first criterion names **two** tags. `phase-01b` L112 and **exit criterion 5** both
say **three**: *"Build the config surface for three lines — `FL1.ITInhibit`, `FL2.ITInhibit`
and `FL3.ITInhibit`, the last published `[PROPOSED]` at `[PLC §5.2.3]`."*

**Build the configuration surface for three and leave FL3 behind the same config switch.**
Whether FL3 carries its own tag or asserts FL1's and FL2's together is `PLC-Q08` / `G30` —
the card's own blocker — so the *surface* is built now and the *behaviour* waits.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| Conditions **1–2** — and `TC-011`/`TC-012` with them | `FW-206`, **Phase 4** (`TC-012` blocked on `PLC-Q12`) |
| `PLCTagService` itself, and `SetITInhibit` as an operation | [`FW-151`](FW-151-PLCTagService.md) |
| The footage feed the watchdog runs over | [`FW-N05`](FW-N05-OPC-Ingest-And-Bounded-Channel.md) / [`FW-203`](FW-203-OPC-Feed-Simulator.md) |
| The broadcast loop this gates | [`FW-150`](FW-150-Broadcast-Loop.md) |
| The config binding | [`FW-144`](FW-144-Configuration-Binding.md) |
| The operator-session remainder | `FW-N11`, uncosted |

---

## 2. What the three conditions actually watch

All three are **watchdogs over the footage tag** that OPC ingest delivers — one shared
watchdog, not three separate ones.

| # | Condition | Set when |
|---|---|---|
| 3 | Feet data **unavailable** | the footage tag is not being delivered at all |
| 4 | Feet data **invalid** | delivered but unusable |
| 5 | **Two or more consecutive recordings missing** | a gap in an otherwise-live feed — **additionally raises the data-recording alert** |

Condition 5's alert goes out on the **existing `AlertRaised` event**. **Do not add a hub
event** — the contract is closed at twelve events plus six markers (`[SIG §5.2]`, `[SIG §5.4]`).

### 2.1 The gate on `RunReading`

*"While set, no rolling data is recorded without an active coil."* The interlock therefore
sits **inside `FW-150`'s broadcast loop, before it persists `RunReading`** — not around the
whole loop and not at the API boundary. Telemetry continues to broadcast; **persistence** is
what stops.

---

## 3. Build order

1. **`ITInhibitService`** in `FlatWire.Infrastructure`, with `SetITInhibit(lineId, bool)`
   called through [`FW-151`](FW-151-PLCTagService.md)'s `PLCTagService` — one boolean per
   line, written, never read.
2. **One shared watchdog** over the footage tag, evaluating conditions 3–5 per line.
3. **Line-scoped state** — a dictionary keyed by line, never a single flag. `TC-017a` is the
   test that catches a shared one.
4. **Condition 5's alert** via the existing `AlertRaised`.
5. **The `RunReading` gate** in `FW-150`'s loop (§2.1).
6. **Config surface for three lines**, each key inside its line's `Tags` block.
7. **Audit every set and clear** — tag path, value, timestamp, result — through
   [`FW-143`](FW-143-Serilog-And-Audit-Log.md)'s writer, honouring `SimulatePLCTagPush`.
8. **Add no clear path.** See `P-25`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-24` precede this story.

### `P-25` — the absent clear path is a deliverable, and it needs a guard

The requirement is *"clears automatically only … enforced by the **absence** of any
endpoint, command or hub method."* An absence cannot be unit-tested, and with backend tests
withdrawn (`[TS §1.2]`) nothing mechanical protects it. `TC-016` is a **manual** sweep of
every UI surface.

**So make the absence visible rather than incidental:**

- **No `ITInhibitController`**, no MediatR command, no hub method — and a comment at the
  service saying why, citing `TC-016`, so the next developer reads it before adding one.
- **`SetITInhibit` is `internal` to the service's own call path** where the language allows,
  so a handler cannot reach it.
- Add it to `FW-138`'s **QA0 checklist** (item 7) as a review item, since that is the only
  verification this layer has.

**A reset button is the failure mode this story exists to prevent.** It will look like a
helpful addition to whoever writes it.

### `P-26` — build the surface for three lines, the behaviour for two

Per §1.1. `FL1` and `FL2` behave now; `FL3` is configured and inert until `G30` decides
whether it carries its own tag or asserts the other two together. **Do not collapse the
config to two lines** — exit criterion 5 names three, and re-widening later touches every
environment file.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. These are **QA-owned P1 cases**, unaffected by the
withdrawal, and they are `phase-01b`'s measure of this story:

| Case | Asserts |
|---|---|
| **`TC-013`** | Condition 3 — feet data unavailable |
| **`TC-014`** | Condition 4 — feet data invalid |
| **`TC-015`** | Condition 5 — two or more consecutive recordings missing |
| **`TC-016`** | **No operator clear path exists on any surface** |
| **`TC-017`** | Blocks transactions and rolling-data capture |
| **`TC-017a`** | **Line-scoped** — FL2 keeps running while FL1 is blocked |

⚠ **`TC-011` and `TC-012` are not this story's** — conditions 1–2, `FW-206`, Phase 4.
Running them at QA0 fails against code that was never in scope here.

⚠ **Condition 5 can only be exercised by dropping readings**, which `FW-203` alone cannot do
— it is a publisher with no control surface. **[`FW-218`](FW-218-Sim-Control-Surface.md)'s
`POST /sim/{lineId}/fault` is the only way to trigger it**, and it is the sole fault in that
story's scope for exactly this reason.

Also confirm: the tag is never read back; `SimulatePLCTagPush` logs the write it would have
made; three lines are configured.

---

## 6. Handoff

`FW-206` adds conditions 1–2 in Phase 4. `FW-150` hosts the `RunReading` gate. `FW-151`
provides the write. `FW-218` is what makes condition 5 demonstrable at all.

---

## 7. Open items and stale citations

| Item | Effect here |
|---|---|
| **`G30`** *(blocker)* | Whether FL3 carries its own `FL3.ITInhibit` or asserts FL1's and FL2's together follows from FM2's controller-namespace question. **Build FL1/FL2 now, FL3 behind the config switch** |
| **`PLC-Q12`** | Blocks `FW-206`'s condition 2, **not this story** |
| **`G33` / `PLC-Q05`** | A wrong tag path **fails silently** — the write reports success while the line keeps its previous settings. An interlock that silently does not engage is the worst case in this story |

| Stale | Correct | Source |
|---|---|---|
| AC 1 names **two** tags — `FL1.ITInhibit`, `FL2.ITInhibit` | **Three** — the config surface includes `FL3.ITInhibit`, `[PROPOSED]` at `[PLC §5.2.3]` | `phase-01b` L112 and **exit criterion 5** |
