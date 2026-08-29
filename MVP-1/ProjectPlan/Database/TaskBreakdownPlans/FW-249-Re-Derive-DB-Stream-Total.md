# FW-249 · Re-derive the DB-stream total on the current basis

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Ready to start — and it must run AFTER [`FW-250`](FW-250-Development-Plan-Xlsx-Multi-Stream.md)**
**Owner:** BA stream *(the figure is `[CE]`'s)*
**Audience:** The analyst building `FW-249`
**Shortcode:** — *(implementation plan, derived from `[TB §7]` and `[CE]`; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Database/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Eight BA hours, no code, and **four details decide whether it
> is right.**
>
> **Additive, never by substitution.** `[CE §8]` is explicit that substituting a number into a
> derivation without re-deriving it *"makes the arithmetic lie."* This is the whole discipline
> of the story.
> **⛔ It must run after `FW-250`.** That generator **silently drops eleven stories**, five of
> them from the very set this total covers. Deriving now bakes the defect into the figure
> `[CE]` publishes.
> **The DB stream has no current total anywhere.** `[TB §7.3]`'s column is pre-`D-32` and its
> 119-story scope excludes `FW-219`–`FW-231` outright.
> **`[CE]` publishes three different Phase-1C figures**, and naming which one a reader should
> cite is half the deliverable.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-249 · Re-derive the DB-stream total on the current basis
> **Hours:** 8 h BA · **Priority:** Medium · **Sprint:** S1 · **Phase:** — · **Stream:** BA
>
> > **No current DB-stream total is published anywhere.** `[TB §7.3]`'s DB column is on the
> > **pre-`D-32`** Phase-1C basis, and its 119-story scope **excludes `FW-219`–`FW-231` entirely** —
> > its Phase-4 DB cell is `FW-159` alone, so `FW-220` (DB 24), `FW-221` (9), `FW-222` (2), `FW-223`
> > (DB 10) and `FW-225` (DB 12) are in none of it. `[CE §8]` separately records that 1C was costed
> > against 22 tables and the build is larger.
> >
> > ⚠ **`[CE]` owns the figure, and this is why the total was not re-derived in the orchestration
> > files:** effort figures propagate to roughly twenty files, and `[CE §8]` is explicit that
> > substituting a number into a derivation without re-deriving it *"makes the arithmetic lie"*.
>
> **Acceptance Criteria:**
> - [ ] A DB-stream total derived from the **current** story set — post-`D-32` 1C, the 33-table build, and `FW-219`–`FW-231` included
> - [ ] ⛔ **Published in an ADDITIVE new sheet or section**, never by substituting into `[CE §3]`, `§3b`, `§3c` or `[TB §7.3]`'s existing arithmetic
> - [ ] The `FW-232`–`FW-249` additive set is shown **separately** and is not folded into the MVP-1 baseline
> - [ ] Every figure it supersedes is named, with the section that carries it, so a reader knows which of `[CE §3]`'s three 1C figures to cite
> - [ ] ⚠ **`[CE §8]`'s known 1C understatement is carried forward, not silently absorbed**
> - [ ] The 114-story / 3,186 h baseline is **unchanged** by this exercise, or the change is called out as a re-baseline in its own right
>
> **Rate-card basis (§2):** not a rate-card unit — an estimation pass across `[TB §7]`'s DB cells and `[CE]`'s three 1C bases, priced at one BA deliverable = **8 h**
> **Dependencies:** — *(reads `[TB §7]` and `[CE]`; blocks no build)*
> **Blockers:** —

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| Re-baselining MVP-1's 3,186 h | ⛔ **Not this story** — AC 6 says it stays unchanged, or the change is its own exercise |
| The schema object counts | `[DBD §6.2]` — a **different kind of number**; do not conflate |
| Fixing the generator | [`FW-250`](FW-250-Development-Plan-Xlsx-Multi-Stream.md) — a **hard predecessor** (§2.1) |
| Publishing the `.xlsx` | `FW-250`'s `P-158` — reviewer-gated |
| Any build work | This story **blocks no build** and is blocked by none |

### 1.2 What already exists

| Thing | State |
|---|---|
| `[TB §7.3]`'s roll-up | ⚠ **Pre-`D-32` 1C basis**; 119-story scope; Phase-4 DB cell is `FW-159` **alone** |
| `[CE §3]` | 1C at **215 h** — *"the base of record"* |
| `[CE §8]` | Records **221 h** without carrying it into §3, **and** records that 1C was costed against **22 tables** while the build is larger |
| `[CE §3c]` | Publishes the post-`D-32` **138 h** additively |
| `[CE §3b]` | ⛔ **Has no Phase 1C row at all** |
| **A current DB-stream total** | ⛔ **Does not exist anywhere** |
| The `FW-232`–`FW-250` set | ✅ Carded, **additive to `[CE §3b]`, in no published total** |
| `build_development_plan_xlsx.py` | ⛔ **Drops eleven stories silently** — see §2.1 |

---

## 2. The four details

### 2.1 `FW-250` is a hard predecessor

`build_development_plan_xlsx.py` cannot parse the parenthesised multi-stream hours form, and
**skips those stories silently**. The casualties are `FW-202`, `FW-219`, `FW-220`, `FW-223`,
`FW-225`–`FW-231`, plus five of the new set.

⛔ **That is very nearly the exact population this story exists to add.** AC 1 requires
`FW-219`–`FW-231` included; the tool most likely to be used to sum them **cannot see them**.

**So: `FW-250` first.** ⚠ And do not work around it by summing by hand — a hand-summed total
published in `[CE]` has no reproducible derivation, which is the property that makes the
existing figures citable.

### 2.2 Additive, and what that actually means

`[CE §8]`: substituting a number into a derivation without re-deriving it *"makes the
arithmetic lie."* The failure mode is concrete — `[CE §3]`'s 1C sits inside a chain where QA is
20 % of a dev base and contingency 15 % of base+BA+QA. **Replacing the dev base leaves the QA
and contingency rows computed from the old one**, and the total still looks arithmetically
sound.

**So the deliverable is a new section that derives its own chain end to end**, names what it
supersedes, and **changes no existing cell.** The precedent is `[CE §3c]`, which published
`D-32`'s 138 h additively beside a §3 that still reads 215.

⚠ **Effort figures propagate to roughly twenty files.** An additive section propagates to none
of them, which is the point.

### 2.3 Three 1C figures, and the reader needs to be told which to cite

`[CE §3]` 215 h · `[CE §8]` 221 h · `[CE §3c]` 138 h · `[CE §3b]` no row at all. AC 4 requires
each superseded figure to be **named with the section that carries it**.

⚠ **This is the most valuable half of the story** and the easiest to skip. The total itself is
arithmetic; the citation map is what stops the next reader picking the wrong one — which is
what produced this gap.

### 2.4 The understatement is carried, not absorbed

`[CE §8]` records that 1C was costed against **22 tables** and the build is larger. AC 5 says
carry it forward.

⛔ **Do not quietly fold a correction for it into the new total.** It is a *known,
owned* understatement with a section that states it. Silently absorbing it would make the new
figure disagree with `[CE §8]` for a reason no reader could reconstruct. **State it, size it if
possible, and leave it attributed.**

---

## 3. Build order

1. ⛔ **Confirm [`FW-250`](FW-250-Development-Plan-Xlsx-Multi-Stream.md) has landed** and the
   eleven stories parse (§2.1). **Do not start otherwise.**
2. **Enumerate every DB-bearing story from `[TB §7]`** — including the DB halves of
   multi-stream cards (`FW-219` DB 26, `FW-220` DB 24, `FW-223` DB 10, `FW-225` DB 12,
   `FW-229` DB 6, `FW-230` DB 4, `FW-231` DB 12, `FW-202` DB 8, `FW-090` DB 20, `FW-102` DB 4,
   `FW-110` DB 8, `FW-201` DB 8, `FW-234` DB 4, `FW-238` DB 8, `FW-243` DB 4, `FW-247` DB 24).
   ⚠ **Quote, never restate** — every figure comes from its card.
3. **Separate three populations**: the MVP-1 baseline's DB hours · the `FW-232`–`FW-250`
   additive set (AC 3) · anything out of MVP-1 scope.
4. **Derive the chain end to end** on the current basis — dev base, BA, QA at 20 %,
   contingency at 15 % — **not** by substituting into an existing row (§2.2).
5. **Build the citation map** (§2.3): every superseded figure, its section, and which to cite.
6. **Carry `[CE §8]`'s understatement forward**, attributed (§2.4).
7. **Publish additively** — a new `[CE]` section or sheet. ⛔ **Change no existing cell**,
   in `[CE §3]`, `§3b`, `§3c` or `[TB §7.3]`.
8. **Confirm 114 stories / 3,186 h is unchanged** (AC 6), or declare a re-baseline explicitly.

---

## 4. Decisions this plan makes

> The `P-##` series belongs to [`Backend/TaskBreakdownPlans/`](../../Backend/TaskBreakdownPlans/)
> and is continuous across the repository; `P-01`–`P-165` precede this story.

### `P-166` — `FW-250` is a hard predecessor, and the total is not hand-summed

§2.1. The generator cannot see most of the population this story adds, and a hand-summed figure
has no reproducible derivation — the property that makes `[CE]`'s existing figures citable at
all.

**Fallback:** if `FW-250` slips, publish the enumeration and the citation map **without** the
total. Those are the durable halves; the arithmetic is the cheap half.

### `P-167` — the citation map is a deliverable in its own right

§2.3. Four sections carry four different 1C answers. A reader who cannot tell which to cite
will pick one at random, which is how this gap formed.

### `P-168` — the new section derives its own chain and touches no existing cell

§2.2, and it is `[CE §3c]`'s established precedent.

---

## 5. Verification

**No code, no tests.** Verified by review against `[CE]` and `[TB §7]`.

| Check | Expected |
|---|---|
| **Predecessor** | `FW-250` landed; the eleven stories parse (`P-166`) |
| Population | Every DB-bearing card in `[TB §7]` is in the enumeration, **DB halves of multi-stream cards included** |
| **Quoted not restated** | Every figure traces to its card. No number originates here |
| **Additive** | `git diff` on `[CE §3]`, `§3b`, `§3c` and `[TB §7.3]` shows **no changed cell** (`P-168`) |
| Own chain | The new section derives dev base → BA → QA → contingency itself |
| Separation | The `FW-232`–`FW-250` set is shown **separately** and folded into no MVP-1 baseline (AC 3) |
| **Citation map** | All four 1C figures named with their sections, and one identified as the one to cite (`P-167`) |
| Understatement | `[CE §8]`'s 22-table basis carried forward **and attributed**, not absorbed (AC 5) |
| Baseline intact | 114 stories / 3,186 h unchanged, or an explicit re-baseline (AC 6) |
| No propagation | The ~20 files quoting `[CE]`'s totals need **no edit**. If any does, the publication was not additive |

---

## 6. Handoff

`[CE]` owns the figure and is where it publishes. The DB `Orchestration.md` **states no total
and must continue not to** — it quotes `[TB §7]` per story, and §8.1 finding 6 is the record of
why. ⚠ **This story does not change that**: it gives the DB stream a citable total in `[CE]`,
not a total in its own index.

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⛔ **`FW-250`** | **Hard predecessor.** Eleven stories are invisible to the generator until it lands (`P-166`) |
| **`[CE §8]`** | The 22-table 1C understatement — **carried, not absorbed** (AC 5) |
| **`[CE §3b]`** | Has **no Phase 1C row**. The new section must not create one there |
| **§8.1 finding 6** | The DB Orchestration's record of why no total exists. ✅ **This story closes it** |
| **`[DBD §6.2]`** | Object counts are a **different kind of number**. Do not conflate the two exercises |
