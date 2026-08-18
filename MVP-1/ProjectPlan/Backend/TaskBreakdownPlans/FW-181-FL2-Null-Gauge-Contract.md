# FW-181 · FL2 null-gauge contract and the Live/Profile binding

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — ⚠ **`[TRP §7]`: "the single most likely thing to ship wrong"**
**Owner:** Real-time (RT) stream
**Audience:** The developer building `FW-181`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Four hours, and `[TRP §7]` singles it out: ***"This is the
> single most likely thing to ship wrong."***
>
> The failure is specific and it looks like success. FL2 standalone has **no live gauge**, so
> the field is **`null`**. A chart handed a null that draws **a flat line at target** shows an
> operator a perfectly in-spec measurement of nothing. **The mockup animates a simulated
> trace** — because a static prototype has no hub — **and the built screen must not.**
>
> Three more, each easy to get backwards: **`null` is not silence** — speed, footage,
> component and line status keep flowing. **Profile is static** — it must not be re-sampled by
> the live tick. And **the toggle binds to line *mode*, not a hard-coded off** — on FL3 the
> same variant *does* receive live gauge, which is why the toggle exists at all.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-181 · FL2 null-gauge contract and the Live/Profile binding
> **Hours:** 4 h RT · **Priority:** High · **Sprint:** S3 · **Phase:** 8 · **Stream:** RT
>
> **As an** FL2 operator,
> **I want** the Live view to say plainly that there is no live gauge,
> **So that** I never read a drawn line as a real measurement.
>
> **Acceptance Criteria:**
> - [ ] FL2 standalone broadcasts **`null`** for live gauge/width while still emitting `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus` — **this contract is unchanged**
> - [ ] ⚠ **Live renders an explicit empty state when the field is `null`** — *"No live gauge on FL2 · see Profile"* — and **must not draw a flat line at target**, which would read as a real in-spec measurement. *(The mockup animates a simulated trace because a static prototype has no hub; the built screen must not.)*
> - [ ] **Profile is the value of record on FL2 standalone** — the incoming spool's FL1 history on a **footage** x-axis, with weld markers and a whole-length verdict badge. **Static: it must not be re-rendered or re-sampled by the live tick**
> - [ ] **Profile is the honest default** on FL2 standalone
> - [ ] **The toggle's availability binds to line mode, not a hard-coded off** — on FL3 the same variant *does* receive live gauge/width, which is why the toggle exists at all
>
> **Rate-card basis:** hub event binding 4 h (§2)
> **Dependencies:** FW-081, FW-150
> **Blockers:** —

### 1.1 ⚠ This story straddles two streams

It is RT-stream and **AC 2, 3 and 4 are rendering** — Angular's, in `ual-angular`.

| Half | Where |
|---|---|
| **AC 1 · AC 5** — the broadcast contract and the mode-bound toggle availability | **server** — this folder |
| **AC 2 · AC 3 · AC 4** — the empty state, the static Profile, the default | **`ual-angular`**, with `FW-081`/`FW-163` |

**This plan covers the server half and states the client contract precisely enough that the
FE half cannot get it wrong.** The rendering rules are reproduced because they are what the
contract exists to enable — not because this story builds them.

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The broadcast loop that applies the suppression | [`FW-150`](FW-150-Broadcast-Loop.md) |
| The `gaugetrace` REST read Profile uses | [`FW-164`](FW-164-Run-Queries-And-RunQueryService.md) |
| The DB3 chart component | `FW-081`, `FW-163`, FE |
| The simulator that must drive FL2 | [`FW-203`](FW-203-OPC-Feed-Simulator.md) |

---

## 2. The contract — `null`, not absent

`FR-120` and `[SIG §5.3]`:

| Channel | FL2 standalone |
|---|---|
| Live **gauge** | **`null`** |
| Live **width** | **`null`** |
| `SpeedFPM` · `PayoffWeight` · `LineStatus` · `FootageCounter` · `ComponentStatus` | ✅ **still emitted** |

> **`[SIG §5.3]` suppresses only the two batched channels.** The line keeps ticking — which is
> what `[TRP §8]` step 9 depends on when it requires Profile to stay static *"across several
> live ticks"*. **There have to be ticks.**

⚠ **The rule is conditioned on FL2 *in standalone mode*, not on FL2 as a line.** `FR-120` and
`[SIG §5.3]` both say so, and **`G40` records this as one of the assertions that rested on the
earlier fixture error.** An **FL3 hybrid** run drives FM2 and is **not** suppressed — which is
AC 5's whole point.

### 2.1 Why `null` and not omission

An omitted field and a null field look the same to a careless client and are not the same
statement. **`null` says "there is no live gauge here"**; omission says "no reading this
tick", which a chart may reasonably interpolate across. The contract requires the former, and
it is what lets the client render an explicit empty state rather than a gap.

---

## 3. What the client must do with it — stated so it cannot be got wrong

Not this story's code. Stated because this contract is worthless if misread.

| Rule | |
|---|---|
| **Empty state** | *"No live gauge on FL2 · see Profile"* |
| ⚠ **No flat line at target** | It **reads as a real in-spec measurement**. The single most likely defect |
| **Profile is the value of record** | The incoming spool's FL1 history, **footage** x-axis, weld markers, whole-length verdict badge |
| ⚠ **Profile is static** | **Not re-rendered or re-sampled by the live tick** |
| **Profile is the honest default** | On FL2 standalone |
| **Toggle binds to line mode** | Not hard-coded off — FL3 receives live gauge |

> **The mockup animates a simulated trace** because a static prototype has no hub
> (`phase-08 §Real-Time`). **The built screen must not.** `[TRP §7]` names this explicitly, and
> `[TRP §1.4]` warns *"DB5 and DB3-FL2 are already correct — do not 'fix' them back."*

---

## 4. Build order

1. Confirm [`FW-150`](FW-150-Broadcast-Loop.md)'s suppression is **mode-conditioned**, not
   line-conditioned (§2) — that is where the rule lives; this story verifies and binds it.
2. Ensure the two channels carry **`null`**, not omission (§2.1).
3. Confirm the other five still flow on FL2 — the check that catches a wholesale suppression.
4. Expose **line mode** on the active-run DTO
   ([`FW-164`](FW-164-Run-Queries-And-RunQueryService.md)) so the client binds toggle
   availability to it rather than to `lineId` (`P-49`).
5. Confirm Profile's source is the **REST** `gaugetrace` read, not the hub.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-48` precede this story.

### `P-49` — the client binds to **route mode**, and the server must therefore publish it

AC 5 requires toggle availability to bind to **line mode**, not `lineId`. FL2 *standalone* has
no live gauge; **FL2 running as part of an FL3 hybrid does.** A client keying on
`lineId === 'FL2'` is wrong on FL3 and will look right for the whole trial, because the trial
is Standalone throughout.

**So the server must publish the run's route mode where the client can see it** — on the
active-run DTO ([`FW-164`](FW-164-Run-Queries-And-RunQueryService.md)) and on the
`LineStatus` payload — rather than leaving the client to infer it.

⚠ **`RouteMode` is not among `[API §2]`'s fourteen canonical enums** as a client-facing field
on this path. Publishing it is a **contract addition** — non-breaking under `[API §8]` (adding
a response field), but it must be mirrored in the TypeScript union
([`FW-147 §3`](FW-147-FluentValidation-Value-Objects-And-Enums.md)) and named in
[`FW-149`](FW-149-IFlatWireClient.md)'s payload if it rides the hub. **Do not let the client
derive it from `lineId`.**

---

## 6. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and by `[TRP §8]` step 9.

| Check | Expected |
|---|---|
| **FL2 live gauge/width** | **`null`** — not `0`, not omitted, not a value |
| **The other five** | `SpeedFPM`, `PayoffWeight`, `LineStatus`, `FootageCounter`, `ComponentStatus` **still arriving** |
| **FL3 hybrid** | **Not** suppressed — live gauge flows |
| Mode, not line | Suppression keys on **route mode**; an FL2 run inside a hybrid is unsuppressed |
| Route mode published | Present on the active-run DTO *(`P-49`)* |
| Profile source | The **REST** `gaugetrace` read |
| **Step 9** | Profile **static across several live ticks** — which needs FL2 ticking |

**FE-side, in the same walkthrough:** the empty state renders its message, **no flat line at
target is drawn**, Profile is the default on FL2 standalone, and the toggle is available on
FL3.

---

## 7. Handoff

`FW-081` / `FW-163` (FE) render both views. [`FW-203`](FW-203-OPC-Feed-Simulator.md) **must
drive FL2** or both FL2 trial screens are dead.
[`FW-164`](FW-164-Run-Queries-And-RunQueryService.md) serves Profile.

---

## 8. Open items

| Item | Effect here |
|---|---|
| **`P-49`** | Publishing route mode is a contract addition needing the three-layer mirror |
| **`G40`** | Recorded that `FR-120`'s condition is **standalone mode**, not the line — one of the assertions that rested on the earlier fixture error |
| **`G9` / `OI-34`** | No cadence target, so *"across several live ticks"* has no defined interval |
| **Pending renames** | `LineStatus` → `LineStateChanged` (`[PLCC §6.3]`). **Build to `[API]`/`[SIG]`** |
