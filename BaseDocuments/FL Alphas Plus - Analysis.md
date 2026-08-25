# FL Alphas Plus — Alpha Creation Logic, Analysed

**Project:** Flat Wire Mill Implementation
**Last Updated:** August 21, 2026
**Document Type:** Analysis of a client-supplied source file — **not a specification, not citable as a requirement**
**Subject:** [`FL Alphas Plus.xlsm`](<FL Alphas Plus.xlsm>) — Tim O'Brien, created 25 May 2026
**Companion:** [`FL Alphas Plus - Module1.bas`](<FL Alphas Plus - Module1.bas>) — the recovered VBA source, verbatim

---

## What this is, and why it is filed here

`FL Alphas Plus.xlsm` is the workbook Tim referenced on the **20 Aug 2026 client call**, where Shray described
inverting its logic to avoid over-planning. It is not a mock-up: it is a **complete, working FL1 → FL2 production
planner and alpha generator** in 561 lines of VBA, and it is the **only end-to-end implementation of the whole
rod → spool → coil chain that exists anywhere** — in this repository or in the delivered contracts.

It is filed in `BaseDocuments/` because it is **client-authored source material**, alongside the `.xlsm` it was
extracted from. Nothing here is a requirement. Where a finding needs to become one, that happens in
`MVP-1/ProjectPlan/Business/` and is cited from there.

> **How the source was recovered.** The VBA lives in `xl/vbaProject.bin`, an OLE (CFB) container whose module
> streams are MS-OVBA RLE-compressed. **`Module1`'s text begins at offset 22177**, behind a ~22 KB performance
> cache — a naive scan for the `0x01` container signature finds a false start at offset 61 and yields garbage that
> still *looks* like source for the first few hundred bytes. The correct offset comes from the **`dir` stream's
> `MODULEOFFSET` record (id `0x0031`)**, which is itself compressed. The extractor is at
> [`MVP-1/ProjectPlan/Tools/extract_vba.py`](../MVP-1/ProjectPlan/Tools/extract_vba.py); re-run it if the workbook
> is ever updated.

---

## 1. The workbook

Three sheets and one code module.

| Sheet | Role |
|---|---|
| **`INPUT`** | Parameters and a computed dashboard |
| **`FL1`** | Output — one row per spool: `Spool #` · `Spool Weight` · `Rod Consumption` · `Spool Alpha` |
| **`FL2`** | Output — one row per output coil: `Stop #` · `Stop Weight` · `Source Alpha` · `Stop Alpha` |

**The `INPUT` cell map**, read directly from the code:

| Cell | Meaning | Value in the shipped run |
|---|---|---|
| `C2` | `startRod` — the first rod alpha | `R00001` |
| `C3` | `rodWeight` | **4,000 lb** |
| `C4` | `orderWeight` | 40,000 lb |
| `C5` | `targetSpoolWeight` | 1,800 lb |
| `C6` | `stopMin` — customer minimum coil weight | 800 lb |
| `C7` | `stopMax` — customer maximum coil weight | 900 lb |
| `H2`–`H6` | Dashboard: rodsUsed · spools · stops · totalOutput · efficiency | 11 · 23 · 45 · 40,400 · 91.82 % |

⚠ **The 4,000 lb rod weight is a third figure.** The 20 Aug transcript uses **~5,500 lb**; the delivered
contracts state **8,690–8,840 lb** (open item **`OI-97`**). It is an input cell, so this is a data variance rather
than a defect — but every count in the shipped run depends on it.

**Entry points:** `RunProduction` (calls the three below) · `GenerateFL1_Optimized` · `GenerateFL2_Optimized` ·
`UpdateDashboard` · `ResetSystem`.

---

## 2. The alpha scheme

**It is derivational and recursive.** Each generation appends a letter to its parent's identity:

```
rod          R00001        IncrementRod  = Left(x,1) & Format(CLng(Mid(x,2)) + 1, "00000")
 └ spool     R00001A       currentRod    & AlphaLetter(alphaIndex)       alphaIndex resets to 1 per rod
    └ stop   R00001AA      Segments(i).Alpha & AlphaLetter(stopAlphaCounter)
```

`AlphaLetter` is Excel-column base-26:

```vba
Do While n > 0
    n = n - 1
    r = Chr(65 + (n Mod 26)) & r
    n = n \ 26
Loop
```

So 1→`A`, 26→`Z`, **27→`AA`**.

### A welded spool carries one alpha per segment, in a single cell

FL1 row 4: `Rod Consumption = R00001 (400 lbs) / R00002 (1400 lbs)` and `Spool Alpha = R00001C - R00002A`.

**The separators are consistent and load-bearing:** `" / "` joins **consumption facts**; `" - "` joins
**alphas**. A hyphen inside an alpha cell means **the cell holds two identities**.

### ⚠ The concatenated form is ambiguous by construction

`R00001A` + a stop suffix of `A` gives **`R00001AA`**. And `R00001` + `AlphaLetter(27)` also gives
**`R00001AA`**. The same string means *"rod 1 → spool A → stop A"* **or** *"rod 1 → 27th segment"*.

It cannot be decomposed without external knowledge, and it **collides outright** once a rod exceeds 26 segments.
**If the scheme is adopted, store the generations as separate columns and treat the concatenation as display
only.**

### The stop suffix is a per-spool stop index, not a per-parent sequence

This is the finding most likely to be mis-read. In `GenerateFL2_Optimized`:

```vba
alphaParts(alphaPartCount) = Segments(workingIndex).Alpha & AlphaLetter(stopAlphaCounter)
```

`stopAlphaCounter` starts at **1 per spool** and increments **per stop** — so **every alpha part within one stop
receives the same letter**.

That explains an apparent gap: FL2 stop 14 is `R00004AB - R00003CB` and **there is no `R00004AA` anywhere**.
`R00004A`'s material appears only in its spool's *second* stop, so it only ever receives `B`. **This is correct
behaviour, not a defect** — but it means `ChildAlpha` + suffix is **not a unique key**, and the letter answers
*"which stop of this spool"* rather than *"which coil from this alpha"*.

### LIFO is deliberate, and it answers the lead-alpha question

The stop alpha is assembled in **reverse consumption order**, by an explicit loop:

```vba
For revIndex = alphaPartCount To 1 Step -1
    If stopAlphaText <> "" Then stopAlphaText = stopAlphaText & " - "
    stopAlphaText = stopAlphaText & alphaParts(revIndex)
Next revIndex
```

So source `R00001C (400 lbs) / R00002A (500 lbs)` yields **`R00002AA - R00001CA`** — the segment that went on
**last** is named **first**, because it comes off first. The tool treats *last on, first off* as a **fact**.

This bears directly on **`Q45`**, which asks whether the label's lead alpha is a fact or a prediction. ⚠ **A tool
is not a client statement** — confirm the unwind direction with engineering before making it a validation.

---

## 3. The data structure

The global the code builds at FL1 and consumes at FL2:

```vba
Public Type SegmentType
    Rod     As String
    Alpha   As String
    Weight  As Double
    SpoolID As Long
End Type
Public Segments() As SegmentType
Public SegmentCount As Long
```

**Confirmed by the client on 21 Aug 2026 as their working data structure.** Array order supplies the sequence.

⚠ **There is not one footage variable in 561 lines — every allocation is in pounds.** The client's model is
**weight-primary**. Any design that makes footage the primary quantity and weight a derived or deferred value is
inverting the client's own model, and should say so deliberately rather than by omission.

---

## 4. Two rules the code states that no repository artifact does

> ### `' RULE: A STOP MAY USE MULTIPLE ALPHAS BUT ONLY FROM THE SAME SPOOL`
>
> Enforced by the loop, which breaks out when `Segments(workingIndex).SpoolID <> currentSpool`.
> **A coil never spans two spools.** So a single spool reference per output coil is correct **by design**, not a
> modelling limitation.

> ### `' FL1 … PURPOSE: 1. Build production spools  2. Ensure FL2 can ALWAYS create valid stops  3. Minimize overproduction`
>
> Implemented as **`VALIDATE FINAL STOP POSSIBILITY`** (FL1) and **`PREVENT INVALID FINAL REMAINDER`** (FL2).
> **FL1 spool sizing is already constrained by FL2's ability to make shippable coils** — which is precisely the
> inversion proposed on the 20 Aug call, built three months earlier. Any planning-side coil-weight question
> (**`Q47`**) should be answered against this tool rather than designed fresh.

---

## 5. The shipped run, and where its numbers come from

With the `INPUT` values above: **11 rods · 23 spools · 45 stops · 40,400 lb · 91.82 %**.

**The 400 lb overproduction discussed on the call is `VALIDATE FINAL STOP POSSIBILITY` working as intended.**
40,000 ÷ 1,800 leaves a 400 lb tail; `400 < stopMin (800)`, so the final spool is raised to **800 lb**:

```
22 × 1,800  +  800  =  40,400
```

A 400 lb spool would have yielded an unshippable coil. **Not a bug** — and the call discussed the number without
identifying the rule producing it.

**Efficiency is metallic yield:** `totalOutput / (rodsUsed × rodWeight)` = 40,400 / 44,000 = **91.82 %**. That is
a working definition for a figure the repository currently has none of (**`OI-60`** / **`Q11`**).

**Welded spools are a third of the total.** Counted off the FL1 sheet: **14 of 23 spools are single-rod, 9 span a
weld.** At the transcript's 5,500 lb rod it is roughly two-thirds single, one-third welded. The multi-rod spool is
the **normal minority**, not an edge case.

---

## 6. ⚠ Three defects — two latent, one benign. Do not port them.

### 6.1 `PREVENT INVALID FINAL REMAINDER` can emit a coil above the customer maximum

```vba
remainder = spoolRemaining - thisStop
If remainder > 0 Then
    If remainder < stopMin Then thisStop = spoolRemaining
End If
```

With `spoolRemaining = 1000`, `stopMax = 900`, `stopMin = 800`: `thisStop` becomes **1,000** — over the stated
maximum — to avoid a 100 lb unshippable tail.

**Latent on the shipped inputs** (1,800 divides cleanly by 900, so the branch never fires) and **live for any
other combination**. It matters to `Q47`: the tool treats *max coil weight* as a preference the anti-remainder
rule may override. **Confirm whether that is intended.**

### 6.2 The FL1 sizing loop decrements by the target, not by what it allocated

```vba
spoolWeights(spoolCount) = proposedSpool          ' may have just been raised
remainingOrder = remainingOrder - targetSpoolWeight
```

When `VALIDATE FINAL STOP POSSIBILITY` raises `proposedSpool`, the loop still subtracts the **target**, so its
accounting drifts and it over-allocates.

**Also latent, and masked for the same reason** — `1800 Mod 900 = 0` means no mid-run bump. Set `stopMax = 800`
and it bumps every spool, and the drift compounds.

### 6.3 `rodsUsed` is derived from output weight, not counted from the segments

```vba
rodsUsed = WorksheetFunction.RoundUp(totalOutput / rodWeight, 0)
```

The segment loop knows exactly which rods it consumed — it calls `IncrementRod` for each — yet the dashboard
recomputes the count from weight. Two sources of truth for one fact. They agree on the shipped run
(`R00001`–`R00011` = 11) and need not in general. **Benign here, but count the segments instead.**

---

## 7. What this changes, and what it leaves open

**Answered or narrowed by this analysis**

| Item | Effect |
|---|---|
| The alpha letter rule | **Known** — a per-spool stop index shared by every alpha part in that stop. No question needed |
| `Q45` — lead alpha, fact or prediction | The tool treats it as **fact**, by an explicit reversal loop. Confirm the physical unwind with engineering |
| `Q47` — planning-side coil weight | Has a **reference implementation**. Answer against the tool |
| `Q10` — footage-to-weight | **Off the genealogy's critical path**: the client's model carries weight directly as a planned allocation. ⚠ Still gates the **printed label** and the **certificate**, which state a weight a customer relies on — a *planned* allocation is not a *measured* one |
| `OI-60` / `Q11` — metallic yield | A working definition exists: `totalOutput / (rodsUsed × rodWeight)` |

**Still open, and raised by this analysis**

1. **What is the stored key?** The concatenated alpha is ambiguous and the suffix is not unique per parent.
2. **Is the anti-remainder rule allowed to exceed the customer maximum?** (§6.1)
3. **Which weight does the model hold** — the planned allocation the tool computes, or a measured value? If the
   certificate needs measured weight per alpha, that is a *different number in the same field*.
4. **Which rod weight is real** — 4,000 / ~5,500 / 8,690–8,840 (`OI-97`)?

---

## Related

| Document | Why |
|---|---|
| [`FL Alphas Plus.xlsm`](<FL Alphas Plus.xlsm>) | The subject |
| [`FL Alphas Plus - Module1.bas`](<FL Alphas Plus - Module1.bas>) | The recovered source, verbatim |
| [`ClientCall_2026-08-20_SyncPlan.md`](ClientCall_2026-08-20_SyncPlan.md) | The call that referenced the tool; `D8` and `D9` are its subject matter |
| [`MVP-1/ProjectPlan/Tools/extract_vba.py`](../MVP-1/ProjectPlan/Tools/extract_vba.py) | Re-derives the `.bas` if the workbook changes |
| `MVP-1/ProjectPlan/Business/BusinessRules.md` §3.3 | The alpha-format table this scheme is a third candidate against |
