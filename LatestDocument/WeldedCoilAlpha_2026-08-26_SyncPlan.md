# Welded Coil — Two Alphas, Not One — Propagation Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 26, 2026 — ✅ **`Q89` ANSWERED YES: every part alpha gets its own `proddb..coils` row.** Reading `R2` adopted as change **`[S]`** (§1.3, §1.9). ✅ **`OI-113` and `OI-128` CLOSE.** ⛔ **§1.4's *"strictly additive"* claim is withdrawn and Phase 9's shared write-back REOPENS** — **`FR-512` is deleted** (its primary-rod clause exists only to collapse N→1) and `FR-509`–`FR-518` re-specified; `FR-518`'s *"shall not create a second coil"* collides head-on. ⚠ **Two `R1` arguments were wrong and are recorded as such:** the `coil_gen_history` guard is per-**child** (so N children satisfy it), and `C4` forbids a **set-based** insert, not N single-row ones. **Two cheap resolutions:** the retry contract is **one column** — `SharedWrittenAt`, since `ChildAlpha` already stores the N alphas — not a new table; and the skid guards are driven off **`@skidAssignment`**, not row counts, which also sidesteps `OI-114`. ⚠ **`FR-335` and four `[CONFIRMED]` sections of `OutputCoilCompletion.md` need client re-sign-off.** New: `Q93` → `OI-135` (the **702**-suffix budget now divides by N) · **`OI-132`** — `OI-114` and `D9` both **state something false** about the legacy writers. *(Earlier — ⛔ **`[G]` CANCELLED: alpha generation stays on `CommonDB.dbo.GenerateCoilAlpha`.** `Q57` **stands unchanged** (its supersession withdrawn), `PlanningDB` is **not** a seventh co-located database, and waves **`S0` and `S9` are cancelled** with it — so none of the 14 required-database lists changes. `Q90`, `OI-129`, `OI-131`, `TC-792` and `TC-793` are **withdrawn**; `OI-130` is kept as a finding for IT/DBA but **is no longer flat wire's exposure**. ✅ **Value preservation is restored** — `CoilNo` keeps its exact string. ⚠ **Two costs:** `F10`'s caveat returns, so `GetCoilAlpha` stays uncallable and **FL1's batch loop must be written**; and `[H]` now owns all **51** qualifications alone *(re-measured; the 148 counted header text — §1.8a)*. **The fork comparison is RETAINED as the evidence for staying** — PlanningDB has two wrong-column predicates, no `GRANT`, and disjoint planning coverage. ⚠ **NEW `[H]`: the four `FlatWire_*` procedures move `united_db` → `FlatWireDB`** — **51 references to qualify — 38 `united_db`, 13 `CommonDB`, 13 left LOCAL**, five file renames, `EXECUTE` grants move database; ✅ **fails loudly — none of the 31 distinct names collides with a `FlatWireDB` table.**)* *(Earlier — **gap review: 10 internal gaps fixed and ~17 coverage gaps folded in from a repository sweep. Four claims in this ledger were FALSE and are withdrawn in place:** §1.7b(1)'s *"exactly three `FlatWireRun*` identifiers"* (there are **18 .NET type names and 162 FK column occurrences** — now §1.7b(2a), the largest un-guarded hazard in `[R]`); §5's *"`Frontend/Mockups/` — nothing structural"* (**DB7 and DB7b render the label's `Source` row**); §5's *"`Deployment.md` … [S9-only]"* (**`V4` checks the OLD trigger name and would reject a correct deployment**); and `S6`'s claim that **`TC-617` names the trigger** — it is in `NFRVerification.md`, not `TestCases.md`, and does not name it. **New:** §9 abort path · a wave-status table · `[G]`/`[R]` risk rows `R-f`–`R-k` · register fields for `Q89`–`Q92` · **three leakage guards that stop guarding post-rename** · `verify_schema_counts.py`'s C3/C5 hard-fail and its fifth doc target · `Operations/Rollback.md` and 15 other unlisted files · 25 unnamed `FW-*` plans · the certificate gap.)* *(Earlier — ⛔ **SINGLE-SOURCE RULE: every alpha, at every hop, comes from `PlanningDB.dbo.GenerateCoilAlpha` and nothing else.** The client's `segmentAlpha + AlphaLetter(stopIndex)` scheme is **rejected outright — not stored, and not rendered either**; an earlier revision rejected it only *"as the stored identifier"* and left a rendering escape hatch, which is now closed (§1.2). ✅ **`Q88` closes** — two alphas *per se* — and moves to `FlatWireDecidedQuestions.md`, dropping out of the client questions workbook. ⚠ **`SourceSegmentAlpha`'s headline justification is withdrawn with it** (it existed partly to render the client's form); the column now rests solely on making the parent segment explicit, and drops with `I6` / `ORD022` / `TC-794` if that is not wanted.)* *(Earlier the same day — **re-reviewed; eight defects fixed.** The two that mattered: §0.1 listed the `NoOverlap` trigger and the `CoilTraceability`→`CoilOutput` FK flatly under *“does not change”* — true when this ledger carried one change, **false now that `[R]` renames both objects**; and §2.1's `SourceSegmentAlpha` comment, §S4's index row and the needing-nothing list still named **pre-rename** dependent objects in post-rename contexts. Also: §1.7d's *“all 21 new names”* → 23 and *“272 objects”* → 292; §1.7b's heading miscounted its own items; a `§1.7b(4)` cross-reference pointed at the wrong item after the renumber; and three *“two changes”* phrasings were disambiguated to `[C]`/`[G]`.)* *(Earlier the same day — **the rename is now 23 tables** (`FlatWireRun` → `FlatWire_Run` and `PayoffPosition` → `FlatWire_PayoffPosition` added), **4,382 occurrences across 150 files**, **292 dependent objects** — 109 checks, **50 of the 55 FKs**, 53 indexes, 32 defaults, 23 PKs, 14 unique constraints, 10 unique indexes and the one **trigger**, the object that fails silently if left behind. ✅ **`Q91` closes** — `FlatWire_Run` / `FlatWire_RunDetail` now agree. ⚠ **But `PayoffPosition` breaks the convention this ledger documented an hour earlier** (§1.7a: *“all 7 lookups excluded”* is now 6 of 7), and it brings **two new traps**: `PayoffPosition` is also a **column** on two tables, and `FlatWireRunRepository` is a **C# class**, not a table — both would be corrupted by a blanket replace. Still a **script edit, not a migration**.)* *(Earlier the same day — **reviewed and corrected on reissue.** Six defects fixed, and two mattered: §1.4's *"`CoilNo` keeps the value it has today, in every case"* was **true of the cardinality change and false once the generator moves** (the sweeps differ, so the suffix can), and §5's own file counts were wrong three ways (**41**, not 43; `S9` is **+7**, not +11). Also: `I6`/`TC-794` added for `SourceSegmentAlpha`, which had no invariant and cited the wrong test; `S9`'s 18 grep hits classified — **only 14 want an edit**; `Q90` added to the false-collision warning.)* *(Earlier the same day — **the generator switch was added.** All flat wire alpha minting moves to `PlanningDB.dbo.GenerateCoilAlpha` at **both hops**, which supersedes `Q57`'s mechanism, adds a live pre-flight gate (`S0`), makes the completion procedure an **executable** change, and adds a seventh required database.)* *(Earlier still — first issue, cardinality only.)*
**Status:** 🟡 **`S1` and `S2` APPLIED 26 Aug 2026** — registers and the design of record. Eight waves remain. No DDL run, no requirement text written, no rename swept. ⛔ **`S1a` is BLOCKED** — 21 of the 24 files dirty in the working tree are files it edits, including `FW-141-Repository-Layer.md`, which is simultaneously dirty *and* the file holding the 18 .NET type names and 162 column names §1.7b(2a) says must **not** be swept. See the readiness gate in the plan file.
**Document Type:** Propagation ledger — the same shape as [`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md) and the `ClientCall_*_SyncPlan.md` ledgers in `BaseDocuments/`
**Propagates:** three changes — a client correction to [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.5 / §2.8 Scenario B, the `CommonDB` → `PlanningDB` generator cutover, and the `CoilTraceability` → `FlatWire_CoilTraceability` rename — into `MVP-1/` and [`FlatWire_MasterSpecification.md`](FlatWire_MasterSpecification.md)
**Trigger:** client statement, 26 Aug 2026 — *on the welded coil, they do not want a single alpha; two alphas are maintained* — plus a same-day internal direction to mint through `PlanningDB..GenerateCoilAlpha`

> ⚠ **FOUR live changes travel in this ledger and a fifth is cancelled. Conflating them is the
> likeliest misreading.**
>
> | | Change | Nature |
> |---|---|---|
> | **[C]** | **Cardinality** — one alpha per coil → one per (coil × source rod) | **Strictly additive.** Touches no shared-schema behaviour |
> | ⛔ **[G]** | ~~**Generator** — `CommonDB` → `PlanningDB..GenerateCoilAlpha`~~ | **CANCELLED 26 Aug 2026 (§1.5).** Minting **stays on `CommonDB.dbo.GenerateCoilAlpha`**; `Q57` stands unchanged; `PlanningDB` is not a seventh database. **Waves `S0` and `S9` cancelled with it.** The fork comparison is retained — it is now the *evidence for staying* |
> | **[R]** | **Renames** — **23 tables** take a `FlatWire_` prefix | ⚠ **By far the largest.** **4,382 occurrences across 150 files** and **292 dependent objects**, including **50 of 55 FKs**. Mechanical — almost no judgement — which is exactly why it is the one that gets left half-applied (§1.7) |
> | **[H]** | **Host** — the four `FlatWire_*` procedures move `united_db` → **`FlatWireDB`** | **51 references must be qualified**, five files renamed, grants move databases. ✅ **Fails loudly** — no collision with any `FlatWireDB` table name (§1.8) |
> | **[S]** | **Shared** — **every** part alpha gets its own `proddb..coils` row, not just the lead | ⚠ **The largest in consequence.** `Q89` answered **yes**, 26 Aug 2026. ✅ **`OI-113` and `OI-128` CLOSE.** ⛔ **§1.4's *"strictly additive"* claim dies and Phase 9's shared write-back REOPENS** — `FR-512` is deleted and `FR-509`–`FR-518` re-specified (§1.9) |
>
> `[C]` and `[R]` ship together because both rewrite the same paragraphs of `RodOrderAllocation.md`
> §2.4/§2.5 and §9.1; `[H]` joins them because it edits the five `Database/Scripts/` files those waves
> already touch. **Every wave below marks which changes it serves.** ⚠ **`[R]` is still the one most
> likely to be left half-applied** — 4,382 occurrences, no acceptance test but a grep, four
> false-positive classes, and counts that cannot detect a partial application. ⚠ **`[R]` is the one most likely to be
> left half-applied**, because a rename has no natural acceptance test beyond "nothing references the
> old name" — and with 23 tables that grep has 23 forms, four of which need guarding against
> false positives (§1.7b).

---

## 0. The client statement, and exactly what it changes

> On [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.8 **Scenario B — welded: two rods, one spool**: the
> client does **not** need a single alpha `R00002E` for the coil made of 500 lb `R00002A` + 400 lb
> `R00001C`. **Two alphas are maintained**, one from `R00002A` and one from `R00001C`.

**One sentence of design changes.** A coil's identity in the **shared alpha namespace** goes from
**one per coil** to **one per (coil × source rod)**. Everything else in the chain — `CoilAlpha`,
the footage ranges, LIFO, `ORD016`, `ORD017` — is untouched.

**This is not a new idea in the repository; it is the resolution of an item already open.** Three
artifacts predicted it:

| Where | What it already says |
|---|---|
| **`OI-113`** *(master spec §11, `[INT §8.1]`, `FW-219`'s plan)* | *"The shared genealogy can hold one parent per coil; a welded flat wire coil has many … the two records now disagree by design"* — owner **IT / Quality**, action **“decide whether any shared consumer needs the full chain.”** **The client has now answered that question: yes.** |
| **`FR-512`** | records the **primary** rod only in the shared tree, and defers the multi-rod chain to `FlatWire_CoilTraceability` |
| The client's own workbook | a stop drawing on two segments is named **`R00002AA - R00001CA`** — *two* alphas in one cell. [`FL Alphas Plus - Analysis.md`](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) §2 records that `" - "` joins **alphas** and `" / "` joins **consumption facts**, and that *"a hyphen inside an alpha cell means the cell holds two identities."* |

`RodOrderAllocation.md` §2.5 read that compound string and concluded *"the compound string is a
**rendering**"* on three counts — 19 characters against `coil_no`'s `char(9)`, the stop letter not
being unique, and `FlatWire_CoilOutput.CoilAlpha` being a unique scalar. **Two of those three counts survive
and one does not.** The string is still a rendering, and nothing compound is stored. What was wrong
was the inference that therefore only **one** alpha exists behind it.

### 0.1 The scope of this change, stated before the detail

| | |
|---|---|
| **Changes** | how many shared-namespace alphas a coil has, where they live, how they are minted, and what the label and certificate render |
| **Does not change — behaviour, under any of the three** | `CoilAlpha` (`FW-#####-C##`), `D5`, `OQ-N` (decided), the `FlatWire_CoilTraceability` → `FlatWire_CoilOutput` FK *relationship*, footage ranges and their half-open semantics, the `NoOverlap` trigger's *logic*, `TC-617`'s *assertion*, `ORD016`, `ORD017`, LIFO / `OQ-M` / `Q45` |
| ⚠ **…but `[R]` renames several of those OBJECTS** | The FK, the trigger and the index all keep their behaviour and **lose their names**: `trg_CoilTraceability_NoOverlap` and `FK_CoilTraceability_CoilOutput` are two of the 292 objects in §1.7c, and `TC-617`'s expected-result text names the trigger. **An earlier revision listed these flatly under *"does not change"*, which was true when this ledger carried one change and is not true now** |
| ⛔ **WITHDRAWN — this row asserted the opposite of the current design** | It read: *"**`FlatWire_CoilOutput.CoilNo` keeps the value it has today, in every case.** So `proddb..coils`, `coil_gen_history`, `coil_cost`, `coil_slit_cuts`, `wip_skids`, `wip_skid_coils` and `wip_log_view` are **not touched**, `D-32` is not approached, and Phase 9 does not reopen."* ⚠ **`Q89` reversed all of it except the first sentence.** `CoilNo` **does** keep its value — it is now the **lead** part — but **seven of those eight shared tables are written N times**, and **Phase 9's shared write-back REOPENS** (§1.9). `D-32` is still not approached: no shared *schema* changes, only more rows in existing columns |
| ✅ **Does not change — the one claim that survived** | `FlatWire_CoilOutput.CoilNo` keeps the value it has today, in every case, as the **lead** part alpha. `D5` stands, and it is still filtered-UNIQUE |
| ⛔ **What the CANCELLED generator change would have done** | It would have made `FlatWire_CompleteCoilOnSkid` an executable change, added `PlanningDB` as a **seventh** co-located database, and superseded `Q57`'s mechanism. ⛔ **All withdrawn (§1.5).** ⚠ **`FlatWire_CompleteCoilOnSkid` is still an executable change — but for `[H]` and `[S]`, not `[G]`**: **51** references needed database-qualifying (§1.8a — ✅ **done in `S5a`**; the figure was **55** here and **148** in §1.8a, both wrong), and `[S]`'s scalar→set rewrite is outstanding |
| **Table count** | **unchanged** — **three** columns on an existing table plus **one filtered unique index** (index statements **69 → 70**), no new table and **no new FK** *(a foreign key cannot reference a filtered unique index — §2.1)*. ⚠ *This row said "two columns" until 26 Aug 2026; `SharedWrittenAt` was added by `[S]`'s retry contract* |
| ⛔ **`[N]` — a SIXTH tracked change, 26 Aug 2026: segment-rooted alphas, blank ignore list, universal registration** | **The design of record is now [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.4/§2.8, and this ledger disagrees with it until `[N]` completes.** One rule: **root on the parent, pass `''`, register the result in `proddb..coils`.** FL1 segments root on the **rod** (one trailing letter); FL2 coil parts root on the **source segment** (two — `R00001A` → `R00001AA`), rod only where `SourceSegmentAlpha IS NULL`. ⛔ **This REVERSES §1.2 row (b) and §2.1's `ChildAlpha` comment**, and it changes **every** coil alpha's shape — single-rod coils included (`R00001D` → `R00001AA`). ⚠ **Its precondition is unbuilt — `OI-138`/`G54`.** See `N1`–`N9` |
| ⚠ **`[A]` — a FIFTH tracked change, added 26 Aug 2026: the alpha-mechanism correction** | Not a design change — a **false statement of how `CommonDB.dbo.GenerateCoilAlpha` works**, which had reached shipped DDL and the shipped procedure. **No verdict, trace, register id, schema object or effort figure moves.** See `S10` |

---

## 1. The decision this forces, and the recommendation

**Three questions for the cardinality change (§1.1–§1.3), what it does not touch (§1.4), the
generator cutover and its gate (§1.5–§1.6), then the table rename (§1.7).** Each question is answered with a recommendation and a
*build-meanwhile* default, so the propagation is not blocked on the client.

⚠ **Cross-document section references in §1 and §2 point at [`RodOrderAllocation.md`](RodOrderAllocation.md), not at this ledger** — its
§2.4 is the segment-alpha design, its §2.5 the welded spool, its §2.8 the worked traces. This ledger
has its own §2.4; where the two could be confused the target is named.

### 1.1 Where do the alphas live?

**On `FlatWire_CoilTraceability`, as `ChildAlpha` — mirroring `FlatWire_SpoolTraceability.ChildAlpha` exactly.**

This is not an analogy, it is the same construct one hop later. `FlatWire_SpoolTraceability` is the
associative row of Rod × Spool and `ChildAlpha` names that **segment**; `FlatWire_CoilTraceability` is the
associative row of Rod × Coil and `ChildAlpha` names that **coil part**. `RodOrderAllocation.md`
§2.4's whole argument for adding `FlatWire_SpoolTraceability.ChildAlpha` — *"it names the SEGMENT, not the spool. That is a CARDINALITY
difference and not a naming one"* — transfers word for word.

**Rejected alternative:** a new `CoilPartAlpha` junction table. It would carry no column
`FlatWire_CoilTraceability` does not already own, and `RodOrderAllocation.md` §2.5 /
`FlatWireSchema_QualityOutput.md` already rejected `SpoolCoilMapping` on that exact reasoning. Do not reintroduce it under a new name.

### 1.2 How are they minted? Three candidates, one recommended

| | Scheme | Verdict |
|---|---|---|
| **(a)** | The client's own: `segmentAlpha + AlphaLetter(stopIndex)` → `R00002AA`, `R00001CA` | ⛔ **REJECTED OUTRIGHT — not as the identifier, not as a rendering, not anywhere** *(directed 26 Aug 2026; an earlier revision rejected it only "as the stored identifier" and left the door open to rendering it)*. Four objections; the first three are in [`FL Alphas Plus - Analysis.md`](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) §2 and the fourth is this repository's. **(i) The letter has the wrong semantics**, so the string cannot key a coil: `stopAlphaCounter` starts at 1 **per spool** and increments **per stop**, so it answers *"which stop of this spool"* rather than *"which coil from this alpha"*, and every part in one stop shares it. *(The shipped run's `R00004AB` with no `R00004AA` is the* **evidence** *of that mechanism — the source calls it "correct behaviour, not a defect", so do not cite it as a defect.)* **(ii) Ambiguous by construction** — `R00001A`+`A` and `R00001`+letter 27 both render `R00001AA`, so it cannot be decomposed without external knowledge. **(iii) Collides outright past 26 segments**, which is (ii) becoming a real duplicate. **(iv) It is minted by a local counter, so `PlanningDB.dbo.GenerateCoilAlpha` never sees it** — the sweep cannot exclude a string it is not shown, and nothing then stops a finished coil taking it |
| **(b)** | `CommonDB.dbo.GenerateCoilAlpha(segmentAlpha, '')` | ✅ **ADOPTED 26 Aug 2026 — this is now THE DESIGN, and this row has been wrong twice.** `GenerateCoilAlpha('R00002A','')` returns **`R00002AA`**: a **child** of the segment, generated by the single-source generator and therefore swept. ⛔ *First superseded text* claimed it *"cannot work — returns a sibling of the segment … a seven-character parent cannot have children"*; that was **measured false** (`F13`). ⛔ *Second superseded text* rejected it on **collision** — `R00002AA` is also suffix 27 of the rod-rooted walk. **That collision is real but bounded:** it needs a rod to pass **26 segments**, i.e. 46,800 lb against the 4,000–8,840 lb in play (`OI-97`), and even then nothing collides because **everything is registered and the sweep finds a free string** — only the shape stops being readable. **What tipped it:** the shape *is* the client's own form, so generating it reproduces their sheet while keeping one generator and one namespace (`Q88`, narrowed). Authority: [`RodOrderAllocation.md`](RodOrderAllocation.md) §2.8 |
| **(c)** | ⚠ **SUPERSEDED by (b) on 26 Aug 2026 — retained as the reasoning, not the design.** Its cardinality (one mint per source parent) survives intact; only the **root** and the **ignore list** changed. One `CommonDB.dbo.GenerateCoilAlpha(rodAlpha, ignoreList)` call per source rod → one alpha rooted on `R00002`, one on `R00001` *(illustrated below as `R00002E` / `R00001F`; the letters are **examples, not values** — see the warning at the foot of this section)* | ✅ **Recommended.** The argument below is generator-agnostic — it turns on the six-character root, which both implementations share — and `[G]`'s cancellation (§1.5) leaves it untouched |

**Why (c).** It is the only candidate that is simultaneously unique, swept, `char(9)`-safe, and
**correctly parented in the legacy tree**: a part alpha rooted on `R00002` groups under master
`R00002` and one rooted on `R00001` under `R00001`, through the same `SUBSTRING(coil_no,1,6)` that
`coil_link_master_coil` uses. It reuses the mechanism `RodOrderAllocation.md` §2.4 already established
rather than inventing a second one, and it satisfies the client's
ask literally — *two alphas, one from each source rod.*

✅ **What (c) cost has been REPAID by `[N]` — and this paragraph asserted the opposite.**
*Superseded 26 Aug 2026:* *"It does **not** reproduce the client's displayed strings. Their sheet shows
`R00002AA - R00001CA`; ours shows two rod-rooted alphas — `R00002E - R00001F` in the illustration."*

**Rooted on the segment, ours IS `R00002AA - R00001CA`** — the client's own form, emitted by the
single-source generator rather than built by a local counter. That was the whole argument for adopting
(b): `Q88` rejected *building* the string and never objected to the shape. `RodOrderAllocation.md` §2.4
currently celebrates that *"the unified namespace reproduces the client's own column"* at the FL1 hop
— **that sentence is true of segments and will not be true of coil parts.** Whether the client needs the
literal `AA`/`CA` strings or two alphas *per se* **was `Q88`, and it is now decided: two alphas *per
se***. The client's derivational form is not reproduced — not stored, and **not rendered either**. See
the single-source rule below.

> ### ⛔ Single-source rule — no second alpha mechanism, anywhere
>
> **Every flat wire alpha, at every hop, comes from `PlanningDB.dbo.GenerateCoilAlpha` and from
> nothing else.** No local counter, no derivational suffix, no letter appended to a parent string —
> not in the database, not in a service, not in a label renderer, not in a report.
>
> **Three things follow, and the third is the one that will be forgotten.**
>
> 1. FL1 segment alphas, the coil's lead alpha and the coil-part alphas are **all** generator mints.
> 2. `AlphaLetter`, `stopAlphaCounter` and `alphaIndex` — the workbook's three counters — are
>    **analysis artifacts only.** They explain the client's sheet; nothing implements them.
> 3. **The rendered label is a join of generated alphas, never a construction.** `<lead> - <second>`
>    concatenates two strings the generator returned. It does **not** append a stop letter to a
>    segment alpha, so it will not reproduce `R00002AA - R00001CA` and is not expected to. **A
>    renderer that builds a suffix is reintroducing scheme (a) by the back door.**

**⚠ The letters cannot be predicted, and the trace must not pretend otherwise.** The second part
alpha for Scenario B is `CommonDB.dbo.GenerateCoilAlpha('R00001', <every FlatWireDB-local R00001 alpha>)`. In the
standalone §2.8 trace — segments `A`,`B`,`C` plus Scenario A's coils `D`,`E` — it would be `R00001F`
**if nothing else off that rod had been minted first**, and `R00001H` if spool 2's two coils had
already gone through FL2. In [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md),
where §4 and §7 are two traces of **one** 40,000 lb run, it is a different letter again and must be
recomputed across the whole run. *(An earlier revision added "and the cutover itself can move it" —
withdrawn with `[G]`; the generator does not change.)* §2.8's existing warning — *"the letters are mint-order artifacts and carry no meaning"* —
stops being tidy housekeeping and becomes load-bearing. **State the call; never hard-code the letter.**

### 1.3 ✅ DECIDED — every part alpha gets its own `proddb..coils` row (`R2`)

**Answered 26 Aug 2026. `Q89` is closed and this section is rewritten.** An earlier revision
recommended `R1` — lead alpha only — and the recommendation is superseded, not merely overridden.

| | Reading | Status |
|---|---|---|
| ~~`R1`~~ | Two alphas maintained in `FlatWireDB`; the shared schema keeps **one** `coils` row keyed on the lead part | ⛔ **REJECTED.** Its reasoning is retained below because two of its three arguments were wrong and that is worth not repeating |
| **`R2`** | **Every** part alpha is its own `proddb..coils` row, weights split from `SegmentWeightLb`, `coil_gen_history` gaining one correctly-parented row each | ✅ **ADOPTED — change `[S]`, §1.9** |

**What `R2` buys, and it is more than the client asked for.**

- ✅ **`OI-113` closes outright.** Each part alpha is its own `child_coil_no`, so
  `ins_coil_gen_history`'s per-child guard permits one correctly-parented row each. The shared tree
  stops disagreeing with `CoilTraceability` — which is precisely the decision `OI-113` was raised to
  force. ⚠ **Conditional on each alpha carrying its OWN parent rod** (§1.9).
- ✅ **`OI-128` dissolves.** Under `R1` the non-lead alphas lived only in `FlatWireDB`, unswept by
  `GenerateCoilAlpha`, so a third-party minter could reissue one. Now every alpha is in the shared
  schema and therefore swept.
- ✅ **`D6`'s *"real loss of fidelity"* is repaired.** Cost and yield see per-rod weights. This is what
  **`Q6`** already recommends: *"footage-based split at the weld point, not dominant-rod attribution …
  dominant-rod attribution makes a certificate assert that material came from a rod it did not."*
- ✅ **The weights already exist.** `FlatWire_CoilTraceability.SegmentWeightLb`, whose DDL comment
  attributes it to the client asking *"how many pounds for each alpha"* on 20 Aug 2026. `FR-333`
  already requires the derived weight per rod on screen, and `vw_OrderRodAttribution` computes it.

> ### ⚠ Two of `R1`'s three arguments were wrong — retained so they are not made again
>
> | `R1`'s argument | Verdict |
> |---|---|
> | *"`ins_coil_gen_history`'s guard forbids the multi-parent write"* | ⛔ **Wrong.** The guard is `WHERE child_coil_no = @ChildCoil` — **per child**. N *distinct* children pass N independent tests. It only ever blocked one child with many parents. **`OI-113` is an argument FOR `R2`** |
> | *"`proddb..coils` cannot take a multi-row insert (`C4`)"* | ⚠ **Overstated.** `C4` forbids a **set-based** insert, because `coils_iud_tg` gates on `@ins_count = 1`. An `AFTER` trigger fires **once per statement**, so **N single-row inserts fire it N times correctly.** `D2`'s *"Forced by C4"* is an inference beyond what the trigger requires |
> | *"`FR-515`'s skid arithmetic breaks"* | ✅ **Real — and resolved cheaply** (§1.9a), not by fighting it |

**The two costs, recorded rather than re-litigated.** The **retry contract** needs widening from a
scalar to a set, and **`FR-335` plus four `[CONFIRMED]` sections of `OutputCoilCompletion.md` need
client re-sign-off.** Both are in `[S]`'s waves.

### 1.4 What does *not* change — and why that is the point

**`FlatWire_CoilOutput.CoilNo` keeps its `DERIVATION` in every case, and the cardinality change alone keeps its
value too.** Under LIFO the coil's lead part is the first material off, which is `MIN(FootageFrom)`
over its traceability rows, which is *already* how `FR-512` and `@primaryRodAlpha` pick the primary
rod. So:

- **The rule that picks it does not move.** `CoilNo` is the lead part's alpha, before and after.
- Every unwelded coil has exactly one part alpha, equal to its `CoilNo`. **Nothing about the
  single-parent case moves structurally** — and single-parent is fourteen of the twenty-three spools.

⛔ **The *"strictly additive"* claim is WITHDRAWN by `[S]`.** It read: *"the cardinality change is
strictly additive … that is what keeps all eight shared writes, `D-32`, `FR-509`–`FR-518` and Phase 9's
build out of scope."* **With `Q89` answered yes (§1.3) none of that holds** — every one of the eight
shared writes is in scope, `FR-509`–`FR-518` are re-specified, **`FR-512` is deleted**, and **Phase 9's
shared write-back reopens.** §8 predicted exactly this: *"if the answer is yes, this ledger is
superseded."*

✅ **What survives is narrower and still true:** `CoilOutput.CoilNo` keeps its derivation and its value
— the lead part — and `CoilAlpha`, `D5`, half-open footage ranges, `ORD016`, `ORD017` and LIFO are all
untouched. **`D-32` also still holds**: `[S]` writes only columns that already exist.

> ### ✅ Value preservation is RESTORED by cancelling `[G]`
>
> An earlier revision warned that *"`[C]` and `[G]` together are NOT value-preserving"* — because
> PlanningDB's sweep is not CommonDB's, so where they disagreed on a root they would return a different
> next-free suffix, moving `CoilNo`'s **string** even though its derivation held. **With `[G]` cancelled
> (§1.5) that warning is withdrawn: the generator does not change, so `CoilNo` keeps its exact value.**
>
> ⚠ **One rule from that warning is kept anyway, on its own merits.** **No test, fixture or worked
> example should assert a specific alpha suffix** — not because a cutover might move it, but because
> **letters are mint-order artifacts and the alpha is opaque** (§2.1). `TC-787` asserts a
> *relationship* — `CoilNo` equals the lead row's `ChildAlpha` — which is the right shape regardless.

### 1.5 ⛔ `[G]` — the PlanningDB cutover is CANCELLED. Alpha generation stays on `CommonDB`

**Directed internally, 26 Aug 2026, reversing the same-day instruction that moved it.** All flat wire
alpha minting stays on **`CommonDB.dbo.GenerateCoilAlpha`** — FL1 segment alphas, the coil's lead
alpha, and the new coil-part alphas.

> ### ✅ `Q57` stands unchanged — there is no supersession
>
> `Q57` decided *"one namespace — both are minted through `CommonDB.dbo.GenerateCoilAlpha`."* An
> earlier revision of this ledger superseded its **mechanism** while keeping its conclusion.
> **That supersession is withdrawn. `Q57` is correct as written and needs no annotation** — the only
> thing to record is that a cutover was considered and rejected, which belongs in this ledger, not in
> the decided register.

**The comparison work is retained, because it is now the evidence for staying rather than a plan for
moving.** Read from `ual-database`: exactly **two** real implementations exist; every other object
named `GenerateCoilAlpha` is a synonym or a one-line pass-through, and **all of them point at
CommonDB**. Nothing forwards to PlanningDB's fork — it is reached only by unqualified calls from
*inside* PlanningDB. Flat wire would have been its **first external caller**.

**Five differences, and every one of them now reads as a reason not to move:**

| | PlanningDB's fork | Verdict for flat wire |
|---|---|---|
| **D-c** | ⚠ **Two wrong-column predicates** — its `coil_mill_processing` and `coil_slitter_processing` *outgoing* branches read `WHERE incoming_coil_no` where CommonDB reads `WHERE coil_no` | **A measurably weaker uniqueness sweep on two of fourteen branches.** Staying on CommonDB avoids adopting a known defect |
| **D-b** | ⚠ **No `GRANT`.** CommonDB's file ends `GRANT EXECUTE … TO [public] AS [dbo]`; PlanningDB's has none | Staying needs **no new grant at all** |
| **D-d** | **Disjoint planning coverage** — CommonDB sweeps the snake_case `planning_*` mirrors in `united_db`; PlanningDB sweeps its own PascalCase `Planning*` | ✅ **Staying keeps flat wire on the SAME sweep as every other alpha caller**, which is what `Q56` established and what a shared namespace depends on |
| **D-a** | Its `coils` read is `FROM proddb..coils`; CommonDB reads a bare local `CommonDB.dbo.coils` | Moot. CommonDB's read is the one `OI-125` already verified sees flat wire's own writes |
| **D-e** | Different parameter names, and no `AS` keyword | Moot |

> ### What cancelling `[G]` removes from this ledger
>
> | | Consequence |
> |---|---|
> | **`S0` pre-flight** | ⛔ **Cancelled.** `P1` existed to prove `proddb..coils` and `CommonDB.dbo.coils` are one object *before* trusting PlanningDB's sweep. On CommonDB that is simply `OI-125`'s existing finding — a resolved item, not a gate |
> | **`S9` co-location sweep** | ⛔ **Cancelled entirely.** `PlanningDB` does not become a seventh co-located database, so **none of the 14 required-database lists changes**, and the four `wip_log` false-positive traps never arise |
> | **`20_FlatWire_Grants.sql`** | The `PlanningDB` seventh-database block is **not needed**. `[H]` still moves the `EXECUTE` grants for the four procedures (§1.8b) — a different edit |
> | **`Q90`** | ⛔ **Withdrawn** — `PlanningDB`'s snapshot isolation is irrelevant if we never read it |
> | **`OI-129`** | ⛔ **Withdrawn** — flat wire is **not** on a disjoint sweep. `Q56`'s finding stands unchanged and the scrap-weight path shares our sweep as before |
> | **`OI-130`** | **Not withdrawn, but no longer flat wire's exposure.** PlanningDB's two wrong-column predicates are a real defect in a shared planning function; we simply do not call it. **Hand the observation to IT/DBA and close it out of this ledger's scope** |
> | **`OI-131`** | ⚠ **Withdrawn as an item, and it takes an upside with it** — see below |
> | **`FR-509`/`FR-512` wording** | The *"minted through the existing coil-alpha generator"* phrasing needs **no change** — it never named a database |

> ### ⚠ One thing the cancellation costs, and it is a real regression
>
> `PlanningDB.dbo.GetCoilAlpha` is the **batch loop FL1 needs** — it takes a `@count`, loops, and
> accumulates an ignore list with `CONCAT_WS`. Finding **`F10`** says *"cite it as the reference loop;
> do not call it,"* **only** because it calls `dbo.GenerateCoilAlpha` unqualified inside PlanningDB.
> The cutover would have made it directly callable.
>
> **Staying on CommonDB restores `F10`'s caveat in full: it remains unusable, and FL1's batch loop must
> be written.** `OI-131`'s truncation defect stops mattering to us — but only because we are not using
> the procedure that had it. **Net: we avoid a defective sweep and a truncating accumulator, and we
> give up a ready-made loop.** That is the right trade, and it is a trade.

---

### 1.7 The table renames — 23 tables take a `FlatWire_` prefix

**Directed internally, 26 Aug 2026.** `[R]`, the third change in this ledger, independent of `[C]` and `[G]`.

> ⚠ **This supersedes the single rename directed earlier the same day.** That instruction used the
> **no-underscore** form and covered **one** table. The convention is now **underscored** and covers
> **21**. Written without backticks so no future sweep can corrupt it: the superseded form was
> *FlatWire* immediately followed by *CoilTraceability* with nothing between; the correct form is
> *FlatWire* then an underscore then *CoilTraceability*. **The no-underscore form appears nowhere in
> the design any more and must not be reintroduced.**

**The 23 renames**, old → new. Twenty-one are `FlatWire_` + the existing name; **`FlatWireRunDetail`
and `FlatWireRun` are the exceptions** — they lose a word rather than gaining a prefix, because they
already carry the name.

| Old | New | | Old | New |
|---|---|---|---|---|
| `SpoolProcessing` | `FlatWire_SpoolProcessing` | | `RollOverride` | `FlatWire_RollOverride` |
| `SpoolTraceability` | `FlatWire_SpoolTraceability` | | `DieChangeEvent` | `FlatWire_DieChangeEvent` |
| `SpoolOrder` | `FlatWire_SpoolOrder` | | `RunReading` | `FlatWire_RunReading` |
| `RodOrderAllocation` | `FlatWire_RodOrderAllocation` | | `RodOrderConsumption` | `FlatWire_RodOrderConsumption` |
| ⚠ `FlatWireRunDetail` | **`FlatWire_RunDetail`** | | `SpcCheckpoint` | `FlatWire_SpcCheckpoint` |
| `RodCheckin` | `FlatWire_RodCheckin` | | `SpcMeasurement` | `FlatWire_SpcMeasurement` |
| `RodStaging` | `FlatWire_RodStaging` | | `WipRejection` | `FlatWire_WipRejection` |
| `SpoolCheckin` | `FlatWire_SpoolCheckin` | | `CoilOutput` | `FlatWire_CoilOutput` |
| `SpoolStaging` | `FlatWire_SpoolStaging` | | `CoilTraceability` | `FlatWire_CoilTraceability` |
| `RunPauseEvent` | `FlatWire_RunPauseEvent` | | `RodCheckout` | `FlatWire_RodCheckout` |
| `WeldEvent` | `FlatWire_WeldEvent` | | ⚠ `FlatWireRun` | **`FlatWire_Run`** |
| | | | ⚠ `PayoffPosition` | `FlatWire_PayoffPosition` |

> ⚠ **This ledger's design sections (§1, §2) already use the NEW names.** `§1.7`'s tables are the only
> place the old names appear deliberately. **If a sweep rewrites the left column above, the mapping is
> lost — which has now happened twice:** once to this table while the section was being written, and
> once to **§8's `Q91` row**, where it silently inverted the claim so two prefixed tables were listed
> as unprefixed. **Before any find-and-replace, exclude §1.7's tables AND §8.**

### 1.7a The 10 tables NOT renamed — and ⚠ the clean pattern is gone

**An earlier revision of this section claimed the exclusions formed three tidy groups: all 7 lookups,
all 3 schedule tables, and the two master records. `PayoffPosition` breaks it.** It is a lookup — it
sits in `01_Lookup` beside `Stand`, `Drawer`, `Edger`, `Dancer`, `Spool` and `AlloyProperty` — and it
is now prefixed while the other six are not. Recorded plainly rather than retrofitted, because a
rationale invented after the fact is worse than an acknowledged exception.

**23 renamed, 10 left alone:**

| Group | Tables | Status |
|---|---|---|
| **Lookups — 6 of 7** | `Stand`, `Drawer`, `Edger`, `Dancer`, `Spool`, `AlloyProperty` | Bare. ⚠ **`PayoffPosition`, the seventh, is renamed** |
| **All 3 schedule tables** | `PassSchedule`, `PassScheduleComponent`, `PassScheduleChangeLog` | Bare — MVP-1 **reads** these and never authors them (`OI-110`); a separate track owns them |
| **One master record** | `Rod` | Bare — it is a **local mirror of shared `coils`**, not a flat wire event |

**The most defensible reading of the split, offered as a reading and not as a rule:** what stays bare
is a **catalogue of things that exist independently of any run** — equipment articles, alloys,
schedules, and the rod master mirrored from the shared schema. What takes the prefix is anything
describing flat wire **structure or activity**, and `PayoffPosition` is line topology rather than a
catalogue of physical articles. ⚠ **That distinction is thin, and it will not survive the next
reader.** Two consequences worth acting on:

1. **Whatever the intent, write it into `[DBD §6.2a]`** — the naming-convention section created for
   `Q60`. Six bare lookups beside one prefixed lookup reads as an oversight unless the document says
   otherwise.
2. **If the direction is really "all lookups eventually", move the remaining six in this same pass.**
   Every FK is already being touched; a second rename wave later costs far more than six more tables
   now. `Q91` is the place that question belongs.

**One place the convention still pays off.** `Spool` stays bare while `SpoolProcessing` becomes
`FlatWire_SpoolProcessing`. `[DBD §6.2a]` exists precisely because *"spool"* names three things; after
this rename the lookup article and the material-in-process are **distinguishable at a glance**.

### 1.7b One resolution, one confirmed rule, two traps, one decision

**(1) ✅ The `FlatWireRun` mismatch is RESOLVED.** An earlier revision flagged that
`FlatWireRunDetail` → `FlatWire_RunDetail` would leave the header as `FlatWireRun` — one entity, two
spellings — and recommended renaming the header in the same pass. **That is now directed:**
`FlatWireRun` → **`FlatWire_Run`**. The pair agrees, and **`Q91`'s open half closes.**

> ⚠ **One lucky consequence, and one unlucky one.** Because `FlatWireRun` is a *prefix* of
> `FlatWireRunDetail`, a plain string replace of `FlatWireRun` → `FlatWire_Run` produces
> `FlatWire_RunDetail` too — **both renames fall out of one substitution.** But the same replace hits
> **`FlatWireRunRepository`**, a **C# class name** in
> [`FW-141-Repository-Layer.md`](../MVP-1/ProjectPlan/Backend/TaskBreakdownPlans/FW-141-Repository-Layer.md),
> and would produce `FlatWire_RunRepository` — wrong, because .NET class names do not take SQL table
> prefixes. ⚠ **An earlier revision said "there are exactly three `FlatWireRun*` identifiers in the
> repository" and generalised the whole hazard from that one case. THAT WAS WRONG, and badly** — see
> the derived-identifier trap at **(2a)** below, which is now the largest un-guarded thing in `[R]`.

**(2) ✅ `PayoffPosition` — TABLE ONLY, never the column. Confirmed as a directive, 26 Aug 2026.**
This was raised as a trap and is now an explicit instruction, so it is stated as a rule rather than a
caution. `FlatWire_DDL_04_Runs.sql` declares `[PayoffPosition] INT NOT NULL` as a **column** on
**`RodStaging`** (~line 92) and **`RodCheckin`** (~line 259). **The column keeps its name. Only the
lookup table is renamed.**

**Measured across the `.sql` files, so the sweep is a checklist and not a judgement call:**

| | Count | Action |
|---|---:|---|
| **Table** references — `[dbo].[PayoffPosition]` in `CREATE TABLE`, `INSERT INTO`, `OBJECT_ID(…)`, `REFERENCES`, `FROM` | **10** | ✅ **Rename** |
| **Column** references — `[PayoffPosition]` in a column list, a `CHECK`, or an index key | **15** | ⛔ **Leave** |
| Dependent-object **names** carrying `PayoffPos*` | **22** | See the rule below |

⚠ **Beyond the DDL there are ~169 occurrences repo-wide, and most are prose.** In the pre-check-in
specifications `PayoffPosition` almost always means *the column* — which payoff bay a rod is on. **A
wrong edit there fails silently**, because prose has no compiler. In the DDL a wrong edit fails
loudly. **Treat every non-SQL occurrence as the column unless it is plainly a table in a schema
listing, an ER diagram, or a `[DBD §6.2]` group table.**

**The rule this implies for dependent-object names, which resolves all 22 cleanly:** *the segment
naming the **owning table** changes; a segment naming a **column** or a **referenced parent** does
not.* Worked through:

```
owner IS the renamed table  -- the PayoffPosition segment DOES move
  PK_PayoffPosition            -> PK_FlatWire_PayoffPosition
  CK_PayoffPosition_Code       -> CK_FlatWire_PayoffPosition_Code
  CK_PayoffPosition_Equip      -> CK_FlatWire_PayoffPosition_Equip
  CK_PayoffPosition_Id         -> CK_FlatWire_PayoffPosition_Id
  UQ_PayoffPosition_Code       -> UQ_FlatWire_PayoffPosition_Code
  DF_PayoffPosition_IsActive   -> DF_FlatWire_PayoffPosition_IsActive

segment names the referenced PARENT -- unchanged (the referenced half is stripped of its prefix)
  FK_RodStaging_PayoffPosition        -> FK_FlatWire_RodStaging_PayoffPosition
  FK_FlatWireRunDetail_PayoffPosition -> FK_FlatWire_RunDetail_PayoffPosition

segment names a COLUMN -- unchanged; only the owner moves
  IX_RodCheckin_LineId_PayoffPosition -> IX_FlatWire_RodCheckin_LineId_PayoffPosition
  CK_RodStaging_PayoffPos             -> CK_FlatWire_RodStaging_PayoffPos
  CK_RodCheckin_PayoffPos             -> CK_FlatWire_RodCheckin_PayoffPos
```

**So exactly six of the 22 object names have their `PayoffPos*` segment rewritten** — the six owned by
the lookup table itself. In the other sixteen that segment is left alone and only the owner prefix is
added. **That is the whole discipline, and it is checkable by inspection.**

**(2a) ⚠⚠ DERIVED IDENTIFIERS — the largest un-guarded hazard in `[R]`, and it was missed until the
gap review.** §1.7b(1) measured `FlatWireRunRepository` and generalised from that single case.
Measured properly across the repository, **two whole families are built by suffixing a renamed table
name**, and both must be left alone:

| Family | Count | Examples |
|---|---:|---|
| **FK/PK COLUMN names** | **162 occurrences over 33 files** | `RodCheckinId` (45) · `WipRejectionId` (37) · `WeldEventId` (32) · `RodCheckoutId` (24) · `PayoffPositionId` (23) · `RollOverrideId` (1) |
| **.NET type names** | **18 distinct, ~57 occurrences** | `WipRejectionController` (12) · `FlatWireRunRepository` (10) · `WeldEventController` (9) · `RollOverrideService` (7) · `IFlatWireRunRepository` (5) · `IRodStagingRepository` · `ICoilOutputRepository` · `RodOrderAllocationService` · … |

⚠ **A blanket `RodCheckin` → `FlatWire_RodCheckin` produces `FlatWire_RodCheckinId` in 45 places and
`IFlatWire_RodStagingRepository`.** Under §1.7b(2)'s own rule — *the table renames, the column does
not* — every one of the 162 column occurrences stays. And .NET type names do not take SQL prefixes at
all.

**Where they live:** `FW-141-Repository-Layer.md` (its repository table maps 20 of the 23 tables to
`I*Repository` names), `FW-142`, `FW-138`, `FW-140`, `FW-174`, `FW-N04`, `phase-01b`, `phase-04`,
`phase-06`, `phase-07`, `StaffedSprintPlans.md`, `TaskBreakdown.md`, `Tools/DevelopmentPlanContent.md`,
`Architecture/PLCCommunication.md`, the master spec — **most of which are not in this ledger's target
list.**

⚠ **§7's gate *"`FlatWireRunRepository` is still `FlatWireRunRepository`"* is one-nineteenth of the
check it needs to be**, and the `sys.columns` gate catches only the DDL half — in a deployed database.
The 162 column occurrences are mostly **prose**, where corruption is silent.

**(2b) ⚠ A FIFTH false-positive class: JS handlers and REST routes.** `Frontend/Mockups/` holds
`window.openWipRejection`, `window.openSpcCheckpoint`, `window.openRodCheckout` and lowercase routes
`POST /weldevent`, `/wiprejection` — interleaved with ~103 legitimate DDL citations in the same files.
The lowercase routes are exactly what a case-insensitive sweep would hit.

**(3) ⚠ Five of the 23 names are also DOCUMENT names.** Measured:

| Name | Also a file |
|---|---|
| **`RodOrderAllocation`** | `RodOrderAllocation.md`, `_DesignPlan.md`, `_SyncPlan.md`, `_WorkedExamples.md`/`.html` |
| `WeldEvent` | `Business/Screens/WeldEvent.md` |
| `WipRejection` | `Business/Screens/WipRejection.md`, `FW-174-WipRejection-And-Checkout-Services.md` |
| `RodCheckout` | `Business/Screens/RodCheckout.md` |
| `SpcCheckpoint` | `Business/Screens/SPCCheckpoint.md` *(differs only in case — a case-insensitive sweep hits it)* |

⚠ **`RodOrderAllocation` is the acute one: of its 208 word-matches, 182 are document references and
only ~101 are the table.** Rename the document and inbound links in 27 files break — this ledger's
included. **Rule: match the table only where it is not followed by `.md`, `.html`, `_SyncPlan`,
`_DesignPlan` or `_WorkedExamples`, and never rename a file.**

**(4) ⚠ `FlatWire_` is already the shared-schema PROCEDURE prefix.** `united_db` holds
`FlatWire_CheckInRod`, `FlatWire_CompleteCoilOnSkid`, `FlatWire_ReleaseStation` and
`FlatWire_ReverseReqsum`. After this rename **`FlatWire_X` names either a `FlatWireDB` table or a
`united_db` procedure**, and nothing in the identifier says which. Nothing breaks — different object
classes in different databases — but `grep FlatWire_` stops discriminating. **`Q92`.**

**(5) The decision: how dependent-object names transform.** 292 objects follow whatever is chosen, so
choose before the first edit. **Recommendation — prefix once at the front, and strip the prefix from
the referenced half:**

```
FK_<child>_<parent>   ->   FK_FlatWire_<child-sans-prefix>_<parent-sans-prefix>

FK_CoilTraceability_CoilOutput    ->  FK_FlatWire_CoilTraceability_CoilOutput
FK_CoilOutput_FlatWireRun         ->  FK_FlatWire_CoilOutput_Run
FK_RodStaging_PayoffPosition      ->  FK_FlatWire_RodStaging_PayoffPosition
FK_SpoolProcessing_Spool          ->  FK_FlatWire_SpoolProcessing_Spool   (parent stays bare)
PK_FlatWireRun                    ->  PK_FlatWire_Run
```

The module appears **once**; a constraint belongs to one module, so repeating it is noise. It also
keeps a real signal: `FK_FlatWire_SpoolProcessing_Spool` shows at a glance that the parent is one of
the **unprefixed lookups**. ⚠ **The alternative — prefixing both halves — yields
`FK_FlatWire_CoilTraceability_FlatWire_CoilOutput`**, 48 characters and four segments. Both are
defensible; what is not defensible is deciding per-constraint while editing 292 of them.

### 1.7c The dependent objects — 292 of them

**This is the real size of the rename, and counts will not detect a half-done one.** Union across all
23 tables, enumerated from the DDL:

| Kind | Count | Notes |
|---|---|---|
| `CK_` check | **109** | Largest group, least visible |
| `IX_` index | **53** | |
| `FK_` foreign key | **50** | ⚠ **of 55 total** — nearly every FK in the schema. Thirteen name *two* renamed tables, and **fourteen point at `FlatWireRun`** alone |
| `DF_` default | **32** | |
| `PK_` primary key | **23** | One per renamed table — a useful cross-check |
| `UQ_` unique constraint | **14** | |
| `UX_` unique index | **10** | Includes `UX_FlatWireRun_ActiveLine`, `UX_SpoolTraceability_ChildAlpha` and this ledger's new `UX_…_ChildAlpha` |
| `trg_` trigger | **1** | **`trg_CoilTraceability_NoOverlap`** — see below |
| | **292** | **Two are historical mentions** in `06`'s header of constraints the `Q60` merge dropped (`FK_SpoolProcessing_SpoolConfiguration`, `FK_Spool_SpoolConfiguration`) and are **not live objects** |

> ⚠ **The trigger is still the dangerous one.** `trg_CoilTraceability_NoOverlap` is cited **by name**
> from `08_Programmability`, `05_QualityOutput`'s header, `TC-192`, `TC-617`, `[DBD]` and four phase
> files, and it is the only thing enforcing half-open non-overlap on the coil genealogy. A rename that
> moves the table and leaves the trigger unbuilt loses that enforcement **silently** — the rows still
> insert, they just stop being checked.

### 1.7d What makes this tractable

**It is a script edit, not a migration.** The deploy path is already **teardown-and-rebuild** (`S8`),
the live database holds **3 rows** and is two schema changes behind the scripts anyway, and production
is Q4 2026. **No `sp_rename`, no data migration, no dual-read window** — and do not add one.

**The teardown needs nothing.** `FlatWire_DDL_99_Teardown.sql` drops the whole database rather than
enumerating tables — verified, 24 lines.

**Object counts do not move.** A rename adds nothing: **33 tables · 55 FKs · 70 index statements ·
1 procedure · 1 trigger** after `[C]`'s additions — **two columns and one index**, of which only the
index moves a published count (69 → 70) — exactly as §2.4 states. So
`verify_schema_counts.py` **cannot catch a half-done rename by count.** What it *will* catch is `C2`,
documentation coverage — every table must appear in its own script header, in a
`Schema/FlatWireSchema_*.md`, in `phase-01c`'s group table **and** as an entity in `[DBD §7]`'s ER
diagrams. **All 23 new names in all four places, or the build gate fails.** That is the useful half of
the coupling and the reason the rename cannot be done in the DDL alone.

**The precedent is `Q60`** — the 23 Aug `Spool`/`SpoolCarrier` swap, which `CLAUDE.md` calls *"the one
rename where a stale reference is silently wrong rather than obviously stale."* It renamed five child
FKs so that **no constraint claimed the wrong parent**, and that is the discipline all 292 objects
need. Note the difference in risk, though: `Q60` swapped two existing names and could therefore
resolve to the *wrong* object; these renames only *lengthen* names, so a stale reference fails
**loudly** at deploy. **That makes this the safer class of rename** — provided each table moves with
its dependent objects in one pass.

---

### 1.8 `[H]` — the four procedures move into `FlatWireDB`

**Directed internally, 26 Aug 2026.** The fourth change in this ledger. `FlatWire_CheckInRod`,
`FlatWire_CompleteCoilOnSkid`, `FlatWire_ReleaseStation` and `FlatWire_ReverseReqsum` are **hosted in
`FlatWireDB`** rather than `united_db`.

**There is already a precedent, and it settles the file-naming convention.**
`30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql` declares `Target DBs : FlatWireDB (procedure home;
dbo.Rod)`. So the four files become `40_FlatWireDB_Proc_…` … `70_FlatWireDB_Proc_…`, and
`99_united_db_Proc_FlatWire_Teardown.sql` becomes `99_FlatWireDB_Proc_FlatWire_Teardown.sql`.

> ⚠ **State the awkward fact first: none of the four touches a `FlatWireDB` object.** Measured — their
> three-part references reach `CommonDB`, `proddb`, `SlitterDB` and `united_db`, and **not
> `FlatWireDB`**. These procedures *are* the shared-schema half of the transaction; the caller
> (`CheckInService`) writes `FlatWireDB` through EF and calls the procedure last on the same
> transaction (`[INT §8.0]`). **So after `[H]` each procedure lives in a database none of whose objects
> it uses.** That is not a reason to refuse — one database owning every flat wire object is a coherent
> goal, and `sp_IngestRodFromCoils` already sits there — but it is the trade being made, and it should
> be recorded rather than discovered.

### 1.8a The real cost — **51 references**, and they do NOT all point at `united_db`

> ⚠ **Re-measured 26 Aug 2026, immediately before executing `S5a`. Both the count and the rule below
> were wrong, and the rule was the dangerous half.** The superseded text read *"148 references have to
> be qualified … every unqualified `dbo.X` in these files resolves to `united_db` today … each one must
> become three-part `united_db.dbo.X`"*, over a table reading 55 / 55 / 10 / 20 / 8.
>
> **The 148 counted the `Target DBs` header blocks.** Those headers list objects as `dbo.coils`,
> `dbo.wip_skids` and so on inside a `/* … */` banner, and a comment-stripper that only skips `--`
> lines reads every one of them as code. Stripping `/* … */`, `--` and string literals properly gives
> **64 references in executable code**, of which **51 need qualifying**.
>
> ⛔ **And the blanket rule would have got 26 of the 64 wrong** — see the two exception classes below.
> It is not *"qualify everything to `united_db`"*; it is *"qualify to the object's own home, and leave
> the four procedures alone."*

| File | Code refs | → `united_db` | → `CommonDB` | **LOCAL — leave** | **To qualify** |
|---|---:|---:|---:|---:|---:|
| `40_…_CheckInRod.sql` | 27 | 20 | 5 | 2 | **25** |
| `50_…_CompleteCoilOnSkid.sql` | 18 | 12 | 4 | 2 | **16** |
| `60_…_ReleaseStation.sql` | 5 | 2 | 1 | 2 | **3** |
| `70_…_ReverseReqsum.sql` | 10 | 4 | 3 | 3 | **7** |
| `99_…_Teardown.sql` | 4 | 0 | 0 | 4 | **0** |
| | **64** | **38** | **13** | **13** | **51** |

> ### ⛔ Exception class 1 — `Logging_Information_In_Table` is `CommonDB`, and it is the single largest group
>
> **13 of the 64.** Every `EXEC [dbo].[Logging_Information_In_Table]` — 5 in `40_`, 4 in `50_`, 1 in
> `60_`, 3 in `70_` — is documented in all four `Target DBs` headers as a **`CommonDB`** object, reached
> from `united_db` through a synonym. Qualifying it `united_db.dbo.` would throw
> `Invalid object name` on **every logging call in all four procedures**. It becomes
> `[CommonDB].[dbo].[Logging_Information_In_Table]`.
>
> ### ⛔ Exception class 2 — the four procedures are the things MOVING
>
> **13 of the 64**, and this is the one that would have been actively wrong rather than merely broken:
> `FlatWire_CheckInRod` (3), `FlatWire_CompleteCoilOnSkid` (3), `FlatWire_ReleaseStation` (4),
> `FlatWire_ReverseReqsum` (3) — the cross-calls between them, plus `99_`'s four `DROP PROCEDURE`
> statements. **Under the blanket rule these become `united_db.dbo.FlatWire_*` — pointing at the
> database `[H]` is moving them OUT of.** They stay unqualified `dbo.`, which is now `FlatWireDB`, and
> that is exactly right. ✅ **`99_…_Teardown.sql` therefore needs no qualification at all** — all four
> of its references are drops of the moving procedures.

> ### ✅ The reassuring half — it fails LOUDLY, and that is measured, not assumed
>
> **None of the 15 distinct unqualified object names collides with a `FlatWireDB` table name.**
> Re-verified 26 Aug 2026 by set-intersecting the measured name list against the 33 `CREATE TABLE`
> names in `01`–`05`: **zero collisions.** So a missed qualification throws **`Invalid object name`** at
> create or first execution; it cannot silently bind to the wrong object. *(The figure was 31 under the
> old miscount.)*
>
> **`[R]` makes this safer still** — after the rename every `FlatWireDB` table carries a `FlatWire_`
> prefix, so the namespaces cannot converge even by accident.
>
> ⚠ **This puts `[H]` in the same risk class as `[R]`: mechanically large, but loud on failure.** It is
> the opposite of the `PayoffPosition` column trap (§1.7b(2)), which fails silently in prose. **Treat
> the 51 as a compile-style checklist, not a judgement exercise** — with the **two exception classes
> above as the judgement part, and they are the whole of it.**

**The two objects this section used to name are both non-issues, and were verified so on 26 Aug 2026.**

✅ **`GenerateCoilAlpha` is ALREADY fully qualified** and always was — `50_` line 469 reads
`SET @sharedCoilNo = [CommonDB].[dbo].[GenerateCoilAlpha](@primaryRodAlpha, '');`. It is **not** in the
unqualified set, so `[H]` has nothing to do to it. *(Superseded text claimed it "appears unqualified …
resolving through the `united_db` synonym … so it would fail." It would not — there is no synonym in
the call path because there is no unqualified call.)*

✅ **`WIPStations` was ALREADY DECIDED, in the code and in a documented constraint.** It has **zero
*unqualified* references** — all seven code sites already read `[CommonDB].[dbo].[WIPStations]`
(`40_` lines 505, 520, 550, 558, 883; `60_` lines 162, 192), so it was never in the set `[H]` sweeps.
Its two *unqualified*-looking occurrences are `Target DBs` header text, the same artifact that produced
the 148.

⛔ **And the question it was deferred on is answered in the file itself.** `40_`'s constraint **`C1`**
(lines 176–178) states it outright: *"`CommonDB..WIPStations` is the ONE physical station table.
`united_db..wip_stations` and `proddb..wip_stations` are BOTH VIEWS OVER IT … one row, three names."*
`60_`'s `C1` repeats it. So `[INT §8]`'s *"views over one table"* is not an open ambiguity — it is a
**recorded finding, and the code already picks the base table.**

> **Deferred decision #2 is therefore WITHDRAWN, not just deferred** — *"decide the qualification
> target; do not guess"* asked for a choice that the code had already made correctly and that `C1` had
> already justified. ⚠ **One thing does survive:** the object is *seeded* by
> `10_CommonDB_Insert_WIPStations_FlatWire.sql`, the file `FlatWire_Scripts_RunAll.sql` deliberately
> skips because it writes irreversible rows into shared tables. That skip is untouched by `[H]`.

### 1.8b What `[H]` changes beyond the procedures

| Target | Change |
|---|---|
| **File names ×5** | `40`–`70` and `99` become `*_FlatWireDB_Proc_*`, per the `30_` precedent |
| [`FlatWire_Scripts_RunAll.sql`](../MVP-1/ProjectPlan/Database/Scripts/FlatWire_Scripts_RunAll.sql) | The `:r` chain names all five files. ⚠ It **deliberately skips `10_CommonDB_…`**; that exclusion is unaffected |
| [`Scripts/README.md`](../MVP-1/ProjectPlan/Database/Scripts/README.md) | The manifest and its per-file "structure / outbound" table, which currently classifies these as `united_db (home)` |
| [`20_FlatWire_Grants.sql`](../MVP-1/ProjectPlan/Database/Scripts/20_FlatWire_Grants.sql) | ⚠ **The `EXECUTE` grants move databases** — from `united_db.dbo.FlatWire_*` to `FlatWireDB.dbo.FlatWire_*`. Simpler, since `FlatWireDB` is ours. **But the procedures' own cross-database reads do not simplify:** ownership chaining does not cross databases, so the *caller's* login still needs rights on `proddb` / `CommonDB` / `SlitterDB` / `wiplogdb` directly. **`[H]` changes which grant is needed, not how many** |
| [`Operations/Deployment.md`](../MVP-1/ProjectPlan/Operations/Deployment.md) | `V4`'s `sys.objects` check — ✅ **`[H]` simplifies it**: the four procedures join the trigger and `sp_GetGaugeTrace` in **one** database, so `V4` becomes a single-database query instead of spanning two. Re-derive its expected row count |
| `[INT §8.0]` / `[INT §8.1]` / `[ARC §10]` | The transaction model is **unchanged** — same instance, same local transaction manager, no MSDTC. **Say so explicitly**: a reader seeing the procedure move will assume otherwise |
| `[DEP §4.2]` | Deploy order holds — `Scripts/` already runs after `Schema/`, and a `FlatWireDB` procedure requires only that the database exists |

### 1.8c `Q92` narrows

`Q92` was raised because `FlatWire_` named **both** a `FlatWireDB` table and a `united_db` procedure,
so the identifier did not say which database to look in. **`[H]` removes the cross-database half of
that ambiguity** — every `FlatWire_` object now lives in `FlatWireDB`.

⚠ **What survives is narrower and arguably worse for a reader:** inside one database,
`FlatWire_RodCheckin` is a **table** and `FlatWire_CheckInRod` is a **procedure**, and the prefix
distinguishes neither. **SQL Server does not care** — different object classes — but `grep FlatWire_`
still fails to discriminate, and the prefix is now redundant on *everything* in `FlatWireDB`, which
strengthens `Q91`'s case rather than closing it. **Update `Q92` to the post-`[H]` form; do not close
it.**

---

### 1.9 `[S]` — the N-record shared write-back

**`Q89` answered yes, 26 Aug 2026.** Per physical coil, loop over its `FlatWire_CoilTraceability`
rows and write one shared-schema record per part alpha.

| Write | Cardinality | Per-alpha value |
|---|---|---|
| `proddb..coils` | **N** | Weight from `SegmentWeightLb`. ⚠ **N single-row statements, never one set-based insert** — `C4` gates on `@ins_count = 1` and an `AFTER` trigger fires per **statement**, so a loop is legal and a batch silently skips `coil_link_master_coil` |
| ⚠ **the mint itself** | **N** | **`GenerateCoilAlpha(SourceSegmentAlpha, '')`** — rooted on the **segment**, blank list (`[N]`, 26 Aug 2026). Rod fallback where `SourceSegmentAlpha IS NULL`. ⛔ **NOT `(RodAlpha, @ignoreList)`**, which is what this section specified until then |
| ⛔ **NEVER re-mint on retry** | — | **Reuse the stored `ChildAlpha` whenever `SharedWrittenAt IS NULL`.** Under a blank list this stopped being an optimisation and became a **correctness** rule: if part 1 committed between attempts, the sweep now sees it, so re-minting part 2 returns a **different letter** than the one already stored. ⚠ **The failure mode changed with it** — no longer a *duplicate coil* but a **valid-but-orphaned alpha**, which no guard detects. ✅ `50_` line 480 already does this via `@expectedCoilNo`; `[S]` widens it to the set |
| `coil_gen_history` | **N** | ⚠ **Each alpha passes ITS OWN parent rod**, not a shared `@primaryRodAlpha`. **This is what closes `OI-113`** — one shared parent for all N would say *"this rod produced N coils"*, which is not multi-rod genealogy |
| `coil_cost` | **N** | `@childCoilWeight` = `SegmentWeightLb`, **split not repeated** |
| `wip_coil_orders` | **N** | ⚠ `coil_planned_wgt` **split**, not copied wholesale — copying N-fold over-counts planned weight against the order |
| `coil_slit_cuts` | **N** | `skid_coil_seq_no` from `@skidAssignment` (§1.9a); `cut_no` / `skid_cut_no` stay `1` |
| `wip_log_view` | **N** | ⚠ **Increment `@logSeqNo`** rather than the one-second spin. The key is UNIQUE on `(wip_log_rev_time, seq_no)` at **second** granularity, and `@logSeqNo` is initialised `0` and **never incremented** today |
| `wip_skids` | **1** | Weights accumulate **once per physical coil**, from `CoilOutput.NetWeightLb` / `GrossWeightLb` — **not** N × the same scalar. The `C9` smallint guard validates per *call*, so it would otherwise admit 3,600 lb onto an 1,800 lb skid |
| `wip_skid_coils` | **N** | All N link. The guard that broke on this is withdrawn in §1.9a |

**Two more scalar-to-N fixes in the same procedure:** the `coil_break` UPDATE targets
`WHERE child_coil_no = @sharedCoilNo` and would leave N−1 alphas with `coil_break = 0`; and
`@genealogyParent`'s read-back is per-child.

### 1.9a The skid guards — driven off `@skidAssignment`, not row counts

**The blocker was real: the shared schema has no column that can express "these N rows are one
physical coil."** It does not need one — **the operator already tells us.** `@skidAssignment` is
`Coil1Of2` / `Coil2Of2`, supplied on DB7, and `D11` already says *"`IsComplete` is driven **solely** by
`@skidAssignment`."* So make the other guards consistent with the one that already works:

| Guard | Today | Under `[S]` |
|---|---|---|
| `COUNT(*) … wip_skid_coils >= 2` → `51016` | counts **rows** | ⛔ **Withdrawn.** Covered by `51015`, which refuses `Coil2Of2` on an `IsComplete = 1` skid and is already physical-coil-grained |
| `MAX(skid_coil_seq_no)+1 > 2` → `51018` | derives from **rows** in `coil_slit_cuts` | ⛔ **Withdrawn.** `skid_coil_seq_no` is **set from `@skidAssignment`** — `1` for `Coil1Of2`, `2` for `Coil2Of2` — so all N rows of one physical coil share its slot |
| `IsComplete` | `@skidAssignment` | ✅ **unchanged** |

✅ **Cheap, and `C12` is why:** *"All integrity is in triggers and procedures. **Nothing below can rely
on the database refusing bad data.**"* Measured: `wip_skid_coils` is **two `char(9)` columns** with one
unique index and **no PK, no FK, no CHECK**; `wip_skids` has no CHECK either; `max_cuts_plan` is a
nullable `int` nothing reads. **These are four `THROW`s in our own procedure**, and the **ten synonym
paths** to the skid tables plus the public-granted `ins_wip_skid_coils` already bypass them.

⚠ **This also sidesteps `OI-114`.** Deriving `MAX+1` over a column that is `int NULL`, carries no
uniqueness constraint, is written `NULL` by one of the writers `OI-114` names and cleared to `NULL` by
two more, was always fragile. Setting it from the operator's declaration is simpler and keeps
`ConveyorInterface_MoveCutsBackToLiftTable`'s `ORDER BY skid_coil_seq_no DESC` grouping by physical
coil.

### 1.9b The retry contract — one column, not a new table

An earlier assessment called for *"a `FlatWireDB` child table for N alphas per `CoilOutput`."*
**Not needed.** `FlatWire_CoilTraceability.ChildAlpha` is **already** per (coil × source rod) — it *is*
the N-alpha store, added by `[C]`. Only a **commit marker** is missing:

```sql
-- SharedWrittenAt -- the RETRY CONTRACT under [S]. NULL until this part alpha's
-- proddb..coils row commits; stamped when FlatWire_CompleteCoilOnSkid returns.
-- A retry passes back every non-NULL ChildAlpha and the procedure skips those:
-- the N-alpha form of @expectedCoilNo, which is CHAR(9) and can carry one.
--
-- WHY A COLUMN AND NOT A TABLE: ChildAlpha already holds the N alphas. The only
-- thing the scalar contract could not express is WHICH of them committed.
ALTER TABLE [dbo].[FlatWire_CoilTraceability] ADD [SharedWrittenAt] DATETIMEOFFSET NULL;
```

⚠ **The failure this fixes was silent.** Today a retry passing alpha #1 short-circuits and
`RETURN 0` — **success** — while #2..N sit committed in five shared tables, referenced by nothing in
`FlatWireDB` and unreported to the caller.

**Signature changes:** `@expectedCoilNo CHAR(9)` → **table-valued**; the three scalar OUTPUTs
(`@sharedCoilNo`, `@skidNo`, `@skidIsComplete`) → a **rowset**; `@primaryRodAlpha` and `@netWeightLb`
→ per-alpha.

✅ **`CoilOutput.CoilNo` is retained unchanged** as the lead alpha and the coil's primary scalar face,
still filtered-UNIQUE. **`D5` stands.**

⚠ **Suffix ceiling.** `GenerateCoilAlpha` gives **702 per rod root** — `A`…`Z`, then `AA`…`ZZ`
(`F4`, and `F13` for the measured walk) — and N alphas per coil divides that by N; `THROW 51010` is the
only handling. Not reachable at ~6 coils per rod, but no longer independent of N. New open item.
*(Read **702**, not the **26** this said until 26 Aug 2026: 26 is only the single-letter range, and the
overflow bumps the stem rather than stopping.)*

---

## 2. The design delta, stated once

Everything below is `FlatWireDB`-local. **`D-32` is untouched.**

### 2.1 Schema

```sql
-- ChildAlpha -- ONE ALPHA PER (COIL x SOURCE ROD). The client does not want a
-- single alpha for a welded coil (26 Aug 2026): a coil made of 500 lb R00002A
-- and 400 lb R00001C maintains TWO alphas, one rooted on each source rod.
--
-- SAME CONSTRUCT AS FlatWire_SpoolTraceability.ChildAlpha, one hop later. That row is
-- the Rod x Spool intersection and names the SEGMENT; this row is the
-- Rod x Coil intersection and names the COIL PART. Neither is the container's
-- identity: FlatWire_CoilOutput.CoilAlpha stays the coil's local, customer-facing one.
--
-- MINTED BY CommonDB.dbo.GenerateCoilAlpha(SourceSegmentAlpha, '') -- rooted on
-- THIS ROW's SOURCE SEGMENT (SourceSegmentAlpha), falling back to the rod only
-- where that is NULL -- FL1-standalone and FL3-from-rod. A BLANK ignore list.
--
-- *** THIS COMMENT SAID THE OPPOSITE UNTIL 26 AUG 2026, TWICE OVER. ***
--   v1: "rooted on THIS ROW's rod, NEVER on the segment ... passing a
--        seven-character segment alpha returns a SIBLING." Measured FALSE: it
--        returns a CHILD, R00002A -> R00002AA (F13).
--   v2: kept the verdict on COLLISION -- R00002AA is also suffix 27 of the
--        rod-rooted walk. True, but bounded: it needs 26 segments off one rod
--        (46,800 lb vs the 4,000-8,840 in play, OI-97), and even then nothing
--        collides because everything is REGISTERED and the sweep finds a free
--        string. Only the shape stops being readable.
--
-- SO: root on the segment. One trailing letter = a segment off the rod; TWO =
-- a coil off that segment. Fixed rooting, never chained -- every coil off one
-- spool roots on the SAME segment, so the string grows one letter and stops.
-- Chaining coil-on-coil would hit the LEN=9 branch and flatten at depth 3.
--
-- THE IGNORE LIST IS EVERY FlatWireDB-LOCAL ALPHA FOR THAT ROD -- both
-- FlatWire_SpoolTraceability.ChildAlpha and FlatWire_CoilTraceability.ChildAlpha, whether or not
-- it also reached the shared schema. Duplicates in an exclusion list are
-- harmless; a missing one reissues an alpha. Cap 500 chars (F11).
--
-- LEAD PART. Exactly one row per coil is the lead -- MIN(FootageFrom), which
-- under LIFO is the first material off and is the same row FR-512 already
-- calls the primary rod. FlatWire_CoilOutput.CoilNo MUST equal the lead row's
-- ChildAlpha, and the lead is the ONLY part that reaches proddb..coils (R1,
-- 1.3). Q89 is open on whether every part should.
--
-- OPAQUE. Never parse it, never rebuild it, never order by it. SeqNo ordering
-- lives on the footage range. The letters are mint-order artifacts: a part
-- alpha and a segment alpha off one rod are drawn from ONE 702-suffix budget,
-- so which letter lands where moves with mint order (see F4, Q59).
ALTER TABLE [dbo].[FlatWire_CoilTraceability] ADD [ChildAlpha] VARCHAR(20) NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FlatWire_CoilTraceability_ChildAlpha]
    ON [dbo].[FlatWire_CoilTraceability] ([ChildAlpha]) WHERE [ChildAlpha] IS NOT NULL;
GO

-- SourceSegmentAlpha -- which SEGMENT of that rod this part came from.
-- (RodAlpha, SpoolAlpha) implies it in every case the design admits, but only
-- because nothing yet forbids one rod contributing two segments to one spool.
-- *** LOAD-BEARING SINCE 26 AUG 2026. IT CANNOT BE DROPPED. ***
-- This column is now THE MINT INPUT: the part alpha is generated off it,
-- GenerateCoilAlpha(SourceSegmentAlpha, ''), falling back to the rod only where
-- it is NULL. Remove it and there is nothing to root on.
--
-- Its justification has moved twice and both earlier versions are misleading:
--   v1 "what lets the client's segment-rooted string form be rendered" --
--      withdrawn when Q88 rejected reproducing that form.
--   v2 "the only reason to keep the column is genealogy precision, making the
--      parent SEGMENT explicit where (RodAlpha, SpoolAlpha) only implies it;
--      if that is not wanted the column drops, and I6 / ORD022 / TC-794 drop
--      with it." *** DO NOT ACT ON v2. *** The drop-if-unwanted clause is
--      exactly wrong now.
--
-- The v2 reason still holds as a SECOND reason -- (RodAlpha, SpoolAlpha) only
-- implies the segment, because nothing yet forbids one rod contributing two
-- segments to one spool (OI-137). But it is no longer the only one.
--
-- NOT AN FK, AND CANNOT BE ONE: its parent index
-- UX_FlatWire_SpoolTraceability_ChildAlpha
-- is FILTERED, and SQL Server will not point a foreign key at a filtered index.
-- Enforced in the domain model (FW-207) and by TC-794 -- I6, added on review;
-- an earlier draft cited TC-786, which tests I3 (the root match) and says
-- nothing about whether the referenced segment exists.
-- NULL on a rod-fed coil -- FL1/FL3-from-rod has no segment to name, the same
-- reason FlatWire_CoilTraceability.SpoolAlpha is nullable.
ALTER TABLE [dbo].[FlatWire_CoilTraceability] ADD [SourceSegmentAlpha] VARCHAR(20) NULL;
GO

-- SharedWrittenAt -- the RETRY CONTRACT under [S] (1.9b). NULL until this part
-- alpha's proddb..coils row commits; stamped when FlatWire_CompleteCoilOnSkid
-- returns. A retry passes back every non-NULL ChildAlpha and the procedure
-- skips those.
--
-- WHY A COLUMN AND NOT A NEW TABLE: ChildAlpha above already holds the N
-- alphas. The only thing @expectedCoilNo CHAR(9) could not express is WHICH of
-- them committed -- so that is the only thing this adds.
--
-- WITHOUT IT the failure is SILENT: a retry passing alpha #1 short-circuits and
-- returns 0 (success) while #2..N sit committed in five shared tables,
-- referenced by nothing here and unreported to the caller.
ALTER TABLE [dbo].[FlatWire_CoilTraceability] ADD [SharedWrittenAt] DATETIMEOFFSET NULL;
GO
```

### 2.2 Invariants

| | Rule |
|---|---|
| **I1** | A completed coil has **one `ChildAlpha` per `FlatWire_CoilTraceability` row**, all non-NULL |
| **I2** | Exactly one row per coil is the **lead** (`MIN(FootageFrom)`), and `FlatWire_CoilOutput.CoilNo` = that row's `ChildAlpha` |
| **I3** | `LEFT(ChildAlpha, 6) = LEFT(RodAlpha, 6)` — ⚠ **the assertion is unchanged and still passes; its REASON changed 26 Aug 2026.** A part alpha is rooted on its **source segment**, not on the rod; the six-character prefix merely **coincides**, because a segment alpha is itself rooted on that rod. `LEFT('R00001CA',6) = 'R00001'`. *(Previously read "a part alpha is rooted on its own row's rod" — right check, wrong explanation.)* |
| **I4** | No string appears in both `FlatWire_SpoolTraceability.ChildAlpha` and `FlatWire_CoilTraceability.ChildAlpha`. **Not expressible as a constraint** across two tables — it rests on the shared ignore list (§2.1) and is asserted by test |
| **I5** | An **unwelded** coil has exactly one part alpha, equal to its `CoilNo`. The single-parent case is **structurally** identical to today — *not* string-identical, because the generator cutover may return a different suffix (§1.4) |
| **I7** | ⚠ **`SUM(SegmentWeightLb)` over a coil's parts equals `FlatWire_CoilOutput.NetWeightLb`.** The double-count guard, and **the most important new test under `[S]`** — without it the shared schema records N × the coil's weight |
| **I8** | Every `ChildAlpha` of a completed coil has a non-NULL **`SharedWrittenAt`**. The `[S]` retry contract (§1.9b) |
| **I6** | Where `SourceSegmentAlpha` is non-NULL it **matches a `FlatWire_SpoolTraceability.ChildAlpha`**, and that segment's `RodAlpha` equals this row's. ⚠ **Added on review** — the column had no invariant and no test, and its own comment cited `TC-786`, which tests `I3` and says nothing about whether the referenced segment exists. **No FK can enforce it** (filtered parent index), so this is the only guard |

### 2.3 Rendering — display only, nothing compound stored

`<lead> - <second>` — illustrated as **`R00002AA - R00001CA`** *(was `R00002E - R00001F`, under rod-rooting)*, parts in **unwind order** (lead first).
⚠ **This is a JOIN of two generated alphas, not a construction.** It appends no letter to anything;
see the single-source rule in §1.2. The `" - "` separator is the client's
own and is load-bearing: their analysis records `" / "` for consumption facts and `" - "` for
alphas. `RodOrderAllocation.md` §2.8's sentence *"the compound display renders from these rows;
nothing compound is stored"* **survives verbatim** — what changes is that the parts are now stored individually and the
arrow form becomes `<lead> - <second> ← R00002A + R00001C`. **The example letters are illustrative
only** (§1.4): a rendering test asserts the *shape and order*, never the suffixes.

### 2.4 Object counts

| | Before | After |
|---|---|---|
| Tables | 33 | **33** — unchanged |
| FK constraints | 55 | **55** — unchanged (the filtered index forbids an FK; §2.1) |
| Index statements | 69 | **70** |
| Unique indexes | 11 | **12** |
| | | ⛔ **`[S]` adds a column, not an index** — `SharedWrittenAt` moves no published count |
| Procedures · triggers | 1 · 1 | **1 · 1** — unchanged |

⚠ **`[DBD §6.2]` is the only site that publishes these, and `verify_schema_counts.py` is fatal on
drift.** Do not restate them anywhere else, and do not publish incrementally — re-derive from a live
teardown-and-deploy at the end of the wave, per the standing rule.

---

## 3. Register ids to mint

Verified free against the live registers on 26 Aug 2026.

> ⚠ **`Q88`, `Q89` and `Q90` will all look taken, and none is.** All three appear in `CHANGELOG.md`
> entries dated **4 and 11 Aug 2026** — the 4 Aug PLC-consolidation entries mint `Q85`–`Q88` and
> `Q89`–`Q92`, and call **`Q90`** *"the serious one"* — under the numbering the three 12 Aug
> renumbering passes retired — and the same is true of **`Q91`** and **`Q92`**, which appear in the
> 4 Aug entries too. Those entries keep their original ids by design. The live registers hold `Q1`–`Q55`, `Q59`, `Q87` open and
> up to `Q86` decided, so **`Q88` is the next free number** — and it is minted **decided**, landing in
> `FlatWireDecidedQuestions.md` rather than the open register. Do not renumber around the change-log
> hits, and do not use the old→new maps to "resolve" them — they map *inbound citations*, not new mints.

| Id | Kind | Content |
|---|---|---|
| ~~**`Q88`**~~ | ✅ **DECIDED 26 Aug 2026 — two alphas *per se*.** Lands in `FlatWireDecidedQuestions.md`, **not** the open register | **The client's `segmentAlpha + AlphaLetter(stopIndex)` form is not adopted in any capacity — not stored, not rendered.** Every alpha comes from `PlanningDB.dbo.GenerateCoilAlpha` and nothing else (the single-source rule, §1.2). The four objections in §1.2(a) stand as the recorded reasoning. ⚠ **One consequence:** `SourceSegmentAlpha`'s original justification was *"it lets the client's form be rendered"* — **withdrawn**; the column now rests solely on making the parent segment explicit (§2.1) |
| ~~**`Q89`**~~ | ✅ **DECIDED 26 Aug 2026 — EVERY part alpha.** Lands in `FlatWireDecidedQuestions.md`, **not** the open register | **Reading `R2` adopted as change `[S]`** (§1.3, §1.9). ⛔ Two of `R1`'s three arguments were wrong — the `coil_gen_history` guard is per-**child**, and `C4` forbids a set-based insert not N single-row ones. ✅ **`OI-113` and `OI-128` close with it.** The superseded question read: *Recommendation: lead only — `FR-515`'s two-coils-per-skid rule breaks arithmetically otherwise (§1.3).* **Why:** it is the difference between an additive change and re-opening Phase 9's shared write-back |
| ⛔ ~~**`Q90`**~~ | **WITHDRAWN 26 Aug 2026 with `[G]`** | `PlanningDB`'s `READ_COMMITTED_SNAPSHOT` setting is irrelevant if flat wire never reads it. **Do not mint it** |
| **`Q91`** | Open question · **`Medium`** · Owner: **Architecture** · `Scope = Other` — **its first half is now DECIDED** | ✅ **The `FlatWireRun` anomaly is resolved** — the header is renamed `FlatWire_Run`, so it agrees with `FlatWire_RunDetail`. ⚠ **What is now open is different and was created by `PayoffPosition`:** one of the seven lookups is prefixed and six are not (§1.7a), so the exclusion set no longer forms a stateable rule. *Recommendation: either move the remaining six lookups in this same pass — every FK is already being touched, so a second wave later costs far more — or write the `PayoffPosition` exception into `[DBD §6.2a]` explicitly.* **Why:** six bare lookups beside one prefixed lookup reads as an oversight unless a document says otherwise |
| **`Q92`** | Open question · **`Low`** · Owner: **Architecture** · `Scope = Other` | ⚠ **`FlatWire_` now prefixes both `FlatWireDB` tables and `united_db` procedures.** `FlatWire_CheckInRod`, `FlatWire_CompleteCoilOnSkid`, `FlatWire_ReleaseStation` and `FlatWire_ReverseReqsum` already own the prefix. Nothing breaks — different object classes, different databases — but the identifier no longer says which, and `grep FlatWire_` stops discriminating. *Recommendation: accept it and note the two namespaces in `[DBD §6.2a]`; a `FW_` table prefix or a `usp_` procedure prefix would both be larger changes than the ambiguity costs.* **Why:** it is a readability cost, not a correctness one — but it should be a recorded decision rather than a surprise |
| ~~**`OI-128`**~~ | ✅ **CLOSED by `[S]` — do not mint it** | The exposure dissolves: every part alpha is now in the shared schema and therefore **swept** by `GenerateCoilAlpha`. *The finding it recorded:* **non-lead part alphas live only in `FlatWireDB`, which `CommonDB.dbo.GenerateCoilAlpha` does not sweep, so a third-party minter can reissue one.** Extends `Q59` / `OQ-P` from FL1 segments to FL2 coil parts. Posture *accept and monitor* — unchanged by `[G]`'s cancellation, because it was never about which generator |
| ⛔ ~~**`OI-129`**~~ | **WITHDRAWN 26 Aug 2026 with `[G]`** | Flat wire is **not** on a disjoint sweep — it stays on CommonDB's, alongside every other alpha caller. **`Q56`'s finding stands unchanged** and the scrap-weight path shares our sweep as before. **Do not mint it** |
| **`OI-130`** | ⚠ **Found, and no longer flat wire's exposure** | **`PlanningDB.dbo.GenerateCoilAlpha` filters the wrong column on two of fourteen branches** — `WHERE incoming_coil_no` where CommonDB reads `WHERE coil_no`. **A real defect in a shared planning function that four PlanningDB procedures depend on — we simply do not call it.** Hand the observation to **IT / DBA** as a finding; it is not an open item against this work |
| ⛔ ~~**`OI-131`**~~ | **WITHDRAWN as an item — and it takes an upside with it** | `PlanningDB.dbo.GetCoilAlpha`'s truncating exclusion list stops mattering because we are not using the procedure. ⚠ **But `F10`'s caveat returns in full: it remains uncallable, so FL1's batch loop must be written** (§1.5) |
| **`Q93`** | Open question · **`Low`** · Owner: **IT / DBA** · `Scope = Other` | ⚠ **The 702-suffix-per-rod ceiling is now divided by N.** `GenerateCoilAlpha` walks `A`..`Z` then `AA`..`ZZ` — the six-character root is the sweep filter, **not** the append stem (`F13`); `[S]` mints one alpha per source rod per coil, and `THROW 51010` is the only handling. *Recommendation: accept and monitor — not reachable at ~6 coils per rod — but record that the budget is no longer independent of N.* ⚠ **Withdrawn as a `Q##` and re-homed as `OI-135`**; read that entry, and note this row said **26** until 26 Aug 2026 |
| **`OI-132`** | Master spec §11 · Owner: **IT / DBA** | ⚠ **`OI-114` and the procedure's `D9` both state something false.** Both assert *"all five hard-code `skid_coil_seq_no = 1`"*. **One of the four writers they name writes `NULL`** (`ConveyorInterface_PrepareDataForCreateSkid.sql:213`) and **two more clear it to `NULL`**. The column is `int NULL` with **no uniqueness constraint**, and there is a live consumer ordering by it **in a write path** — `ConveyorInterface_MoveCutsBackToLiftTable.sql:312`. ✅ **`[S]` sidesteps it** by setting the value from `@skidAssignment` (§1.9a), but the register entry is still wrong and should be corrected |
| **`G53`** | Gaps register · **`High`** · Owner: **BA / Development** · Phase 9 | **The multi-part alpha has no specified rendering on DB7, the coil label, the skid label or the welding-wire certificate.** `OutputCoilCompletion.md` §4 shows *"Source rod alphas — every rod in the traceability chain"*; it does not say what identifier is printed for each. Blocks Phase 9's label work, not the schema |
| **`ORD018`–`ORD022`** | Validation rules, `[REQ §5.28]` | **I1–I4 and I6** of §2.2. ⚠ **Five, not four** — `I6` (`SourceSegmentAlpha` references a real segment of the same rod) was added on review; no FK can enforce it, so a rule and a test are the only guard |
| **`FR-561`–`FR-566`** | Requirements, new `[REQ §5.30]` | §4 wave `S3` |
| **`TC-784`–`TC-794`** | Test cases | §4 wave `S6` — **eleven**: `TC-792`/`TC-793` cover the cutover, `TC-794` covers `I6` |
| **`FW-231`** | Backlog story | *Multi-alpha coil identity + generator cutover — mint, persist, render.* Additive to the 3,186 h baseline, on the `FW-219` precedent (`G44`) |

**Superseded or amended in place, never deleted** — the register's own rule is that a decided item
keeps its full decision text:

| | |
|---|---|
| **`Q57`** | ✅ **STANDS UNCHANGED — the supersession is withdrawn.** An earlier revision superseded its *mechanism* (`CommonDB` → `PlanningDB`) while keeping its conclusion. With `[G]` cancelled there is nothing to supersede: *"one namespace, minted through `CommonDB.dbo.GenerateCoilAlpha`"* is correct as written. **Do not annotate the decided register** — record the considered-and-rejected cutover here instead |
| **`Q56`** | The scrap path shares **CommonDB's** sweep. Still true of *that* path; **no longer true of flat wire.** Cross-reference `OI-129` |
| **`Q59`** | Widened twice — to coil parts (`OI-128`) and to the disjoint-sweep case (`OI-129`) |
| **`OI-113`** | **Narrowed, not closed.** The client answered its open question, but under `R1` the shared tree still holds one parent, so the two records still disagree by design |
| ⛔ **`OI-125`** | **No change needed.** An earlier revision made its `proddb..coils`-is-a-synonym finding *"load-bearing for a second reason — it is what makes `P1` pass"*. `P1` is cancelled with `[G]`, so the finding reverts to what it always was: a **resolved** item recording that CommonDB's sweep sees flat wire's own writes |
| **`Q45`** / **`OQ-M`** | Unwind direction now also decides *how many* alphas each coil has |
| **`FR-509`**, **`FR-512`** | Amended in place, superseded text retained |

---

## 4. The waves

**Ten live waves.** ⛔ **`S0` and `S9` are cancelled with `[G]`** (§1.5) — `S0` existed to gate the
PlanningDB cutover and `S9` to add it as a seventh database. `S1`→**`S1a`**→`S2`→`S3` are ordered;
`S4`–`S7` and `S5a` may run in parallel once `S3` lands; **`S8` is last and must be.** Each wave is tagged **[C]** cardinality, **[R]** rename, **[H]** host, **[S]** shared. ⛔ **No live wave carries `[G]`** —
it is cancelled, and `S0`/`S9` went with it.

### Wave status

⚠ **Tracked here because the precedent this ledger names failed exactly this way.**
[`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md)'s header read *"Planned, not
executed"* for three days while its work had been applied — two documents in one folder disagreeing
about whether the same work had happened. **Three interleaved changes across eleven waves will
reproduce that at greater scale unless state is recorded per wave.**

| Wave | Serves | Status |
|---|---|---|
| ~~`S0` pre-flight~~ | ~~`[G]`~~ | ⛔ **Cancelled** |
| `S1` registers | `[C][R][H][S]` | ✅ **Applied 26 Aug 2026** |
| `S1a` renames | `[R]` | 🔲 Not applied |
| `S2` design of record | `[C][R][H][S]` | ✅ **Applied 26 Aug 2026** |
| `S3` requirements | `[C][S]` | ✅ **Applied 26 Aug 2026** |
| `S4` schema | `[C][R][S]` | 🟡 **`[C][S]` half applied 26 Aug 2026**; `[R]` half awaits `S1a` |
| `S5` service / API / screens | `[C][R][S][N]` | 🟡 **Procedure, `FW-219` and `OutputCoilCompletion.md` applied 26 Aug 2026.** ⛔ **Still not applied: `APIs.md` and `Services.md` — both dirty in the working tree.** `OutputCoilCompletion.md` → **v1.6**, with §4.1 and §8.3 flagged for client **re-signing** and the label-rendering question raised in its §10 |
| `S5a` procedure relocation | `[H]` | ✅ **Applied 26 Aug 2026** — 51 refs qualified (38 `united_db` / 13 `CommonDB`, 13 left local), 5 files renamed, grants + `:r` chain + manifest + `V4` + `[INT]`/`[ARC]` updated |
| `S6` tests | `[C][R][S]` | 🟡 **`[C][S]` half applied 26 Aug 2026**; `[R]` half awaits `S1a` |
| `S7` client deliverables | `[C][S]` | ✅ **Applied 26 Aug 2026** |
| ~~`S9` co-location sweep~~ | ~~`[G]`~~ | ⛔ **Cancelled** |
| `S10` alpha mechanism | **`[A]`** | ✅ **Applied 26 Aug 2026** — 7 files; ⚠ **applied OUT OF BAND first and that cost a site** (see the wave) |
| `N1` registers | **`[N]`** | ✅ **Applied 26 Aug 2026** — `OI-137`/`OI-138`/`OI-139` minted, `G54` minted, `Q88` narrowed, `Q89` amended, `OI-135` restated as tiered, `OI-136` resolved |
| `N2` design of record | **`[N]`** | ✅ **Applied 26 Aug 2026** — §1.2 rows (b)/(c), §2.1's `ChildAlpha`, `SourceSegmentAlpha` **elevated to load-bearing**, §1.9 gains the segment-rooted mint and the **never-re-mint** rule, `I3`'s reason restated, `S10`'s conclusion superseded, `TC-795`→`TC-792`, both mirror docs |
| `N3` requirements | **`[N]`** | 🔲 Not applied — ⚠ **with `N6`**; blocked on `OI-139` |
| `N4` schema comments | **`[N]`** | ✅ **Applied 26 Aug 2026** — `FlatWire_DDL_03_Materials.sql` and `_05_QualityOutput.sql` `ChildAlpha` comments. **Comments only; baseline unmoved at 33 · 55 · 70 · 1 · 1** |
| `N5` procedure + `S5`'s `[S]` half | **`[N]``[S]`** | ✅ **Applied 26 Aug 2026 in ONE pass** — `50_…CompleteCoilOnSkid.sql` **1,176 → 1,473 lines**. Scalar → set: a `@parts` table read from local `CoilTraceability`, per-part segment-rooted mints, three per-part write loops, the two skid guards withdrawn, `skid_coil_seq_no` from `@skidAssignment`, `@logSeqNo` incremented, `coil_break` and `coil_planned_wgt` fixed. Structurally verified: 21/21 `BEGIN`/`END`, 247/247 parens, 4/4 cursors balanced |
| `N6` tests | **`[N]`** | 🔲 Not applied — ⚠ **with `N3`** |
| `N7` client deliverables | **`[N]`** | ✅ **Applied 26 Aug 2026** — `_WorkedExamples.md` §4/§7 and `AllocationExamplesContent.md`; `.xlsx` regenerated, all four leakage guards clean. ✅ **The `.html` needed NO edit** — it names only *segment* alphas, which `[N]` does not change |
| `N8` the build item `FW-231` | **`[N]`** | ✅ **Applied 26 Aug 2026** — `FW-231` minted (18 h, S2/phase-08), **`FW-230` amended** (its ignore-list criterion withdrawn), additive effort sheet **`[CE §3g]`** *(not §3d — §3d–§3f were taken)*, `phase-08` gains the shared write, `[INT §8.0a]` corrected from *"no shared table is written"* |
| `S8` / `N9` counts / changelog | `[C][R][H][S][A][N]` | 🔲 Not applied — **last** |

**`S8` reconciles this table against the header `Status:` line** and fails if they disagree. Mark each
wave `✅ Applied <date>` as it lands, in the same commit as the wave.

⚠ **`S1a` is placed where it is on purpose.** The rename must precede every wave that writes the
table's name — otherwise `S4` creates `UX_CoilTraceability_ChildAlpha` and `S1a` immediately renames
it, and `S2`/`S3` document a name that is about to change. **Rename first, then build on the new
name.**

### `S0` — ⛔ CANCELLED with `[G]`

**`P1`/`P2`/`P3` existed to prove PlanningDB's sweep, co-location and isolation before trusting it.**
With the cutover withdrawn none is needed: `P1` reduces to `OI-125`'s **already-resolved** finding that
`proddb..coils` is a synonym over `CommonDB..coils`, and `P2`/`P3` concerned a database flat wire does
not read. **No wave gates the others now** — `S1` is first.

### `S1` — Registers **[C][R][H][S]** ✅ **APPLIED 26 Aug 2026**

> ✅ **All four targets were clean in the working tree, so this wave carries none of the collision risk
> that blocks `S1a`.** Applied: `Q88`/`Q89` → decided register (30 → 32, window to Aug 26) · `Q91`–`Q93`
> minted and `Q45`/`Q59` amended in the open register (57 → 60) · **`OI-113` closed**, `OI-130` and
> `OI-132` minted in master-spec §11 · `G53` minted and `G44` annotated · four `CHANGELOG.md` rows.
> ⛔ **`OI-128`, `OI-129`, `OI-131` and `Q90` deliberately not minted.** Verified: zero malformed table
> rows introduced in any of the four files.

| Target | Change |
|---|---|
[`Analysis/FlatWireOpenQuestions.md`](../Analysis/FlatWireOpenQuestions.md) | Mint **`Q91`**, **`Q92`**, **`Q93`** in §A16 — ⚠ **three, not five.** `Q88` and `Q89` are **decided** and belong in the other file; **`Q90` is withdrawn** with `[G]`. ⚠ **All five register fields are required**, not just `Recommendation:` and `Why:` — the format is **Q## · Priority · Owner: … · Open · Scope = …** and all 57 existing entries carry all five. §3 now assigns priority, owner and scope for each; do not invent them. Amend **`Q45`** and **`Q59`** |
[`Analysis/FlatWireDecidedQuestions.md`](../Analysis/FlatWireDecidedQuestions.md) | **Land BOTH `Q88` and `Q89` here as decided.** `Q88` — two alphas *per se*, the client's derivational form not adopted, single-source rule stated. `Q89` — **every part alpha reaches `proddb..coils`** (`[S]`), closing `OI-113` and `OI-128`. ⛔ **`Q57` needs NO supersession and `Q56` no annotation** — both were `[G]` work, withdrawn (§1.5) |
[`LatestDocument/FlatWire_MasterSpecification.md`](FlatWire_MasterSpecification.md) §11 | **Mint exactly two: `OI-130`** *(PlanningDB's wrong-column predicates — a finding for IT/DBA, not flat wire's exposure)* and **`OI-132`** *(`OI-114` and `D9` state something false about the legacy writers)*. ✅ **CLOSE `OI-113`** — each part alpha is its own child with its own parent under `[S]`. ✅ **CLOSE `OI-128`** — every alpha is now swept. ⛔ **Do NOT mint `OI-129` or `OI-131`** (withdrawn with `[G]`). ⛔ **`OI-125` needs no change** — its `P1` role died with `[G]` |
[`MVP-1/ProjectPlan/Development/GapsRegister.md`](../MVP-1/ProjectPlan/Development/GapsRegister.md) | Mint **`G53`** (multi-part alpha rendering, Phase 9). Add a line to **`G44`** noting that the **cardinality change, the rename and `[S]`'s reopening of the shared write-back** all land inside its scope. ⛔ **No generator-cutover mention** — cancelled |

### `S1a` — The renames **[R]** *(after `S1`, before everything else; §1.7)* — **23 tables**

⚠ **One pass per table, table and its dependent objects together.** Splitting a table from its
constraints leaves a constraint claiming a parent that no longer exists under that name.

| Target | Change |
|---|---|
| **Decide the constraint rule FIRST** | §1.7b(5) — recommended: prefix **once**, after the kind token, referenced half bare → `FK_FlatWire_CoilTraceability_CoilOutput`. **Every one of the 292 objects follows whatever is decided here**, so decide before the first edit, not during |
| **DDL — 23 tables, 292 dependent objects** | `01_Lookup` (⚠ **`PayoffPosition` IS renamed** — this file is no longer references-only) · `03_Materials` (5 tables, incl. `FlatWireRun`) · `04_Runs` (11) · `05_QualityOutput` (6) · `06_ForeignKeys` (**50 of 55 FKs**, fourteen of them pointing at `FlatWire_Run`) · `07_Indexes` (53 `IX_` + 10 `UX_`) · `08_Programmability` (**`trg_…_NoOverlap`** — the `DROP` guard *and* the `CREATE TRIGGER … ON` target, plus `sp_GetGaugeTrace`'s body, which reads `RunReading`) · `09_Programmability_MVP2` (`sp_ShiftSummary`'s body) · all five `FlatWire_SampleData_*.sql` |
| ✅ **`PayoffPosition` — TABLE ONLY, never the column** *(confirmed directive, 26 Aug 2026)* | §1.7b(2), which carries the counted checklist: **10 table references to rename, 15 column references to leave**, and of the 22 dependent-object names **exactly six** have their `PayoffPos*` segment rewritten — the six owned by the lookup itself. ⚠ **Outside the DDL, treat every occurrence as the column** unless it is plainly a table in a schema listing, an ER diagram or a `[DBD §6.2]` group table: in the pre-check-in specs `PayoffPosition` almost always means the column, and a wrong edit there **fails silently** |
| ⚠ **`FlatWireRunRepository` is a C# class, not a table** | §1.7b(1). The one-substitution trick (`FlatWireRun` → `FlatWire_Run` also fixes `FlatWireRunDetail`) **also corrupts this identifier.** Exclude it by name in [`FW-141-Repository-Layer.md`](../MVP-1/ProjectPlan/Backend/TaskBreakdownPlans/FW-141-Repository-Layer.md) |
| **`Database/Scripts/`** | `30_…_sp_IngestRodFromCoils.sql` (writes `Rod` — **not renamed** — but reads renamed tables) · `40_…_CheckInRod.sql` · `50_…_CompleteCoilOnSkid.sql`. ⚠ **Do not rename the procedures themselves** — `FlatWire_CheckInRod` and friends already own that prefix (§1.7b(2)) |
| **Docs `verify_schema_counts.py` `C2` requires** | For **all 23** new names: the script header, a `Schema/FlatWireSchema_*.md`, `phase-01c`'s group table, **and `[DBD §7]`'s ER diagrams**. **Four places × 23 tables, or the build gate fails** — and the count check will *not* catch a half-done rename |
| **`[DBD §6.2a]`** | ⚠ **Write the convention down, including the exception** (§1.7a). **`PayoffPosition` is prefixed while the other six lookups are not**, so there is no longer a rule that can be stated without naming it. Left unwritten, the 10 exclusions read as oversights. This is the section created for `Q60` and where the rule belongs |
| ⚠ **Files the target list missed entirely** | **`Operations/Rollback.md`** — **7 executable reconciliation queries** naming 5 renamed tables (`M1` `FlatWireRun`, `M2` `RodCheckin`, `M4` `RodStaging` **with the `PayoffPosition` column in its select list**, `M5`/`M6` `CoilOutput`, `M7` `RodCheckout`); the file appears **nowhere** in this ledger and its queries are copy-pasted during a failed deploy · **`Operations/Monitoring.md`** (a `RunReading` growth-rate **alert definition**) · **`Testing/NFRVerification.md`** · **`Testing/TestStrategy.md:168–171`** (a fixture→table map naming **15 of the 23** — a good half-done-rename detector if updated) · **`Architecture/MachineSimulator.md`** (`CK_FlatWireRun_Status`), **`PLCCommunication.md`**, **`SignalR.md`** · **`Analysis/FlatWireShopfloorDashboards.md`** (15 occurrences — ⚠ **6 real against 8 markdown-link false positives in one file**), **`FlatWireProcessWalkthrough.md`** (7), **`FlatWireEndToEndProcess.md`** (1), **`FlatWirePlan.md`** (1 — its clearance in §5 was `CoilNo`-scoped only) · **`Development/StaffedSprintPlans.md`**, **`Tools/DevelopmentPlanContent.md`**, **`Tools/TrialRunContent.md`** |
| ⚠ **25 of 28 `FW-*.md` plans unnamed** | The ledger names `FW-219`, `FW-220`, `FW-141`. **`FW-207-Domain-Model.md` carries 19 of the 23 names** and **`FW-142-Dapper-EF-And-FlatWireDbContext.md` 12** — neither mentioned. Also `FW-080`, `FW-138`–`FW-140`, `FW-143`, `FW-147`, `FW-149`, `FW-150`, `FW-157`, `FW-164`, `FW-168`, `FW-170`, `FW-172`, `FW-174`, `FW-177`, `FW-179`, `FW-205`, `FW-208`, `FW-223`, `FW-N04`, `FW-N05`, `Orchestration.md`, `TrialOrchestration.md`. ✅ **`GenerateCoilAlpha` appears in only `FW-219`, so `[G]` is fully covered** |
| **The remaining ~120 files** | Mechanical. ⚠ **Use the guarded patterns in §1.7b, not a bare `sed`.** Four distinct hazards: five names are also **document filenames** (`RodOrderAllocation` alone is 182 document references against ~101 table references, and `SPCCheckpoint.md` differs only in case); `PayoffPosition` is also a **column**; `FlatWireRunRepository` is a **class**; and `FlatWire_` already prefixes four `united_db` **procedures** that must not change. **Never rename a file.** Exclusions: `CHANGELOG.md` keeps its original text by design; `BaseDocuments/` client `.docx`/`.xlsx` are read-only evidence |
| ⚠ **The guards that STOP GUARDING — do these or the gates certify falsely** | **Three leakage guards hardcode the 23 bare names**, and two prefix them with ``: `build_allocation_examples_xlsx.py:82`, `build_development_plan_xlsx.py:484`, `build_questions_xlsx.py:314`. ⚠ **In `FlatWire_CoilTraceability` the character before `CoilTraceability` is `_`, a word character — so `CoilTraceability` no longer matches and the guard reports "clean".** `FlatWire_Run` / `FlatWire_RunDetail` escape **all three**. §7 gates on these guards passing; post-rename they **cannot fail**. `Tools/README.md` already states the rule: *"a guard that cannot fail is worse than no guard, because it certifies."* **Extend all three regexes to the prefixed forms** |
| ⚠ **`verify_schema_counts.py` HARD-FAILS on two unlisted seed files** | `C3` reads `NO SEED: (\w+)` markers and `C5` reads `C5-OK: <table>.<col>`, both compared against DDL-derived names. The markers are pre-rename: **`FlatWire_SampleData_Lookup.sql:151`** (`NO SEED: PayoffPosition`) and **`FlatWire_SampleData_Runs.sql:255`** (`C5-OK: RodOrderConsumption.RodCheckoutId`). Neither file is in the target list — only `_QualityOutput.sql` is. **§7's "verify_schema_counts.py passes" is unsatisfiable as this ledger stood** |
| ⚠ **`C2` enforces a FIFTH documentation target** | §1.7d and §7 name four. The script also requires every table in **`FlatWireSchema_Mapping.md`'s Table Inventory** — **22 pre-rename rows, 76 occurrences, not in the target list.** Two more schema docs are missed: **`FlatWireSchema_Runs.md` (95 occurrences — the largest of the six)** and **`FlatWireSchema_Lookup.md` (9, the `PayoffPosition` group)** |
| **Teardown** | ⚠ **Needs nothing.** `FlatWire_DDL_99_Teardown.sql` drops the whole database rather than enumerating tables — verified, 24 lines |
| **`sp_rename`** | ⚠ **Not used, and do not add it.** §1.7d — teardown-and-rebuild is already the deploy path |

### `S2` — The design of record **[C][R][H][S]** ✅ **APPLIED 26 Aug 2026**

> ✅ **All three targets were clean.** Applied to `RodOrderAllocation.md`: §2.5 *What FL2 creates*
> rewritten *(two identities + N part alphas; the `D6` precedent narrowed to the **spool** hop)* ·
> §2.4's counters callout **three → four**, with the single-source rule and the `R00004AA`
> evidence-not-defect note · §2.8 Scenario B's FL2 table showing **two part alphas with both calls and
> no hard-coded letter**, plus the weight-split double-count warning and the `OI-113` close condition ·
> Scenario A gains its bounding line *(14 of 23 spools are single-rod)* · **five `F`-findings annotated**
> — `F3` stays a warning, `F10`'s caveat **stands** and FL1's batch loop is owed, `F11` understated,
> `F4` no longer independent of N, `F12` unchanged · the object map flagged as read from the **older**
> `ual-database` copy · `OQ-Q`/`OQ-R` marked decided. `_WorkedExamples.md` §1.4/§2/§7 updated;
> `_DesignPlan.md` carries a superseding pointer, not a rewrite. Verified: **zero malformed table rows
> introduced** in any of the three.

| Target | Change |
|---|---|
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.5** *What FL2 creates* **[C][S]** | ⚠ **The largest single edit — one rewrite, not two.** *(An earlier revision listed this section twice, once for `[C]` and once for `[S]`.)* The three-count rejection of the compound string is **half right: rewrite, do not annotate** — the string stays a rendering, but N alphas exist behind it. Replace the two-identities table with **two identities + N part alphas**, and state that **every part alpha now reaches `proddb..coils`** (`[S]`). `Primary rod` becomes `lead part`; *"the rod of the first segment consumed"* stays true. ⛔ **The `D6` precedent it cites — *"the shared schema takes one; the local table keeps all"* — no longer describes the COIL hop.** It still describes the **spool** hop (`OI-115`'s lead-alpha narrowing), so **narrow that sentence, do not delete it** |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.5** *Two identities, one of them renamed* | The `Before/After` table gains a **third** row for `FlatWire_CoilTraceability.ChildAlpha`. `D5` **still stands** and `OQ-N` **stays decided** — say so explicitly, because a reader will assume otherwise |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.4** | The three-letter-counters callout gains a **fourth** counter — the coil part. And the *"unified namespace reproduces the client's own column"* claim must be **narrowed to segments** (§1.2) |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.8 Scenario B** | Rewrite the FL2 table: coil 2 gets **two** alphas. Show both calls with their ignore lists. **Do not hard-code the second letter** — derive it (§1.2). Coil 1 and every unwelded coil are unchanged |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.8 Scenario A** | **No change to the trace.** Add one line: single-parent coils are unaffected. This is worth saying — it is what bounds the change |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§9.1** | ⚠ **Substantial rewrite — five findings change status.** ⛔ **`F3` STAYS a warning; it does NOT become the design**, because `[G]` is cancelled (§1.5) — record that a cutover was considered and rejected, and why. Its claim is verified exactly right, and it missed two things: the two functions name *different* `coils` objects, and PlanningDB carries two wrong-column predicates. ⛔ **`F10`'s *"do not call it"* caveat STANDS** — an earlier revision said it *"evaporates"*, which was `[G]`-era and is now wrong: `GetCoilAlpha` remains uncallable, so **FL1's batch loop is owed**. Add the truncation bound to it (`GetCoilAlpha`'s 2048→500 pre-seed, which also means **`F11` is understated**). `F4`'s suffix budget is now shared **four** ways and is **no longer independent of N** (`Q93`). ⛔ **`F12`/`OQ-P` gains NEITHER surface** — the coil-part surface **closes** with `OI-128` under `[S]`, and the disjoint-sweep surface died with `[G]`; it stands unchanged. The object map's *"only the first is named anywhere in the flat wire artifacts"* becomes **false**. ⚠ **And the object map is itself stale:** its line counts (199/196) and *"function, 1 line"* wrapper rows describe the **older** `ual-database` copy — the `Second-Branch` copy has **190/187** and replaced the three pass-through *functions* with **synonyms**, so `SlitterDB`'s *"two hops"* and the `SET QUOTED_IDENTIFIER OFF` note no longer describe it. **Say which copy the map is read from** |
[`RodOrderAllocation.md`](RodOrderAllocation.md) **§2.4 consequences**, **§10** | ⛔ **No generator swap** — the `ChildAlpha` comment block and the five-consequences table keep `CommonDB.dbo.GenerateCoilAlpha`, and consequence 3's LocalDB warning is unchanged. New local `OQ-Q`/`OQ-R` → `Q88` (decided) / `Q89`. ⚠ **`F10`'s caveat must be RESTATED, not removed** — `GetCoilAlpha` stays uncallable, so FL1's batch loop is owed (§1.5) |
[`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) **§1.4, §2, §7** | §1.4's `CoilNo` row gains the part-alpha row; §2's *"a weld does not mint a child alpha"* is **still true and now easy to misread** — it means the `-A` mid-run suffix, so tighten it; §7's FL2 table gets both alphas, **recomputed across the whole 40,000 lb run**, not copied from §2.8 |
[`RodOrderAllocation_DesignPlan.md`](RodOrderAllocation_DesignPlan.md) | **Note only, no rewrite.** It is the historical plan; add a superseding pointer at its line 677 table |

### `S3` — Requirements **[C][S]** ✅ **APPLIED 26 Aug 2026** *(unblocks `S4`–`S7`)*

> ✅ **`BusinessRequirements.md`:** new **§5.30** with `FR-561`–`FR-570` and `FR-561a`–`e` *(15 rules,
> all `[PROPOSED]`)* · ⛔ **`FR-512` DELETED** with its superseded text retained and its mid-run-break
> half explicitly **not** deleted · `FR-509`/`510`/`511`/`513`/`514`/`516`/`518` amended per-record ·
> `ORD018`–`ORD024` written as `FR-561a`–`e` plus `FR-567`/`FR-569` · **`FR-335`, `FR-339`, `FR-515`
> counting basis moved to physical coils and flagged for client re-sign-off** · coverage matrix row and
> total **380 → 395**. **Master spec:** FR block table, the `CoilNo` row amended to *lead part*, the
> `coil_gen_history` row marked **`OI-113` closed**, and **three new data-dictionary rows**
> (`ChildAlpha`, `SourceSegmentAlpha`, `SharedWrittenAt`). Verified: **zero malformed rows introduced**
> in either file.
>
> ⚠ **Two things `S3` deliberately did NOT do.** `FR-563` (label and certificate rendering) is written
> but **cannot be built until `Q87` is answered** — it was deferred on the 24 Aug call. And the
> `[CONFIRMED]` amendments carry a re-sign-off flag rather than a silent edit.

| Target | Change |
|---|---|
[`Business/BusinessRequirements.md`](../MVP-1/ProjectPlan/Business/BusinessRequirements.md) | **New §5.30 — `FR-561`–`FR-570`**, all `[PROPOSED]`, client-directed. **561** one alpha per source rod, minted through the existing generator rooted on **that** rod · ⚠ **562 EVERY part alpha is written to the shared coil master** *(an earlier revision of this wave said "the lead is the only part written" — that was the rejected `R1` reading and is **wrong** under `Q89`)*; the lead is retained as the coil's one scalar shared face · **563** the label and certificate render every part in unwind order, hyphen-joined; nothing compound is stored · **564** the ignore list is every `FlatWireDB`-local alpha for that rod, both tables · **565** a part alpha is opaque and never parsed · **566** an unwelded coil has exactly one part alpha, equal to its shared identity · **567** part weights are **split** and sum to the coil's net weight · **568** each part's genealogy names **its own** source rod · **569** the retry contract is the **set** of alphas already written · **570** the two-per-skid rule counts **physical** coils, not shared records |
| same, **§5.28** | **`ORD018`–`ORD024`** = **I1–I4, I6, I7, I8** — seven rules, not four. `ORD022` = `I6` (`SourceSegmentAlpha` resolves), `ORD023` = `I7` (part weights sum to the coil's), `ORD024` = `I8` (`SharedWrittenAt` non-NULL on a completed coil). ⛔ **`I5` gets no rule** — it is a *regression guard*, tested by `TC-785`, not an invariant to enforce |
| same, **§5.25** ⚠ **[S] reopens this whole block** | ⛔ **`FR-512` is DELETED**, not reworded — its *"the shared genealogy shall record the **primary** rod"* clause exists solely to collapse N→1, and `[S]` removes the reason for it. **`FR-509`, `FR-510`, `FR-511`, `FR-513`, `FR-514`, `FR-516` re-specified per-record** — all are singular today (*"a shared coil identity"*, *"a finished-goods coil row"*, *"with one cut"*). ⚠ **`FR-518` collides textually**: *"a retry … shall not create a second coil"* is exactly what `[S]` does by design — rewrite it around the `SharedWrittenAt` contract (§1.9b) |
| same, **`FR-335` / `FR-339` / `FR-515`** ⚠ **[S] · client sign-off** | Re-specified in terms of **physical** coils. ⚠ **`FR-335` is `[CONFIRMED]`** with source `PKG003` — **flag for client re-sign-off, do not silently amend** |
| same, **coverage matrix** | New §5.30 row; `FR-561`–`FR-570` → `TC-784`–`TC-799` → `FW-231` |
[`FlatWire_MasterSpecification.md`](FlatWire_MasterSpecification.md) | Mirror §5.30 in the FR block table (line ~513); update the `CoilNo` data-dictionary row (line ~1893) to say *lead part*; update the `coil_gen_history` shared-write row (line ~2085); add `FlatWire_CoilTraceability.ChildAlpha` / `SourceSegmentAlpha` to the data dictionary |

### `S4` — Schema **[C][R][S]** 🟡 **`[C][S]` HALF APPLIED 26 Aug 2026**

> ⚠ **Deliberate deviation from this ledger's own sequencing, stated rather than hidden.** §4 says
> `S1a` must precede any wave that writes a table name, *"otherwise `S4` creates
> `UX_CoilTraceability_ChildAlpha` and `S1a` immediately renames it."* **`S1a` is blocked
> indefinitely** on the 21 dirty files it edits, and "immediately" is therefore not happening. The
> `[C]`/`[S]` schema work was applied using **pre-rename** names — which is what keeps the DDL
> internally consistent with the other 33 tables and with `TestCases.md` — and `S1a` will sweep all of
> it in one pass. **The alternative was to leave a verified, additive schema change unbuilt on account
> of a rename that cannot start.**
>
> ✅ **Applied:** three guarded `ALTER … ADD` columns on `CoilTraceability` — `ChildAlpha`,
> `SourceSegmentAlpha`, `SharedWrittenAt` — each carrying its rationale in comment · one filtered
> unique index, **69 → 70 index statements** · seed updated so the **already-multi-rod fixture**
> `FW-00421-C01` exercises N identities, with part weights **144.90 + 144.90 summing exactly to its
> 289.80 net** and `CoilNo` populated so `I2`/`TC-787` finally has a fixture · schema doc columns and
> three *cannot-be-enforced-here* constraint notes · `[DBD §6.2]` baseline **33 · 55 · 70 · 1 · 1** and
> the unique-index list **eleven → twelve** · the external-reference list gains both new columns with
> their reasons.
>
> ✅ **`verify_schema_counts.py` passes all five checks** — C1 counts, C2 coverage across six schema
> documents plus `phase-01c` plus `[DBD §7]` plus `Mapping.md`, C3 seed coverage, C4 reachability,
> C5 seed FK ordering (0 findings). ⛔ **`phase-01c` needed nothing:** no table was added, and its
> count lines are **dated verification records**, not live assertions — audit trail, left alone.

| Target | Change |
|---|---|
[`FlatWire_DDL_05_QualityOutput.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_05_QualityOutput.sql) | The two guarded `ALTER TABLE … ADD` blocks of §2.1, in the file's existing `IF NOT EXISTS (… sys.columns …)` idiom. **Also finish `G-1`**: the `FlatWire_CoilTraceability` header's rationale is already corrected for spools; extend it to say the rows are now **identity-bearing**, not only range-bearing |
| ⚠ **[S]** `FlatWire_DDL_05_QualityOutput.sql` | A **third** guarded `ALTER TABLE … ADD` — `SharedWrittenAt DATETIMEOFFSET NULL` (§1.9b). ⛔ **No index** — published counts do not move |
[`FlatWire_DDL_07_Indexes.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_07_Indexes.sql) | `UX_FlatWire_CoilTraceability_ChildAlpha`, filtered, beside `UX_FlatWire_CoilOutput_CoilNo` — ⚠ **both under their post-`S1a` names**, since `S1a` runs first |
[`FlatWire_DDL_03_Materials.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_03_Materials.sql) **[G]** | ⚠ **The FL1 hop is ALREADY BUILT and names the old generator twice** — the `FlatWire_SpoolTraceability` header (~line 228) and the `ChildAlpha` comment block (~line 459) both say `CommonDB.dbo.GenerateCoilAlpha`. Swap both, and update the `Q59` *limit-of-the-guarantee* note for the disjoint-sweep case. **This is the row most likely to be missed**, because the cardinality change does not touch this file at all |
[`FlatWire_SampleData_QualityOutput.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_SampleData_QualityOutput.sql) | ⚠ **The fixture already exercises the case** — `FW-00421-C01` has two parents, `R00041` and `R00042`. Seed a `ChildAlpha` on all three rows and set `FlatWire_CoilOutput.CoilNo` on that coil to the lead's, so **I2 has a fixture to be tested against**; it is `NULL` on both seeded coils today. Respect `verify_schema_counts.py` C3/C5 |
[`Schema/FlatWireSchema_QualityOutput.md`](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_QualityOutput.md) | Two column rows; amend the `CoilNo` row to *lead part*; generator swap; extend the `SpoolCoilMapping`-rejected note so nobody re-proposes a junction table on the strength of this change |
[`Schema/FlatWireSchema_Materials.md`](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Materials.md) **[G]** | Generator swap in its `FlatWire_SpoolTraceability.ChildAlpha` description |
[`Database/DatabaseDesign.md`](../MVP-1/ProjectPlan/Database/DatabaseDesign.md) | **§6.2** counts (§2.4) · the unique-index list **11 → 12** · the index-rationale table · **§7** ER text · the *documented external references* list gains `SourceSegmentAlpha` **with its reason** (filtered parent index, not a design choice) |
[`Phases/phase-01c-database-foundation.md`](../MVP-1/ProjectPlan/Development/Phases/phase-01c-database-foundation.md) | Group table + acceptance criteria — **defer to `[DBD §6.2]`**, do not restate figures. This file has asserted counts that would reject a correct deployment twice before |

### `S5` — Service, API and screens **[C][R][S]** *(after `S3`)* ⛔ *(was "and the generator cutover" — withdrawn with `[G]`)*

| Target | Change |
|---|---|
[`Backend/APIs.md`](../MVP-1/ProjectPlan/Backend/APIs.md) §4.15 | `POST /coil/complete` — each traceability element in the request/response gains `childAlpha`. ⚠ **Re-check the worked example's footage arithmetic when editing**; it lost a foot once already (half-open `[From, To)`, `TC-617`). Line ~1261's *"`CoilNo` is not added to the response"* needs a decision: the part alphas **are** customer-facing through the certificate, so they should surface — unlike `CoilNo` |
[`Backend/Services.md`](../MVP-1/ProjectPlan/Backend/Services.md) | `CoilCompletionService` — the mint becomes a **loop over distinct source rods** with a shared ignore-list accumulator, then lead resolution, then one `FlatWire_CompleteCoilOnSkid` call with the lead. Replicate §2.4's two guards per mint (`THROW 51010` blank return, `UPDLOCK, HOLDLOCK` re-check → `51011`) |
[`Architecture/Integration.md`](../MVP-1/ProjectPlan/Architecture/Integration.md) | ⚠ **§8.0a — a narrower edit than an earlier revision claimed** ⛔ *(it said "SECTION REWRITE" for the generator change; withdrawn with `[G]`)*. The generator, its object set and its `Q59` clause are **unchanged**. What `[H]` changes is the **procedure home**, so §8.0a's cross-database-caller framing and LocalDB warning describe a `FlatWireDB`-hosted procedure. ⚠ **State that the transaction model is unchanged.** *(Superseded text:* — the whole section is *about* the generator. Its object-set callout (*"twelve objects across four databases — `united_db`, `SlitterDB`, `wiplogdb` and, through a synonym, `CommonDB..coils`"*) must be re-derived for PlanningDB's **different** set, which adds `proddb` and `PlanningDB` and drops the `united_db` snake_case mirrors; its LocalDB warning gains `PlanningDB`; its `Q59` clause gains the disjoint-sweep case. **Also correct a live imprecision:** CommonDB's function reaches `coils` by a **bare local reference, not a synonym** — the synonym is `proddb..coils` → `CommonDB..coils`, a different hop, and exactly what `P1` tests. Then **§8.1**: the two-identity table (~line 234) becomes three, the *"one parent only — `OI-113`"* rows (~lines 101, 240) gain the client's answer, and ⚠ **say plainly that all eight shared writes are unchanged** — a reader will assume otherwise. The isolation note (~line 167) gains `PlanningDB` or records it **unmeasured** |
[`Scripts/50_…_CompleteCoilOnSkid.sql`](../MVP-1/ProjectPlan/Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql) **[H]** | ⚠ **Still an EXECUTABLE change — but for `[H]`, not `[G]`.** ⛔ **The three generator call sites do NOT change** — they stay `CommonDB.dbo.GenerateCoilAlpha`. What changes is the **host**: **16** references need database-qualifying — **12 to `united_db`, 4 to `CommonDB`** — and the file is renamed (§1.8a). ⛔ **NOT 55, and not all to `united_db`** (§1.8a, re-measured 26 Aug 2026). **Keep both guards** — `THROW 51010` on the blank return (the sentinel is `' '` in both functions, so it survives) and the `UPDLOCK, HOLDLOCK` re-check → `51011`, **which is now the authoritative uniqueness gate** (§1.5). ⛔ **`@primaryRodAlpha` and `@expectedCoilNo` do NOT keep their meaning** — that was the `R1` reading, and `Q89` decided `R2`; the `[S]` row below is authoritative for both. *(Superseded text: "Under `R1`, `@primaryRodAlpha` and `@expectedCoilNo` keep their meaning exactly.")* Extend the `D6` block: the caller now holds one alpha per parent locally, and `Q89` is where a change here would come from. *Also fix while in the file: the `"sixteen tables"` figure, wrong twice — it is 14 selects over 12 objects, and the object set changes with the new function anyway* |
| ⚠ **[S]** `Scripts/50_…_CompleteCoilOnSkid.sql` — **the largest single edit in this ledger** | The loop over `FlatWire_CoilTraceability` rows (**N single-row inserts, never a batch** — `C4`); **each alpha's own parent rod** (the `OI-113` close condition); `@expectedCoilNo` → **table-valued**; three scalar OUTPUTs → a **rowset**; per-alpha weight from `SegmentWeightLb`; `wip_skids` weights accumulated **once per physical coil**; the two skid guards withdrawn and `skid_coil_seq_no` set from `@skidAssignment` (§1.9a); **`@logSeqNo` incremented** instead of the second-spin; the `coil_break` UPDATE widened to all N; `coil_planned_wgt` **split** not copied. ⚠ **Same file as `[H]`'s 55 qualifications — one pass, not two** |
| ⛔ ~~`Scripts/20_FlatWire_Grants.sql`~~ **[G]** | **CANCELLED with `[G]`** — no seventh database, so no `PlanningDB` block. ⚠ **`[H]` still edits this file** for a different reason: the four `EXECUTE` grants move `united_db` → `FlatWireDB` (§1.8b) |
[`TaskBreakdownPlans/FW-219-…md`](../MVP-1/ProjectPlan/Backend/TaskBreakdownPlans/FW-219-FlatWire-CompleteCoilOnSkid.md) | ⛔ **Its `OI-113` paragraph is SUPERSEDED, not reinforced.** *"Do not resolve it by inserting several rows"* was written under `R1`; `Q89` decided `R2` and **inserting N rows is now the design**, one per source rod, each with its own parent. Rewrite the paragraph to say so and to record **why** — the per-child guard `WHERE child_coil_no = @ChildCoil` permits it, and the *"one child, many parents"* shape it actually forbade is not what `R2` does. **`OI-113` is CLOSED** (§1.3). *(Superseded instruction: "Record why the answer is `R1` (§1.3) so nobody re-litigates it from the client note alone" — the reverse of the decision.)* |
[`Business/Screens/OutputCoilCompletion.md`](../MVP-1/ProjectPlan/Business/Screens/OutputCoilCompletion.md) | Client-review specification — §4 traceability chain, the *Source rod alphas* label row, confirmed-decision `D6`, and a new open item for `G53`. **Bump the `**Version:**` header and stamp the same value on the `CHANGELOG.md` row** (this folder's thirteen specs have no in-file change-history block since 15 Aug 2026) |

### `S5a` — The procedure relocation **[H]** ✅ **APPLIED 26 Aug 2026**

> ✅ **Done:** 51 references qualified to their own homes · 5 files renamed `*_united_db_Proc_*` →
> `*_FlatWireDB_Proc_*` (via `git mv`) · all five `USE [united_db]` → `USE [FlatWireDB]` · headers
> restructured so `FlatWireDB` is the procedure home · 8 copy-paste-runnable smoke-test snippets
> repointed · `20_FlatWire_Grants.sql` notes corrected · `:r` chain and `README.md` manifest ·
> `Deployment.md` `V4` **3 → 7 rows, now a single-database query** · `[INT §8.0]`/`[INT §8.1]`/`[ARC §10]`
> all state the transaction model is **unchanged**.
>
> ⚠ **Three of this wave's own instructions were wrong and are corrected in §1.8a:** the count
> (**148 → 51**, the 148 counted header text), the rule (**not** all to `united_db` — 13 are `CommonDB`
> and 13 are the procedures being moved), and both "objects deserving naming" (`GenerateCoilAlpha` was
> already qualified; `WIPStations` had no unqualified reference and its deferred decision was already
> answered by `40_`'s own constraint `C1`).
>
> ⚠ **`99_…_Teardown.sql`'s rationale INVERTED** — it existed because the four procedures did *not* go
> with the database. Now they do. It is a no-op in the full teardown path and **still required** for the
> `[H]` abort path, which is the only way to drop the procedures while keeping the run data.

| Target | Change |
|---|---|
| ⚠ **Qualify **51** references — to their own homes, not all to `united_db`** | The core of `[H]`, **re-measured 26 Aug 2026: 64 code refs, 51 to qualify** — 25 in `40_`, 16 in `50_`, 3 in `60_`, 7 in `70_`, **0 in `99_`**. ⛔ **The old instruction — "every unqualified `dbo.X` becomes `united_db.dbo.X` — 55/55/10/20/8, 148 total" — was wrong twice:** the 148 counted `Target DBs` header text, and the blanket target would have got **26 of 64 wrong**. Split: **38 → `united_db`**, **13 → `CommonDB`**, **13 stay LOCAL**. ✅ **A miss throws `Invalid object name`; none of the 15 distinct names collides with any of the 33 tables** (§1.8a) |
| ⛔ **`Logging_Information_In_Table` → `CommonDB`, all 13** | The largest single group and **not** a `united_db` object: 5 in `40_`, 4 in `50_`, 1 in `60_`, 3 in `70_`. Qualifying it `united_db.` breaks **every logging call in all four procedures** |
| ⛔ **The four `FlatWire_*` procedures stay unqualified** | 13 refs — their cross-calls plus `99_`'s four `DROP PROCEDURE`s. They are the objects being **moved**; `dbo.` now means `FlatWireDB` and is correct. **Do not sweep these** |
| ✅ **`GenerateCoilAlpha` needs nothing** | Already `[CommonDB].[dbo].[GenerateCoilAlpha]` at `50_` line 469, and never unqualified. *(Superseded: "unqualified today, resolving through the `united_db` synonym".)* |
| ✅ **`WIPStations` — zero code refs here** | Header text only. **Deferred decision #2 does not arise in `S5a`.** It still stands for `10_CommonDB_Insert_WIPStations_FlatWire.sql`, the hand-run file `RunAll` skips |
| **Five file renames** | `40`–`70` and `99` → `*_FlatWireDB_Proc_*`, per the `30_FlatWireDB_Proc_sp_IngestRodFromCoils.sql` precedent. Each file's `Target DBs` header changes its *procedure home* clause |
| [`FlatWire_Scripts_RunAll.sql`](../MVP-1/ProjectPlan/Database/Scripts/FlatWire_Scripts_RunAll.sql) · [`Scripts/README.md`](../MVP-1/ProjectPlan/Database/Scripts/README.md) | The `:r` chain and the manifest. ⚠ The deliberate skip of `10_CommonDB_…` is unaffected |
| [`20_FlatWire_Grants.sql`](../MVP-1/ProjectPlan/Database/Scripts/20_FlatWire_Grants.sql) | `EXECUTE` grants move `united_db` → `FlatWireDB`. ⚠ **The cross-database read grants do NOT simplify** — ownership chaining does not cross databases (§1.8b) |
| [`Operations/Deployment.md`](../MVP-1/ProjectPlan/Operations/Deployment.md) | ✅ **`V4` simplifies** to a single-database `sys.objects` query. Re-derive its expected row count. *(This is the same `V4` that `[R]` must repoint at the renamed trigger — one edit, two changes)* |
| `[INT §8.0]`, `[INT §8.1]`, `[ARC §10]` | ⚠ **State that the transaction model is UNCHANGED** — same instance, local transaction manager, no MSDTC. A reader seeing the procedure move will assume otherwise |

### `S6` — Tests **[C][R][S]** *(after `S3`)*

| Target | Change |
|---|---|
[`Testing/TestCases.md`](../MVP-1/ProjectPlan/Testing/TestCases.md) | **`TC-784`** two-rod coil mints two alphas, one per rod · **`TC-785`** single-rod coil mints exactly one, equal to `CoilNo` (**I5** — the regression that matters most) · **`TC-786`** `LEFT(ChildAlpha,6) = LEFT(RodAlpha,6)` (**I3**) · **`TC-787`** `CoilNo` = lead row's `ChildAlpha` (**I2**) · **`TC-788`** no alpha collides across `FlatWire_SpoolTraceability` and `FlatWire_CoilTraceability` for one rod (**I4**) · **`TC-789`** the filtered unique index rejects a duplicate and admits multiple `NULL`s · **`TC-790`** the ignore list carries both tables · **`TC-791`** the rendered label is unwind-ordered and hyphen-joined, nothing compound stored · **`TC-794`** `SourceSegmentAlpha` resolves to a real segment of the same rod (**I6**) — **no FK can enforce it, so the test is the only guard**. ⛔ **`TC-792`/`TC-793` are cancelled with `[G]`** — they tested the new generator's sweep and blank guard. Update **§5.16**'s coverage row |
| ⚠ **[S]** new cases | ⚠ **`TC-792`**, not `TC-795`, for `SUM(SegmentWeightLb)` = `NetWeightLb` (**I7** — the double-count guard, most important new test). *This row predicted `TC-795` before the cases were numbered; they landed as `TC-792` = weight sum (`FR-567`) and `TC-795` = genealogy parentage (`FR-568`). `TestCases.md` is authoritative.* · **`TC-796`** N `coils` rows and N `coil_gen_history` rows **each with a different `parent_coil_no`** — the `OI-113` close condition; if they share one parent it has **not** closed · **`TC-797`** a retry passing k of N writes only N−k and reports all N · **`TC-798`** two **physical** coils still close one skid · **`TC-799`** `skid_coil_seq_no ∈ {1,2}` across all N rows |
| **[R]** ⚠ **34 test cases, not two** | An earlier revision named only `TC-192` and `TC-617` and read as exhaustive. **Measured: 34 distinct cases reference a renamed table or the coil identity, spanning `TC-030`→`TC-770`** — and **13 of those reference dependent-object names** (`CK_RodCheckout_ModeP`, `CK_RunPauseEvent_NotesOther`, `UX_RodStaging_Bay`, `trg_CoilTraceability_NoOverlap`, …), i.e. §1.7c's 292 objects. `TestCases.md` is in scope so the sweep reaches them; the *instruction* was wrong, not the target |
| **[R]** ⚠ **`TC-617` is in the WRONG FILE and the claim about it was false** | It lives in **`Testing/NFRVerification.md`**, not `TestCases.md` — and **it does not name the trigger**; the trigger sits beside it in `RodOrderAllocation_WorkedExamples.md`. **`NFRVerification.md` is not in the target list**, so the prescribed edit had no file to land in. It also holds `TC-601`, `TC-623` (*"`RunReading` retention and rollup"*) and — most relevant to `[C]` — **`TC-616`**, *"reconstruct the chain for a coil made from three rods across two welds"*, whose expected result should now assert per-rod **alphas**, not only footage |

### `S7` — Client deliverables **[C][S]** ✅ **APPLIED 26 Aug 2026**

> ✅ `AllocationExamplesContent.md`'s welded sheet now shows **two identities with the weight split**,
> in client language, with the `Order Handoff` spool-segment rows **untouched** as the wave warned.
> `ClientQuestionsContent.md`: **`Q88` and `Q89` authored in Part 2 — *Decisions to Confirm*, not
> Part 1**, because both are decided. `_WorkedExamples.html`'s caption says two identities; verified
> self-contained, `div`s balanced 42/42, no font under 14 px. **All three generators pass** —
> questions workbook (27 decisions · 57 open · leakage clean), allocation examples (13 sheets · 333
> rows · arithmetic and leakage clean), coverage matrix (**0 undeclared holes**).
>
> ⛔ **Two of this wave's own instructions were WRONG and are corrected here.** *(1)* It said to author
> prose for **`Q89` only**; the generator refused, because a decided question must sit in Part 2 and
> **`Q88` needs an entry there too**. *(2)* It said *"`Q90`–`Q92` are internal; confirm the scope
> filter excludes them"* — ⚠ **there is no scope filter.** `build_questions_xlsx.py` demands strict
> 1:1 coverage between each register's index table and this file, so an internally-owned question in
> the register **must** appear in a client deliverable. Per `CLAUDE.md`'s own rule for items that are
> *"ours to answer, not the client's"*, `Q91`–`Q93` were therefore **withdrawn from the open register
> and re-minted as `OI-133`–`OI-135`**.
>
> ⚠ **`S1` had a gap this wave exposed:** it added register *bodies* but not the *index tables* the
> generators parse. Both indexes are now updated.

| Target | Change |
|---|---|
[`Tools/AllocationExamplesContent.md`](../MVP-1/ProjectPlan/Tools/AllocationExamplesContent.md) | The welded sheet's *"Coil 2 \| R00002E"* rows become two identities. ⚠ **Two traps.** The `Order Handoff` sheet's `R00002E` is a **spool segment alpha in an unrelated scenario** — do not touch it. And the leakage guard is fatal: no table, column, file, requirement, gap or test id may reach a client cell |
[`Tools/ClientQuestionsContent.md`](../MVP-1/ProjectPlan/Tools/ClientQuestionsContent.md) | Client-facing prose for **`Q89`** only — ⚠ **`Q88` is decided and is no longer a client question.** Structure is parsed from the registers — **prose only here**. `Q90`–`Q92` are internal; confirm the scope filter excludes them |
| ⚠ **Close the client loop — this ledger has none** | **`Q89`** is the question whose answer *"supersedes this ledger"* (§8) and now carries **Owner: IT / Quality · High** (§3) — **give it a date.** And **`Q88` was closed internally** on an instruction citing `R00002A` / `R00001C`, the *segment* alphas, while what ships is two generator mints. **The delivered strings match neither the client's sentence nor their workbook.** The client-facing worked-examples deliverable must show a welded coil's two identities **in the delivered form**, so the divergence is visible before sign-off rather than at UAT |
| ⚠ **Two more generators, in no wave and no gate** | **`build_development_plan_xlsx.py`** reads `TaskBreakdown.md` (edited: `FW-231`) plus **`StaffedSprintPlans.md`** and **`Tools/DevelopmentPlanContent.md`**, neither in the list — adding `FW-231` without a matching sprint row trips its coverage guard. **`build_trial_run_xlsx.py`** reads `TrialRunPlan.md` and `TaskBreakdown.md`, both edited, plus **`Tools/TrialRunContent.md`**; it hard-codes `TOTAL_HOURS = 869` and every guard reconciles to it. ⚠ **A `~$FlatWire_TrialRunPlan.xlsx` lock file is currently in `Development/`** — the rebuild will `PermissionError` until Excel is closed |
[`RodOrderAllocation_WorkedExamples.html`](RodOrderAllocation_WorkedExamples.html) | **Light touch.** It carries no alpha strings by design; only the welded-scenario caption *"has two parents on its certificate"* needs to say two identities. Re-verify self-containment, SVG well-formedness, the 14 px floor |
| Regenerate | `build_allocation_examples_xlsx.py` · `build_questions_xlsx.py` · `build_coverage_matrix.py` |

### `S10` — The alpha-mechanism correction **[A]** ✅ **APPLIED 26 Aug 2026**

⚠ **This wave is written after the fact, because the correction was applied OUT OF BAND — and doing so
cost a site.** It was treated as "documentation-only, five files" from a standalone plan rather than
entered here first, so it never got a §5 inventory row. The grep used was for the two *exact* false
phrases (*"sibling of the segment"*, *"seven-character parent"*); a proper inventory would have searched
the **mechanism** (*"appends `A`…`Z` to the six-character root"*), and that is precisely the phrasing
that was missed — **in `50_…_CompleteCoilOnSkid.sql`, the shipped procedure.** Recorded so the next
correction goes through the ledger first.

**What was false.** `CommonDB.dbo.GenerateCoilAlpha`'s six-character root
`SUBSTRING(LTRIM(RTRIM(@CoilNo)),1,6)` is the exclusion sweep's `LIKE` filter **only**. The stem the
suffix is appended to is `@CoilNo` **verbatim** — `SET @CoilAlpha = LTRIM(RTRIM(@CoilNo)) + CHAR(@AlphaTobeAdded)`.
So a seven-character segment alpha returns a **child**, not a sibling.

**Measured on `DEVUAL-UADEV001\TEST1`, and against the function source:**

| Call | Returns | |
|---|---|---|
| `GenerateCoilAlpha('R00002','')` | `R00002A` | |
| `GenerateCoilAlpha('R00002A','')` | **`R00002AA`** | ⚠ **a CHILD, not a sibling** |
| `GenerateCoilAlpha('R00002AAA','')` | **`R00002B`** | the `LEN = 9` branch — the **only** sibling case (`F7`) |
| `GenerateCoilAlpha('R00002', <all 26 single letters ignored>)` | **`R00002AA`** | ⛔ **the collision, proven** — suffix 27 of the rod-rooted walk is the same string a segment-rooted mint produces |

⛔ **THE VERDICT MOVED THE SAME DAY — `[N]` adopted segment-rooting, and `S10` must not be read as forbidding it.**
**`S10`'s MEASUREMENT is what made `[N]` possible and stands entirely:** the six-character root is the sweep filter, the
append stem is `@CoilNo` verbatim, and a seven-character input returns a **child**. That is the finding, it was correct,
and `F13` carries it.

**`S10`'s CONCLUSION is superseded.** It read: *"Never root on a segment still holds, but because the two schemes
**collide**, not because one fails: they issue the same string by two paths that cannot see each other. And depth
**wraps** — `R00002AAA` is nine characters, so its next generation is `R00002B`, a sibling of the seven-character
segment, flattening the hierarchy at depth 3."*

**Both halves survive as BOUNDS rather than prohibitions, and that is the whole difference:**
- the **collision** needs a rod past **26 segments** (46,800 lb against 4,000–8,840 in play, `OI-97`), and even there
  nothing is reissued because everything is **registered** and the sweep finds a free string — the *shape* stops being
  readable, which is a legibility cost, not a correctness one;
- the **depth-3 flattening** applies to *chained* rooting (coil on coil). `[N]` roots every coil off a spool on the
  **same** segment, so the string grows exactly one letter and stops. Fixed rooting was never what the wrap threatened.

⚠ **Ceiling corrected 26 → 702** (`A`–`Z`, then `AA`–`ZZ`; the overflow bumps the stem rather than
stopping). `OI-135` had said **26** in its headline while its own body said **702**, and its headroom
read *"~13 of 26"* — understating it 27-fold.

| # | Target | Change |
|---|---|---|
| 1 | [`RodOrderAllocation.md`](RodOrderAllocation.md) §9.1 | Sweep filter separated from append stem; **`F13` minted** with the measured values |
| 2 | [`RodOrderAllocation_DesignPlan.md`](RodOrderAllocation_DesignPlan.md) | The mirrored paragraph |
| 3 | **This ledger** | §1.2 row **(b)**, §2.1's `ChildAlpha` comment, §1.9's ceiling, both `Q93` rows |
| 4 | [`FlatWire_MasterSpecification.md`](FlatWire_MasterSpecification.md) | **`OI-135`** headline and headroom |
| 5 | [`FlatWire_DDL_05_QualityOutput.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_05_QualityOutput.sql) | The `ChildAlpha` comment. ✅ **Comment only — runner stays idempotent, `[DBD §6.2]` baseline untouched, no re-deploy owed** |
| 6 | [`FlatWireDecidedQuestions.md`](../Analysis/FlatWireDecidedQuestions.md) | `Q89`'s dangling **`Q93`** citation repointed to `OI-135` (`Q93` was withdrawn the same day) |
| 7 | ⚠ **[`50_…_CompleteCoilOnSkid.sql`](../MVP-1/ProjectPlan/Database/Scripts/50_FlatWireDB_Proc_FlatWire_CompleteCoilOnSkid.sql)** `D5` | **THE MISSED SITE, found only when this wave was written up.** *"appends `'A'..'Z'` to the six-character root"* — the false mechanism, in the **executable** procedure. Its worked value `R00421A` **is** correct, because a rod alpha is exactly six characters and the two coincide there; they stop coinciding for any longer input. Corrected, with an explicit *do not pass a segment alpha here on the strength of the old sentence* |

✅ **Checked and correct, left alone:** `FlatWire_DDL_03_Materials.sql`, `FlatWireSchema_Materials.md`,
`RodOrderAllocation.md` §2.4 and `_DesignPlan.md` — all four say FL1 segment alphas and FL2 coil
identities are *"the same strings off the same six-character root"*, which is **the collision argument
and is right**. `FR-561c` (*a part identity's six-character root equals its own row's rod alpha*) also
holds, including past suffix 26: `R00002AA`'s six-character root is still `R00002`.

---

### `S8` — Counts, effort, backlog and the change log **[C][R][H][S]** *(last)*

| Target | Change |
|---|---|
| Live verification | ⚠ **The deployed database is two schema changes behind the scripts** — measured 25 Aug: 34 tables · 57 FKs, still holding `SpoolCarrier`/`SpoolConfiguration`. **Teardown and rebuild first**, or the published count is wrong for reasons unrelated to this wave. Then `FlatWire_DDL_RunAll.sql`, idempotent re-run, **on the shared instance**, not LocalDB. Then `verify_schema_counts.py`. **Publish the count once, from that run, at `[DBD §6.2]` only** |
[`Development/TaskBreakdown.md`](../MVP-1/ProjectPlan/Development/TaskBreakdown.md) | **`FW-231`**, sprint-assigned. Update the `OI-113` checklist line under `CoilCompletionService` (line ~697). ⚠ **Story headings, hour cells and sprint cells are parsed by three `.xlsx` generators** — match the row format exactly and use no strikethrough |
[`Development/CapacityAndEffortModel.md`](../MVP-1/ProjectPlan/Development/CapacityAndEffortModel.md) | **New additive sheet `§3d`. Never edit a published total in place** — ~20 files quote them. Working estimate to be ratified, not published from here: DDL + schema docs **4 h** (the `FW-219` DB line's own basis) · service **12 h** · label/cert rendering **8 h** · API **4 h** · ⛔ ~~generator cutover + grants + co-location sweep 10 h~~ **withdrawn with `[G]`** · ⚠ **`[H]` procedure relocation 14 h** (51 qualifications across five files, five renames, the grants move, `V4` re-derived, plus one smoke execution per procedure) · ⚠ **rename sweep 28 h** (23 tables · 292 dependent objects · 150 files · four doc-coverage targets each, plus four classes of false-positive to guard; the 6 h in an earlier revision costed **one** table) · QA **12 h**. Carried **additively to the 3,186 h baseline** on the `FW-219`/`G44` precedent |
[`Development/TrialRunPlan.md`](../MVP-1/ProjectPlan/Development/TrialRunPlan.md) | §5.3's `FlatWire_CoilOutput.CoilNo / SharedSkidNo` row gains the two new columns and the index |
[`Phases/phase-09-…md`](../MVP-1/ProjectPlan/Development/Phases/phase-09-output-coil-completion-labeling-packing.md) | The *Per-order attribution, and the `CoilNo` rename* section gains the cardinality change. **Say that the eight shared writes are unchanged** |
[`CHANGELOG.md`](../CHANGELOG.md) | One row per touched document, in that document's own section — plus **three** `## Repository-wide` rows — cardinality, the **rename**, and the **procedure relocation**. ⛔ **No generator-cutover row** — a cancelled change gets a line in this ledger, not in `CHANGELOG.md`. **`OutputCoilCompletion.md`'s row carries its new `Version`.** Do **not** add a `## Change Log` to any document |
[`CLAUDE.md`](../CLAUDE.md) | One clause in the `LatestDocument/` row: this ledger exists and the welded coil carries N alphas. ⛔ **The generator is unchanged** — do not write `PlanningDB` into `CLAUDE.md`. **The *Deploying the schema* warning block's co-location list gains `PlanningDB`** (`S9`). ⚠ **That row's `34 tables · 57 FKs` is already stale against the live `33 · 55`** — leave it to the count sweep that owns it; do not fix it inside this wave |

### `S9` — ⛔ CANCELLED with `[G]`

**This wave existed only to add `PlanningDB` as a seventh co-located database.** With the cutover
withdrawn (§1.5) **there is nothing to sweep**: none of the 14 required-database lists changes, and the
four `wip_log` / generator-sweep false-positive traps never arise.

⚠ **Two findings from it are worth keeping even though the wave is gone**, because they are true of the
repository regardless:

- **`grep -rl wiplogdb` returns 18 files, and only 14 carry a required-database list.** The other four
  match on `wip_log | wiplogdb, via proddb..wip_log_view` **data-flow** rows, or on the **generator
  sweep** list in `RodOrderAllocation.md` / `_DesignPlan.md`. **Anyone who later does add a database to
  the co-location set needs that classification** — it is recorded here so it does not have to be
  re-derived.
- **`Operations/Deployment.md` and `Architecture/Architecture.md` are not `[G]`-only targets.** Both are
  heavy `[R]` targets in their own right — see §5, where that misclassification is withdrawn.

---

## 5. Impacted-file inventory — measured

`grep -rl` over the repository, 26 Aug 2026. **Two rules:** a file appearing under `SharedCoilNo` or
`CoilNo` is *candidate*, not *in scope* — most hits are the `wip_stations.CoilNo` station-claim column,
which is a **different column in a different database** and must not be swept; and change-log entries
keep their original text by design.

| Tier | Files | In scope |
|---|---|---|
| **Design of record** | `RodOrderAllocation.md`, `_WorkedExamples.md`, `_DesignPlan.md` | **3** (one note-only) |
| **Requirements / master spec** | `BusinessRequirements.md`, `FlatWire_MasterSpecification.md` | **2** |
| **Screens** | `OutputCoilCompletion.md` | **1** *(version-bumped)* |
| **Architecture / API / services** | `Integration.md`, `APIs.md`, `Services.md` | **3** |
| **Schema** | `FlatWire_DDL_05`, `_07`, **`_03_Materials` (already built — `[R]` only; ⛔ its generator swap is cancelled)**, `FlatWire_SampleData_QualityOutput.sql`, `FlatWireSchema_QualityOutput.md`, **`FlatWireSchema_Materials.md`**, `DatabaseDesign.md`, `phase-01c` | **8** |
| **Shared write-back** | `40_`, `50_`, `60_`, `70_`, `99_` ⚠ *(**executable** — 51 qualifications + five renames, `[H]`)*, `20_FlatWire_Grants.sql`, `FlatWire_Scripts_RunAll.sql`, `Scripts/README.md`, `FW-219`'s plan, `FW-220`'s plan | **10** |
| **Registers** | `FlatWireOpenQuestions.md`, `GapsRegister.md` | **2** *(+ master spec §11, counted above)* |
| ⚠ **`[A]` alpha mechanism** — *added 26 Aug 2026 after the fact* | `RodOrderAllocation.md` §9.1, `_DesignPlan.md`, this ledger, `FlatWire_MasterSpecification.md` (`OI-135`), `FlatWire_DDL_05`, `FlatWireDecidedQuestions.md`, **`50_…_CompleteCoilOnSkid.sql`** | **7** — six of them already in the tiers above, which is exactly why the seventh was missed: **`50_` was in scope for `[H]` and `[S]` but nobody had it in scope for `[A]`**, because `[A]` had no inventory row until this one. `S10` |
| **Plan / tests** | `TaskBreakdown.md`, `TestCases.md`, `CapacityAndEffortModel.md`, `TrialRunPlan.md`, `phase-09` | **5** |
| **Client deliverables** | `AllocationExamplesContent.md`, `ClientQuestionsContent.md`, `_WorkedExamples.html` + 3 regenerated `.xlsx` | **3 sources** |
| **Repository** | `CHANGELOG.md`, `CLAUDE.md` | **2** |
| **Registers (decided)** | `FlatWireDecidedQuestions.md` — **`Q88` lands here as decided.** ⛔ `Q57` is **NOT** superseded and `Q56` needs **no** annotation (§1.5) | **1** |
| ⚠ **Rename sweep (`S1a`)** | **150 files / 4,382 occurrences** across the 23 tables — the widest change in this ledger by an order of magnitude, and **292 dependent objects** on top. ~30 files are already counted in the tiers above; **~120 are new**. ⚠ **A large fraction of the 4,382 are not the tables at all** — `RodOrderAllocation` contributes **182 document-filename references**, `PayoffPosition` is also a **column**, and `FlatWireRunRepository` is a **class** (§1.7b) | **+120** |
| ⛔ ~~**Co-location sweep (`S9`)**~~ | **CANCELLED with `[G]`** — it added **+7** files for `PlanningDB` as a seventh database. None is needed. *(The 18-vs-14 grep classification is preserved in `S9`'s stub, because it is true of the repository regardless)* | **+0** |
| | | **≈ 160 source files** — *29 `[C]` · **120** `[R]` · **11** `[H]`* ⛔ *(the **12** `[G]` files and `S9`'s **+7** are both withdrawn)* |

⚠ **The rename is the largest of the three by file count and the smallest by judgement.** Nothing in
those 120 files needs a decision — they mention a table and the string changes. That is exactly why it
is the one most likely to be left half-applied, and why `S1a` runs as a single guarded pass rather
than being folded into the other waves.

⚠ **But "mechanical" is not "safe to `sed`", and there are now four separate hazards** (§1.7b): five
names are also **document filenames**, one differing only in case; **`PayoffPosition` is also a
column** on `RodStaging` and `RodCheckin`; **`FlatWireRunRepository` is a C# class**; and `FlatWire_`
already prefixes four `united_db` **procedures**. The single largest count in the sweep —
`RodOrderAllocation`'s 208 — is **182 document references against ~101 table references**, and
rewriting the wrong ones breaks inbound links in 27 files, this ledger's included.

> ⚠ **The three counts above were wrong in the first reissue and are corrected here.** The row-by-row
> tiers sum to **41**, not the *"≈ 43"* published; the `S9` delta is **+7**, not *"+11"* — the 11 is the
> number of co-location files **already counted elsewhere**, which the earlier row had inverted; and
> the cutover adds **12** files, not 14. Recorded rather than silently fixed, because a propagation
> ledger whose own file count is wrong is the thing that lets a wave finish half-applied.

**Measured as needing nothing — recorded so each absence reads as a finding, not an oversight.**
⚠ **Every judgement here is about the CARDINALITY change.** ⛔ **The `[S9-only]` flags below are
withdrawn** — `S9` is cancelled with `[G]`, so nothing is in scope "for that wave only". Two of the
entries so flagged turned out to be heavy `[R]` targets anyway; see `Deployment.md` and
`Architecture.md` below.

- **`MVP-2/` — nothing, either change.** Its only coil-endpoint reference is a pointer *into*
  `MVP-1`'s `APIs.md` §4.15–§4.16, and that pointer stays correct. Same result as the 22 Aug
  propagation.
- **`Analysis/FlatWireDecidedQuestions.md`** — ⚠ **this entry inverted when the cutover was added.**
  It needed nothing for the cardinality change (`Q57`/`Q58` stay decided; the namespace is still
  unified and `SharedCoilNo` still renamed) — but the cutover **supersedes `Q57`'s mechanism and
  annotates `Q56`**, so it is now an `S1` target — and **`Q88` lands here as decided** (26 Aug).
  `Q89` still lands here only when the client confirms.
- **`Scripts/60`, `70`, `10_CommonDB_…` — nothing.** Their `CoilNo` is `WIPStations.CoilNo`, the
  station-claim column. **Do not sweep these.**
- ⚠ **`Scripts/40_…_CheckInRod.sql` — nothing for the coil change, and its `[S9-only]` flag is withdrawn.** It is now a **`[H]` target**: 55 unqualified references to qualify and a file rename (§1.8a).
- ⚠⚠ **`Frontend/Mockups/` — THIS CLAIM WAS FALSE and is withdrawn.** It read *"nothing structural.
  No mockup renders a shared coil alpha."* The letter survives — `CoilAlpha` is the only *coil* alpha
  rendered — but **the inference does not.** `dashboard_7_coil_completion.html:827` and
  `dashboard_7b_packing_station.html:800` both render, inside a block headed *Prints on confirm*:
  `Source | R00041, R00042`. **That row is the label's rendering of shared-namespace rod alphas — the
  exact row `[C]` changes.** Three real edits follow: the row's **values** become the part alphas (not
  a reformat — different strings, and hard-coded in a mockup); its **`", "` separator** must become the
  `" - "` alpha-join form per §1.2(3); and the traceability panel's `.trace-rod-body` **gains a field
  per row plus a fourth link in `Chain:`**. **`G53` is a gap AND two mockup edits.**
- **`SupportGuide.md`, `FlatWirePlan.md` — nothing.** All `CoilNo` hits are the station column or the
  cancelled `Coil/BundleNo` rename (`D-32`).
- ⚠ **`Operations/Deployment.md`, `Architecture/Architecture.md` — the `[S9-only]` flag was wrong twice over.** `S9` is cancelled, and both were `[R]` targets all along.
  `Deployment.md` carries **14 occurrences in four executable blocks**, and ⚠ **`V4` is the one that matters most**:
  `SELECT name FROM sys.objects WHERE name IN ('trg_CoilTraceability_NoOverlap', …)` — **the only
  in-repo existence check for the trigger this ledger calls its headline silent-failure risk, and it
  checks the OLD name.** Unedited it returns 1 row instead of 2 and **rejects a correct deployment**.
  `V6` joins `CoilTraceability` to itself. ⚠ **`V4` is also a `[H]` target** — with the four procedures
  hosted in `FlatWireDB` it becomes a single-database query (§1.8b). `Architecture.md` carries **18** —
  `D-12`, `D-13`, `D-30` and the `NFR012`/`NFR013` rows.
- **`FlatWire_DDL_06_ForeignKeys.sql` — nothing, either change.** No FK is added: the parent index
  `UX_FlatWire_SpoolTraceability_ChildAlpha` is **filtered**, and SQL Server will not point a foreign
  key at a filtered index (§2.1). ⚠ **The FK count is unchanged; 50 of the 55 existing FKs are
  *renamed* by `S1a`, which is a different statement** (§1.7c).

---

## 6. Sequencing, and what this collides with

**Three live pieces of work touch the same files. This wave should go first, and here is why.**

1. **The 6 Aug ledger's `W3`–`W8` are documented and unexecuted**, and `W3`–`W7` is **blocked on
   `Q41`** (what an FL2 pre-check-in does) with `A3`, the PLC review, overdue. Folding a settled
   change into a blocked wave makes it wait on an unanswered question — the same reasoning
   `RodOrderAllocation_SyncPlan.md` §3 used, and it held.
2. **`OI-118` — and ⚠ its count-movement risk is already discharged.** An earlier revision said its
   `SpoolStaging` requirement text *"will move counts again"*. **The table is built** —
   `CREATE TABLE [dbo].[SpoolStaging]` at `FlatWire_DDL_04_Runs.sql:614`, inside the published 33 —
   so what remains open on `OI-118` is the **requirement text, endpoints and screen**, not the schema.
   **The mitigation still stands for other reasons:** publish the object count **exactly once**, from a
   live deploy, at the end of the wave. Publishing incrementally is the thing that has gone wrong
   before.
3. **`LatestDocumentSync_2026-08-25_SyncPlan.md` finding 2 — the deployed database is two schema
   changes behind the scripts** (measured: 34 tables · 57 FKs, still holding `SpoolCarrier` and
   `SpoolConfiguration`). ⚠ **A teardown and rebuild is owed *before* `S8`'s verification**, or the
   count published from it will be wrong for reasons that have nothing to do with this change.

**Risks specific to this wave.**

| | Risk | Handling |
|---|---|---|
| **R-a** | A reader takes the client note as licence to write several `coil_gen_history` rows | §1.3's `FR-515` argument goes **into the artifacts**, not just this ledger — `FW-219`'s plan and `[INT §8.1]` both |
| **R-b** | Someone sweeps `CoilNo` globally and corrupts `WIPStations.CoilNo` | §5's do-not-sweep list. The two columns are in different databases and mean different things |
| **R-c** | `S2` hard-codes `R00001F` and the worked-examples document contradicts it | §1.2 — state the call, derive the letter, recompute per document |
| **R-d** | The `SourceSegmentAlpha` FK is "fixed" by someone who does not know the parent index is filtered | The reason is in the column comment (§2.1), not only here |
| **R-e** | `[C]` — `I5` regresses: the single-parent case grows a second alpha | `TC-785` exists for exactly this, and fourteen of twenty-three spools are single-parent |

⚠ **`R-a`–`R-e` are all `[C]` risks — they were written before the other changes existed.** `[R]` and
`[H]` had no rows at all until the gap review, which meant the ledger's own self-declared most likely
failure mode was absent from its own risk register:

| | Risk | Handling |
|---|---|---|
| **R-f** | ⚠ **`[R]` half-applied.** 4,382 occurrences over 150 files, **no acceptance test but a grep**, and counts cannot detect it (§1.7d) | §7's per-table grep gate is the *only* detector. **`S1a` must be one commit** so a partial application is revertible as a unit (§9) |
| **R-g** | `[R]` — **a file renamed by mistake.** Five table names are also document filenames; `RodOrderAllocation` alone is 182 document references against ~101 table references | §1.7b(3)'s guarded pattern, plus §7's "no file renamed, no link broken" gate |
| **R-h** | `[R]` — **the `PayoffPosition` column corrupted.** ⚠ **Fails loudly in the DDL and *silently* in prose**, where it usually means the column | §1.7b(2)'s 10-rename / 15-leave checklist, and the `sys.columns` gate that must return zero `FlatWire[_]%` |
| **R-i** | `[R]` — **`FlatWireRunRepository` corrupted.** The one substitution that correctly fixes `FlatWireRunDetail` also breaks this **C# class** | Excluded by name in §1.7b(1); gated in §7 |
| ⛔ ~~**R-j**~~ | ~~`[G]` — `P1` fails after `[C]` and `[R]` have landed~~ | **WITHDRAWN with `[G]`** — there is no cutover to fail |
| **R-l** | `[H]` — **a missed qualification among the 51.** ✅ **Loud, not silent** — `Invalid object name` at create or first execution, and no `FlatWireDB` table name collides (§1.8a) | The five-file checklist in `S5a`, plus `V4` and a smoke execution of each procedure |
| **R-m** | ⚠ `[H]` — **the procedures end up in a database none of whose objects they use**, so a later reader "corrects" them back to `united_db` | §1.8's opening note states the trade deliberately. **`sp_IngestRodFromCoils` is the precedent** that this is intended |
| ⛔ ~~**R-k**~~ | ~~`Q89` returns "one row per alpha" after the wave lands~~ | **DISCHARGED — it happened.** `Q89` was answered **yes** on 26 Aug 2026 *before* any wave landed, so the risk never materialised as a late reversal. `[C]`'s design is superseded by `[S]` (§1.3) rather than reopened mid-flight |
| **R-n** | ⚠ **`[S]` — the weight split double-counts.** `wip_skids.skid_net_wgt` accumulates a scalar; N calls with the coil's full weight record **N × actual**, and the `C9` smallint guard validates per *call* so it admits 3,600 lb onto an 1,800 lb skid **without complaint** | **`I7`/`TC-795`** is the only detector. Accumulate skid weights **once per physical coil**, and take part weights from `SegmentWeightLb` (§1.9) |
| **R-o** | ⚠ **`[S]` — `OI-113` looks closed but is not.** If all N alphas pass one shared `@primaryRodAlpha`, `coil_gen_history` gets N rows that all name the same parent — saying *"this rod produced N coils"*, which is **not** multi-rod genealogy | **`TC-796`** asserts N **different** `parent_coil_no`. This is the single condition the close depends on |
| **R-p** | `[S]` — a `proddb..coils` insert is "optimised" into a batch | `C4`: `coils_iud_tg` gates on `@ins_count = 1` and a set-based insert **silently skips** `coil_link_master_coil`. The loop must issue N **single-row** statements |

---

## 7. Verification gates

Every one is mechanical. None is a judgement call.

- [ ] `verify_schema_counts.py` passes; `[DBD §6.2]` publishes **33 · 55 · 70 · 1 · 1** from a live
      teardown-and-deploy on the **shared** instance
- [ ] `build_coverage_matrix.py` passes — `FR-561`–`FR-566` all covered by `TC-784`–`TC-794`
- [ ] `build_questions_xlsx.py` passes all four guards (coverage · drift · team names · leakage) with
      **`Q89` present and `Q88` absent** (it is decided). **`Q90`–`Q92` are internal** — confirm the
      scope filter treats them as such
- [ ] `build_allocation_examples_xlsx.py` regenerates; the welded sheet shows two identities and no
      identifier leaks into a client cell
- [ ] `grep -rn "R00002E"` returns only **superseded-text** sites. ⚠ **Two things named `R00002E` are
      NOT the coil alpha and must stay untouched:** the `Order Handoff` sheet's spool **segment**
      `R00002E`, and `AllocationExamplesContent.md`'s segment rows — segment alphas are unchanged by
      `[N]`, and only the *coil* alphas moved to `R00002AA`/`R00002AB`/`R00001CA`
- [ ] No document gained a `## Change Log`; `CHANGELOG.md` has one row per touched file;
      `OutputCoilCompletion.md`'s `**Version:**` header and its `CHANGELOG.md` row carry the **same**
      value
- [ ] `RodOrderAllocation.md` §2.8 Scenario A is byte-identical apart from the one added line — the
      single-parent case did not move
- [ ] **For each of the 23 tables, the old bare name is gone.** Run the guarded grep per name —
      unprefixed and not followed by `.md` / `.html` / `_SyncPlan` / `_DesignPlan` /
      `_WorkedExamples` — and expect hits **only** in `CHANGELOG.md`, `BaseDocuments/` and §1.7's own
      mapping tables. **This is the whole acceptance test for `[R]`; counts cannot detect a half-done
      rename**
- [ ] ⚠ **No file was renamed, and no document link broke.** `RodOrderAllocation.md`,
      `WeldEvent.md`, `WipRejection.md`, `RodCheckout.md`, `SPCCheckpoint.md` and
      `FW-174-WipRejection-…md` all still exist under their original names, and every inbound link
      still resolves
- [ ] **All 292 dependent objects renamed**, and `sys.triggers` shows the renamed
      **`trg_…_NoOverlap`** bound to the renamed table. ⚠ **Check this one explicitly:** a missing
      trigger loses half-open non-overlap enforcement *silently* — the rows still insert
- [ ] **`sys.foreign_keys` returns 55**, and none names a table that no longer exists.
      **`sys.tables` returns 33** with 23 carrying the prefix and 10 bare
- [ ] ⚠ **`PayoffPosition` the COLUMN is untouched.** `FlatWire_RodStaging` and `FlatWire_RodCheckin`
      still declare `[PayoffPosition] INT NOT NULL`; **no column anywhere is named
      `FlatWire_PayoffPosition`**; and the `PayoffPos*` segment is rewritten in **exactly six**
      dependent-object names — the six owned by the lookup — and left alone in the other sixteen
      (§1.7b(2))
- [ ] **`sys.columns` has zero rows where `name LIKE 'FlatWire[_]%'`** — the cheapest single check that
      no table prefix leaked onto a column
- [ ] ⚠ **`FlatWireRunRepository` is still `FlatWireRunRepository`** in `FW-141`, and the four
      `FlatWire_*` **procedures** are **relocated, not renamed** — same four names, new host (`[H]`)
- [ ] **`[H]`: `sys.procedures` in `FlatWireDB` returns the four `FlatWire_*` procedures plus
      `sp_IngestRodFromCoils`**, and `united_db` returns none of them
- [ ] ⚠ **`[H]`: zero unqualified `dbo.X` left in the five relocated files.** Grep each for
      `dbo.` not preceded by a database qualifier. ✅ A miss is loud, but the grep is cheaper than a
      failed deploy (§1.8a)
- [ ] **`[H]`: each of the four procedures executes end-to-end at least once** from its new host — the
      only check that catches a qualification that parses but points at the wrong database
- [ ] `verify_schema_counts.py` `C2` passes for **all 23** new names — each in its script header, a
      `Schema/FlatWireSchema_*.md`, `phase-01c`'s group table **and** `[DBD §7]`'s ER diagrams
- [ ] **`[DBD §6.2a]` states the convention *and* the `PayoffPosition` exception** — six lookups bare,
      one prefixed, and why (§1.7a)
- [ ] **`TC-192` and `TC-617` name the renamed trigger**, and both still pass against it
- [ ] ⚠ **No test, fixture or acceptance criterion asserts a specific alpha suffix as a cutover
      invariant** (§1.4). Assertions are on *relationships* — `CoilNo` = the lead row's `ChildAlpha`,
      `LEFT(…,6)` matching — never on a literal suffix. A suffix assertion passes before the cutover
      and fails after it, for no defect. ⚠ **`[N]` proved this twice over:** the coil alphas moved
      `R00002E` → `R00002AB`, and `LEFT(…,6)` still holds because a segment alpha is itself rooted on
      the rod — the assertion survived precisely because it was on the relationship
- [ ] ⚠ `50_…_CompleteCoilOnSkid.sql` — `git diff` shows **the three generator call sites, the
      `Target DBs` header and the comment blocks, and nothing else.** Specifically **no change to any
      of the eight shared writes**, and both guards (`51010`, `51011`) still present
- [ ] ⛔ **No `P1`/`P2`/`P3` evidence is owed** — the pre-flight died with `[G]`. If a gate list still
      demands a synonym query or a `PlanningDB` co-location check, it is stale
- [ ] ⚠ **`[S]`: `SUM(coil_net_wgt)` over a physical coil's N shared rows EQUALS
      `FlatWire_CoilOutput.NetWeightLb`** — the double-count guard (`I7`/**`TC-792`**, not `TC-795`). **Check this
      first**; it is the failure the `C9` smallint guard cannot catch
- [ ] ⚠ **`[S]`: `coil_gen_history` has N rows for the coil, each with a DIFFERENT `parent_coil_no`.**
      If they share one parent, **`OI-113` has not closed** and the change bought nothing (`TC-796`)
- [ ] **`[S]`: retry** — complete a coil, kill the caller before it stamps `SharedWrittenAt`, retry:
      no duplicate `coils` rows, and **all N alphas reported** (`TC-797`)
- [ ] **`[S]`: two *physical* coils still close one skid**, and `skid_coil_seq_no ∈ {1,2}` across all
      N rows per slot (`TC-798`, `TC-799`)
- [ ] **`[S]`: `sys.indexes` still shows 70 index statements** — `SharedWrittenAt` is a column, not an
      index, so no published count moves
- [ ] **`[S]`: `git diff` on `50_…_CompleteCoilOnSkid.sql` shows the loop, the TVP, the rowset outputs
      and `[H]`'s 55 qualifications in ONE pass** — not two overlapping edits to the same file
- [ ] `TC-785` passes — an unwelded coil still mints exactly **one** alpha equal to its `CoilNo`.
      **The regression that matters most:** fourteen of twenty-three spools are single-parent
- [ ] `TC-792` passes — an alpha from the new generator is absent from `coils`
- [ ] **Retry safety survived the cutover:** call `FlatWire_CompleteCoilOnSkid` twice with
      `@expectedCoilNo` set on the second call; it is a no-op and no second coil is minted
- [ ] **No prescriptive `CommonDB.dbo.GenerateCoilAlpha` left.**
      `grep -rn "CommonDB.dbo.GenerateCoilAlpha"` returns only historical text — `CHANGELOG.md`, and
      `Q56`/`Q57`'s retained decision bodies, which keep it **by design**
- [ ] ⛔ **No `PlanningDB` anywhere.** `grep -rn PlanningDB` over `MVP-1/` returns **nothing** — the cutover is cancelled (§1.5), so no co-location list, grants block or connection reference should name it
- [ ] `20_FlatWire_Grants.sql`'s four `EXECUTE` grants name **`FlatWireDB`**, not `united_db` (`[H]`, §1.8b)
      `sys.databases` check

---

## 8. What is still open after this wave

| | |
|---|---|
| ~~`Q89`~~ | ✅ **Closed 26 Aug 2026 — every part alpha.** `OI-113` and `OI-128` close with it |
| **`Q93`** | The **702**-suffix-per-rod ceiling is now divided by N *(said 26 until 26 Aug 2026)*. *Accept and monitor* — now `OI-135` |
| **`OI-132`** | ⚠ **`OI-114` and `D9` state something false** about the legacy writers' `skid_coil_seq_no`. `[S]` sidesteps it; the register entry is still wrong |
| ~~`Q88`~~ | ✅ **Closed 26 Aug 2026** — two alphas *per se*; the client's derivational form is not adopted at all, stored or rendered |
| **`Q89`** | Whether every part alpha reaches `proddb..coils`. **If the answer is yes, this ledger is superseded and Phase 9's shared write-back reopens** along with the skid rule (`FR-515`). That is why the `R1` recommendation is argued from arithmetic |
| ~~**`OI-113`**~~ | ✅ **CLOSED by `[S]`** — each part alpha is its own `child_coil_no`, so `ins_coil_gen_history`'s per-child guard permits one **correctly-parented** row each and the shared tree stops disagreeing with `CoilTraceability`. ⚠ **Conditional: each alpha must carry its OWN parent rod** (§1.9). *Superseded text:* Narrowed, not closed. Under `R1` the shared tree still holds one parent, so it and `FlatWire_CoilTraceability` still disagree by design — and that must stay documented wherever the shared tree is consumed |
| **`OI-128`** | Non-lead alphas are unswept. Posture *accept and monitor*; the fix costs a shared-schema writer and touches `D-32` |
| **`G53`** | Label and certificate rendering of a multi-part alpha. Blocks Phase 9's label work |
| **`Q45` / `OQ-M`** | Unwind direction — now decides how many alphas each coil carries, not only whose parentage it records. **Build to LIFO meanwhile** |
| ⛔ ~~`Q90`~~ | **Withdrawn with `[G]`** — `PlanningDB`'s isolation is irrelevant if flat wire never reads it |
| **`Q91`** | ⚠ **Whether the six remaining lookups follow.** This ledger leaves the schema **half-prefixed: 23 tables carry `FlatWire_`, 10 do not** — the 6 lookups `Stand`, `Drawer`, `Edger`, `Dancer`, `Spool`, `AlloyProperty`; the 3 `PassSchedule*` tables; and `Rod`. **`PayoffPosition` is the seventh lookup and it *is* prefixed**, which is what stops the exclusion set from stating as a rule (§1.7a). *Either move the remaining six in this same pass — every FK is already being touched — or write the exception into `[DBD §6.2a]`.* **Owner: Architecture · Medium** |
| **`Q92`** | ⚠ **NARROWED by `[H]`, not closed.** It was raised because `FlatWire_` named both a `FlatWireDB` table and a `united_db` procedure, so the identifier did not say which **database** to look in. `[H]` removes that half — every `FlatWire_` object now lives in `FlatWireDB`. **What survives is narrower and arguably worse for a reader:** inside one database `FlatWire_RodCheckin` is a **table** and `FlatWire_CheckInRod` a **procedure**, and the prefix distinguishes neither. The prefix is now redundant on *everything* in `FlatWireDB`, which **strengthens `Q91`** rather than closing it. *Record the object-class ambiguity in `[DBD §6.2a]`.* **Owner: Architecture · Low** |
| ⛔ ~~`OI-129`~~ | **Withdrawn with `[G]`** — flat wire stays on CommonDB's sweep alongside every other alpha caller. `Q56`'s finding is unchanged |
| `OI-130` · ⛔ ~~`OI-131`~~ | **`OI-130` is a real defect in PlanningDB's fork — and no longer flat wire's exposure**, since we do not call it. Handed to IT/DBA as a finding. ⛔ **`OI-131` is withdrawn** with `[G]` — ⚠ **and it takes an upside with it: `F10`'s caveat returns, so `GetCoilAlpha` stays uncallable and FL1's batch loop must be written** (§1.5) |
| ⚠ **`[H]` — FL1's batch loop is owed** | ⛔ `[G]`'s cancellation restores `F10` in full: `PlanningDB.dbo.GetCoilAlpha` calls its own generator unqualified and stays **uncallable**, so the `@count`-driven loop with a `CONCAT_WS` ignore-list accumulator that FL1 needs **must be written**. Cite `GetCoilAlpha` as the reference implementation; do not call it |
| ⚠ **`[H]` — `WIPStations`' qualification target** | One of the 31 objects needing a database qualifier is reached today through a `united_db` view, and `[INT §8]` records that `united_db..wip_stations` and `proddb..wip_stations` are **views over one table**. **Decide the target; do not guess** (§1.8a) |
| **`Q10` / `OI-45`** | Inherited and unchanged: the dimensional basis still gates every weight in every trace here |

---

## 9. Abort path — how each change is backed out

⚠ **This section did not exist until the gap review. The ledger had no occurrence of "rollback",
"revert", "abort" or "undo" in 1,031 lines** — for a change renaming 23 tables and rewriting ~161
files. The answers are simple, which is exactly why they were worth writing down.

**The enabling rule: one wave, one commit.** Each live wave — `S1`, `S1a`, `S2`–`S8`, `S5a` — lands as a single commit whose message names
the wave. Nothing else in §9 works without it — a wave spread over five commits is not revertible as a
unit, and `S1a` in particular is a 150-file text sweep whose only detector is a grep.

| Change | Abort path |
|---|---|
| **`[C]`** cardinality | **Documents:** `git revert` the `S2`/`S3` commits. **Schema:** the two columns and one index are additive and guarded — dropping them is a reverse `ALTER`, or simply teardown-and-rebuild, which is already the deploy path. **No data migration exists to unwind** |
| ⛔ **`[G]`** generator | **Nothing to abort — the change is cancelled** (§1.5). Alpha generation never leaves `CommonDB.dbo.GenerateCoilAlpha`, so no call site, grant or co-location list moves |
| **`[H]`** host | **Five file renames revert with the commit.** ⚠ **And unlike the grants, the procedures DO have a reverse script** — `99_…_Proc_FlatWire_Teardown.sql` drops all four, so a failed `[H]` is: teardown the procedures, `git revert` `S5a`, re-run `FlatWire_Scripts_RunAll.sql`. **The 51 qualifications revert with the file contents; none is a database-state change** |
| ⚠ **`[S]`** shared | **The one change with committed shared-schema rows to unwind.** `SharedWrittenAt` is what makes it tractable: the non-NULL set is exactly what reached `proddb..coils`, so a compensating delete is enumerable rather than guessed. ⚠ **But `coils` DELETE archives to `coils_hist` and copies `coil_cost` to `coil_cost_hist` via `coils_iud_tg`** — so an abort leaves history rows. **Decide with IT before the first `[S]` deploy whether that is acceptable**, because it is not reversible by `git revert` |
| **`[R]`** renames | **Documents:** `git revert` the `S1a` commit — this is why it must be one commit. **Schema:** ⚠ **no `sp_rename` was used, so there is nothing to reverse** — teardown with `99_Teardown.sql` (which drops the whole database, 24 lines) and rebuild from the reverted scripts. **The live database holds 3 rows**, so the data cost of a teardown is nil |

**What cannot be aborted, and must therefore not be started early.** `S8`'s `CHANGELOG.md` rows and the
`[DBD §6.2]` published count are the outward-facing half: once a count is published, other documents
quote it. **That is why `S8` is last** and why the count is published exactly once, from a live deploy.

---

## Related

| Document | Why |
|---|---|
| [`RodOrderAllocation.md`](RodOrderAllocation.md) | The design this corrects — §2.4, §2.5, §2.8 |
| [`RodOrderAllocation_SyncPlan.md`](RodOrderAllocation_SyncPlan.md) | The 22 Aug propagation this rebases onto; its `C2` was the `SharedCoilNo` → `CoilNo` rename |
| [`RodOrderAllocation_WorkedExamples.md`](RodOrderAllocation_WorkedExamples.md) | §7 is Scenario B with its order dimension; the letters there span a whole run |
| [`FL Alphas Plus - Analysis.md`](../BaseDocuments/FL%20Alphas%20Plus%20-%20Analysis.md) | §2 — the client's own two-alpha cell, the `" - "` / `" / "` separator rule, and the four defects that keep `R00002AA` out of the database |
| [`50_…_CompleteCoilOnSkid.sql`](../MVP-1/ProjectPlan/Database/Scripts/50_united_db_Proc_FlatWire_CompleteCoilOnSkid.sql) | Constraints `C4`, `C5` and decisions `D5`, `D6` — the three reasons `R2` is not the default |
| `ual-database` — `Databases\CommonDB\Functions\GenerateCoilAlpha.sql` · `Databases\PlanningDB\Functions\GenerateCoilAlpha.sql` · `Databases\PlanningDB\Stored Procedures\GetCoilAlpha.sql` | **The evidence base for §1.5's cancellation** — the two forks compared side by side, which is what shows PlanningDB's is the weaker. Read from the `Second-Branch` working copy; note `RodOrderAllocation.md` §9.1's object map was read from the *older* copy and its line counts differ |
| [`20_FlatWire_Grants.sql`](../MVP-1/ProjectPlan/Database/Scripts/20_FlatWire_Grants.sql) | The six-database co-location assertion — ⛔ **unchanged by `[G]`'s cancellation**; `[H]` moves only the four procedure `EXECUTE` grants |
