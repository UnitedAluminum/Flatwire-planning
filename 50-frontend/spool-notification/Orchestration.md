# FL1 Spool Completion Notification — Execution Orchestration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — folder created. First full FL1 comparison of
[`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md)
against the built Angular library and the mockup. **64 stories, 0 delivered.**
**Document Type:** Execution index and dependency graph for the FL1 spool completion notification
**Status:** Active — **the entry point for this folder**
**Owner:** Frontend (Angular `flat-wire`), with backend and real-time dependencies named per story
**Audience:** The delivery lead sequencing this feature, and any developer picking up a story
**Shortcode:** — *(orchestration, derived from the specification and the code; **not citable as a requirement**)*
**Part of:** `50-frontend/spool-notification/` — folder index: this file

---


<!-- DEMOTED BY THE FS-## CONSOLIDATION -->
> ⛔ **SUPERSEDED for status, readiness and blockers — 9 Sep 2026.** This board is
> **hand-maintained** and predates the `FS-##` consolidation. Three of its kind went stale
> once [`STATUS.md`](../../STATUS.md) was generated, and its status tables are now superseded
> a second time.
>
> | For | Read |
> |---|---|
> | Status, % complete, what is blocked | [`FEATURES.md`](../../FEATURES.md) and [`STATUS.md`](../../STATUS.md) — **generated** |
> | What can start now | those boards' **▶ Ready to start now** lines |
> | Open items and gaps, rolled up | the owning parent’s §6 — [`FS-11`](../../10-requirements/features/FS-11-spool-lifecycle-fl2.md) |
> | What this functionality is, and what a change touches | [`FS-11`](../../10-requirements/features/FS-11-spool-lifecycle-fl2.md) |
>
> **What is still worth reading here:** the dependency-wave and sequencing narrative, which
> exists nowhere else. ⛔ **Do not trust a status glyph, a percentage or a blocker list on
> this page.** Where this file and a generated board disagree, the board wins; where it and a
> plan disagree, the plan wins.

> **What this file is.** It says **what can start, in what order, and what is stopping it.** It
> holds no build detail and **no requirement text** — every statement here resolves to
> [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md)
> (cited as `§n` / `R-n` / `S-n` / `A-n` / `B-n` / `D-n`) or to a task file. Where this file and a
> task plan disagree, **the plan wins**; where a plan and the specification disagree, **the
> specification wins**.
>
> ⚠ **This folder deliberately restates no rule.** `CLAUDE.md`: *"a fact is asserted in one
> document and cited everywhere else."* The 43 behaviour rules, the four ladder rungs and the 32
> acceptance criteria live in the specification and are cited, never copied — so a revision there
> cannot leave this folder quietly wrong.
>
> ⛔ **This folder holds no task files, and that is deliberate.** `tools/fwtasks.py`'s
> `load_tasks()` reads a fixed `TASK_DIRS` list with `os.listdir()` — **non-recursive** — so an
> `FW-*.md` placed here would be invisible to [`STATUS.md`](../../STATUS.md) and to
> `check_docs.py`. ⚠ **Restated 9 Sep 2026:** this used to end *"task files stay flat in
> `{30,40,50,60,70}-*/tasks/`"*. **There are no task files anywhere any more** — the `FS-##`
> consolidation retired all 204. A work item is now a `######` card in
> [`TaskBreakdown.md`](../../60-delivery/TaskBreakdown.md) plus an activity row in its owning
> parent under [`10-requirements/features/`](../../10-requirements/features/README.md), which is
> where this file's story links now point.

## The folder

| File | What it is |
|---|---|
| `Orchestration.md` | This file — the entry point, the status board and the sequence |
| [`Backlog.md`](Backlog.md) | The 64 stories, `SCN-##`, with status, gap and required change per story |
| [`GapAnalysis.md`](GapAnalysis.md) | `G-1`…`G-12` as Requirement → Current → Gap → Corrective action, plus the specification-vs-code and mockup-vs-code tables |
| [`ImplementationPlan.md`](ImplementationPlan.md) | The working plan the other three were derived from, kept as the record of the pass. ⚠ **Point-in-time — do not update it**; it duplicates the three above and the three win. Its `NQ-1`…`NQ-14` are now `Q96`–`Q109` |

**Story ids are `SCN-##` and are deliberately not `FW-###`.** `FW-###` is a working id replaced in
one scripted pass from [`TaskIdMap.md`](../../90-registers/TaskIdMap.md); minting new ones here
would corrupt that mapping, and every new task file additionally needs a `######` card in
[`TaskBreakdown.md`](../../60-delivery/TaskBreakdown.md) or `check_docs.py` errors on parity — cards
that feed three client `.xlsx` generators. **`SCN-##` is an analysis id, not a work item id.** Each
story names its owning task below.

---

## 1. Status board

**64 stories. Nothing is delivered.**

| Status | Count | Meaning |
|---|---|---|
| **Completed** | 2 | `SCN-A8`, `SCN-A16` — ⚠ satisfied because the right presentation choice was made and because no Escape handler was written. **Protect these; do not implement them** |
| **Partially Implemented** | 6 | `A2`, `A3`, `A5`, `A9`, `A13`, `B13` |
| **Not Started** | 38 | ➕ `A4` released from hold · `A14` unblocked · **`A18` new** (the `Q20` supervisor mirror) |
| **Blocked** | 11 | `A11`, `A12` · `B17`, `B19` · `D1`, `D2`, `D6` · `E2` · `F1`, `F3` · `G3` — ⚠ **`A11` and `F1` are each down to one remaining blocker**, `A14` has left the list entirely |
| **Needs Clarification** | 4 | `A17` · `B16` · `D3` · `G2` |
| **On Hold** | 0 | ✅ **`A4` released 8 Sep 2026** — `Q18` closed and M4 is a confirmed requirement |
| **Not Applicable** | 3 | `D7`, `F2`, `G4` |

### 1.1 The owning task files

| Part | Specification | Owning story | State |
|---|---|---|---|
| **A** — milestone alerts | `§2`, `§3` — `FR-130`–`FR-137`, **`Should`** | [`FW-N02`](../../10-requirements/features/FS-11-spool-lifecycle-fl2/RT/FW-N02.md) | `blocked`, 4–8 h |
| **B** — stop confirmation | `§4` — `FR-140`–`FR-157`, **`Must`** | [`FW-202`](../../10-requirements/features/FS-08-active-run-monitoring/FE/FW-202.md) | `blocked`, 98 h, critical |
| **C** — short close | `§5` — `FR-130b`–`FR-130d`, **`Must`** | no owner | see §5 |

The card, the pill and the accent map were built by
[`FW-062`](../../10-requirements/features/FS-08-active-run-monitoring/FE/FW-062.md) as part of the DB3 shell.

---

## 2. The two findings that reshape the work

**2.1 Both evaluators are server-side by specification.** `§4.2` design point 6: *"the evaluator
lives in the service, not the browser."* `[SIG §5.5]` says the same of Part A — raised *"server-side
on crossing, not client-side on a threshold check… so every client evaluates the same number rather
than each computing its own."*

⛔ **So `resolveSpoolMilestone()` is not merely mis-tuned — it is in the wrong tier.** It survives as
a presentation map from a server-supplied percentage to an accent, never as the ladder. See
[`GapAnalysis.md`](GapAnalysis.md) `G-2`.

**2.2 Part A's two events are unpublished.** `[SIG §5.5]` records this as *"a scope decision rather
than an omission"* because Part A is `Should`. Part B's events **11** and **12** are published and
built. **Part A's frontend is therefore blocked on backend publication; Part B's is not.**

> ⭐ **The single question that gates the most work is whether Part A is in scope at all.** If the
> `[SIG §5.5]` scope decision stands, all **18** EPIC A stories are blocked and the only shippable
> Part A behaviour is the docked indicator driven by Part B's state. Raised as **`Q96`**.

---

## 3. Sequence

| Phase | Work | Gate |
|---|---|---|
| **0** | Settle `Q96`, `Q42`, `Q99`, `Q104`, `Q105`. ✅ **`Q18` closed 8 Sep 2026.** Land the register and task corrections in §6 | the three tools in §7 |
| **1** | Corrections to what is built — `A3` (M3 threshold **and removal of the `Danger` branch**), `G-5`, `G-6`, `G-9`, `G-12`, **and `A4`** — ✅ released, build it with `A3` in one pass | specs green; card still inert |
| **2** | Part B client contract — `B1`, `B4`, `B5`, `B10`, `B14`, `G1` | listeners registered **before** the group join |
| **3** | The dialog — `B6`, `B7`, `B8`, `B9`, `B11`, `B12`, `B15`, `B18` → EPIC C → EPIC D → `B20`, `E1` | `TC-169`–`TC-184` |
| **4** | Part A, once `Q96` closes — `A12`, `A1`, `A2`, `A5`, `A6`, `A7`, `A9`, `A10`, `A13`, `A15` | card renders |
| **5** | Part C — `F1`, `F3`, once the 10-90 SOP and `OI-25` land | |

Phases **1 and 2 are independent** and can run in parallel. Phase 3 depends on 2. Phase 4 is
independent of 3 but shares the docked indicator, so sequence `A9` after `B13`.

⚠ **Phase 2 is unblocked by `Q18`** — the operator answers on the **latched weight**, not on a
percentage (`§4.4` `S-4`). But `B2`/`B3` depend on the server stop edge, which is dark until
commissioning test `C2`; develop against `DELETE /sim/FL1/run`, which is what `G43` exists to
provide.

---

## 4. Blockers

| Blocker | Blocks | Note |
|---|---|---|
| **`Q96`** *(new)* | all 18 of EPIC A | Is Part A in scope, given `[SIG §5.5]` leaves its events unpublished? |
| ~~**`Q18`**~~ ✅ **closed 8 Sep 2026** | — | The ladder's denominator now has a source: the **order**, reusing *Max Wgt of Spool* and adding a matching minimum. `A4` released, `A11` and `F1` each down to one blocker, `§3.2` no longer `[CLIENT INPUT REQUIRED]` |
| **`Q98`** | `A11` | The one blocker left on target resolution |
| **10-90 SOP** | `F1`, `F3` | ⚠ **Being revised, not merely unlocated** — the version received will not be the one the July call described |
| **`Q33`** | every weight | `§10`: *"the weight basis for every part of this document"* |
| **`FW-202`'s stop edge / test `C2`** | `B2`, `B3` | `TryMapLineState` returns `false` — the primary trigger does not exist yet |
| **`Q42`** | `D1`, `D2` | The carrier format — a hard gate on **every** commit (`S-28`) |
| **`FW-244`** | `B19` | `FlatWireRun.PromptAnsweredBy` does not exist, so `S-12` cannot be satisfied |
| **`OI-56` / `OI-38`** | all of EPIC C | If no scale exists at the take-up, `§4.5` is largely inert |
| **`OI-25`** | `F3`, and `§3.1`'s *footage at spool start* | |
| **10-90 SOP** | `F1`, `F3` | ⚠ **Not in the repository.** `§5.1`: *"It must be obtained from Operations and cited."* |
| **No FL1 completion-workflow screen** | `B9`, `G3` | The specification's own *"Known gap in the deliverables"* (`§10`) — Part B's Yes path has no destination |

---

## 5. Part C has no owning story

`§5` is `[CONFIRMED — July 30, 2026]` and `Must`, and **no task file covers it.** `FW-202` is Part B;
`FW-N02` is Part A. Short close (`F1`) and the mid-run coil break (`F3`) sit in neither, and `F3` is
*"a run and stop model change, not a screen rule"* (`§5.1`), so it is not a frontend story at all.
**This needs an owner before Phase 5 can be planned.**

---

## 6. What this analysis changed elsewhere

Landed with this folder, per the split-per-convention rule that findings belong in the registers and
build detail belongs in task plans:

| Where | What |
|---|---|
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G116`**–**`G119`** — the ladder does not implement `§2.1`; no FL1 spool alpha before commit; `S-13` has no transport; three contradictory commit gates |
| [`Questions.md`](../../90-registers/Questions.md) | **`Q96`**–**`Q109`** — fourteen new questions, grouped in §9 below |
| [`FW-N02`](../../10-requirements/features/FS-11-spool-lifecycle-fl2/RT/FW-N02.md) | ⚠ its build order evaluates the ladder over `payoffWeight$`; `[SIG §5.2]` names **`FootageCounter`** as spool progress's source |
| [`CHANGELOG.md`](../../CHANGELOG.md) | one row |

⛔ **`STATUS.md` is generated.** Never edit it — run `python tools/build_status.py`.

---

## 7. Before you finish

```bash
python tools/build_status.py     # regenerate STATUS.md
python tools/check_docs.py       # task <-> phase <-> register integrity
python tools/linkcheck.py        # no path reference broke
```

---

## 8. Before you write the code

⚠ **This repository plans the work; it does not define how the code is written.** The Angular
standards live in the application repository, `UALUADEV`, and they are **mandatory** —
`CLAUDE.md`, `.claude/instructions/`, `.claude/commands/generate-tests.md` (**14 absolute rules**),
`.claude/code-review-guidelines/`. Run `/generate-tests` before any spec and `/angular-review`
before the PR.

⛔ **`ng lint` passing is not evidence of compliance.** ⚠ Check a CSS class exists before using it —
`big-screen` still does not.

**Two things on this screen that must not be changed while implementing:**

1. ⛔ **The card must not become a modal.** `R-7` is non-blocking, and `[UIC §3.16]` is explicit that
   `CommonPopupService` is not to be used for it — *"a modal would block the line."* Part B's dialog
   **is** a modal by specification (`§4.6`); the prohibition does not extend to it.
2. ⛔ **Do not add an Escape handler to the card.** `§2.3`: *"dismissal must be deliberate — pressing
   Escape does not acknowledge."* It is satisfied today by the absence of a handler.

---

## 9. The fourteen new questions

Full text in [`Questions.md`](../../90-registers/Questions.md). Grouped here by subject so a reader
of this folder can see which part of the feature each one holds up.

| Id | Group | Holds up |
|---|---|---|
| **`Q96`** | Notification behaviour | **All of EPIC A** — is Part A in scope, given its events are unpublished? |
| **`Q97`** | Notification behaviour | `B13`, `B16` — how does the client learn the Armed state? `S-13` and `§4.2`#13 have no transport |
| **`Q98`** | Business rule | `A11` — `§3.2` grades against a **range**; the ladder is a percentage of a single target. Which bound is 100 %? |
| **`Q99`** | UI / UX | `C5`, `D3` — `B-16`, `§4.6` and `S-22` describe three different commit-gate models |
| **`Q100`** | UI / UX | `A17` — should M4 be `aria-live="assertive"` rather than polite? |
| **`Q101`** | UI / UX | `B15` — has the worst-case completion step been shown to fit without scrolling (`D3`)? |
| **`Q102`** | PLC | `F3` — how long after the stop timestamp is a late footage tick still the closing spool's? |
| **`Q103`** | Spool / order handling | `B12`, `D6`, `A13` — the carrier is the pre-commit identity; what does the card's sixth cell show? |
| **`Q104`** | Backend / API | `D1` — `CompleteSpoolRequest` has no carrier field, yet `S-28` makes it a hard gate |
| **`Q105`** | Backend / API | `B19` — `PromptAnsweredBy` does not exist |
| **`Q106`** | Spool / order handling | `A10` — does a mid-spool rod change or weld reset milestone state? |
| **`Q107`** | Error / edge cases | `B16` — what does the screen show during a comms loss with weight already over target? |
| **`Q108`** | Error / edge cases | `B14` — what does the losing terminal show when another operator answers mid-edit? |
| **`Q109`** | Error / edge cases | `B4` — `LatchedWeightLb` is non-nullable, so an unlatched weight broadcasts as `0` |

---

## 10. Related

| Document | Relationship |
|---|---|
| [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md) | **The source of truth.** Parts A, B and C, `R-1`–`R-12`, `S-1`–`S-31`, `A-1`–`A-10`, `B-1`–`B-22` |
| [`ActiveRunMonitor.md`](../../10-requirements/screens/ActiveRunMonitor.md) | The host screen. ⚠ Its `§1.4a` row 4 and the specification's `§1.3` **contradict each other** on FL2/FL3 — `Q19` |
| [`SignalR.md`](../../20-architecture/SignalR.md) | `[SIG §5.2]` events 11/12; `[SIG §5.5]` Part A's unpublished pair; `[SIG §5.6]` the Angular mirror |
| [`APIs.md`](../../40-backend/APIs.md) | `[API §4.6c]` — `POST /spool/complete`, endpoint 16b |
| [`UIConventions.md`](../UIConventions.md) | `[UIC §3.16]` the corner card; `[UIC §3.19]` the accent ladder |
| [`TestCases.md`](../../70-testing/TestCases.md) | `TC-160`–`TC-168` Part A · `TC-169`–`TC-184` Part B |
