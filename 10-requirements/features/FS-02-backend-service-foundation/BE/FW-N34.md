---
id: FW-N34
legacy_id:
title: Widen the EdgeType enum across all three mirror legs, and replace the enforcement it removes
status: not-started
status_confirmed: true
status_note: "**New 10 September 2026** — minted because the client's four-value edge-profile vocabulary (`D-61`) cannot be applied to `FW-147`, which is `done`. ⛔ **This is not a cosmetic enum edit.** `FW-147` owns one third of a three-way mirror (*'define once; mirror in three places — a C# enum, a TypeScript union, and a DB CHECK'*) and its `Bevel` rejection **is** the enum having only two members: *'the absence is the enforcement, so a helpful addition breaks it.'* Widening it therefore **removes a control that story deliberately built**, and something explicit has to take its place. ⛔ **BLOCKED on `OI-05`** — if `Bevel` is simply `Broken Edge` under another name, the vocabulary is complete as-is; if it is a fifth profile, the enum and the modal both change. Answering it first is the difference between doing this once and doing it twice."
owner:
jira:
mvp: 1
phase: "1B"
stream: BE
streams: [BE]
priority: high
hours: 6
sprint: S2
depends_on: [FW-147]
blocked_by: [OI-05]
has_plan: true
started:
completed:
---

# FW-N34 - Widen the EdgeType enum across all three mirror legs, and replace the enforcement it removes

## 1. What to build

**Hours:** 6 h BE · **Priority:** High · **Sprint:** S2 · **Phase:** 1B · **Stream:** BE

> ⚠ **BE-only, deliberately.** The Angular half — creating `edge-type.enum.ts` and deciding the display pipe — is **`FW-132`**'s, which already owns that leg of the mirror and is `not-started`. Splitting it here would duplicate the work and, because `destination_stream()` takes the **first** of `FE → BE → RT → DB → QA → BA`, a `[BE, FE]` story would also file under `FE/` and away from `FW-147`.

**As a** developer applying the client's edge-profile vocabulary,
**I want** `EdgeType` widened in the C# enum, the TypeScript union and both DB `CHECK`s together,
**So that** the three-way mirror stays a mirror and nothing silently accepts a profile the plant cannot make.

> ⚠ **The database half is already done and deployed.** `D-61` and `FW-268` widened both columns to
> `varchar(20)` and re-valued `CK_PSC_EdgeType` (four) and `CK_TIE_EdgeType` (three) on 10 Sep 2026,
> verified on `DEV00164-001`. **This story is the application half**, which was deliberately left
> until `OI-05` is answered.

**Acceptance Criteria:**

- [ ] ⛔ **`OI-05` ANSWERED FIRST — is `Bevel edge` the same profile as `Broken Edge`?** Do not start
      before this lands (`Q110` item 1). The Dashboard 9 / 9A Generate modal offers Round / Flat /
      **Bevel**; the client's four are `Natural Round Edge`, `Full Round Edge`, `Square Edge`,
      `Broken Edge`. **If they are the same thing** the vocabulary is complete and the modal is
      relabelled. **If `Bevel` is a fifth profile**, the enum, both `CHECK`s and the modal all move
      again — and the DB half would have to be redeployed.
- [ ] **The C# enum takes the four values** — `FlatWire.Domain/Enums/CanonicalEnums.cs`. ⚠ **Rewrite
      its `<remarks>` block with it**: the current text explains why `Bevel` is *absent* rather than
      rejected, and that rationale no longer holds once the list is the client's.
- [ ] ⛔ **SOMETHING EXPLICIT MUST REJECT AN INVALID PROFILE, because absence no longer can.**
      `FW-147` L195: *"The absence is the enforcement, so a 'helpful' addition breaks it"*, and L398
      records `Bevel` as *"rejected at model binding by not being enum members"*. With four members
      that binding-time rejection still works for a genuinely unknown string, but the **three-vs-four
      split** does not enforce itself: an endpoint writing a **tool** must reject
      `Natural Round Edge`, which the schedule accepts. Add a **validator**, and test it.
- [ ] ⭐ **The TypeScript leg is CREATED, not edited — it does not exist.** `ComponentState` and
      `MachineName` each have a real `projects/flat-wire/src/lib/enums/*.enum.ts`; `EdgeType` has
      none, only `edgeType?: string | null` on `active-run-response.model.ts` and a bare `'Square'`
      string in `flat-wire-api.service.ts`. ⚠ **That is `FW-132`'s unbuilt work, not a defect** —
      coordinate rather than duplicate.
- [ ] **The three DTO / doc sites move with it** — `Models/Run/RunContracts.cs` (`ComponentStateItem.EdgeType`),
      `Repository/IContextRepository.cs`, and `Infrastructure/Services/PassSchedulePushPayload.cs`,
      whose *"the geometry has no tag anywhere on the surface"* note stays true.
- [ ] **Fixtures and specs** — `StubRunService.cs:231` (`EdgeType.Square.ToString()`),
      `flat-wire-api.service.ts:133`, and `flat-wire-api.service.spec.ts`.
- [ ] **`TC-020` updated** — it asserts the enum mirror, and `FW-264` records that its own matrix
      *"asserts the C# side of `TC-020` only"*.
- [ ] ⛔ **`FW-147` is NOT reopened.** It is `done` and verified; this story carries the change and
      `FW-147` gains a pointer to it. Same for `FW-138` (which holds the `Bevel` rejection as a
      verification item) and `FW-212` (whose `PassScheduleComponentSnapshot.EdgeType` is *"carried
      and unread"*, so it changes type but nothing reads it).
- [ ] ⚠ **Decide the display pipe, or hand it to `FW-132`.** `[API §2.1]` requires *"a single Angular
      display pipe"* mapping `Round`/`Square` to *"Round Edge"/"Flat Edge"*, and **no such pipe
      exists**. The client's values already read as operator labels, so the cleanest outcome is to
      **retire the pipe requirement** — which also removes the `Flat Edge`/`Square` translation
      `G76` was about.
- [ ] ⛔ **No schema change here.** If one is needed, the DB half was wrong — go back to `FW-268` and
      **redeploy with a teardown**, because `IF NOT EXISTS` guards mean an incremental `RunAll`
      silently changes nothing.

## 2. Context you need

**The mirror is the point.** `[API §2]`: *"define once; mirror in three places — a C# enum in
`FlatWire.Domain/Enums`, a TypeScript union, and a DB `CHECK`."* `FW-147` L43 says it *"owns one
third of a three-way mirror"* across **fourteen** enums, and `D-53` cites *"`FW-147`'s enum-mirror
inventory"* as a thing a rename would churn. **That inventory is the checklist for this story.**

**Why the two vocabularies differ in size.** `CK_PSC_EdgeType` takes four because that is the
**product** edge an order specifies. `CK_TIE_EdgeType` takes three because `Natural Round Edge`
means *no edging* — no physical set is ever ground for it, and the client's own roll table carries
no such row (only `-S`, `-R`, `-B` suffixes). A schedule specifying it leaves the `EdgeSet`
component `Bypass` or `Skip`, which `CK_PSC_State` already expresses, so `CK_PSC_EdgeTypeReq` does
not fire. ⛔ **Do not "simplify" the two lists into one.**

## 3. Verification

- The four values round-trip C# → DTO → TypeScript → DB and back.
- An endpoint writing a **tool** rejects `Natural Round Edge`; an endpoint writing a **schedule**
  accepts it. ✅ Both already proven at the database level on `DEV00164-001`.
- `/generate-tests` before any Angular spec, `/angular-review` before the PR — `ng lint` passing is
  **not** evidence of compliance.

## 4. Handoff

- **`FW-132`** builds the TypeScript enums and owns the pipe decision.
- **`FW-269`** / **`FW-270`** consume the three-value tool vocabulary; both had criteria that
  **inverted** on 10 Sep and are already corrected.
- **`OI-05`** is the gate. **`G76`** is closed by `D-61`; **`G128`** owns the order-side vocabulary,
  which is upstream Web epic `E06` and outside this backlog.
