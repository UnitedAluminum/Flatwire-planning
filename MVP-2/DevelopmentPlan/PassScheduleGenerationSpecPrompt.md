# Specification Prompt — Flat Wire Processing Pass Schedule Generation

**Project:** Flat Wire Mill — Shopfloor & Real-Time
**Last Updated:** August 1, 2026
**Status:** Ready to use

Hand the block below to Claude Code (or any agent with repo access) to produce a **client-facing
Pass Schedule Generation Specification** — a combined FDD/SRS that defines what an industry-standard
pass schedule generation engine must do, and enumerates everything United Aluminum must supply or
decide before it can be built.

It is a **specification** prompt, not an implementation prompt. The output is one markdown document
intended to be sent to the client for review, completion, and sign-off.

---

## The prompt

> Produce a **Flat Wire Processing Pass Schedule Generation Specification** for United Aluminum —
> a professional Functional Design Document / Software Requirements Specification that defines
> everything required to build an industry-standard pass schedule generation engine for the flat
> wire mill, and that clearly identifies every piece of engineering data, process knowledge, and
> business rule the client must provide or confirm before implementation can begin.
>
> Write it to `MVP-2/RequirementDocuments/PassScheduleGenerationSpec.md`.
>
> The document has two jobs, equally weighted. First, it is the **engineering specification** for
> the generation engine. Second, it is the **information-request instrument** — a structured
> checklist and questionnaire the client can work through, complete, and approve. Do not let the
> second job become an afterthought appended to the first.
>
> ### Ground yourself first — physical process only
>
> Read these for equipment topology, material flow, alloys, and terminology. **Read them for the
> manufacturing process, not for the software.**
>
> 1. `CLAUDE.md` — terminology rules and the flat wire domain summary.
> 2. `MVP-1/ProjectPlan/Business/VisionAndScope.md` — the FL1 / FL2 / FL3 line flows.
> 3. `LatestDocument/FlatWire_MasterSpecification.md` — equipment configuration and process
>    vocabulary. **Equipment sections only.**
> 4. `Analysis/FlatWireProcessWalkthrough.md` — the end-to-end process narrative.
> 5. `Analysis/FlatWireOpenQuestions.md` — the existing `Q##` decision register. Read it so your
>    questionnaire does **not** re-ask what the client has already answered, and so your new IDs do
>    not collide with theirs.
>
> ### What must not appear in the document
>
> The specification must stand on its own for a reader who has never seen this system. It must
> contain **no** database table or column names, **no** API endpoint paths, **no** screen or
> dashboard names or numbers, **no** phase/sprint/story IDs, **no** class or service names, and
> **no** description or critique of anything already built or specified. The client is not being
> shown a defect list; they are being asked to specify a process.
>
> Prior internal analysis has identified real engineering gaps in how pass schedules are currently
> derived. **Reframe every one of those as a forward-looking engineering requirement, a recommended
> default, or a client question.** Never as a correction to existing work.
>
> ### Grounding facts you may state as given
>
> These are equipment facts, not implementation details, and the document should be built on them
> rather than describing a generic rolling mill:
>
> - **FL1** — rod payoff → wire drawing at two draw boxes (DB1, DB2) → 12" flattening mill FM1 →
>   intermediate spool. **FL1 has no edger**, so flat wire width leaving FM1 is set entirely by free
>   lateral spread.
> - **FL2** — pre-flattened spool → finishing mill FM2: **three stands — S1 (8"), S2 (6"), S3 (6", final)**, with edgers at S2 and S3 only
>   (S1, S2, S3). **Edgers are fitted at S2 and S3 only.**
> - **FL3** — FL1 feeding FL2 continuously as one line, **with no intermediate anneal**.
> - Alloys in scope: **1100, 1350, 3003, 5052, 6061**.
> - Units are **US customary throughout** — inches, pounds, feet per minute, °F. Carry gauge and
>   die dimensions to four decimal places.
> - Terminology: **"flat wire," never "strip."** Round wire before flattening is "wire" or "rod"
>   as appropriate to the stage.
>
> A pass schedule on this line therefore spans **two physically different processes** — *wire
> drawing* through dies (DB1, DB2) and *flat rolling* through mill stands (FM1, FM2). These obey
> different mechanics and different limits. **Any section that treats the whole line as one rolling
> sequence is wrong.** Give drawing and rolling their own treatment throughout Sections 3, 6, 7
> and 8.
>
> ### Provenance discipline — the most important rule in this prompt
>
> This document goes to a customer and will be used to make engineering commitments. Every
> quantitative statement in it must carry one of three tags, and the tag must be visible at the
> point the number appears:
>
> | Tag | Meaning |
> |---|---|
> | `[INDUSTRY STANDARD]` | Established published practice or physical law. Name the source — the relation, the author, or the standard. |
> | `[RECOMMENDED DEFAULT]` | A starting value we propose, to be tuned against trial data. Say what it is based on and how it will be refined. |
> | `[CLIENT INPUT REQUIRED]` | We do not know this and cannot responsibly guess. Show it as a blank awaiting the client. |
>
> **Never present a United Aluminum-specific value as known.** Per-pass reduction limits for their
> alloys, roll force and drive limits for their mills, their tolerance bands, their speed envelope,
> their product dimensional range — all of these are `[CLIENT INPUT REQUIRED]`, regardless of
> whether a plausible number could be inferred. Do not invent vendor names, model numbers, or
> equipment capacities. Where a physical relation is standard but its coefficients are
> plant-specific, state the relation as `[INDUSTRY STANDARD]` and its coefficients as
> `[CLIENT INPUT REQUIRED]` — that split is the normal case and should appear often.
>
> ### Identifier scheme
>
> Number every item the client must act on, so it can be tracked through review:
>
> - `PSG-D##` — a data item or decision the client must supply (Sections 5, 7, 9).
> - `PSG-Q##` — an open question for the client (Section 10).
> - `PSG-A##` — an assumption we have made (Section 11).
> - `PSG-R##` — a risk (Section 11).
>
> These must not collide with the existing `Q##`, `OQ-##`, `FR-###`, `G##`, or `OI-##` series.
>
> ### Document structure
>
> Use exactly these thirteen sections, in this order.
>
> **1. Introduction** — purpose of the document; what pass schedule generation is for; why pass
> schedules matter in flat wire manufacturing; objectives of the generation engine; scope and
> explicit non-scope; assumptions; intended audience (process engineering, operations, quality,
> and the development team).
>
> **2. Pass Schedule Fundamentals** — what a pass schedule is and why it is required; the flat wire
> process from rod to finished coil; the manufacturing objectives a schedule must satisfy
> simultaneously (dimensional accuracy, surface finish, edge condition, metallurgical condition,
> throughput, tooling life); the engineering principles involved; a terminology table defining every
> term used later — draft, pass, reduction, elongation, spread, area reduction, draw ratio, roll
> gap, mill spring, aspect ratio, cold work, anneal.
>
> **3. Industry Standard Pass Schedule Design** — the substantive engineering section. Split it into
> drawing and rolling.
>
> *Wire drawing (DB1, DB2):* area reduction per die and how reductions **compound** rather than add
> across passes; the ideal, redundant, and friction components of drawing stress; the drawing-stress
> safety factor against the exit yield strength; die half-angle, bearing length and approach
> geometry; the Δ (delta) parameter and its role in avoiding central bursting and chevron cracking;
> die sequence design and why equal per-pass reduction is a defensible default but a tapered
> sequence is often preferred; back tension; lubrication regime; work hardening and when an
> intermediate anneal becomes necessary.
>
> *Flat rolling (FM1, FM2):* draft and reduction per stand; elongation and mass-flow continuity;
> **lateral spread** — the fact that width out of a flattening pass is a predicted quantity, not an
> assumed one, and the classical empirical treatments of it; the effect of edge geometry on
> cross-sectional area, and why a round edge is not a rectangle; roll separating force and drive
> power as the real limits on draft; **mill spring** and the gaugemeter relation, whereby exit
> thickness exceeds the unloaded roll gap by a load-dependent amount; roll flattening; roll gap
> setting and the distinction between a set gap and a delivered gauge; inter-stand speed ratios from
> constant mass flow; strip tension between stands; surface finish; edge profile control and what
> changes when a stand has no edger.
>
> *Both:* cumulative cold work across the whole route and its metallurgical consequences; tolerance
> and capability; process optimisation strategies and what is actually being optimised.
>
> Three topics must be treated explicitly and at depth, because they are the difference between a
> schedule that runs and one that does not:
>
> - **Compounding reduction.** Total reduction across *n* passes is `1 − (1 − r)ⁿ` for equal passes,
>   not `n × r`. Give the pass-count relation `n = ⌈ln(1 − R_total) / ln(1 − r_max)⌉` and the
>   equal-reduction distribution `r_each = 1 − (1 − R_total)^(1/n)`.
> - **Lateral spread.** Width must be predicted, not assumed. Explain why this matters most acutely
>   on FL1, which has no edger and therefore delivers whatever free spread produces, and why the
>   edgers at FM2 S2 and S3 change the problem rather than removing it.
> - **Inter-stand pass allocation.** When a finishing mill follows a flattening mill, the total
>   reduction must be *distributed* across the stands. The upstream mill must deliver an
>   intermediate gauge, not the final gauge — otherwise the downstream stands have nothing to do.
>   Show how the allocation is derived and what bounds it.
>
> **4. Required Inputs** — every input needed to generate a schedule, as a table with columns:
> Input · Description · Unit · Data type · Mandatory/Optional · Example · Source · Client must
> supply (Y/N). Cover at minimum: alloy and temper; incoming rod diameter and its tolerance;
> incoming rod condition and prior work history; target thickness; target width; target
> cross-sectional area; edge profile; mechanical properties (yield, tensile, elongation, work
> hardening behaviour); customer specification and any precision or certification requirement; line
> selection; stand and die configuration available; roll diameters; speed limits; coil or spool
> weight and dimensional limits; surface finish requirement; heat treatment and anneal requirements;
> production constraints. Group them by whether they come from the order, the material, the machine,
> or process engineering.
>
> **5. Required Master Data** — the reference data the engine reads. For each: purpose, required
> fields, owner, source, and whether the client must provide it. Cover material master, product
> master, machine master, roll master, die/tooling master, material property master, reduction rule
> master, speed rule master, quality rule master, tolerance rule master, and process parameter
> master. State plainly for each whether it exists today, exists but is unpopulated, or does not
> exist. Assign every unpopulated field a `PSG-D##`.
>
> **6. Pass Schedule Generation Logic** — the algorithm end to end. Required content: the full
> calculation sequence with every formula stated symbolically and in units; decision logic for pass
> count and route; how intermediate dimensions are derived at each stage; how the final pass is
> adjusted for tolerance and finish; die selection and snapping to available tooling, including
> **re-validation of per-pass reduction after snapping**, since snapping redistributes reduction
> between passes; roll gap derivation including mill spring compensation; speed and speed-ratio
> derivation; constraint checking; optimisation objective and method; validation; exception handling
> and recovery. Include readable **pseudo-code**, at least two **Mermaid flow diagrams** (overall
> generation flow, and the pass-count/route decision tree), and **two fully worked examples carried
> through every step with the arithmetic shown**:
>
> - A nominal case — 1100, rod 0.375", target 0.110" × 0.625", round edge.
> - A stress case that must be *rejected or warned* — one that cannot be achieved in the available
>   passes, or that violates a machine limit. Show the engine detecting it, and state exactly what
>   the operator or engineer is told.
>
> Where a coefficient is unknown, carry the symbol through the worked example and show the result as
> a function of it rather than substituting an invented number.
>
> **7. Engineering & Manufacturing Rules** — every rule that constrains generation: maximum and
> minimum reduction per pass (drawing and rolling stated separately); width-to-thickness ratio
> limits; rolling force and drive power limits; machine load limits; speed limits; material-specific
> rules; product-specific rules; surface finish rules; tolerance rules; safety margins. Present as a
> table with a column that marks each rule `[INDUSTRY STANDARD]` or `[CLIENT INPUT REQUIRED]`, and
> make sure a reader can see at a glance which rules we are asserting and which we are asking for.
>
> **8. Validation Framework** — everything checked before a schedule may be approved, organised as
> engineering, material, machine capability, quality, process parameter, and production feasibility
> validations. For each: what is checked, the pass/fail criterion, the severity (blocking error vs
> warning), and the message the user sees. Include the validations that only become possible once
> the client supplies missing data, and mark them as such.
>
> **9. Client Review & Information Required** — the checklist section, and one of the two most
> important in the document. One row per item, with columns: `PSG-D##` · Requirement · Description ·
> Why it is required · Impact if unavailable · Priority (High/Medium/Low) · Recommended value or
> industry best practice · Client decision required (Y/N) · **Client comments** (blank) ·
> **Approval status** (blank). Cover at minimum: material-specific reduction limits; maximum
> allowable draft per pass per stand; machine capacity limits including roll force and drive power;
> mill spring characteristics; spread behaviour; rolling speed rules; roll and die change criteria;
> pass sequence rules; surface finish requirements; customer-specific processing rules; quality
> acceptance criteria; tolerance limits; product dimensional envelope; scrap and rework handling;
> exception handling rules; operator override permissions; approval workflow. Order the table by
> priority so the client sees the blocking items first. The last two columns must be genuinely empty
> and wide enough to write in.
>
> **10. Open Questions for Client** — the questionnaire, and the other most important section.
> Organise by category: Material · Machine · Rolling Process · Drawing Process · Product · Quality ·
> Production · Exceptions · Optimisation · Approval. Each question gets a `PSG-Q##` and four parts:
> background (what we understand today), why the answer is needed (what it blocks), example or
> candidate values to make the question easy to answer, and a blank response space. Ask questions a
> process engineer can actually answer — specific, bounded, and one thing at a time. A question that
> requires the client to write an essay will not be answered.
>
> **11. Assumptions & Risks** — every assumption as `PSG-A##` with what we assumed and why; every
> risk as `PSG-R##` with the consequence if an assumption proves wrong, a likelihood/impact
> assessment, and a concrete mitigation. Include the assumption that trial data will be available to
> calibrate the empirical coefficients, and the risk that it is not.
>
> **12. Implementation Readiness Assessment** — an honest assessment: what we have; what is missing;
> which missing items are **critical blockers** as opposed to items that can be defaulted and tuned
> later; development prerequisites; recommended next steps with a suggested sequence. Be direct
> about what cannot be built correctly today, and equally direct about what can proceed immediately
> under stated defaults. Distinguish the two clearly — the client needs to know that supplying data
> is on the critical path, without being told the whole project is blocked.
>
> **13. Future Enhancements** — AI-assisted generation; automatic optimisation; predictive quality
> analysis; digital twin simulation; SPC feedback into schedule refinement; learning from historical
> schedules and their measured outcomes; MES/ERP integration. Keep each to a short paragraph, and be
> clear these are post-go-live.
>
> Close with a **Client Sign-off Checklist** — a single consolidated table summarising every pending
> decision and approval, cross-referenced by `PSG-D##` and `PSG-Q##`, with columns for owner,
> due date, response, and sign-off. This is the page the client's process engineer will actually
> work from, so it must be complete enough to stand alone.
>
> ### Document conventions
>
> - Open with the repo header block — **Project · Last Updated · Status** — and end with a **Change
>   Log** table, per house convention.
> - Client-facing register throughout. Professional, plain, and confident. No internal shorthand, no
>   agent commentary, no meta-narration about the writing process.
> - Tables, formulas, decision trees, and worked calculations wherever they carry the meaning better
>   than prose. Mermaid for diagrams.
> - State formulas symbolically first, then substitute. Show units.
> - This is a substantial document — Sections 3, 6, 9 and 10 carry the weight and should be deep.
>   Do not pad Sections 1, 2 and 13 to match them.
>
> ### Before you finish, verify
>
> 1. Every number carries a provenance tag, and no UAL-specific value is asserted as known.
> 2. Drawing and rolling are treated separately wherever their mechanics differ.
> 3. Compounding reduction, lateral spread, and inter-stand pass allocation are each covered
>    explicitly and correctly.
> 4. No table, endpoint, screen, phase, or story name appears anywhere.
> 5. Nothing reads as a critique of existing work.
> 6. Both worked examples are carried through every step, arithmetic shown, and the stress case is
>    genuinely rejected rather than quietly passed.
> 7. Every `PSG-D##` and `PSG-Q##` appears in the final sign-off checklist, and every checklist row
>    traces back to a numbered item.
> 8. The client comment and approval columns are empty and usable.
> 9. A process engineer who has never read our documentation could answer the questionnaire from it.

---

## Notes for whoever runs this

- The output is **client-facing**. Expect to review the provenance tags before it is sent — that is
  the fastest way to catch anything the agent asserted that we do not actually know.
- The questionnaire in Section 10 and the checklist in Section 9 are the working deliverables. If
  those two sections come back thin, re-run with emphasis on them rather than accepting the draft.
- Section 12's readiness assessment should agree with what we already know about the schedule: the
  engine can be built against defaults, but the empirical coefficients need trial data, and the
  machine limits need a vendor datasheet. If it claims the work is fully unblocked, it is wrong.
