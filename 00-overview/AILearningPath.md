# A learning pathway for AI integration

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Document Type:** Developer learning pathway — derived, not a requirement, and carries no shortcode
**Applies to:** Any UAL module. Written in the Flat Wire repository because that is where the opportunity assessment lives, but the techniques are not specific to it
**Version:** 1.1
**Last Updated:** September 4, 2026 — **technical specifics added to every stage.** Each now names the actual methods, libraries and parameters rather than the concept alone, and §6 carries the real API surface — model id, thinking and effort configuration, tool definitions, strict schemas, structured outputs, caching mechanics and the C# client shape *(previously 1.0, first issue)*
**Status:** **Direction only.** Completing this commits nothing and schedules nothing
**Audience:** One developer working through it start to finish

---

## What this is, and what it is not

`[AI]` says **what** could be built. This says **how to become able to build it**.

It is a **general curriculum with Flat Wire illustrations**: each stage teaches a portable technique
and the mill supplies the worked example, so the skill moves to the furnace and slitter modules
unchanged.

**Be clear-eyed about the trade.** A grounded pathway would have produced a shipped feature; this
produces *capability*. Nothing built here goes to production. §9 is where you spend it.

**Seven stages, sequential, each with a proof.** A stage is finished when the thing you built
behaves. Sizes are relative learning effort, `S` / `M` / `L`, and are **not** an estimate of anything.

### The distinction that decides the ordering

Of the eight ideas `[AI]` leads with, **most are not language-model work**. Language models are stage
six of seven, because a developer who learns only the API can build the least valuable third of the
catalogue.

### ✅ The gate blocks shipping, not learning

`[AI §5.4]` records two open decisions — the Anthropic package against the no-new-frameworks rule,
and `[SEC]`'s silence on egress. **Neither blocks anything here.** They govern what may be
*deployed*. Every stage below is completable today.

⚠ **Learn in Python, ship in C#.** The numerical and optimisation libraries are where the teaching
material is, and fighting the ecosystem while learning the concept is a poor trade. A notebook on
your own machine is not a production dependency. §6 gives the C# surface for the one stage where the
port is non-obvious.

---

# 1. `M` — What makes an answer trustworthy

**Concept.** Three kinds of number live on any screen — **measured**, **derived** and **predicted** —
carrying completely different warranties. Two disciplines follow: **provenance**, so every derived
value records what produced it, and **uncertainty as a first-class output**, because a prediction
without an interval is an opinion wearing a number's clothes.

**Technically.** A provenance record is four fields on the row, not a log line: `value`,
`method_version`, `inputs_hash`, `computed_at`. Uncertainty is either a **parametric interval** from
the fit's covariance, a **bootstrap** interval (resample residuals, refit, take percentiles), or a
**conformal** interval when you want a distribution-free coverage guarantee. Prefer conformal when
you cannot defend the error distribution — it needs only a held-out calibration set.

**Seen here.** Consumption records already store their own conversion basis and converter version on
the row, *so changing a formula later never retro-changes history*. That is model provenance,
invented for arithmetic.

**Build.** Store method version and inputs alongside one computed output. Change the formula;
demonstrate historical rows do not move.

**Done when** you can point at any number you rendered and say which of the three it is, and the
interface shows the difference unasked.

⚠ **Trap.** A predicted number styled identically to a measured one is the most common way an AI
feature loses trust — usually permanently, the first time someone is burned.

---

# 2. `M` — Statistics that pay before any model

**Concept.** Control charts, and why a threshold alarm is the weakest detector available. Reacting to
*trend* rather than *breach*. Capability, where defining the stable window is the hard part.
Attribution: ranking what *explains* an outcome, not what correlates with it.

**Technically.**

| Tool | The parameters that matter |
|---|---|
| **Shewhart** | ±3σ from a baseline period. Detects large shifts fast, small drifts never |
| **EWMA** | `z_t = λx_t + (1−λ)z_{t−1}`. **λ ≈ 0.2** is the usual starting point; smaller = smoother and slower. Control limits widen toward `σ√(λ/(2−λ))` |
| **CUSUM** | Accumulates `max(0, x_t − (μ₀+k) + S_{t−1})`. Tune **k ≈ δ/2** for a shift of size δ, and **h ≈ 4–5σ** for the alarm. Faster than EWMA on a sudden step |
| **Capability** | `Cp = (USL−LSL)/6σ`, `Cpk = min(USL−μ, μ−LSL)/3σ`. Both are meaningless unless the window is in control first — check with a chart *before* computing |
| **Attribution** | **Permutation importance** as the honest baseline: shuffle one feature, measure the loss increase. Reach for SHAP only when you need per-row attribution and can defend the extra machinery |

Libraries: `scipy.stats`, `statsmodels`, and for charts either hand-rolled (twenty lines) or
`pyspc`. Do not reach for a framework here.

**Seen here.** Capability per run is a stated requirement with no implementation and no defined
window. Drift is watched by a person waiting for a breach.

**Build.** EWMA over a measurement series, detecting drift *before* it crosses the limit. Then
capability over a window you defined and can defend.

**Done when** your detector fires earlier than a threshold alarm on the same series and you can state
its false-positive rate rather than guess.

⚠ **Trap.** Capability over an unstable window is a number with no meaning. Everyone argues about the
formula; nobody defines the window.

---

# 3. `L` — Optimisation, which needs no history at all

**Concept.** Writing a constraint model down honestly. Bin packing and cutting stock. Sequencing with
changeover costs. And the part that decides everything: **objective design**.

**Technically.**

- **Start with a solver, not a heuristic.** `OR-Tools` **CP-SAT** handles the integer and logical
  constraints these problems actually have — "this order cannot be split across two rods", "this
  boundary cannot be crossed once mounted" — and it proves optimality or gives you a bound.
  `PuLP` or `Pyomo` over CBC/HiGHS if the problem is cleanly linear.
- **Cutting stock** is classically column generation, but for realistic instance sizes a direct
  CP-SAT model with an upper bound from **first-fit-decreasing** is simpler and fast enough. Get FFD
  working first — it is twenty lines and gives you a baseline to beat.
- **Sequencing with changeovers** is asymmetric TSP in disguise. CP-SAT's `AddCircuit`, or
  `routing` from OR-Tools if you need vehicles as well.
- **Objectives** are almost always multiple and conflicting. Two honest ways to combine them:
  **lexicographic** (satisfy feasibility, then minimise changeovers, then balance load — solve in
  order, freezing each) or **weighted sum** with weights you can defend. Lexicographic is easier to
  explain to the people who own the objective, which matters more than it sounds.

**Seen here.** Rod-to-order allocation, today a hand-maintained spreadsheet. Line loading where
changeovers dominate. Furnace batching against shared capacity. All buildable before a single coil
exists.

**Build.** A cutting-stock model with real constraints — including one awkward one — solved with FFD
first, then CP-SAT. Change the objective and watch the answer change.

**Done when** you can state your objective in one sentence and defend it against a plausible
alternative, and your CP-SAT model closes the gap to your FFD baseline.

⚠ **Trap.** An optimiser is exactly as good as its objective, and the objective is almost always the
thing nobody has written down. Expect to spend longer agreeing it than coding the solver.

---

# 4. `L` — Fitting: regression and the grey-box pattern

The signature technique for process manufacturing.

**Concept.** Least squares, and what a **residual** actually is. Then **grey-box modelling** —
`prediction = known model + learned correction`. Regularisation so a fit with few points does not
chase noise. Uncertainty intervals, which change the interface rather than the maths.

**Technically.**

The pattern, stated properly: for a known physical model `f(x; θ)` with unknown parameters `θ` and a
residual model `g(x)`,

```
ŷ = f(x; θ̂) + g(x)
```

Fit in two passes. **First** estimate `θ̂` by non-linear least squares on the physics alone —
`scipy.optimize.curve_fit` or `least_squares`, which gives you the Jacobian and hence the covariance.
**Then** fit `g` on the residuals `y − f(x; θ̂)`, keeping it deliberately weak: a low-order polynomial
or a smoothing spline, not a gradient-boosted tree. If `g` is doing most of the work, your physics is
wrong and you should fix that instead.

| Concern | What to reach for |
|---|---|
| Few points, correlated inputs | **Ridge** (`sklearn.linear_model.Ridge`). Choose α by cross-validation, not by eye |
| Heteroscedastic error | **Weighted least squares** — weight by `1/σᵢ²`. Measurement noise is rarely constant across a range |
| Parameter uncertainty | Covariance from `curve_fit`'s `pcov`; standard errors are `sqrt(diag(pcov))` |
| Prediction interval | **Bootstrap** the residuals if the model is non-linear. Parametric intervals from `pcov` assume linearity near the optimum and quietly under-report otherwise |
| Is the correction real? | Hold out a block, not random rows. Process data is autocorrelated and random splits leak |

Grey-box earns its place three ways: it works with **very little data** because the known model
carries most of the signal; it stays **auditable** because the two terms display separately; and it
**degrades gracefully** because with no correction learned you still have the formula.

**Seen here.** A family of values a running process measures about itself faster than anyone can
supply them — spread coefficients that arrived as placeholders, a mill spring curve without which
first-off setup is trial and error.

**Build.** Implement `ŷ = f(x; θ̂) + g(x)`. Fit on roughly twenty points. Report a bootstrap interval.

**Done when** you can display the physics term and the correction separately, and the interval
visibly widens where you have no data.

⚠ **Trap.** Fitting a black box where a formula exists throws away the thing that lets the model work
on twenty points instead of twenty thousand.

---

# 5. `M` — Choosing what to measure

Converts *"we have no data"* from a blocker into a plan.

**Concept.** Choosing the next observation to shrink uncertainty fastest rather than to cover a grid.
Borrowing a related process's history.

**Technically.**

- **Fisher information and D-optimal design.** For a model with parameters `θ`, the information matrix
  is `Fᵀ W F` where `F` is the Jacobian at the candidate points. A **D-optimal** design maximises
  `det(FᵀWF)` — in practice, greedily add the candidate that increases the determinant most. Fifty
  lines with `numpy`, and it beats a grid convincingly.
- **Bayesian optimisation** when each observation is expensive and you want the *optimum* rather than
  the *parameters*: a Gaussian process surrogate plus an acquisition function — expected improvement
  is the safe default. `scikit-optimize` or `BoTorch`.
- **Transfer**, in ascending order of machinery: **hierarchical / partial pooling** (a per-line
  parameter drawn from a plant-wide prior) is usually enough and is interpretable; feature-space
  transfer next; fine-tuning a trained model last, and rarely justified at these data volumes.

**Seen here.** A trial planned for coverage produces a calibrated process; one planned to prove the
line runs produces a line that runs and constants still at placeholder values.

**Build.** A model with two unknown parameters. Choose five samples by D-optimality; compare
convergence against five evenly spaced and five random.

**Done when** your chosen samples converge measurably faster, and you can say by how much.

⚠ **Trap.** Sampling where it is convenient rather than where the model is uncertain. It feels
thorough and is nearly worthless.

---

# 6. `L` — Language models

Sixth, not first — and the track opens with when not to use one.

## 6.1 When a language model is the wrong tool

Anything with a correct answer computable from records. Anything needing a number to be exactly
right. Anything you cannot evaluate. If a formula, a query or a solver answers it, use that — the
model's job is the *interface*, not the *arithmetic*.

## 6.2 The request surface, concretely

Everything goes through one endpoint, `POST /v1/messages`. Tools and output constraints are features
of it, not separate APIs.

| Parameter | What to set, and the trap |
|---|---|
| `model` | **`claude-opus-5`**. Use the exact id — never append a date suffix |
| `thinking` | `{"type": "adaptive"}`. ⚠ **`budget_tokens` is removed on this model and returns a 400** — if you recall that pattern, it is stale |
| `output_config.effort` | `low` · `medium` · `high` · `xhigh` · `max`, default `high`. It lives **inside** `output_config`, not top-level. Lower effort on a newer model often beats higher effort on an older one — measure before assuming you need `max` |
| `max_tokens` | ~16,000 non-streaming, ~64,000 streaming. Lowballing truncates mid-thought and costs a retry |
| `output_config.format` | Structured outputs. ⚠ **Not** the deprecated top-level `output_format` |
| assistant prefill | ⚠ **Removed — returns a 400.** Use structured outputs or a system instruction to control shape |

## 6.3 Tool use — the shape that matters

A tool definition is a name, a description, and a JSON Schema for one object argument. Two
non-obvious rules:

- **`strict: true` goes on the tool definition itself**, as a top-level field — *not* on
  `tool_choice`. It requires `additionalProperties: false` and `required` on the schema, and in
  exchange guarantees the arguments validate exactly. Take it every time.
- **Parallel tool use is on by default.** One assistant message may contain several `tool_use`
  blocks. Execute them concurrently, then return **every** `tool_result` in a **single** user
  message. Splitting them across messages silently teaches the model to stop making parallel calls,
  and a failed tool still needs a `tool_result` with `is_error: true` rather than being dropped.

The description is all the model knows about the tool. Say what it does, **what it returns**, and
when to use it, in one to three sentences.

**Keep the set small.** Each round re-reads everything so far, so many tools with large results is
the main way this gets slow and expensive. Five or six, returning small plain data.

## 6.4 In C#, where the port is non-obvious

The client is `AnthropicClient` from `Anthropic`; request and response types live in
`Anthropic.Models.Messages`, and the beta equivalents in `Anthropic.Models.Beta.Messages`.

```csharp
using Anthropic;
using Anthropic.Models.Messages;

AnthropicClient client = new();

var parameters = new MessageCreateParams
{
    Model = "claude-opus-5",
    MaxTokens = 16000,
    Tools = [
        new Tool {
            Name = "find_rod",
            Description = "Look up one rod by alpha. Returns alloy, temper, diameter, "
                        + "supplier heat, status and location.",
            InputSchema = new() {                    // Type is auto-set - do not set it
                Properties = new Dictionary<string, JsonElement> {
                    ["alpha"] = JsonSerializer.SerializeToElement(
                        new { type = "string", description = "Rod alpha, e.g. R00045" }),
                },
                Required = ["alpha"],
            },
        },
    ],
    Messages = [new() { Role = Role.User, Content = "..." }],
};
```

Four things that will cost you an afternoon each if you guess:

1. The type is **`Tool`**, not `ToolParam`. `ToolUnion` converts implicitly inside a `[...]`
   collection expression, so no wrapper is needed for custom tools — but Anthropic-defined tools
   (web search, code execution) **do** need `new ToolUnion(...)` explicitly.
2. **There is no `.ToParam()` helper** for echoing a response back as the assistant turn. Reconstruct
   each block variant by hand — `TextBlock` → `TextBlockParam`, `ToolUseBlock` → `ToolUseBlockParam`.
   ⚠ **Do not use `new ContentBlockParam(block.Json)`**: it compiles and serialises, but `.Value`
   stays null and every `TryPick*` / `Validate()` then fails. It is a degraded pass-through, not the
   typed path.
3. A **thinking block's `Signature` must be preserved verbatim** when echoed. The API rejects
   tampering.
4. **One `tool_result` per `tool_use` block.** The follow-up is rejected if any `tool_use` id lacks a
   match.

For the loop itself, start with the runner rather than hand-rolling:
`client.Beta.Messages.ToolRunner(betaParams)`, then `await foreach (BetaMessage message in runner)`.
Move to a manual loop only when you need control it does not give you.

## 6.5 Structured outputs

`OutputConfig { Format = new JsonOutputFormat { Schema = ... } }`, where `Schema` is required and
`Type` is auto-set to `json_schema`. Use it when the *payload* must be shaped — and remember it is
incompatible with document citations, which is a 400 rather than a silent fallback.

## 6.6 Cost — caching is the whole game

Rendering order is **`tools` → `system` → `messages`**, and caching is a **prefix match**: any byte
change anywhere in the prefix invalidates everything after it. So put the stable content first — the
frozen system prompt, the deterministic tool list — and everything volatile after the last
breakpoint. A timestamp or an unsorted JSON blob near the front silently costs you the entire cache.

In C#: `CacheControl = new CacheControlEphemeral()` on the block you want to end the prefix at,
optionally `new() { Ttl = Ttl.Ttl1h }`. It also exists on `Tool.CacheControl` and top-level on
`MessageCreateParams`. Maximum **four breakpoints** per request.

⚠ **Verify rather than assume.** Read `response.Usage.CacheReadInputTokens` and
`CacheCreationInputTokens`. If reads are zero across repeated identical requests, something in your
prefix is moving — that is the bug, and it is invisible without checking.

Other levers, in the order they pay: caching, then input-token hygiene, then **Batch API at 50%**
for anything not latency-sensitive, then effort tuning, then model choice. Count tokens with the
API's own `count_tokens` endpoint — never `tiktoken`, which is a different tokeniser.

## 6.7 Long conversations

Two different features, often confused. **Context editing** *clears* old tool results
(`context_management.edits`, beta `context-management-2025-06-27`). **Compaction** *summarises*
(beta `compact-2026-01-12`). If you use compaction, append the whole `response.content` back to your
messages — extracting only the text silently loses the compaction state.

## 6.8 Failure handling

Catch a **chain**, most specific first — not-found, then rate-limited, then a general API status
error, then a connection error. A single broad catch loses the distinction between retryable
(429, 5xx, network) and not (400, 404), which is exactly the distinction your retry policy needs.

## 6.9 Evaluation — the actual deliverable

**Build** a tool-using assistant over three functions, **plus an eval set of twenty questions with a
pass/fail harness**. Assert on the *retrieved rows*, not on prose. Keep a handful of adversarial
cases: a question with no answer in the data, one that needs two tools, one containing an injection
attempt.

**Done when** your eval **fails** on a deliberately worsened prompt. If it does not, it is measuring
nothing.

⚠ **Trap.** Shipping without an eval. You cannot then distinguish improvement from regression, and
*"it seems better"* is what makes an LLM feature quietly rot.

---

# 7. `M` — Shipping it, and keeping it working

**Concept.** Provenance on outputs. Monitoring for drift, because a model degrades silently rather
than failing. Retraining as a decision, not a habit. Human-in-the-loop, specifically the pattern where
the system proposes and a person's approval is what takes effect.

**Technically.**

- **A model registry entry is the unit**, not a file: version, training window, parameters, metrics,
  and the hash of the code that produced it. `MLflow` if you want it off the shelf; four columns in a
  table if you do not.
- **Drift has two kinds and you must watch both.** *Input* drift — the **population stability index**
  (`PSI > 0.2` is the conventional alarm) or a two-sample **Kolmogorov–Smirnov** test on each feature.
  *Performance* drift — track the residual distribution over time, because inputs can look identical
  while the relationship moves.
- **Retraining triggers** should be a rule you wrote down: a drift threshold, a volume of new labels,
  or a calendar interval — chosen deliberately, and with the previous version kept so you can compare.
- **Champion/challenger** before you replace anything: run the new version in shadow, scoring but not
  acting, until it beats the incumbent on the eval that matters.

**Seen here.** The conversion-version pattern from §1, generalised to model outputs. And the rule that
a system may check and draft, but may not sign.

**Build.** Version and confidence on every model output, then the small view answering: when did this
coefficient last move, and by how much?

**Done when** you can answer *"which version produced this number, and when did it last change?"* for
any output, without reading code.

⚠ **Trap.** An invisible stale coefficient inside a contractual document is a recall. The failure is
not a wrong model; it is a right model whose inputs quietly went out of date.

---

# 8. What you will know

That integrating AI into a manufacturing system is mostly **not** modelling. It is knowing which
technique the problem wants — and being willing to answer *"none of them, use the formula"*; keeping
measured, derived and predicted distinguishable all the way to the screen; and being able to prove a
thing works, before and after you change it.

The techniques rank roughly opposite to how they are taught: optimisation and statistics pay first
and need no data, grey-box fitting pays most in process manufacturing, and language models are the
narrowest tool of the four despite the attention.

---

# 9. Where to spend it

| Next | Why |
|---|---|
| Pick an item from **`[AI]`**'s catalogue and build it | Those needing no production data are buildable immediately: allocation, sequencing, capability reporting, certificate conformance, document extraction |
| Follow **[`AskFlatWire-LearningPath.md`](../50-frontend/AskFlatWire-LearningPath.md)** | The worked example of taking one catalogue item to a screen in this stack. It assumes §6 and goes straight to integration |

⚠ Read `[AI §5]` before committing. Several items are blocked on decisions or on data that does not
exist yet, listed there by whether the blocker is a decision, a small build, or physics and time.

---

## Related documents

| Document | Why |
|---|---|
| [`AIOpportunities.md`](AIOpportunities.md) `[AI]` | **The companion.** It says what could be built; this says how to become able to build it. §5 lists what blocks each item |
| [`AskFlatWire-LearningPath.md`](../50-frontend/AskFlatWire-LearningPath.md) | The screen-specific pathway — one catalogue item taken to implementation |
| [`AskFlatWire.md`](../10-requirements/screens/AskFlatWire.md) | The worked example behind §6 |
| [`Architecture.md`](../20-architecture/Architecture.md) `[ARC]` | §14, the stack rule that governs shipping and not learning |

> ⚠ **The API surface in §6 moves.** Model ids, parameter names and beta flags change between
> releases, and several patterns widely recalled from older material are now rejected outright — the
> thinking budget and assistant prefill among them. Check the current official documentation before
> writing, rather than trusting either memory or this page.
