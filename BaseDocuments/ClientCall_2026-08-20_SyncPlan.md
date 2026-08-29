# Client Call 20 Aug 2026 — Action Items and Document Sync Plan

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 25, 2026 — **W3 and W4 marked applied, W5–W7 partial**, from the `LatestDocument/` → `MVP-1/ProjectPlan/` sync audit *(previously August 24, 2026 —* **§8 added as a pointer to [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md)**, which owns the following week's call. It completes this ledger's `D8`, tracks `A1`–`A8` to status, and records the schedule re-baseline. *(previously August 20, 2026)*
**Status:** **Waves W1–W4 applied; W5–W7 partly applied — see the per-wave breakdown below.** The nine decisions are recorded against `FR-031`, `FR-172`, `Q41`–`Q47`, `OI-118`–`OI-122`, `G42` and `G46`, and the two affected specifications are re-issued. **W3 and W4 are now applied (25 Aug 2026); W5–W7 are partly applied.**

> **Status by wave, 25 Aug 2026:**
> - **W3 — requirement text: ✅ APPLIED.** `FR-031` superseded in place in both `[REQ]` and the master specification; new **`FR-533`–`FR-540`** in `[REQ]` §5.29 with cases **`TC-776`–`TC-783`**; `TC-042` withdrawn; the two line-capability tables that **do not cite `PCI002`** (`[VS]`, `[PLC]`) both corrected, plus the dashboards design reference, `RodPreCheckin.md`, `phase-04`, `[TB]` and `FlatWireSchema_Runs.md`. All of it tagged **`[PROPOSED]`** — see below.
> - **W4 — schema and DDL: ✅ ALREADY COMPLETE**, on 22 Aug 2026. `SpoolStaging`, `SpoolOrder` and `SpoolTraceability` are built, in the runner and seeded. ⚠ **The count re-derivation this wave demanded is done and landed at `33 tables · 55 FKs`, not the 31 predicted here** — the 23 Aug `SpoolConfiguration` merge (`Q60`) went the other way. `CK_RodStaging_LineId` correctly stays `FL1`/`FL3`.
> - **W5 — contracts: ⚠ PARTIAL.** All five `lineId = FL2` → `422` sites in `[API]` are **marked withdrawn-pending-this-wave**, but the contract still specifies the refusal and **`FL2PO` is still not created**. The endpoint change itself is owed.
> - **W6 — mockups: ⚠ PARTIAL.** The four `PCI002` comments in `dashboard_5a`, `dashboard_1` and `dashboard_2a` are corrected; **the pre-check-in control is not built.** ⚠ **The *next-carrier field* task is NOT APPLICABLE** — the word "carrier" does not appear in `spool_notification.js` or `dashboard_7_coil_completion.html`, so there was nothing to change.
> - **W7 — plans, tests, effort: ⚠ PARTIAL.** Test cases written; `phase-04` and `[TB]` line 1638 corrected; **`FW-224` recorded as reserved** in `[TB]`; a new **`[CE]` §3f`** carries the story with **no hours**, because action **`A6`** is unreported and the sizing is blocked on `Q41`.
>
> ⚠ **Everything in W3 rests on `Q41`'s recorded RECOMMENDATION, not a client answer.** `Q41` is `Critical` and open. The adopted reading is *validate and release, persisted record, no bay, `Should`* — which the delivered `SpoolStaging` shape already matches. **If the client answers differently the requirement text and the endpoint change; the table does not.** **The 24 Aug 2026 call has its own ledger** — [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md); **§8 here is a pointer to it**, summarising only what it changes about *this* document. It adds no wave to this one.
**Source:** Client call 20 Aug 2026, 11:00 UTC, 1h 31m 49s — Tim O'Brien, Bob Scott, Shannon Riotte (United Aluminum); Srikanth Prabhala, Yogender Punia, Shray Anand, Divesh Malhotra, Waseem Khan, Ritika Raheja, Vicky Arora (Nagarro). Transcript: *Shopfloor · Review Priorities · Discuss Open Items · Use Time For Demos*, 20260820_110013UTC — Teams meeting recording. ⚠ **The transcript is not yet filed in this folder**; file it alongside the 6 Aug one, whose entry in the ledger below assumes it is here.
**Flat wire span:** 00:00 – 01:07:31. Everything after that is the Xamarin→MAUI / handheld deployment thread and is **not** flat wire; it is summarised in §7 for completeness and touches no register.
**Registers touched:** `Q##` ([FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md), 36 → 47) · `OI-##` ([FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11, → `OI-122`) · `G##` ([Development/GapsRegister.md](../MVP-1/ProjectPlan/Development/GapsRegister.md), `G42` updated, `G46` added) · `FR-###` ([BusinessRequirements.md](../MVP-1/ProjectPlan/Business/BusinessRequirements.md), `FR-031` reversed — W3)

---

## 1. Why this call mattered

Two of the nine decisions do something no previous call has done, and one is a register repair that had to
happen before anything else could be numbered.

| | What it does |
|---|---|
| **`D1` — FL2 gets pre-check-in** | **The first outright reversal of a requirement that is asserted in the DDL.** `FR-031` reads *"the system shall **not** support pre-check-in on FL2 — a `lineId` of `FL2` is rejected"*, and the rule is asserted across **eighteen documents** — **sixteen citing `PCI002` in thirty places**, plus two that assert it without citing the rule at all ([`PLCTagSpecification.md`](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md) line-capability table and [`VisionAndScope.md`](../MVP-1/ProjectPlan/Business/VisionAndScope.md) line-capability table), **so a grep for `PCI002` alone will miss two of them**. Among the eighteen: a `CHECK` constraint in [`FlatWire_DDL_04_Runs.sql`](../MVP-1/ProjectPlan/Database/Schema/SQL/FlatWire_DDL_04_Runs.sql), a *"deliberately NOT created"* comment in [`10_CommonDB_Insert_WIPStations_FlatWire.sql`](../MVP-1/ProjectPlan/Database/Scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql), a `422` branch in the contract, a test case, two phase files, the whole rationale of [`SpoolQueue.md`](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) §1.2, and comments inside three mockups. The 30 Jul call carried three reversals; **none of them reached a constraint** |
| **`D2` — one spool, many rods, many orders** | **Client confirmation of `G42`, whose own note says to raise it now while it is free.** `G42` (15 Aug) found that `SpoolProcessing` carries `ParentRodAlpha` and `SourceRodAlpha` — two **single-rod** columns — with **no child table**, against `FR-172`, which is a `Must` requiring *"multi-parent genealogy so one output spool identifier references all contributing parents."* Srikanth reached the same design independently on the call. **The free window closes at `S1`, 24 Aug**: with weld capture descoped nothing writes the table, so today it is a DDL file and a domain type; after weld capture returns it is a migration plus a backfill against certificate data |
| **`D3`–`D6` — the spool carrier** | **Closes [`SpoolQueue.md`](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) §7 item 1**, open since 2 Aug: *"Your own description distinguishes the spool number (a reusable physical carrier, like a furnace plate) from the material identity loaded onto it — the system currently records only the second."* That is now answered on all four counts: what the carrier is, how it is entered, when it is captured, and how it is read at FL2 |
| **The register repair** | `Q37`–`Q40`, `OI-115` and `OI-116` were minted on 19 Aug in [`GapsRegister.md`](../MVP-1/ProjectPlan/Development/GapsRegister.md) `G45`, [`Integration.md`](../MVP-1/ProjectPlan/Architecture/Integration.md) §8.0, [`BusinessRequirements.md`](../MVP-1/ProjectPlan/Business/BusinessRequirements.md) §5.26, [`FW-220`'s plan](../MVP-1/ProjectPlan/Backend/tasks/FW-220.md) and `CHANGELOG.md` — and **never added to the two authoritative registers**. This call's ids would have collided with them. Recorded as **`G46`** and repaired in W1 |

**What this call does not do.** Nothing here touches the pass schedule, the generation physics, the PLC tag
surface or the FM2 stand model. `D-26`, `D-31` and `D-32` are all untouched — and `D-32` is the reason the new
association tables are `FlatWireDB`-local rather than extensions of `wip_skid_coils` (§3.2).

---

## 2. Decision ledger — the nine decisions mapped to register IDs

| # | Topic | Register ID | New status | Effect |
|---|---|---|---|---|
| **D1** | **FL2 gets pre-check-in**, mirroring Dashboard 2A | **`FR-031` reversed** · new **`Q41`**, **`OI-118`** | `Decided` — shape open | Reverses a requirement asserted across **18 documents**, including a `CHECK` constraint. New `FR-533`+ and `FW-224`+ owed. See §3.1 |
| **D2** | **A spool carries many rods and many orders**; FL2 output is **per order** | **`G42` client-confirmed** · **`FR-172`** corroborated · new **`OI-119`**, **`OI-121`** | `Decided` | The `SpoolTraceability` child is now client direction, and gains a **weight-per-alpha** column. See §3.2 |
| **D3** | **Spool numbers are static**, stenciled, plate-like; 30 now, 45 likely; one standard size | **`SpoolQueue.md` §7 item 1** closed · new **`OI-120`**, **`Q42`** | `Decided` | The dynamic-number option was raised twice and rejected. No carrier entity exists in the schema. See §3.3 |
| **D4** | **Free-text entry validated against the registry**, not a drop-down | `SpoolQueue.md` §3.2 · `RocCheckin.md` §4 | `Decided` | 30–45 rows is too long to scroll on a panel. See §3.3 |
| **D5** | **The carrier is captured at the FL1 spool-completion transaction**, and it is a **hard gate** | **`Spool.md`** May 2026 text superseded · new **`Q46`** | `Decided` | Supersedes *"at the start of the FL1 job"*. Mandrel diameter rides with it and has no home. See §3.4 |
| **D6** | **FL2 scans a high-temp label**; any one coil code on it resolves the spool | new **`Q44`** · **`OI-115`** narrowed | `Decided` — content owed | First mechanism agreed; etched steel plates are a later option. Label **content** is unspecified anywhere. See §3.5 |
| **D7** | **The label's lead alpha is the one expected at the next check-in** — *last on, first off* | new **`Q45`** | `Open` — principle stated | ⚠ **Contested in the same conversation**, and the two speakers are not making the same claim. See §3.6 |
| **D8** | **Output coil alphas are created on an actual transaction**, not pre-generated at FL1 | new **`OI-121`** · action **A1** | **Rejects the earlier design; replacement not settled** | Tim's alternative — *wire on a spool with pounds per alpha* — is on the table and unadopted. See §3.7 |
| **D9** | **Plan to the maximum output coil weight and work backwards** | **`Q18`** / **`PSG-D32`** corroborated · new **`Q47`** | `Decided` — method agreed | ⚠ **The arithmetic is misstated on the recording.** See §3.8 |

**Corroborated, not changed:** the **~1,800 lb FL1 spool** and **800/900 lb FL2 coil** multiples were restated
for the **third** time (30 Jul, 6 Aug, 20 Aug). The route set was restated as **three** operations — *roll*,
*roll-anneal*, *roll-anneal-roll* — with FL3 hybrid collapsing to *roll*. Both already hold in
[`BusinessRules.md`](../MVP-1/ProjectPlan/Business/BusinessRules.md) §3 and `Q18`; no edit.

---

## 3. The decisions in detail

### 3.1 D1 — FL2 gets pre-check-in, and this one reaches the DDL

Tim, at 03:20, reporting a decision taken with Bob after the previous week's meeting:

> *"Something that Bob and I discussed after last week's meeting that we both agreed upon, a slight change.
> **We do want pre-check-in for FL2.** And the reason for that is to validate the next spool and to eliminate
> the potential for downtime due to the fact that they grabbed the wrong spool and then would have to — they
> would find out at check-in and then have to go and locate the correct one. By having the pre-check-in, they
> could check it in advance, validate that it's correct, and mitigate any chance of excess downtime trying to
> locate material."*

**What is reversed.** `FR-031` — *"The system shall **not** support pre-check-in on FL2 — a `lineId` of `FL2`
is rejected. FL2 is check-in only"* — and every artifact that repeats it. **Eighteen documents assert it** —
sixteen cite `PCI002` across thirty citations, and two state the exclusion without citing the rule, so a
grep for `PCI002` alone will miss those two. All eighteen are assigned to W3–W7 below.

> **⚠ The physical premise behind `PCI002` was never contradicted, and this is the single most important thing
> to carry forward.** `PCI002`'s stated reason is *"no staging space"*, and that is still true — FL2 has one
> traversing payoff and no floor space. Tim asked for **validation**, not staging. So *"mirror Dashboard 2A"*
> cannot be taken literally: **DB2A's two defining mechanics do not exist at FL2.**
>
> | Dashboard 2A mechanic | At FL2 |
> |---|---|
> | **Two payoff bays**, staged alternately, with `Staged` / `Blocked` / welded bay states | **One** traversing payoff. There is no second bay to stage into and nothing to alternate |
> | **Visual inspection before unbanding** — oxidation, surface defects, water stains | **Not performed.** [`RocCheckin.md`](../MVP-1/ProjectPlan/Business/Screens/RocCheckin.md) §4.3: *"Not required. The material was inspected at FL1 before it was drawn and flattened"* |
> | `RodStaging.PayoffPosition NOT NULL`, `CK_RodStaging_LineId IN ('FL1','FL3')`, `IsWelded`, `UnstageKind` | Rod-shaped columns with no spool meaning |
>
> **`RodStaging` therefore cannot host it** — recorded as **`OI-118`**, with the table-count consequence in W4.

**What is open, and it is `Critical`.** **`Q41`** asks what an FL2 pre-check-in actually *does*: whether it
persists a record or is a read-only validation; whether it claims a WIP station and holds it or claims and
releases within the transaction; and whether it **gates** check-in or stays `Should` as FL1's does
(`RodPreCheckin.md` §1.4: *"Check-in does not depend on it"*). Our recommendation is in the register.

**Where it should live.** [`SpoolQueue.md`](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) — Dashboard 5A
— already does two-thirds of what Tim described: it lists runnable spools, resolves the order from a scanned
spool, and sits immediately before check-in. What it does not do is **validate and record**; §12 of its own
rules says *"This screen never changes any record."* D1 is the change to that rule, not a new screen.

**Cost.** `FW-224`+ is owed, sized across DB, BE, FE and test, and **additive** to the 3,186 h baseline
following the `FW-219` / `FW-220` precedent — action **A6**.

### 3.2 D2 — a spool carries many rods and many orders

This occupied 06:08 – 17:04 and settled in three steps.

**Step 1 — the case is real, and it is FL1's.** Srikanth: *"FL2 cannot be that case, it's just FL1."* Bob drew
the distinction that matters:

> *"We could technically have two separate orders that are made onto a spool coming off of FL1. When it gets
> checked into FL2, we're only going to make one order at a time out of FL2, but there could be two orders or
> more on the spool going into FL2."*

**Step 2 — the client's own analogues.** Three were offered, and they are worth recording because each is an
existing UA behaviour the flat wire design can be measured against:

| Analogue | Offered by | What it establishes |
|---|---|---|
| A **master coil with two buildups** on the 23 mill, one per order | Tim | Multiple orders off one input is ordinary, not an edge case |
| The slitter **bow-to** operation | Bob | *"Very similar to the bow-to operation"* |
| A **furnace plate** carrying several coil codes | Tim, Bob | The one that also answers identification — see §3.3 and §3.5 |

Yogender's objection was recorded and answered: on the slitters the split is **across the width** and here it
is **across the length**. Bob and Srikanth held that this makes no difference to the record-keeping, and the
mill buildup case is the closer analogue.

**Step 3 — the cardinality, stated by Srikanth at 14:43.**

> *"One spool can contain multiple root coil numbers or A-rods, multiple alphas. Likewise, it can also contain
> multiple order numbers. So spool to A-rods is one to many. In turn, that one A-rod could be on multiple
> orders as well."*

```
Spool  1 ──── many  Rod (A-rod alpha)          ← welded continuous feed at FL1
Rod    1 ──── many  Order                       ← already decided, Q70 / 30 Jul 2026
Spool  1 ──── many  Order  (derived, and planning's to allocate)
FL2    output ── exactly one order at a time    ← Bob, 07:09
```

**The design Srikanth proposed, and where it must land.** He named the existing pattern directly at 15:49:

> *"How do you do it in the web skid coils table? Currently, after the skid is created containing different
> coil numbers or alphas, you create an association in the web skid coils table. They are one to many. Likewise,
> the spool coming out of FL1 should have a separate table … or we can use `wip_skid_coils`, whatever you guys
> prefer. That table should contain the one-to-many relationship. … or you could create an equivalent of
> `wip_coil_orders` and store in that one entry for the combination of the spool, the rod alpha and the order
> number. And whenever it goes through any operation coming out of FL1, you would store that. Going into FL2,
> you would use that. And that's it — the utility ends there."*

> **⚠ Of the two options he offered, only one is permitted.** **`D-32` (18 Aug 2026) cancelled the shared-schema
> migration**: the existing `coils` / scheduling schema is read and written as it stands and **never altered**.
> Writing spool rows into `proddb..wip_skid_coils` would be a new use of a shared table by a new writer, not a
> write into an existing column by an existing pattern — and the closing scope note of `D-32` exists precisely
> to stop that. **Both associations are therefore `FlatWireDB`-local, mirroring the *pattern* and not extending
> the tables.** The precedent is the `Rod` mirror (`D-04`, 29 Jul): a local master mirroring `coils` is what
> lets the FKs be enforced.

**What this confirms and what it adds.** It confirms **`G42`**, whose recommended resolution — *"a
`SpoolTraceability` child keyed on `SpoolAlpha` — source rod alpha, sequence, start and end footage, weld event
reference"* — is now client direction rather than our proposal. It **adds** two things `G42` does not have:

1. **Weight per source alpha.** Tim at 39:38: *"It's how many pounds are on the spool and how many pounds for
   each alpha."* `G42`'s child carries footage; the client asked for weight. Footage → weight is **`Q10`**,
   still open and deliberately without a recommendation, so a derived weight inherits the most widely depended
   on open number in the build. Recorded as **`OI-121`**.
2. **A spool↔order association.** `G42` does not mention orders at all. `SpoolProcessing.OrderNo` is a scalar
   `VARCHAR(50) NULL` and `SpoolCheckin.OrderId` is a scalar `VARCHAR(20) NOT NULL`. Recorded as **`OI-119`**,
   which also picks up a pre-existing contradiction: `SpoolQueue.md` rule **SQ-6** lets an unallocated spool
   check in, which the `NOT NULL` forbids.

**The route set, restated in passing (08:03 – 10:45).** Srikanth reduced the flat wire routes to the same three
the coil business already uses, and Bob confirmed: *"Nope, you got it handled."*

| Flat wire route | Coil-business equivalent | Stock take-out point |
|---|---|---|
| FL1 only · or FL3 hybrid (one roll operation) | **roll** | after FL1 |
| FL1 + anneal | **roll-anneal** | after anneal |
| FL1 + anneal + FL2 | **roll-anneal-roll** | after FL2 |

A stock order may be defined at any of the three, with the remainder restocked — *"so all the three scenarios
are likely."* This is consistent with the operating routes already in `BusinessRules.md` §3; no edit.

### 3.3 D3 and D4 — the carrier is static, stenciled, and typed not picked

**Static, not dynamic.** The question was put by Srikanth at 17:46 — *"Do you want standardized spool numbers,
or are they going to be dynamic spool numbers generated, like as we do for the skid numbers?"* — with the
distinction being the one UA already lives with: *"They're going to be like 2A, 2B, 2C, standard plate numbers.
**I can't make up a plate number, but a skid number I can make up.**"* Tim: *"No, standardized. Yeah."*

> **The dynamic option was raised twice more and rejected both times, and the reason matters.** Tim floated it
> at 40:40 (*"Would the process be easier if the spool numbers were dynamic rather than standard?"*) and
> Yogender agreed; Srikanth pushed back (*"Why should that be dynamic?"*) and Bob closed it at 47:15:
>
> > *"I think you're linking the dynamic numbering of a spool with the creation of a coil code. I think they
> > could still be static — just still set numbers for spool numbers and they select it — and then you're still
> > going to have to generate the welded coil codes on the same spool, and then those have to be handled at FL2
> > later. But I don't think we need dynamic either for the spool number."*
>
> **Dynamic numbering was standing in for the output-alpha problem, which is `D8` and a separate question.**
> Anyone re-reading only the 40:40 exchange will conclude the opposite of what was decided.

**The physical facts, all new to the repository:**

| Fact | Source |
|---|---|
| **30 spools purchased**; a decision on a further **15** was being taken later the same day (→ 45) | Tim, 20:59 |
| **All one standard size.** *"It's all going to be all one standard size. They're all the same"* | Tim, 23:24 |
| **All identical except for identity.** *"They're all identical, except that each is identified separately"* | Srikanth, 22:09 |
| **Marked physically**, as plates are stenciled. *"That would be the plan — to mark the spools with whatever nomenclature we're going to use to identify them"* | Tim, 23:00 |

**D4 — entry mechanism.** Srikanth at 21:07: *"Even if you take 30 or 45, it's a long list to select from the
drop-down. Scrolling and all is not easy. If it's okay with you all, we can make it a **text box** and we can
then **validate that against the database entries** that we have, just for the validation."* Bob and Tim both
assented. This is the answer to the drop-down question Yogender asked at 19:44.

**What this closes and what it opens.** It **closes `SpoolQueue.md` §7 item 1** — the carrier is the reusable
physical article, the material identity is separate, and only the carrier is typed and validated. It opens
**`OI-120`**: *nothing in the schema is a spool carrier.* ⚠ **Schema half closed 22 Aug 2026** — `Spool` is built; the format (`Q42`) and the seed are still open. `SpoolConfiguration` is a **size class**
(`Name` e.g. *15lb / 30lb*, with min/max weight, core and outer diameters) and the client has just confirmed
every spool is one size — so it cannot hold 30–45 instances, and no column links a material `SpoolProcessing` row to the
carrier it is wound on. **`Q42`** asks the format and where the registry is mastered.

### 3.4 D5 — the carrier is captured at the FL1 transaction, and the line stops without it

Yogender put the choice at 23:44 — capture at check-in, or at the transaction. **Bob answered immediately and
gave the reason (23:59):** *"It'll have to be on transaction, because **multiple spools will come out of a
bundle**."* One ~5,500 lb rod yields roughly three ~1,800 lb spools, so a single check-in cannot name them all.

**Tim added the physical reason, and it is the more durable one (25:39):**

> *"I don't know that I would do it at check-in because that's going to be a completely different screen.
> Check-in is going to happen **at the payoff at the other side of the machine**, whereas the spool is going to
> happen at the **output side** of the machine, which is where the operator station is."*

Bob: *"And that's where the space is."* And later, at 27:26: *"It's really far away from each other. So having
it at check-in, they may not know exactly what that spool number is. But having the output side have that
available … once they now walk over towards where the spool is, they can key it in on that screen."*

**It is a hard gate.** Tim, 26:00:

> *"Once you've done the create-spool transaction, the next part of that is what's the next spool coming on.
> **Because you cannot create a spool transaction without a spool to create that transaction.**"*

Srikanth asked directly whether that becomes a showstopper for the next operation starting. Tim: *"Yes."* Bob:
*"Yep."* So the completion transaction **names the next carrier**, and the line cannot continue until it does.

**The physical sequence Tim described (24:20):** take the old spool off → put the new spool on → attach the
material to the spool → thread mode → run. The system's capture point sits inside the completion transaction
that precedes that sequence.

> **This supersedes the May 2026 description** in [`Spool.md`](../MVP-1/ProjectPlan/Business/Spool.md) §"Status
> (May 4, 2026)": *"Alphas are loaded onto a spool number **at the start of the FL1 job**; operators are
> required to input the spool number being used."* The capture point is the **spool-completion transaction**,
> which recurs several times per job — not the job start, which happens once.

**A rider with no home — `Q46`.** Tim, 24:52: *"I would say probably similar to kind of like when you're on a
slitter and you have to select the mandrel size, almost like that. Like we need to know what spool is there.
**We need to know what diameter mandrel is attached.**"* Nothing in the schema or on any screen captures a
per-spool mandrel or core diameter; `SpoolConfiguration` carries a min/max **range** on the size class, which is
not a selection. Whether it is chosen per spool, fixed by the single standard size, or read from the machine is
`Q46`.

### 3.5 D6 — a high-temp label, two per spool, and any coil code resolves it

**The constraint first (Tim, 20:17):** *"Given that we're going to be annealing these, we won't be able to put
the label on them and scan — unless we were to attempt to use one of the thermal labels, but then it would have
to be replaced all the time. Those labels are going to last multiple cycles."*

**The mechanism agreed.** Bob, 30:46: *"I think it'll be the **1½ by 3 inch label**, the ones that are output
from the mills — we'll use those, because you get **2 per label, one for each side of the spool**, slap it on."*
Tim: *"My thought was the high-temp labels with the alphas on them, just like we do the cut labels now that are
going to anneal."* Bob confirmed the sequencing: *"I think that's our first mechanism"*, with the steel plates
below as a later improvement.

**What the label carries.** Tim, 31:18: *"What we would want is we would want that label to print with the
**spool number** — and maybe **list out the alphas** that are attached to it — and then they would be scanning
in the spool number."*

**How it is read, and this is the furnace-plate behaviour again.** Bob, 31:54: *"They're going to scan in the
coil code that's on the spool."* Tim: *"But there's going to be multiple coil codes, right?"* Bob:

> *"Just like the furnace plate — these two come together. **They only have to scan one of the coil codes on a
> furnace plate to get it into anneal.**"*

So **any one identifier on the label resolves the spool**, and the resolution is the system's job. Tim closed
it at 36:00: *"However we scan that in — if we scan that in by the spool number, or if we scan it in by coil
code, we should be able to pull everything that's attached to it."* This is already the shape of
`SpoolQueue.md` rule **SQ-2** (*"the order a scanned spool belongs to is determined **by the system**"*),
widened from one identifier to any of several.

**The later option — A4.** Bob, 29:35: metal number plates *"like a stainless steel etched barcode … they
supposedly can survive through anneals. We just have to weld them onto each side, like tack them on."* He had
looked at these for furnace plates and hit a problem getting them onto multiple corners; a spool needs only two.
He owns the investigation.

**What is open — `Q44`.** [`SpoolCompletionNotification.md`](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md)
refers to printing the labels **nine times** and **never states what is on them**. The field list, the media,
and whether the etched plate replaces or supplements the label are owed. The media and the two-up layout are
recorded as confirmed in W2.

**`OI-115` is narrowed by this.** That open item asks what FL2 spool check-in owes the shared schema, and
specifically whether `SP-00021` should be parked in `WIPStations.CoilNo` — *"a column every legacy reader treats
as a coil number with no FK to stop it."* This call says FL2 scans **a coil code off the spool**, so the natural
value is the **lead rod alpha**, which every legacy reader would read correctly. Recorded as a narrowing on
`OI-115`, not a closure — the reqsum and `actual_start_date` halves are still undefined for a spool.

### 3.6 D7 — the lead alpha, and a conflict that is really two different claims

**The rule as stated.** Bob, 32:14: *"We're planning the whole thing, so we're going to know which one is on the
label and which one we expect to check in. Even though it may have two within the spool, we should know which
one we're expecting to check in. … **Whichever one is going to be the lead in printing the label should always
be the one that is expected for check-in at the next operation.**"*

**Tim's basis for it** — *"Right, because the last one on is going to be the first one off"* — expanded at
35:35: *"Say you have R1A and R2A on the spool and R2A came on last, then R2A would be the first one off on FL2
and R1A would be the last one off. So we'll know that it's the opposite order. We had discussed that the spool
runs in reverse."*

> **⚠ The apparent disagreement is not one.** Yogender, at 37:44: *"At FL1 it will be a continuous operation, so
> there will be no identification that this coil number will be processed first or second, because it will be a
> continuous run. … We can't identify that this is going to be the first one."*
>
> | Speaker | Claim | Status |
> |---|---|---|
> | **Tim** | The **rod alphas** come off in reverse of the order they went on | Physically determined by the take-up; plausible and testable |
> | **Yogender** | The **FL2 output coils** cut from the spool cannot be sequenced in advance | True on a continuous FL1 run, and about a different object |
>
> **Both are correct as stated.** They only look contradictory because *"which one is first"* is being asked
> about two different things. **`Q45`** asks the one question that follows: is *last on, first off* guaranteed
> by the traversing take-up, and is the lead alpha on the label therefore a **fact** or a **prediction**? If it
> is a prediction, the label is advisory and check-in must accept any alpha on the spool.

### 3.7 D8 — alphas are created on a transaction, and the replacement design is not settled

**The design being rejected.** Yogender described the working position at 45:37 and 39:46: the two FL2 output
coil alphas, with their orders, would be **created at the FL1 transaction** and their labels printed then — so
that the material leaving FL1 carried the identities it would be shipped under.

**Srikanth rejected it twice, and the second time is the definitive one (49:40):**

> *"I don't understand the need for this dynamic number that you're talking about. **The alphas need to be
> created based on an actual transaction done and stored accordingly.** So, not that they'll be processed at FL1
> — generate that first at FL2. I don't think that would fly."*

**Tim's alternative, offered at 38:45 and not adopted:**

> *"Do we need to handle this as it being two separate coils, or can we just handle it as being stored alphas in
> a database as **one unit with multiple alphas on it**, and then it doesn't process it to multiple into a coil
> **until the end of FL2**? Because if that was the case, then we would only scan in one thing and it would just
> be a matter of the alpha tracking. … It doesn't need to be X amount of coils on a spool. It just needs to be
> **a wire on a spool with multiple alphas** — and as long as we're tracking where the alphas are as they go on
> and where the alphas are as they come off, we attach them to the finished coil coming off of FL2. So it's not
> a matter of how many coils are on a spool. **It's how many pounds are on the spool and how many pounds for
> each alpha.**"*

This is a coherent model and it is the one the schema is closest to already: `SpoolProcessing` is a material record,
`CoilTraceability` materialises output coils with footage ranges at FL2, and `OI-121`'s weight-per-alpha column
is the missing piece. **But it was not adopted on the call**, and the conversation ended with Srikanth unable to
see the problem the earlier design was solving:

> *"Maybe because I'm biased that it's not a problem. Sorry about that."*

**Resolution mechanism — action A1.** Yogender: *"I will try the scenario and share the exact steps in the
Excel sheet, so it will be easy to understand."* Srikanth: *"That would be helpful"* and, on Bob's suggestion
that pictures would do: **"Pictures and description are both required. So make them come down to my level."**

> **Recorded as an open item, not a decision.** **`OI-121`** carries the weight-per-alpha gap; **`OI-122`**
> carries the scope tension behind the whole exchange. Do not implement either model until A1 is reviewed.

**`OI-122` — the scope tension nobody named on the call.** **Weld capture was descoped on 14 Aug 2026.**
`[TRP §1.5]` records the single-rod spool as a deliberate consequence — *"with no welds the chain is one rod
long"* — and the trial demonstrates exactly that. **This entire call is about the welded multi-rod spool.** So
the requirement just confirmed by the client has no demonstration in the trial, and the artefact that would
prove it (`G42`'s child table) is in its free window precisely *because* nothing writes it yet.

### 3.8 D9 — plan to the maximum output coil weight and work backwards

**What Shray brought.** Tim had shared a Visual Basic script for alpha generation
([`FL Alphas Plus.xlsm`](<FL Alphas Plus.xlsm>), already filed in this folder) whose logic makes **1,800 lb
spools out of FL1 with the remainder as the last spool**. Shray proposed inverting it: *"determine number of
coils first, which would be generated at FL2, then backtrack to the number of spools generated, and based on
that we will calculate the amount of weight on each spool."* His case: a **40,000 lb** order, maximising FL1
output, **over-produces by 400 lb**, and a 400 lb coil is below the customer minimum — so it is scrap.

**The two constraints, in order (Bob, 53:51):**

> *"In general you want to **maximise your spools out of FL1, so you can maximise your anneal capacity**. And
> then in general you always have to take into account the **min and maxes for the output customer** and then
> make multiples of those backwards at the max shippable weight. So there's two sides of it — because if you
> have a customer that is not exactly the multiple you need, you have to make sure that you're **not creating
> waste at the FL2 side**. Because we're welding at the FL1 side, but we're cutting and re-going again at the
> FL2 side."*

**Tim's rule (59:14):** *"It should be rounded to the nearest **output**. Because if the customer's min is 700
lb for the finished coil off of FL2, then putting 400 lb on a spool does nothing for us but create scrap,
because we can't use it."*

**The tie-break Shray asked for and got.** With a customer range of 800–900 lb, which value does the algorithm
divide by? Srikanth: *"Instead of taking 800 or somewhere in between, I would **start with the 900 and work
backwards**."* Tim: *"No, I was going to say the exact same thing. **We should be optimising to the max
weight.**"*

**The method, as worked on the call:**

```
planned weight (order + upper tolerance)  =  44,000 lb
maximum output coil weight                =     900 lb
44,000 / 900                              =      48.8
floor                                     =      48 coils
48 × 900                                  =  43,200 lb   ← plan this
```

No overage, and inside the customer's upper tolerance.

> **⚠ The arithmetic is misstated twice on the recording.** Shray read out **48.8**, Srikanth took the floor to
> **48**, Shray computed **43,200** — and Srikanth then said *"42,200. Yeah, so that's 42,000 total is what
> we'll go with."* **48 × 900 = 43,200.** The method is right and the number spoken over it is wrong; anyone
> working from the audio will implement a figure 1,200 lb light. Recorded here for the same reason the 6 Aug
> ledger recorded the three-times-restated consumption sequence.

**Two further rules stated, and one question left open:**

| | |
|---|---|
| **The input is the planner's planned weight, not the order weight** | Shray: *"Planners usually over-plan the order by some percentage, so I won't be running at the order weight … we will be running this by the planner's planned weight,"* with the existing over-order warning shown in the solution pop-up. Srikanth accepted this |
| **Below the spool size, the order quantity governs** | Srikanth: *"If the order quantity is greater than 1,800 lb it's one thing. If it's less — let's say order quantity is only 1,000 lb — then you go with the order quantity"* |
| **`Q47` — is the maximum the target, or the start of a search?** | Shray asked whether to *"backtrack from 899, 898 and see what minimum scrap we can generate."* Srikanth's answer — *start with 900 and work backwards* — reads naturally as **use the maximum**, and Tim's *optimise to the max weight* agrees. But Shray's question was about **searching downward**, and it was not answered in those terms. Both readings are on the recording |

**Corroborates, does not change:** `Q18` (the customer min/max is the basis, e.g. 900 max / 800 min) and
**`PSG-D32`** (the planned output multiple per line, as distinct from the take-up rating). Review is **Monday
24 Aug with Tim** — action **A2**.

---

## 4. Action items with owners and dates

> **Status at 24 Aug 2026 is tracked in [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) §4**, not here — `A7` is done, `A1` slipped, and `A3` has still not moved.

| # | Action | Owner | Due |
|---|---|---|---|
| **A1** | **The Excel walkthrough of the multi-order / multi-alpha spool scenario**, step by step, with **pictures *and* description** — Srikanth was explicit that pictures alone will not do. This is what unblocks `D8`, and `D8` currently has a rejected design and no adopted replacement | **Yogender** | **before Mon 24 Aug** |
| **A2** | **More dry-run examples of the spool / coil sizing algorithm**, reviewed with Tim. *"I will create some more dry-run examples also"* | **Shray** | **Mon 24 Aug** |
| **A3** | **PLC technical details — still not started.** *"The last two days I was tied up in a DOT audit, so there was not much movement on anything."* This is **`A4` from the 6 Aug ledger, unmoved for two weeks**, and it gates `PLC-Q02` / `PLC-Q04` / `PLC-Q05`, all **Critical** on `[PLC]`'s sign-off sheet, plus commissioning tests `C1` / `C11` | **Tim O.** | **overdue** |
| **A4** | Investigate **stainless-steel etched barcode number plates** that survive anneal, tack-welded one per side. *"I could probably look into that, Tim, to see if they can provide the number plates that have barcodes on them"* | **Bob S.** | — |
| **A5** | Confirm the **stencil nomenclature** for the carriers and the **30 → 45** decision, which was being taken later the same day | **Tim O. / Bob S.** | — |
| **A6** | **Size `FW-224`+ for the FL2 pre-check-in** across DB, BE, FE and test, **additive** to the 3,186 h baseline in `[CE §3b]`, following the `FW-219` / `FW-220` precedent. Blocked on `Q41` for shape | **Nagarro** | **before `S1`** |
| **A7** | Moves onto flat wire after putting a logical end to the Xamarin→MAUI migration. *"Starting Monday I can move on to flat wire, and maybe once my part is done — because that is not that big"* | **Waseem** | **Mon 24 Aug** |
| **A8** | **File the 20 Aug transcript in this folder**, alongside the 6 Aug one, so the ledger's source citation resolves | **Nagarro** | — |

### Risks stated or visible on the call

- **`S1` starts Mon 24 Aug and both `D1` and `D2` land inside it.** `D1` reverses a requirement asserted in a
  `CHECK` constraint; `D2`'s table is in the window `G42` describes as *"free"* only until something writes it.
- **`A3` has not moved in two weeks.** The PLC review was `A4` on 6 Aug — *"not started; next after A1"* — and
  is still not started. Three `Critical` tag confirmations and the Phase-4 tag push sit behind it.
- **`D8` has a rejected design and no adopted replacement.** The alpha-creation moment is load-bearing for the
  FL1 label, the FL2 scan, and the traceability chain — and A1 is the only thing scheduled against it.
- **The trial does not exercise any of this.** Weld capture is descoped, so the multi-rod spool that this whole
  call is about has no demonstration (`OI-122`).
- **Tim dropped at 01:03:11** for his next meeting, before `D9`'s arithmetic was worked through. The 43,200
  figure has not been confirmed by UA.

---

## 5. Propagation waves

**W1 and W2 are complete as of 20 Aug 2026. Everything below them is documented, not done.**

| Wave | Targets | Files | Risk |
|---|---|---|---|
| **W1 — Registers** ✅ | [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) — **`Q37`–`Q40` backfilled** (the `G46` repair) and **`Q41`–`Q47` added**, index counts, priority table, Quick Reference log and the *"no numbering holes"* paragraph all realigned · [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) §11 — **`OI-115`/`OI-116` backfilled**, **`OI-118`–`OI-122`** added · [GapsRegister.md](../MVP-1/ProjectPlan/Development/GapsRegister.md) — **`G42` updated** (client-confirmed, weight-per-alpha, spool↔order sibling, window closes at `S1`), **`G46` added** | 3 | L |
| **W2 — The two specifications** ✅ | [SpoolQueue.md](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) **v1.4** — §1.2 rationale, §3.2 order-set, §3.5 carrier-vs-material, §4 fields, §6 confirmed decisions, §7 item 1 **closed**, §8 assumption 1 **replaced**, and the stray change-history row at the foot removed · [SpoolCompletionNotification.md](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md) **v2.3** — next-carrier capture as a hard gate, mandrel diameter, and the **label content that this document has never stated** | 2 | M |
| **W3 — Requirement text** | [BusinessRequirements.md](../MVP-1/ProjectPlan/Business/BusinessRequirements.md) — **`FR-031` superseded in place, never renumbered**; new **`FR-533`+** for the FL2 pre-check-in; `FR-172`'s spool-side genealogy given a table at last · [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) **§2.2** (line-capability table), **§4.1** (`FR-031`), **§5.3a** (the DB5A rationale), the **`RodStaging` schema block** (its `LineId` CHECK note), **§5.12** (`FL2PO` *"deliberately not created"*), the **`POST /staging/rod`** block (the `422`) · [VisionAndScope.md](../MVP-1/ProjectPlan/Business/VisionAndScope.md) line-capability table and [PLCTagSpecification.md](../MVP-1/ProjectPlan/Architecture/PLCTagSpecification.md) line-capability table — ⚠ **these two are the ones that do not cite `PCI002`**, so they will not appear in the obvious grep; `[PLC]` is **prose only**, it owns every tag path string and this change adds none · [FlatWireShopfloorDashboards.md](../Analysis/FlatWireShopfloorDashboards.md) — not a requirements source, but it states the exclusion twice and is read as background | 4 | **H** |
| **W4 — Schema + DDL** | ⚠ **The table count moves 28 → 29** once `OI-118` resolves to a `SpoolStaging` table, and **again** for `SpoolTraceability` and the spool↔order association (`G42`, `OI-119`, `OI-121`) — so plan for **28 → 31** and re-derive in one sweep, not incrementally. *"34 tables · 57 FKs · 69 index statements · 1 procedure · 1 trigger"* is a **published, verified** figure cited in **20+ files** (`CHANGELOG.md` ×10, master spec ×8, `Architecture.md` ×4, `DatabaseDesign.md` ×4, `SQL/README.md` ×4, `FlatWire_DDL_RunAll.sql` ×2, `CLAUDE.md` ×2, `MVP2-SCOPE.md` ×3, `FlatWireSchema_Mapping.md`, `GapAnalysis.md`, `VisionAndScope.md`, `Orchestration.md`, `FW-142`, `FW-143`, `FW-223`, `TrialRunPlan.md`). Files: `FlatWire_DDL_01_Lookup.sql` (the `Spool` registry), `_03_Materials.sql` (`SpoolProcessing.OrderNo`, `ParentRodAlpha`), `_04_Runs.sql` (`CK_RodStaging_LineId`, the new staging table), `_06_ForeignKeys.sql`, `_07_Indexes.sql`, the seed files, and [FlatWireSchema_Runs.md](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Runs.md) / [FlatWireSchema_Materials.md](../MVP-1/ProjectPlan/Database/Schema/FlatWireSchema_Materials.md). **Verify by teardown → `RunAll` → idempotent re-run**, and publish the new counts once | 10+ | **H** |
| **W5 — Contracts + shared schema** | [APIs.md](../MVP-1/ProjectPlan/Backend/APIs.md) — `POST /precheckin` loses its `lineId = FL2` → `422` branch; `GET /spools` returns an order **set**; `POST /checkin/spool` selects one order from the set · [Integration.md](../MVP-1/ProjectPlan/Architecture/Integration.md) §8.0 — **`OI-115` narrowed**: the FL2 station claim is the **lead rod alpha**, not `SP-00021` · [`10_CommonDB_Insert_WIPStations_FlatWire.sql`](../MVP-1/ProjectPlan/Database/Scripts/10_CommonDB_Insert_WIPStations_FlatWire.sql) — **`FL2PO` must now be created**, against a comment that says it is deliberately absent. ⚠ **Interacts with `OI-26`** (does FL3 share FL1's VPS?) and **`G21`** (`UX_RodStaging_Bay` scope), neither closed | 4 | **H** |
| **W6 — Mockups** | `dashboard_5a_spool_queue.html` — the pre-check-in action, the order **set**, the carrier column, and the `PCI002` comment at line 24 · `dashboard_2a_rod_precheckin.html` — reference only; **do not point it at FL2**, §3.1's table says why · `dashboard_1_line_status.html` — its line-capability strip states the exclusion · the spool-completion dialog — next-carrier field and the label preview. **Each change must be reflected in its owning specification** | 3 (+2 specs) | M |
| **W7 — Plans, tests, effort** | [TaskBreakdown.md](../MVP-1/ProjectPlan/Development/TaskBreakdown.md) — **`FW-224`+ minted, additive**; line 1629's *"FL1/FL3 only — `PCI002` excludes FL2"* · [CapacityAndEffortModel.md](../MVP-1/ProjectPlan/Development/CapacityAndEffortModel.md) §3b — **a new additive sheet, never an in-place edit of a total** · `phase-04` line 50 and **`phase-08`** (the FL2 spool check-in phase, which states the exclusion and is where an FL2 pre-check-in would land) · [TrialRunPlan.md](../MVP-1/ProjectPlan/Development/TrialRunPlan.md) §1.5 (`OI-122`) · [TestCases.md](../MVP-1/ProjectPlan/Testing/TestCases.md) — an existing case asserts the `422`, and new cases are owed for the FL2 pre-check-in and the multi-order spool | 6 | M |

**Blocked on client input:** W3's `FR-533`+ text and W4's staging table both need **`Q41`** (what an FL2
pre-check-in does); W4's carrier registry needs **`Q42`** (format and mastering); W4's weight column needs
**`Q10`**, which is the oldest and most depended-on open number in the build; W6's label preview needs **`Q44`**.
**W4's genealogy child is *not* blocked** — `G42` specifies it, the client has now confirmed it, and its free
window closes at `S1`.

**Convention reminders for every wave:** update **Last Updated** on each document touched and append its row to
[`../CHANGELOG.md`](../CHANGELOG.md) — **not to the document itself**; a client-review specification states its
version in its `**Version:**` header and **nowhere else**, and the same value is stamped on the `CHANGELOG.md`
row; strike resolved register items with a `DECIDED (date)` note and **never delete them**; keep `Q##`
numbering contiguous; **supersede requirement ids in place, never renumber**; phase files must not restate
foundations text; **no tag path string outside `PLCTagSpecification.md`**; and backlog story headings, hours and
sprint cells are **parsed by three `.xlsx` generators** — no strikethrough in them.

---

## 6. Send back to the client (open, blocking, or owed)

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | **`Q41`** — what does an FL2 pre-check-in *do*? Persist or validate only; claim-and-hold or claim-and-release; gate check-in or stay `Should` | Tim O. / Bob S. | `FR-533`+, `FW-224` sizing, the W4 staging table |
| 2 | **`Q42`** — the carrier identifier format and where the registry is mastered; and the **30 → 45** confirmation (A5) | Tim O. / Bob S. | The `Spool` seed, DB5/DB5A entry validation |
| 3 | **`Q43`** — how many orders may one spool carry, and does FL2 check-in **choose** the order or inherit it? | Tim O. / Planning | `SpoolCheckin.OrderId`, the spool↔order association |
| 4 | **`Q44`** — the label **field list**, and whether the etched plate replaces or supplements the high-temp label (A4) | Tim O. / Bob S. | FL1 label printing, the FL2 scan |
| 5 | **`Q45`** — is *last on, first off* guaranteed by the traversing take-up, making the lead alpha a fact rather than a prediction? | Tim O. / Engineering | Whether FL2 check-in may refuse a non-lead alpha |
| 6 | **`Q46`** — mandrel / core diameter at FL1: selected per spool, fixed by the one standard size, or read from the machine? | Tim O. | The completion transaction's field set |
| 7 | **`Q47`** — is the maximum coil weight the optimisation target, or the start of a downward search? | Tim O. / Planning | Shray's algorithm (A2) |
| 8 | **`Q10`** — the footage-to-weight dimensional basis. **Now also gates weight-per-alpha on the spool** (`OI-121`). It is the most widely depended-on open number in the build and deliberately carries no recommendation | Tim O. / Bob S. | Every derived weight, and now the genealogy |
| 9 | **`A3` — the PLC review**, carried from 6 Aug and unmoved. Closes `PLC-Q02` / `PLC-Q04` / `PLC-Q05`, all Critical | Tim O. / Engineering | Phase 4 tag push, commissioning `C1` / `C11` |
| 10 | **`Q37`–`Q40`** — the four IT sign-off values for the check-in write-back (transaction token, WIP-log status, stamping the rod's `coils` row, delete-vs-orphan on reversal). **Registered at last in W1** | Tim O. / IT | `FW-220` reaching any shared environment |
| 11 | **`OI-115`** — the FL2 spool check-in shared write set. **Narrowed by `D6`** but not closed; it **blocks building**, not just deploying | IT / Architecture | The FL2 half of `FW-220` |
| 12 | Carried and still owed: **`Q73 item 6`** (multi-order-last without welding), **`Q31`** (no-weld disposition), **`Q32`** / **`PSG-Q29`** (dancer mode), the **`PSG-D##`** coefficient set, the **QC reduction rules**, **`Q18`**'s order field, **`Q22`** tolerance values, **`Q26`** panel resolution | Tim O. / Bob S. / QC / IT | Seed data, Phase 1 canvas, Phase 4, `FW-013` |

---

## 7. Non-flat-wire, for the record (01:07:31 – end)

Recorded because the call is one meeting and the flat wire team was on it, but **none of this touches any
register.** Waseem reported the **Xamarin → MAUI migration** functionally complete and running, with the
handheld screens migrated in code but not yet on the MVVM pattern used for the transfer-operator screens — 23
of 24 screens still owed a look-and-feel pass, a handheld menu item to be added with Sushant, and scanner flows
(modify load) not yet working. Srikanth's call: **finish tomorrow if it is one more day, otherwise put a logical
end to it and move to flat wire on Monday** — *"if it's one more week … we might be cutting very close on the
flat wire"* — which is where **A7** comes from. The handheld release was verified live during the call (D-72
schedule, cooling chamber, warehouse) and published. Agreed separately: releases must reach Srikanth **at least
a month ahead**, not at the wire; Waseem to find a **sanity-test route** that is not his own machine (TestFlight
is iOS-only, so a Windows cross-platform build was floated); the certificate expiry notification to be moved
earlier; and the **periodicity data-recording app is still on .NET 2.0** and should be migrated this year. The
21 Aug 07:30 call is **half an hour of flat wire**, then Jaspreet on **Phase-2 deployment dates**.

---

## 8. The 24 Aug 2026 call — see its own ledger

The following week's call has its **own document**:
**[ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md)**. It is recorded there and not here,
so that nothing in it has two homes.

**What it does to this ledger**, in one paragraph, so a reader of this file is not left with a stale picture:

- **`D8` is completed, not changed.** §3.7 records the FL1-pre-generation design as rejected on **Srikanth's
  word alone**, with Tim's *pounds-per-alpha* alternative unadopted. On 24 Aug **Bob and Tim both agreed on
  the record**, and **check-in** was named as the excluded moment for the first time. It settles **when**, not
  **what** — `OI-121`, `Q43` and the choice between the two models are all untouched, and **`A1` is still the
  only thing scheduled against the replacement design**.
- **Action status:** **`A7` done** · **`A1` slipped** (one day, and it is singular) · **`A3` not raised by
  either side and now three weeks unmoved** · `A2`, `A4`, `A5`, `A6` not reported · **`A8` still owed**, with
  two transcripts now unfiled. Full table in that ledger's §4.
- **The `S1` risk at the head of §4 has materialised.** *"`S1` starts Mon 24 Aug and both `D1` and `D2` land
  inside it"* — on the evidence of the 24 Aug call, **`S1` opened with requirements work only and the build
  starts 31 Aug**, three resources short, and the 30 Sep finish no longer holds. **Deliberately not propagated
  in either ledger**; it is action `A9` there.
- **Nothing else here moved.** No decision reversed, no wave unblocked, and every item on §6's send-back list
  stands exactly as written.

---

## Related Documents

| Document | Why |
|---|---|
| [FlatWireOpenQuestions.md](../Analysis/FlatWireOpenQuestions.md) | Authoritative `Q##` register — W1; `Q37`–`Q47` |
| [FlatWire_MasterSpecification.md](../LatestDocument/FlatWire_MasterSpecification.md) | `OI-##` register §11 and the reconciliation authority — W1, W3 |
| [GapsRegister.md](../MVP-1/ProjectPlan/Development/GapsRegister.md) | `G42` client-confirmed, `G46` added — W1 |
| [SpoolQueue.md](../MVP-1/ProjectPlan/Business/Screens/SpoolQueue.md) | The most affected specification — its §7 item 1 is what `D3`–`D6` answer |
| [SpoolCompletionNotification.md](../MVP-1/ProjectPlan/Business/Screens/SpoolCompletionNotification.md) | Where `D5` and `D6` land — and it has never stated what the label prints |
| [RodPreCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RodPreCheckin.md) | §1.3 excludes FL2; `D1` reverses it, and §3.1 explains why it cannot simply be pointed at FL2 |
| [RocCheckin.md](../MVP-1/ProjectPlan/Business/Screens/RocCheckin.md) | §4.3 is the source of *"spool inspection not required"*, which shapes `Q41` |
| [Spool.md](../MVP-1/ProjectPlan/Business/Spool.md) | Its May 2026 *"at the start of the FL1 job"* is superseded by `D5` |
| [Integration.md](../MVP-1/ProjectPlan/Architecture/Integration.md) | §8.0 / §8.1 — where `OI-115` and `Q37`–`Q40` were minted without reaching a register |
| [ClientCall_2026-08-06_SyncPlan.md](ClientCall_2026-08-06_SyncPlan.md) | The precedent for this document; its `A4` is this call's `A3` |
| [ClientCall_2026-08-24_SyncPlan.md](ClientCall_2026-08-24_SyncPlan.md) | **The following week's call — §8 points at it.** It completes this ledger's `D8`, tracks `A1`–`A8` to status, mints **`Q87`**, and records the schedule re-baseline against `S1`'s 24 Aug start |
| [FL Alphas Plus.xlsm](<FL Alphas Plus.xlsm>) | Tim's alpha-generation calculator — the script `D9` inverts |
