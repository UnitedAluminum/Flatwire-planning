# Client e-mail — 2 September 2026 — The pass calculator's twenty formulas

**Source:** `RE: SMP changes (flat wire)` — Tim O'Brien (UA) to Sushant Sinha; cc DG UA DEV,
Miroslaw Marczuk, Ryan Dinneen, Fabian Vasquez, Srikanth Prabhala, Ryan T. Bobbitt.
**Sent:** Wed 2 Sep 2026 **17:23:17 UTC**. **Analysed:** 3 Sep 2026.
**Attachments:** 2 — `Wire Flattening Mathematical Calculation Formulas.docx` (**new**, and the whole
of the content) and one signature graphic. See §7.

> ⚠ **`95-archive/` is not citable.** Nothing in this file is a requirement. It is the audit record
> of what arrived; the binding statements live in the registers and files named in §5.

---

## 1. What this closes — and the subject line is a red herring

**The thread is *SMP changes (flat wire)*. This message has nothing to do with SMP.** It answers a
side-question Sushant asked inside the thread on 27 August — *"Please share the calculation formulas
for the width and temper as per cross sectional area"* — and the SMP process-letter conversation
running in the same thread is untouched. **`OI-27`, `OI-143`, `OI-64` and `G86` are not affected**
and remain owed by Srikanth Prabhala.

| Action owed | Status |
|---|---|
| **`A2`** — temper calculation logic from the Technical Team (owed since 23 Jul) | ⛔ **NOT ANSWERED.** Half of the 27 Aug ask, and the half that did not arrive. Tim: *"after I have finished with some updates to the table lookups and **temper calculations**"* — now with an ETA, not an answer |
| **`A3`** — weight calculation approach for rod | ⚠ **Partial.** `F1` supplies the footage↔weight relation for a round section. The ± x ft tolerance is still unstated |
| **`A1`** / **`Q33`** — the spool OD formula | ⛔ **Untouched.** Still the only one of thirteen left blank in the 1 Sep reply |
| **`PSG-D08`** / blocker **B4** — spread behaviour, round→flat and flat→flat | ⭐ **The RELATION is supplied; the coefficient is not.** See §3.1 |
| **`PSG-D25`** / blocker **B5** — edger partition coefficient | ⭐ **The RELATION is supplied; the coefficient is not.** See §3.1 |
| **`PSG-Q31`** — is the edger partition *relation* right, not just its coefficient | ✅ **Answered in form.** The client has supplied his own |
| **`Q10`** *(Critical)* — the footage formula the client is disputing | ⭐ **The formula is not in dispute.** See §3.2 |

**No new `A##` id is minted here.** `ClientEmail_*` ledgers consume call-ledger ids; they do not
mint them.

---

## 2. What arrived, in Tim's words

> *"Attached are all the formulas that I am using in my current pass calculator. I will send the
> calculator next week after I have finished with some updates to the table lookups and temper
> calculations.*
>
> *Please note that two formulas us an empirical calculation factor which I have plugged a
> irrelevant value as a place holder, until, which time we are able to run samples and generate our
> own table for the factor to be pulled from."*

### 2.1 ⚠ The formulas are images, and this transcription is the only searchable form

The attachment is five pages: a 44-symbol legend table, then **twenty formulas, every one of them a
PNG image**. There is no OMML and no selectable formula text. The document was opened by reading the
`.msg` CFB container directly and unzipping the `.docx`; the twenty images were ordered by their
`r:embed` position in `word/document.xml` and read individually.

**That makes the table below load-bearing rather than decorative.** Where a rendering is ambiguous
it is flagged, and `Q93` is the send-back for every such point.

| # | Name (Tim's heading) | Formula as rendered |
|---|---|---|
| F1 | Linear Feet Wire/Rod | `L_F = tω / (π r² · 12 · ρ₁)` |
| F2 | Linear Feet Round to Round | `L_F = L₁ (D_i / D_f)²` |
| F3 | Area Reduction Percentage % | `RA% = (D₁² − D₂²) / D₁²` |
| F4 | Linear Feet Round to Flat | `L_F = (π r² L₁) / (W₂ T₂)` |
| F5 | Thickness Reduction % | `t% = ((T₁ − T₂) / T₁) · 100` |
| F6 | Cumulative True Strain | `Σεi = ε_t₁ + ε_t₂ + ε_t₃` |
| F7 | Individual True Strain | `ε = ln(X₂ / X₁)` |
| F8 | True Area Reduction Formula | `q' = ln(a₁ / a₂)` |
| F9 | Wire/Rod Cross-Sectional Area | `Ae₁ = π × (D₁ / 2)²` |
| F10 | Round to Flat Cross-Sectional Area | `Ae₂ = (W₂ × T₂) − (4r² − π r²)` |
| F11 | Engineering Thickness Reduction % | `εT = ((D₁ − T₂) / D₁) · 100` |
| F12 | Cross-Sectional Area Reduction % | `Z = ((Ae − A_F) / Ae) × 100` |
| F13 | Material Elongation (Length Multiplier) | `ΔL = A₁ / A₂` |
| F14 | Final Cross-Sectional Area Flat Wire | `a = W₂ − (T₂² − (π T₂² / 4))` |
| F15 | Theoretical Finish Width Round to Flat | `ωT = (π D₁²) / (4 T₂)` |
| **F16** | **Calculated Width Round to Flat** | `ωĆ = C₅ [ (0.7854 D₁²/T₂)(1 − 15.8 (1 − 2T₂/D₁)^2.25 (2R/D₁)^−0.82) + 0.1426 D₁ (2T₂/D₁) ]` |
| F17 | Linear Feet (Flat to Flat) | `L_F = (L₁ W₁ T₁) / (W₂ T₂)` |
| F18 | Contact-Length Approximation | `L = √( R (T₁ − T₂) )` |
| **F19** | **Theoretical & Calculated Width Flat to Flat** | `TωĆ = W₁ [ 1 + C₆ ((√(R(T₁−T₂)) / W₁)((T₁−T₂)/T₁)) ]` |
| **F20** | **Edging Theoretical Calculated Thickness** | `tĆ = T₁ [ 1 + k ((W₁ − W₂) / W₁) ]` |

### 2.2 The three empirical constants, as the document describes them

| Constant | Tim's words | Appears in |
|---|---|---|
| **`C₅`** — Spread Factor | *"`C₅` = 1.00 then → published theoretical prediction; `C₅` > 1.00 then → predicts more spread; `C₅` < 1.00 then → predicts less spread"* | F16 |
| **`C₆`** — Empirical Spread Factor | *(legend entry absent — the symbol is defined only under F19)* | F19 |
| **`k`** — Empirical Spread Factor | *(legend: "Empirical Spread Factor")* | F20 |

⚠ **`C₆` is missing from the legend table** — the legend lists `(C)₅` and `(k)` and no `C₆`. The
covering note's *"two formulas"* with placeholder values are F19 and F20; `C₅` is described as a
scale on a published prediction, defaulting to 1.00.

### 2.3 ⭐ The one line in the legend that settles a modelling question

> *"`(a₂)` = Final cross-sectional area of the flat wire (**approximated as a rectangle with rounded
> edges for mill stands, and width × thickness for edgers**)"*

Two different edge geometries, chosen by **operation**, stated by the client for the first time.

---

## 3. What the repository already knew, and where this corrects it

### 3.1 ⭐ Blockers B4 and B5 — the relations arrive, the coefficients do not

`[PSG §12.3]` names five critical blockers and separates them:

> *"B1, B2, and B3 are **data requests** — they exist somewhere… **B4 and B5 are different in kind:
> they require measurement**, and cannot be resolved by asking harder."*

That framing is right about the *coefficients* and, it turns out, incomplete about the *relations*.
`[PSG §3.3.3]` had asked for something more than a number:

> *"Published strip-rolling spread relations should not be applied to it directly. This pass needs
> **its own empirical relation**, calibrated from your trial data. This is **PSG-D08** and is among
> the highest-priority items in this document."*

| Blocker | What `[PSG]` asked | What arrived | What is still owed |
|---|---|---|---|
| **B4** / `PSG-D08` — round→flat | its own empirical relation for a **round** entry | **F16** — a round-entry correlation carrying the roll radius explicitly, with `C₅` as the calibration scale | the value of `C₅` |
| **B4** / `PSG-D08` — flat→flat | `w_out = w_in · exp(β · ε_h)`, `[PSG §3.3.12]` | **F19** — a *linear-in-strain* form with `C₆` | the value of `C₆` |
| **B5** / `PSG-D25` — edger partition | *"how width displaced at an edger divides between length and centre bulge"* | **F20** — the thickness response, with `k` | the value of `k` |

**`k` is the partition coefficient, in a different parameterisation.** Volume conservation applied
to F20 gives `L₂/L₁ = (W₁/W₂) / (1 + k · ΔW/W₁)`. On a 0.550″ → 0.500″ edger pass, `k = 1` elongates
the section by 0.83% — essentially all the displaced width goes to thickness and bulge; `k = 0` puts
all of it into length. So `k` is the complement of `[PSG §3.3.11]`'s `φ`, and **`PSG-Q31` — which
asks whether the *relation* is right, not only its coefficient — is answered in form**: the client
has supplied his own rather than accepting ours by analogy.

⚠ **B4 and B5 remain blockers.** `[PSG §12.5]`'s prerequisite **P5** (trial instrumentation) is
unchanged. What changes is that each measurement now has a named quantity to fit.

### 3.2 ⭐ `Q10` — the footage formula is not what we disagree about

`Q10` is `Critical` and records the client disputing our figures twice in one document on 3 Sep:

> *"**What formula was used** to calculate the linear footage, this number is **lower than my
> calculations**… Please provide the formula used for comparison."*

**F1 rearranges to `lb/ft = π r² · 12 · ρ₁ = A × 12 × ρ` — algebraically identical to `FR-332a`**,
and identical to the reply drafted at
[`ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md`](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md)
§7. The method is not in dispute. The divergence has to be in the inputs, and there are two
candidates, both now evidenced:

1. **Density `ρ₁`.** Ours is 0.098 lb/in³ for 1100; Tim's value is nowhere stated.
2. **Which cross-sectional area.** ⚠ **Tim's own document uses two incompatible ones for flat wire**
   — `W₂ T₂` (square edge) in F4 and F17 where footage is computed, but the **rounded-edge** area in
   F10 and F14. `[PSG §3.3.4]` puts that correction at **3.8% of area on a 0.110″ × 0.625″
   section**. A contributing term, not the whole gap — §7 of the allocation ledger shows FL1 +15.5%
   and FL2 −10.6%.

### 3.3 ✅ `[PSG §3.3.4]`'s round-edge area — confirmed first-hand

`[PSG §3.3.4]` asserts, tagged `[INDUSTRY STANDARD]`:

```
Round edge:   A = t · w − t² · (1 − π/4) = t · w − 0.2146 · t²
```

**F14 is that relation, and F10 is it again** expressed through an edge radius. This is first-party
confirmation of an assumption the specification had to tag rather than source.

⚠ **F14 as rendered is dimensionally invalid.** `a = W₂ − (T₂² − πT₂²/4)` subtracts an area from a
length. With `× T₂` restored it reproduces F10 exactly and matches `[PSG §3.3.4]` to twelve decimal
places. Near-certainly a typo — but it is the client's document, so it is asked (`Q93`), not
silently corrected.

⚠ **F10's `r` is not the rod radius the legend claims.** The legend maps `(r) = Radius of the wire
rod`, and the formula only reproduces `[PSG §3.3.4]` when `r = T₂/2`, the **edge** radius. On a
0.250″ rod flattened to 0.100″ × 0.511″ the two readings differ by **23% of area** — 0.0377 vs
0.0489 in². A calculator built from the legend is wrong; one built from the algebra is right.

### 3.4 ⚠ F6's cumulative strain is degenerate as written

`Σεi = ε_t₁ + ε_t₂ + ε_t₃` sums the length, width and thickness true strains, which the legend
confirms. For any volume-conserving pass that sum is **identically zero** — verified to twelve
decimal places on a flat→flat pass.

`[PSG §3.3.13]` exists because of this exact family of error and prescribes equivalent (von Mises)
strain instead:

```
ε_eq = √( (2/3) · (ε_w² + ε_t² + ε_l²) )
```

The consequence is not academic: **Step 12's cumulative strain gates the FL3 hybrid route**, the one
route with no intermediate anneal, and under-reporting strain errs toward selecting hybrid for
material that cannot absorb the cold work.

Most probably Tim means a sum **over passes** rather than over dimensions. It is asked (`Q93`), not
assumed — the specification's Provenance Convention requires the relation to be tagged at the point
of use, not repaired behind the client's back.

### 3.5 ⭐ F16 completes the calculation `[PSG §6.3 Step 2]` says it cannot do

Worked Example A is *alloy 1100 · rod 0.3750″ · target 0.1100″ × 0.6250″ · round edge · FL1*.
Step 2 computes the zero-elongation lower bound and then stops:

> *"With no calibrated spread coefficient the engine cannot compute the true entry diameter. It
> proceeds on the bound and flags the schedule accordingly."*

Solving **F16** for `D₁` at `T₂ = 0.1100`, `w_target = 0.6250`, `R = 6.0` (FM1's 12″ mill) and
`C₅ = 1.00`:

| Quantity | Value |
|---|---|
| `[PSG]` lower bound `d_min = √(4 A_final / π)` | **0.2902″** |
| **F16 solved entry diameter** | **0.2933″** → `W₂` = 0.6248″ |
| Difference | **+0.0030″**, i.e. **larger** than the bound |
| Implied elongation over the flattening pass | **1.021** |

**The direction is the one `[PSG §3.3.3]` predicts** — *"the true required entry diameter is
**larger** than this expression gives"* — and the magnitude is physical. Step 3's total drawing
reduction moves **40.10% → 38.85%** and the pass count stays at **2**, so nothing downstream
destabilises.

**Independent cross-check, against a dimension the client stated in a different message.** `OI-97`
records Tim writing on 3 Sep: *"FL1 `.085t x .700w`"*. F16 at `C₅ = 1.00`, `R = 6.0` maps a
**0.2842″** FM1 entry to **0.085″ × 0.7000″** — **0.09% off his stated width**, elongation 1.094.
The correlation reproduces United Aluminum's own product geometry at the unscaled published value.

### 3.6 ⚠ …but F16 has a hard domain limit, and the nominal product sits near its floor

Checked across `D₁ ∈ {0.1875, 0.250, 0.3125, 0.375}` and `R ∈ {6.0, 4.0, 3.0}` — the
`Stand.RollDiameterIn` radii for FM1, FM2 S1 and FM2 S2/S3:

- **Undefined for `T₂ ≥ D₁/2`.** `(1 − 2T₂/D₁)^2.25` raises a negative base to a fractional power.
  The engine must reject the input, not trap a `NaN`.
- **Physically valid only above ≈ 57–60% thickness reduction** on the rounded-edge area basis. Below
  that, F16's width implies a cross-section *exceeding* the incoming area — negative elongation. At
  `D₁ = 0.250″, R = 6.0` the crossover is `T₂ = 0.1018″`, i.e. **59.3%**.
- ⚠ **Worked Example A runs at 62.5% — barely inside.** The guard is load-bearing on the nominal
  product, not a theoretical edge case.
- ⚠ **The floor moves with the area basis, and that decides the example.** On Tim's own square-edge
  footage basis (F4/F17) the same crossover is **65.1%**, so Worked Example A comes out at an
  implied elongation of **0.982 — unphysical**, where the rounded-edge basis (F10/F14) gives
  **1.021**. §3.2's inconsistency is not cosmetic: **it flips the specification's nominal product
  between valid and invalid.**

### 3.7 ⛔ F16 falsifies `FW-013`'s acceptance criterion

[`05-Backlog-MVP2.md`](../../60-delivery/05-Backlog-MVP2.md) pins `FW-013` to a concrete case —
*alloy 1100, rod 0.375″, gauge 0.125″, width 0.875″* → *"then it returns `preflattenDiameterIn
0.3732`, `areaReductionPct 0.95`, `drawPasses 0`, `routeMode Hybrid`"*.

| | Value |
|---|---|
| The AC's `0.3732` | the **square-edge** zero-elongation bound |
| The **round-edge** bound `[PSG §6.3 Step 1]` actually computes | **0.3674** |
| **F16 solved entry diameter** | **0.3823″** — **larger than the 0.375″ rod** |
| `[PSG §6.3 Step 3A]` rod-adequacy margin | **+0.98% → −3.93%** |

So the failure that `Step 3A` and `V43` were added in v1.5 to catch — *"an undersize rod passed
silently"* — **now actually fires**, on the document's own example, where the bound let it through
with a thin margin. The AC's expected values are no longer the right answer; a rejection is.

⚠ **`C₅ = 1.00` is the unscaled published value, not a calibrated one**, so this says the product is
*at or past* the feasibility edge on 0.375″ rod, not that it is definitively impossible. That is
still a different result from the one the AC asserts, and `Step 3A`'s worked figure has to be
recomputed either way.

### 3.8 ⚠ F19 conflicts with `[PSG §3.3.12]`'s parameterisation — and F16 retires an assumption

`[PSG §3.3.12]` models a stand as `w_out = w_in · exp(β · ε_h)` with `β` a calibratable **constant**.
F19 is `w_out = W₁(1 + C₆ · (L_p/W₁)(Δh/T₁))` — linear, and carrying `R` and `W₁` explicitly.
Equating them:

```
β = ln( 1 + C₆ · √(R · Δh) · Δh / (W₁ T₁) ) / ln(T₁ / T₂)
```

**Under the client's model `β` is not constant.** It varies with roll radius, entry width and draft;
only `C₆` is constant. The two agree to first order and diverge beyond it. `[PSG §3.3.12]`'s
pre-compensation of E2 for S3's spread — `w_E2_out = w_target / exp(β_S3 · ε_h,S3)` — has to be
restated by **inverting F19**, or every FL2 and FL3 coil is pre-compensated against the wrong
number, on the one pass where the tolerance is tightest.

⭐ **F16 retires `w_eff(d) = d`.** `[PSG §6.3 Step 2]` needs an "effective entry width" for the round
section only because the exponential model requires a transverse datum; `w_eff(d) = d` is adopted
`[RECOMMENDED DEFAULT]` and `[PSG §12.1]` lists it as one of three places where the document is not
resting on established practice. **F16 takes `D₁` and `T₂` directly and needs no `w_eff` at all** —
so that exception disappears rather than being retagged. With the edger partition becoming
client-supplied (§3.1), `[PSG §12.1]`'s *"three exceptions"* drops to **one**: the round→flat grip
criterion, `PSG-Q32`.

⚠ Step 2's separate `t_exit` caveat — that FL3 delivers an *intermediate* gauge, so Step 2 must be
recomputed once Step 9 has run — is **unaffected**. F16 consumes the same `t_exit`.

### 3.9 Smaller discrepancies, none of them structural

| Item | Finding |
|---|---|
| **F18 vs `[PSG §3.3.6]`** | Tim uses the **nominal** roll radius `R`; the specification uses the **deformed** radius `R′` (Hitchcock flattening). Immaterial inside a fitted spread correlation, where the difference is absorbed into `C₅`/`C₆`. **Material in the force model** `F = w̄ · L_p · Q_p · σ̄_f`, which feeds `PSG-D10` and `PSG-D11` |
| **F3 vs F12** | Two names for one quantity — F3 is the round→round special case of F12, with `π` cancelling. Both drop the `× 100` in one variant, deferring to *"with formatted cell in %"* |
| **F5 vs F11** | Two *"thickness reduction %"* definitions, identical whenever `T₁ = D₁`. Which one applies to a round entry is unstated |
| **F19 bracket balance** | The rendered image carries one unclosed parenthesis. §2.1's reading is the only dimensionally coherent one, but it is an inference |
| **Notation drift** | F2 writes `D_i / D_f` where the legend defines `D₁ / D₂`; F13 writes `A₁ / A₂` where the legend defines `Ae / A_F`; `L` is overloaded — linear feet in the legend, contact length in F18 |
| ⚠ **`C₆` collides with an existing id** | The repository already has a **`C6`** — a 23 Jul call clarification on dancers and tension. The client's constant must be namespaced on absorption |

---

## 4. What this changes in the repository

### 4.1 The formula set gets one assertion site, and it is `D-43`

Per the repository's own rule — *a fact is asserted in one document and cited everywhere else* — the
twenty relations are asserted once, as **`D-43`** in `[MSP §10.2]`, and cited from the specification,
the registers and the backlog. Nothing cites this ledger for them.

### 4.2 `PassScheduleGenerationSpec.md` goes to v1.6, and adopts the client's forms

The client calibrates against **his own** parameterisation, so the trial data will fit `C₅`, `C₆`
and `k` — not `β` and `φ`. The specification therefore adopts F16, F19 and F20 as its primary
relations and keeps `β`/`φ` as **derived** reporting quantities with the mapping stated (§3.8).

**A fourth provenance tag is required.** The Provenance Convention has three — `[INDUSTRY
STANDARD]`, `[RECOMMENDED DEFAULT]`, `[CLIENT INPUT REQUIRED]` — and none of them describes a
relation the client supplied as his own practice. **`[CLIENT SUPPLIED]`** is added.

### 4.3 Two guards become validations, not commentary

`V46` (F16 domain, `T₂ < D₁/2`), `V47` (implied elongation ≥ 1.0) and `V48` (predicted width
cross-checked against volume conservation on the rounded-edge area). §3.6 shows why: the nominal
product sits 3 points above the floor, and the wrong area basis puts it below.

### 4.4 `FW-013`'s acceptance criterion is re-derived

§3.7. The expected outcome becomes a `Step 3A` / `V43` rejection, with the `C₅ = 1.00` caveat stated
in the AC so the number is not read as settled.

### 4.5 What this does **not** change

- **No new `FW-###` tasks.** B4 and B5 still block *production use* of generated schedules, and
  `[PSG §12.4]`'s *"development is not blocked"* was already true. `FW-013` is deferred MVP-2 and has
  no task file. Nothing is unblocked that was blocked.
- **No schema or DDL change.** `G91` records that the empirical factors are **lookup tables** with no
  home in `FlatWireDB`; building that home is not this pass.
- **No SMP change.** Different sub-conversation in the same thread. `OI-27`, `OI-143`, `OI-64` and
  `G86` are untouched.
- **No new `FR-###` contradiction.** `FR-381`/`384`/`385`/`386`/`387` were already superseded by
  `[PSG]` at `[MSP §10.5]`; this strengthens that case rather than adding to it. §10.5 gains a
  **sixth** rebuild item — the entry-diameter solve — and nothing else.
- **No `[SIM]` change.** `MachineSimulator.md` A8 (*"lateral spread is ignored; width is targeted
  directly"*) stands, and `G39` already owns it.
- **No temper work of any kind.** Nothing arrived. See §6.

---

## 5. Where the binding statements went

| Register / file | Entry |
|---|---|
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §10.2 | **`D-43` minted** — the client's formula set is the engineering basis for width, cross-sectional area, footage and edging. Supersedes nothing; fills `[PSG §3.3.3]`'s explicit request. ⛔ No temper relation |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §10.5 | The *"rebuild the five formulas"* instruction gains a **sixth** item — the entry-diameter solve |
| [`MasterSpecification.md`](../../10-requirements/MasterSpecification.md) §11 | **`OI-45` amended** — the footage dimensional basis now has a client-side data point: two incompatible flat-wire areas in one document |
| [`Questions.md`](../../90-registers/Questions.md) | **`Q93` minted** — the six-part send-back on the formula document · **`Q10` amended** — the formula is not in dispute; re-pointed at density and edge geometry |
| [`Gaps.md`](../../90-registers/Gaps.md) | **`G90` minted** — F16's domain limit and validity floor · **`G91` minted** — the empirical factors are lookup tables with no home in `FlatWireDB` · **`G74` amended** — named client formulas now produce exactly the five missing `PassScheduleComponent` columns |
| [`PassScheduleGenerationSpec.md`](../../10-requirements/screens/PassScheduleGenerationSpec.md) **v1.6** | `[CLIENT SUPPLIED]` tag added; §3.3.3 · §3.3.4 · §3.3.6 · §3.3.11 · §3.3.12 · §3.3.13 · §6.3 Steps 2/3A/9A/9B/10 · §6.4 Worked Example A · §8 (`V46`–`V48`) · §9 · §12.1–§12.3 · §12.5 |
| [`05-Backlog-MVP2.md`](../../60-delivery/05-Backlog-MVP2.md) | **`FW-013` AC re-derived** — `0.3823″` entry, past the 0.375″ rod; expected outcome becomes a `Step 3A` / `V43` rejection |
| [`ClientCall_2026-07-23_SyncPlan.md`](ClientCall_2026-07-23_SyncPlan.md) | **`A2` and `A3` annotated in place** — `A2` still owed, now with an ETA; `A3` partially served by `F1` |
| [`ClientQuestionsContent.md`](../../tools/deliverables/ClientQuestionsContent.md) | `Q93` authored; `FlatWire_ClientQuestions.xlsx` regenerated |
| **No task file minted** | See §4.5 |

---

## 6. Still owed by the client

| # | Item | Why it matters |
|---|---|---|
| 1 | ⛔ **The temper formulas.** Half of the 27 Aug ask; `A2`, owed since **23 July**. Now has an ETA — *"next week"*, w/c 7 Sep 2026 — and still no content | `PSG-D29` (strain → temper), validation `V16`, and `D-39`'s three named-but-unquantified regimes. `V16` reports *not evaluated* rather than passing, so **target temper is a mandatory input that nothing consumes** |
| 2 | ⛔ **The pass calculator itself** — promised *"next week"* | It will show which of `C₅`/`C₆`/`k` are scalars and which are table lookups, and settle every `Q93` ambiguity by demonstration |
| 3 | ⛔ **Values for `C₅`, `C₆` and `k`** — placeholders pending sample runs | **Blockers B4 and B5.** Width is not designed on any line until these land |
| 4 | ⛔ **What the factor tables are keyed by** — *"generate our own table for the factor to be pulled from"* | `G91`. Alloy? Stand? Gauge band? The lookup's key decides whether `AlloyProperty` can hold it or a new table is needed |
| 5 | ⛔ **`Q93`'s six transcription points** — F14's missing `× T₂`, F10's `r`, F6's sum, F19's brackets, F5-vs-F11, and the square-vs-round area split | §3.6 shows the last one flipping the nominal product between feasible and infeasible |
| 6 | ⛔ **The spool OD formula** — `A1` / `Q33`, owed since 23 Jul, asked twice, left blank in the 1 Sep reply | Unchanged by this message |
| 7 | ⛔ **The rod footage ± x ft tolerance** — `A3`'s remaining half | `D-37`; `FR-153`'s ±2% variance threshold |
| 8 | ⛔ **Density `ρ₁` per alloy**, as Tim's calculator uses it | `Q10` (Critical) and `PSG-D30`, which *"must not resolve to a second value"* |

---

## 7. Attachments — 2, one of them the whole message

| File | Content |
|---|---|
| **`Wire Flattening Mathematical Calculation Formulas.docx`** — 210,929 bytes, 5 pages | **New.** Authored by Tim O'Brien, created 2 Sep 16:55 UTC, modified 17:22 UTC — three minutes before the mail went out. 267 words of selectable text: a 44-symbol legend table and nothing else. **The twenty formulas are `image1`–`image20`, all PNG.** Copied into this folder |
| `image001.gif` — 131,049 bytes | Signature graphic. No content |

⚠ **The 27 Aug attachment in this thread — Srikanth's SMP process-creation notes — is NOT carried in
this `.msg`.** The quoted text references it (*"Attached document has the notes related to SMP
process creation"*), but Outlook did not carry it forward into the reply. It is not in this folder
and has not been analysed here.

⚠ **Cite the formulas by their `F##` number in §2.1, never by image number.** The `imageN.tmp` names
are zip-entry artefacts and are not even in document order inside the archive.

---

## 8. Thread provenance — where this sits

`RE: SMP changes (flat wire)` carries **two sub-conversations**. This ledger records the calculation
one; the process-letter one is at
[`ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md`](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md).

| Date | From | What |
|---|---|---|
| 25 Aug 10:52 IST | Sushant Sinha | *"Please share the details for SMP changes related to flat wire."* — opens the thread |
| 26 Aug 12:12 (UA local) | Sushant Sinha | Reminder |
| 27 Aug 02:36 (UA local) | Srikanth Prabhala | SMP process-creation notes, **attachment not carried forward** |
| **27 Aug 22:26 IST** | **Sushant Sinha** | **The ask this answers** — *"calculation formulas for the width **and temper** as per cross sectional area"* |
| 1 Sep 07:38 (UA local) | Sushant Sinha | *"Gentle reminder."* |
| **2 Sep 17:23:17 UTC** | **Tim O'Brien** | **This message — twenty formulas, no temper** |

⚠ **The ask was two-part and the answer is one-part.** Width arrived; temper did not. That
asymmetry is the whole of §6 row 1 and is the reason `A2` does not close.

---

## Related Documents

| Document | Why |
|---|---|
| [PassScheduleGenerationSpec.md](../../10-requirements/screens/PassScheduleGenerationSpec.md) | **The authority on the calculations.** Every formula here lands in it; v1.6 is this pass |
| [MasterSpecification.md](../../10-requirements/MasterSpecification.md) | `D-43` (this ledger's authority), §10.5's superseded `FR-` arithmetic, `OI-45`, `OI-97` |
| [Questions.md](../../90-registers/Questions.md) | `Q93` (the send-back), `Q10` (the footage dispute), `Q33` (the OD formula, still owed) |
| [Gaps.md](../../90-registers/Gaps.md) | `G90` (F16's domain), `G91` (no home for the factor tables), `G74` (the missing `PassScheduleComponent` columns) |
| [ClientCall_2026-07-23_SyncPlan.md](ClientCall_2026-07-23_SyncPlan.md) | `A1`, `A2`, `A3` — the formula actions this partly serves and mostly does not |
| [ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md](ClientEmail_2026-09-03_RodOrderAllocation_SyncPlan.md) | §7's drafted footage reply, which `F1` now lets us send with the client's own formula quoted back; and `OI-97`'s `.085t x .700w`, used as the §3.5 cross-check |
| [ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md](ClientEmail_2026-09-03_ProcessLetters_SyncPlan.md) | **The same thread's other sub-conversation.** Nothing here touches it |
| [05-Backlog-MVP2.md](../../60-delivery/05-Backlog-MVP2.md) | `FW-013`, whose acceptance criterion §3.7 falsifies |
