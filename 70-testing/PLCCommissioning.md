# Flat Wire Mill — PLC Commissioning Tests

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `06-TestPlanAndTestCases.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Commissioning tests — safety preconditions, sequence, abort criteria
**Status:** Baselined — **safety-critical; read §8.1 before any test**
**Owner:** QA stream / controls engineer
**Audience:** QA, controls engineer, mill operations
**Shortcode:** `[COM]`
**Part of:** `ProjectPlan/Testing/` — index: [README.md](../DOCUMENTS.md)

---

## 8. PLC commissioning tests

Executed on the physical line with the commissioning engineer. **This is the only place several behaviours can be proven at all** — see §3.4.

> **C1–C11 are reproduced in [`PLCTagSpecification.md`](../20-architecture/PLCTagSpecification.md) §11** so the client can read the commissioning plan alongside the tag map they are being asked to sign. **This document remains authoritative for the pass criteria.** **Applied 4 Aug 2026 — the two documents now agree:** `C5` above records *which controller(s) were written*. Without it the test passed whether the FL3 batch reached one controller or two, which is the open question (**`PLC-Q08`** / gap **G30**).

### 8.1 Safety preconditions

- [ ] The line is under the commissioning engineer's control, not production control.
- [ ] Area clear, guards in place, E-stop verified — the same checks the check-in wizard's step 6 makes.
- [ ] **No production order is loaded.** Test material only.
- [ ] Everyone present knows the application **never sends a stop command** — the operator stops the machine physically.

### 8.2 Who must be present

Commissioning engineer (PLC) · Engineering (tag map owner) · one line operator · **one developer or DBA with `CommonDB` write access** *(`appsettings` write access until `D-44`, 4 Sep 2026 — the paths are `OPCTags` rows now, so the person who can fix a wrong path is whoever can `UPDATE` that table)* · QA to record.

### 8.3 Sequence

| # | Test | Method | Pass |
|---|---|---|---|
| **C1** | **Tag paths resolve** | Read every registered tag path in turn. ⚠ **`GetOPCInfo` must return a non-empty `Tags` list first** — if it does not, the registration is missing (`G60`) and `C1` cannot start | Every path resolves. **Correct any wrong path with an `UPDATE` on that line's `CommonDB.OPCTags` row — no file change and no redeploy** *(`D-44`; this read "correct any wrong path in `appsettings.json`" until 4 Sep 2026)*. Record each corrected `TagKey` → `TagName` so `[DEP §3.2]`'s version-stamped script can be regenerated |
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
| **C13** | ⚠ **Simulator reconciliation — record the observed value for every simulated channel and diff it against the model** | With the line running under a normal production schedule, capture **each channel the simulator drives** — `GaugeReading`, `WidthReading`, `SpeedFPM`, `PayoffWeight`, `FootageCounter`, `ComponentStatus`, `LineStatus` — over a representative period, and diff the observed behaviour against the model: value ranges, update cadence, the `LineStatus` vocabulary actually emitted, how footage and weight track speed, and the settling behaviour after a set-point change. Walk **`[SIM §5.6]`'s assumption table A1–A10 row by row** and mark each **confirmed**, **corrected** or **still unknown** | **Every provisional assumption (A1–A7) carries a verdict, and each correction is written back into `[SIM]`.** A8 and A9 are permanent simplifications and are recorded as such, not tested. ⚠ **This test can pass while finding the model wrong** — the pass condition is that the diff was *taken and recorded*, not that it was empty. **A silent divergence is the failure mode**, which is the whole of **`G39`**: everything passes against the simulator, suites go green, operators train on it, and the gap appears here, in the window `[PLCC §4]` calls *"the worst compression in the schedule."* Note the trial also **steers** the simulator (`FW-218`), which makes it more convincing and no more verified |

> **`C13` closes `G39`'s second half.** That gap's resolution has two parts: `[SIM §5.6]`'s assumption table, delivered with the specification, and *"a scheduled act with an owner rather than an intention"* — which is this row. Without it the table is documentation nobody is required to read. **It is numbered 13, after `C11`, rather than renumbered into sequence**: existing citations to `C1`, `C8` and `C11` must keep resolving, and `[TRP §8]` cites all three.

### 8.4 Abort criteria

Abort and reconvene if: any tag write produces unexpected machine motion · `ITInhibit` fails to block run · the footage counter is wrong by more than the agreed tolerance · or any safety precondition lapses.

---
