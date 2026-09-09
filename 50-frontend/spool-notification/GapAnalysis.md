# FL1 Spool Completion Notification — Gap Analysis

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created.
**Document Type:** Requirement-to-code gap analysis
**Status:** Active
**Owner:** Frontend (Angular `flat-wire`)
**Shortcode:** — *(derived; **not citable as a requirement**)*
**Part of:** `50-frontend/spool-notification/` — folder index: [`Orchestration.md`](Orchestration.md)

---

> Each gap reads **Requirement → Current → Gap → Corrective action**. Requirements are cited to
> [`SpoolCompletionNotification.md`](../../10-requirements/screens/SpoolCompletionNotification.md),
> never restated. Code paths are relative to
> `c:\UAL\Second-Branch\ual-angular\projects\flat-wire\src\lib\`.
>
> **Four of these were not recorded anywhere before this pass** — `G-3`, `G-4`, `G-7` and `G-8`.
> They are now [`Gaps.md`](../../90-registers/Gaps.md) **`G116`**–**`G119`**.

---

## G-1 · The feature is unreachable

**Requirement** `A-2` — crossing 75 % raises the notification within one telemetry update.
**Current** `models/active-run.model.ts:100` returns `spoolReading: null` unconditionally; its own
comment says the data *"belongs to the spool completion story… today it never does."*
**Gap** The `@if (spoolReading(); as reading)` at `components/active-run/active-run.component.html:220`
can never be true. Everything downstream is dead code — confirmed by full-repo grep:
`resolveSpoolMilestone`, `SPOOL_MILESTONE_TONES`, `SPOOL_MILESTONE_ACCENTS`,
`SPOOL_PLACEHOLDER_PERCENT` and `hasSpoolOverlay` have **no production importer**.
**Corrective action** Replace the literal with a mapper gated on `profile.hasSpoolOverlay`, fed by
the server progress payload. ✅ **`Q18` has now closed (8 Sep 2026) and this gate is gone** — the
customer minimum and maximum ride on the order, reusing *Max Wgt of Spool* for the maximum and adding
a matching minimum, so the mapper has a target to resolve against and no longer has to return `null`
for want of one. ⚠ **`Q98` still gates `SCN-A11`**; check it before treating target resolution as
fully unblocked.

## G-2 · The ladder is evaluated in the wrong tier

**Requirement** `§4.2`#6 — *"the evaluator lives in the service, not the browser."* `[SIG §5.5]`
says the same of Part A: raised *"server-side on crossing, not client-side on a threshold check…
so every client evaluates the same number rather than each computing its own."*
**Current** `components/active-run/spool-milestone.model.ts` is a client-side threshold check.
**Gap** Architectural, not cosmetic. Two FL1 terminals could disagree, and `R-12`'s
Operations-tunable thresholds cannot be honoured by a compiled constant.
**Corrective action** Demote the function to a presentation map (server percent → accent); move the
ladder to `FW-N02`'s server evaluator.

> ⚠ **And correct the stream while doing it.** [`FW-N02`](../../40-backend/tasks/FW-N02.md) builds the
> evaluator over `payoffWeight$`. `[SIG §5.2]` row 5 names **`FootageCounter`** as spool progress's
> consumer and row 4 confines `PayoffWeight` to payoff bars; `§3.1` derives weight **from footage**.
> Payoff weight is rod *depletion*, not spool *fill* — the two diverge by scrap, threading and
> in-machine wire, which is to say near target, exactly where the ladder matters.

## G-3 · M3 is practically unreachable, and M4 has no margin `G116`

**Requirement** `§2.1` — M3 at **≥ 100 %**; M4 at **> 101 %** *and M3 unacknowledged*, the 1 %
*"exists so the state cannot flicker the instant target is touched."*
**Current** `=== 100 → Success`, `> 100 → Danger`.
**Gap** Strict equality on a continuously-varying percentage means M3 essentially never renders
(99.7 → Warn, 100.3 → Danger); M4 fires with no margin, producing precisely the flicker forbidden;
and M4 ignores whether M3 was acknowledged.

**Corrective action — M3 half (`SCN-A3`, build now)** `>= 100 → Success` with **no upper bound**,
and **delete the `> 100 → Danger` branch**. `Danger` is M4's rung alone, so with `SCN-A4` on hold the
ladder must not emit it at all — leaving it would ship the unmargined flicker `§2.1` forbids, under a
rung nobody has agreed to.

**Corrective action — M4 half (`SCN-A4`, ✅ RELEASED 8 Sep 2026)** `Q18` has closed and **M4 is
confirmed wanted**, unqualified — an unacknowledged climb past target escalates to a distinct
over-target state rather than a percentage above 100. ⚠ **The hold is lifted and the M3 half above
must be re-read with it**: `Danger` *is* now a rung the client has agreed to, so the instruction not
to emit it at all no longer applies once `SCN-A4` is built. Build both halves in one pass or the
ladder is briefly inconsistent. Narrow M3 to
`>= 100 && <= 101`, add `> 101 && !acked(M3) → Danger`, with `SPOOL_SCALE_TICKS.OVER = 101` **as a
threshold only** — not a fourth scale label, since `[UIC §3.16]` records the axis/threshold coupling
as deliberate and the scale is 400 px wide.

> ⚠ **What the hold costs, so it reads as a decision and not an oversight.** `§2.1`'s own rationale
> for proposing M4 is that an unacknowledged M3 keeps climbing and *"a notification silently reading
> '104 % of target' in a *target reached* style understates the situation."* Holding M4 accepts that
> understatement meanwhile. `SpoolMilestone.Danger` and its tone and accent entries stay dead —
> ⛔ **do not delete them; they are M4's.**

## G-4 · FL1 has no spool alpha before commit, and three surfaces show one `G117`

**Requirement** [`BusinessRules.md`](../../10-requirements/BusinessRules.md) — the `SP-#####` alpha
is *"Generated by **FL1 at spool completion**"*. `§4.6` asks the evidence footer for *"spool
identity"*.
**Current** The mockup shows `SP-00031` in the card's TKUP-1 cell, the dialog sub-header and the
evidence footer. The prompt payload's `SpoolAlpha` is **structurally null on FL1** — the broadcast
handler sets it `null`, and the replay path joins it from `SpoolCheckin`, which an FL1 run does not
have. **FL1 checks in rods.**
**Gap** Three surfaces would render an identity that does not yet exist.
**Corrective action** Pre-commit identity is the **carrier** (`Spool.SpoolNo`, `§4.7`); the alpha
first exists in `CompleteSpoolResponse.SpoolAlpha` and belongs on the **result step only**.
`SpoolReading` gains `spoolCarrier` — ⛔ **not** `spoolAlpha`.

## G-5 · Acknowledge and Complete are the same action

**Requirement** `R-3` (acknowledging dismisses) versus `S-13` / `§4.6` (manual completion runs the
transaction).
**Current** `components/active-run/active-run.component.ts`:
```ts
public acknowledgeSpool(): void { this.isSpoolAcknowledged.set(true); }
public completeSpool(): void  { this.isSpoolAcknowledged.set(true); }
```
**Gap** `completeSpool()` makes no server call, does not clear `spoolReading`, closes no spool.
**Corrective action** Separate them; `completeSpool()` opens the completion step.

## G-6 · Milestone state never resets

**Requirement** `R-9` / `A-10` — per spool; a new spool re-arms all milestones from zero.
**Current** `isSpoolAcknowledged` is set once and never cleared — not by `clear()`, not by
`apply()`, not on a line change.
**Gap** `A-10` fails; and because DB3 is one screen for all three lines (`D-55`), navigating away
from FL1 and back returns to a spuriously acknowledged card.
**Corrective action** Key ladder state to spool identity; reset on a new spool **and** in `clear()`.

## G-7 · `S-13`'s availability condition has no transport `G118`

**Requirement** `S-13` / `B-11` — manual completion whenever weight ≥ target **and** the line is not
running, *"including after a No"*, hidden while running. `§4.2`#13 makes it the **comms-loss
fallback**.
**Current** The pill's *Complete spool* button is always visible and inert.
**Gap** *Weight ≥ target* is the server's **Armed** state, and **no event broadcasts it.** Event 11
fires only on the stop edge. After a decline the client can infer it — event 12 told it — but
**before any prompt, precisely the comms-loss case, it cannot.** The one scenario the fallback exists
for is the one it cannot serve.
**Corrective action** Broadcast the Armed state, or return it on `GET /run/active`. Raised as `Q97`.

## G-8 · Three commit gates contradict one another `G119`

**Requirement** `B-16` / `S-20` / `D4` — variance *"never disables the commit control."* `§4.6` —
*"the commit control is unavailable until it [the carrier] is valid."* `S-22` — an incomplete
override *"does not commit"* but flags the missing fields and focuses the first.
**Gap** Three interaction models: never-disabled (variance), disabled (carrier),
enabled-but-rejects-on-click (override).
**Corrective action** The consistent reading is **enabled-but-validates-on-click** throughout, since
that is what `S-22` describes and what `D4`'s rationale demands. Confirm — `Q99`.

## G-9 · The card claims *Live* with no staleness handling

**Requirement** `§2.3` — *"a visible last updated indication."*
**Current** The footer renders `Live · updated {{ updatedAt }}` with a pulsing dot, unconditionally.
**Gap** On feed loss the connection banner appears while the card still asserts *Live*.
`[UIC §3.18]` permits `.live-dot` only where *"it is asserting the reading is current."*
**Corrective action** Derive the footer from connection state.

## G-10 · Milestone copy exists for one rung of four

**Requirement** `§2.1` gives each rung distinct content.
**Current** `src/assets/content-data/flat-wire.json` has `spoolNearingCompletion` and
`approachingTarget` — M1 only.
**Gap** M2, M3 and M4 have no title or lead. The mockup has all four.
**Corrective action** Add three title/lead pairs; source `badge` per rung.

## G-11 · The live secondary data is specified and none of it is built

**Requirement** `§2.3` names five live values — percent, remaining, spool footage, fill rate,
estimated time to target — plus a visible *last updated*.
**Current** The template loops `reading().cells` in `col-4` (a 3-across grid, so 2×3); the six
content-data keys `complete`, `remaining`, `spoolFootage`, `fillRate`, `estToTarget`, `takeUp` are
orphaned. `updatedAt` **is** rendered.
**Gap** Five specified values unbuilt. ⚠ Note the arithmetic: `§2.3` names **five**, the grid holds
**six**, and the sixth key is `takeUp` — the mockup uses that cell for the spool alpha, which per
**G-4** does not exist on FL1 before commit.
**Corrective action** Populate the five specified values; settle the sixth under `Q103`.

## G-12 · The pill's glyph ignores the milestone

**Current** `<i class="fa-solid fa-circle-check text-success">` is hard-coded.
**Gap** An over-target state renders with a success glyph.
**Corrective action** Drive from `reading().accent`; add the *acknowledged* / *target reached* note
that `§4.6`'s Declined row calls for.

---

## Specification vs implementation

| Requirement | Implementation | Verdict |
|---|---|---|
| `§2.1` M3 ≥ 100 % | `=== 100` | **Defect** — unreachable |
| `§2.1` M4 > 101 % and M3 unacked | `> 100`, no ack test | **Defect** — flickers. ⏸ On hold (`SCN-A4`); the branch is **removed**, not corrected, meanwhile |
| `§2.1` M1 ≥ 75 % | `Info` at any value below 90 | **Defect** — no lower bound |
| `§4.2`#6 evaluator server-side | client-side function | **Architectural** |
| `R-9` per-spool state | flag never reset | **Defect** |
| `R-12` thresholds configurable | compiled constant | **Not met** |
| `R-3` vs `S-13` | both handlers identical | **Defect** |
| `§2.3` five live values | `cells` never populated | **Not met** |
| `§2.3` last-updated | `updatedAt` rendered | ✅ **Met** |
| `R-7` non-blocking | inline, no backdrop | ✅ **Met** |
| `§2.3` Escape does not acknowledge | no handler | ✅ **Met** |

## Mockup vs implementation

Mockup: [`dashboard_3_active_run.html`](../mockups/dashboard_3_active_run.html) +
[`spool_notification.js`](../mockups/spool_notification.js).

| # | Mockup | Implementation | Which is right |
|---|---|---|---|
| 1 | Four title/lead pairs | One (M1 only) | **Mockup** — `§2.1` |
| 2 | Six live cells | `cells` empty | **Mockup** for five — `§2.3`; the sixth is `Q103` |
| 3 | Pill button gated `pct>=100 && !RUNNING` | always visible | **Mockup** — `S-13`/`B-11` |
| 4 | Pill note *acknowledged* / *target reached* | absent | **Mockup** — `§4.6` |
| 5 | Tick labels gain `hit` once passed | no styling | Mockup (cosmetic) |
| 6 | Full three-step dialog | none | **Mockup** — `§4` |
| 7 | `targetLb: 2000` | none | **Neither** — withdrawn by `D5` |
| 8 | `SP-00031` shown pre-commit | none | **Neither** — no alpha before commit (`G-4`) |
| 9 | Escape / backdrop dismiss the dialog | n/a | **Neither** — violates `S-10`/`B-9` |
| 10 | `.fwn-demo` jump bar | none | **Implementation** — ⛔ must not ship |
| 11 | Card at `bottom:124px` clearing a bottom command bar | `bottom:50px` (`src/styles/styles.scss`), left nav rail | **Implementation** — composition is not taken from the mockup (`F-15`); verify `R-10` against the traces card |
| 12 | Client-side tick and ladder | none | **Neither** — server-side (`G-2`) |

---

## Testing

**The UAT basis is `§7` — `A-1`…`A-11` and `B-1`…`B-22`, all 33.** ⚠ **`A-11` is new** (the
unacknowledged-100 % supervisor mirror, `Q20`), and **`B-13`…`B-22` are untestable** until a take-up
scale exists — `Q30` confirms none does. Beyond them:

**Ladder boundaries (unit)** 0, 74.9, **75**, 89.9, **90**, 99.9, **100**, 100.5, **101**, 101.1.
✅ **`SCN-A4` is released**, so the full ladder is in scope: the 100–101 band asserts `Success`,
`> 101` with M3 unacknowledged asserts `Danger`, acknowledging M3 also closes M4, and *ack M3 then
exceed 101 % → no M4*. Acknowledging M2 closes M1.

⛔ **Assert against literals, not imported constants** — a spec that imports `SPOOL_SCALE_TICKS`
passes when the constant is wrong. `spool-milestone.model.spec.ts` already does this correctly.

**State (unit)** A new spool re-arms from zero (`A-10`); navigating off FL1 and back resets the
acknowledged set; the mapper returns `null` when the target is null.

**Prompt (integration)** Re-delivery of the same `runId` yields **one** dialog (`B-10`);
event 12 from another terminal closes it (`§4.2`#14) — and see `Q108` for the mid-edit case;
`LatchedWeightLb: 0` is not presented as fact (`Q109`); `TargetLb: null` renders no percentage.

**Verification (integration)** `B-12`…`B-22` in full — specifically that a > 2 % variance **never**
disables commit (`D4`), and that a **422 `SUPERVISOR_AUTH_REQUIRED`** surfaces the override panel
rather than a generic error toast.

**Carrier** Unrecognised → refused with the field marked; already carrying material → refused
**naming the spool it holds** (`S-29`); commit blocked without one (`S-28`); a declined prompt
captures none (`S-30`).

**Layout** `D3` — the worst case (over target, out of tolerance, override open, carrier invalid) must
fit **without scrolling** at 16:9; `R-10` — the card obscures neither the nav rail nor either trace
header.

**End-to-end on FL1**, against the shared instance **`DEV00164-001`** — ⚠ not LocalDB, because
check-in spans `united_db` in one `SqlTransaction` with no MSDTC:

```powershell
dotnet run --project FlatWire.API          # useMockData off
curl -X DELETE http://localhost:5000/sim/FL1/run    # the RUNNING -> STOPPED edge
```

`TC-171` 3 s stop against a 5 s dwell · `TC-172` weight latched at the stop timestamp ·
`TC-173` refresh mid-prompt · `TC-175` the label follows the row · `TC-176` No → 200, nothing
written · `TC-179` manual path with no prompt outstanding · `TC-182` variance beyond 2 % still
commits.
