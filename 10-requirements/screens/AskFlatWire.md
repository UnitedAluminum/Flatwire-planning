# Flat Wire Processing — Ask Flat Wire Specification

**Project:** Flat Wire Mill Implementation
**Document Type:** Functional Requirement Specification — Issued for Client Review
**Applies to:** All three lines; supervisor, quality, engineering and planning roles
**Version:** 1.2
**Last Updated:** September 4, 2026 — **§2.1 added: how the screen uses a wider panel.** The rail grows between 240 and 320 px, the reading spine stays at 760 px at every size because line length is a readability limit, and result tables take the full width up to ~1,240 px — worth about 450 px of extra table on the 1920 canvas. Also records, for a reviewer opening the mockup on a laptop, that below the specified panel height the whole suite scales down together *(previously 1.1 — **§2 redesigned: the screen is a conversation, not a dashboard.** Six stacked panels become one surface holding a rail and a transcript; a result now sits inside the answer that produced it. §5's chip strip moves under the question it describes; §6 becomes a single composer that adds turns rather than replacing the screen; §7 separates per-result export from whole-conversation export. **No rule changed** — `AQ-1`–`AQ-14` are behaviour, not layout *(previously 1.0, first issue, September 4, 2026)*)*
**Status:** **PROPOSED**. This screen is in neither MVP-1 nor MVP-2
**Screen reference:** Ask Flat Wire (`ASK`) — mockup `dashboard_ask.html`
**Requirement source:** Your written request of 4 September 2026, including the worked example quoted in §1.2. No numbered requirement group exists for this screen yet

---

## Reading Convention

| Tag | Meaning |
|---|---|
| `[CONFIRMED]` | Agreed with United Aluminum. Built as stated. |
| `[PROPOSED]` | Our design recommendation, requiring your confirmation at review. |
| `[CLIENT INPUT REQUIRED]` | We do not know this and will not assume it. Listed in Section 12. |

> **Please read this one with particular attention.** It is a first issue, so nothing in it has been
> reviewed before, and the whole screen is a proposal rather than a commitment. **Nothing here is
> scheduled, costed or scoped into a release.** If the answer to Section 12's first question is
> "not now", the correct outcome of this review is that the document is parked — that is a success,
> not a failure.

---

# 1. Introduction

## 1.1 Purpose

Ask Flat Wire lets a person type a question in plain English and get back the actual production
records that answer it — across rods, spools, coils, welds, runs and quality checks — then refine
the question, and export the result as a report.

It replaces a specific piece of daily friction: today, answering *"which coils came off that rod,
and were any of them welded?"* means opening several screens, reading each one, and assembling the
answer by hand. There is no screen that spans the material journey, because every existing screen is
built around one station.

## 1.2 Why this screen is being proposed

Three reasons, in order of weight.

**First, you asked for it, and the request came with its own worked example.** On 4 September 2026:

> *"Show me all coils produced from Rod R00045 during the last shift, including their weight,
> dimensions, weld information, and current status."*

That one sentence crosses four kinds of record and a time window. It is used verbatim as the first
demonstration on the mockup, and every design decision in this document was tested against it.

**Second, the data to answer it already exists and is already exact.** This screen invents no
number. It reads what the plant recorded and presents it. That makes it the lowest-risk place to
introduce this kind of assistance: nothing it produces reaches a machine, a schedule or a
certificate without a person putting it there.

**Third, the traceability you are building for welding-wire certificates has a second use.** Every
event on a run is stamped with its position along the wire, and the genealogy already resolves
finished footage back to the supplier heat. That chain was built to satisfy customers. It also
answers most of the questions a supervisor asks at the end of a shift — but only if something can
walk it, which nothing currently can.

## 1.3 What this screen is not

- **It does not predict.** No forecasts, no estimates, no "expected" anything. It reports what was
  recorded. A question that asks for a prediction is declined, visibly — see §9.
- **It does not write.** It cannot change a record, release a hold, alter a schedule or send
  anything to a machine.
- **It is not a replacement for the operator screens.** Nobody checks a rod in from here.
- **It is not the certificate.** A report exported from this screen is a working document. Whether
  it can ever be a controlled one is an open question in §12.
- **It does not print travelers.** The traveler is digital by decision. This screen exports reports,
  which are a different thing.

## 1.4 It is registered here, not adopted

`[PROPOSED]` This screen sits deliberately outside the operator suite, in the same way the machine
simulator console does. Five points, so no reader mistakes it for scoped work:

1. It is **not counted** in the fifteen-dashboard inventory.
2. It is **not** on the operator navigation path for any production task.
3. It **is** reachable from the line board and the More Options menu, because a reviewer has to be
   able to open it. That is the one exclusion it does not take.
4. It has **no dashboard number**. `ASK` is a mnemonic, in the manner of Die Change, Die Management
   and OEE. It must not be tidied into the numbering.
5. It has **no story, no phase and no owner**, and is not a build target.

---

# 2. Layout

`[PROPOSED]` **This screen is a conversation, not a dashboard.** The first design of it was six
stacked panels — a header, an ask bar, a strip of chips, an answer panel, a results panel and a
footer — and it read as a control surface rather than an assistant. It has been reworked so the
conversation is the only thing on screen, and so a result appears *inside* the answer that produced
it rather than in a panel of its own.

```
┌─ United Aluminum application bar — shared, unchanged ────────────────────┐
├──────────────┬───────────────────────────────────────────────────────────┤
│ Ask Flat Wire│                                                           │
│ ASK proposed │        Show me all coils produced from Rod R00045    You  │
│ ‹ Line status│        during the last shift…                             │
│              │             Coil · from R00045 · ●20 Jul 07:00→15:00      │
│  + New       │                                                           │
│    question  │   Three coils, 2,624.25 lb, one of them welded            │
│              │   Rod R00045 ran on FL3 hybrid across two runs and        │
│  THIS SHIFT  │   produced three coils totalling 2,624.25 lb…             │
│  › Coils fr… │                                                           │
│    Holds by… │   │ "Last shift" is not defined anywhere in the design.   │
│    Spool SP… │   │ Resolved to the window shown above the answer.        │
│              │                                                           │
│  YESTERDAY   │   ┌─────────────────────────────────────────────────┐     │
│    Weld cou… │   │ COIL          RUN       FOOTAGE   NET LB        │     │
│              │   │ FW-00600-C01  RUN-0002   11,518   900.07        │     │
│              │   └─────────────────────────────────────────────────┘     │
│              │   3 rows · findRod › runsForRod › coilsForRun ·           │
│              │   rows are retrieval output                               │
│  Build report│   Excel   Word NEW   PDF                                  │
│  More options│                                                           │
│  ─────────── │   ┌───────────────────────────────────────────────────┐   │
│  Carl Bishop │   │ Ask about rods, spools, coils, welds…       [ → ] │   │
│  Supervisor  │   └───────────────────────────────────────────────────┘   │
└──────────────┴───────────────────────────────────────────────────────────┘
```

**Left — a narrow rail.** The screen's name, the `PROPOSED` chip, a link back to the line board, a
prominent **New question**, and recent questions grouped by shift so a supervisor can return to what
they asked earlier. Below them, the two whole-conversation actions and the signed-in operator.

**Right — the conversation, and nothing else.** Questions and answers alternate down a single
centred column. A question sits in a light bubble on the right; an answer has no bubble, no card and
no icon, which is what tells the two apart without labelling either. Beneath each question, in small
muted type, is **how the system read it** — see Section 5.

**A result belongs to the answer that produced it.** The table appears within the answer, behind one
hairline rule, followed by a single line giving the row count, which retrieval operations ran, and
the reminder that the rows are those operations' output. That one line replaces the five separate
elements the previous design used.

Everything is drawn from controls already in the suite — the dense table from the spool queue, the
list idiom from the pass-schedule change history, the colour semantics used everywhere. The screen
obeys the same rules as the rest: no text below 14 px, large touch targets on anything that commits,
and **no action that depends on hovering**, which is why the export actions under a result are always
visible rather than appearing on hover as they would in a consumer chat tool.

## 2.1 How it uses a wider panel

`[PROPOSED]` The screen is authored for the 1280 × 1024 panel and renders at exactly 1:1 there and on
the 1920 × 1080 canvas. On the wider one it does **not** simply stretch, and it does not leave the
conversation stranded in the middle either. Two widths move independently:

| | Behaves how | Why |
|---|---|---|
| **The rail** | Grows gently with the panel, between 240 and 320 px | A fixed rail looks abandoned on a wide screen; an unbounded one wastes it |
| **The reading spine** — questions, answers, notes and the box you type in | **Stays at 760 px at every size** | Line length is a readability limit, not leftover space. A 1,200 px line of prose is harder to read, not easier |
| **Result tables** | Take the full width of the conversation area, up to about 1,240 px | This is the one thing that genuinely wants the room: more columns visible without sideways scrolling |

Both are centred on the same line, so the layout stays coherent as the panel changes. The practical
effect at 1920 is that a result table gains roughly 450 px of usable width while the prose above it
is unchanged.

⚠ **Below the specified panel height the whole screen set scales down together.** On a display
shorter than 1024 px — a 1366 × 768 laptop, say — the shared fitting behaviour shrinks every screen
in the suite proportionally, and text is rendered below the 14 px floor. That is a property of the
suite, not of this screen, and it does not arise at either of the two resolutions the panel
specification names. It is recorded here because a reviewer opening the mockup on a laptop will see
it and should know it is expected.

---

# 3. Asking a question

`[PROPOSED]` The question box takes focus when the screen opens, so a keyboard or a scanner can be
used immediately. Three example questions sit beneath it as one-tap chips; the first is your own,
quoted above.

There is no query syntax to learn and no field to choose. A person types what they want.

---

# 4. How the answer is produced

## 4.1 The tool path, which is the normal path

`[PROPOSED]` The system does not turn your question into a database query. It is given a small,
fixed set of **retrieval operations** — find a rod, find the runs that consumed it in a window, find
the coils a run produced, find the welds on a run, resolve a coil's genealogy — and it composes
them.

This matters for one reason above all others. **Footage is counted three different ways in this
plant**: from the start of a run, from the start of a coil, and from the start of a spool. They are
not interchangeable, and converting between them depends on values recorded at the time, not on
arithmetic. A run counter can read 23,100 ft while the coils that run produced sum to 22,722 ft —
the difference is threading scrap and the tail, and it belongs to no coil. Because the retrieval
operations do that conversion internally, the conversion cannot be got wrong.

⚠ **This is largely new capability, not a new front end over what exists.** There is today no way to
read a coil's genealogy back out of the system — the chain is written when a coil completes and has
no read path. Most of the retrieval operations above would have to be built. Section 12 lists that
as a cost rather than burying it.

## 4.2 The one rule that makes this safe

`[PROPOSED]` **The language model writes the summary paragraph. It does not produce the table.**

The rows come from the retrieval operations and are rendered directly. The model's text is never
parsed to build a row. A number in the table has therefore come from the database and nowhere else,
and no amount of confusion in the written summary can put a wrong weight in a column.

This is the guarantee everything else in Section 8 rests on, and we would not propose the screen
without it.

## 4.3 The fallback, and why it is fenced

`[PROPOSED]` No fixed set of retrieval operations anticipates every question. When the question
cannot be expressed with them, the system may fall back to a generated read-only query — and this
path is fenced, because it does not have the protection §4.1 describes.

| # | Guard | Why |
|---|---|---|
| 1 | Read-only, on its own credential | It can never write, under any fault |
| 2 | Restricted to reporting views, never the underlying records | The views perform the footage conversion, so the one join that could produce a plausible wrong answer cannot be written wrongly |
| 3 | The query is displayed **before** it runs, and travels with the export | A reviewer can check the question was answered the way they think |
| 4 | Results are visibly marked as **not validated** | A tool-path answer is correct by construction; this one is not, and the screen must never present them as equals |
| 5 | Row cap and time limit | An unbounded query against the measurement history is an incident, not a slow page |

---

# 5. What the system understood

`[PROPOSED]` Directly beneath each question, in small muted type, the screen shows how it read that
question — the kind of record, what it was filtered by, the time window, and which details were
asked for. **A wrong reading is corrected by tapping that line, not by rewriting the sentence.**

It sits with the question rather than above the answer deliberately: it is a statement about what
was *asked*, not about what was *found*, and putting it anywhere else invites the reader to check it
against the wrong thing.

This is the trust surface of the screen. It is also where the screen is honest about something it
cannot know:

⚠ **"Last shift" is not defined anywhere in this design.** There are no shift start and end times,
no shift names, no weekend or holiday pattern, and no rule for a run that crosses a boundary. This
is a known open item and it blocks the shift report as well. Rather than guess, this screen resolves
the phrase to an **explicit date and time range and displays the range it used**, so it can be
corrected in one tap. `[CLIENT INPUT REQUIRED]` — Section 12, item 1.

---

# 6. Refining without starting over

`[PROPOSED]` There is one place to type, pinned at the foot of the conversation, and it takes both a
first question and a follow-up in the same plain language — *"only the ones with a weld"*, *"add the
supplier heat"*, *"same for R00046"*.

A follow-up **adds a turn to the conversation** rather than replacing what is on screen. The earlier
question, its answer and its rows stay above, so a supervisor can see how an answer was arrived at
and can still export any earlier result. The previous result is not re-fetched if it does not need
to be. Nobody navigates anywhere.

---

# 7. Reports and export

`[PROPOSED]` Export works at **two different scopes**, and the previous design conflated them by
putting all four actions in one footer cluster. They are separated:

| Scope | Action | Where it sits |
|---|---|---|
| **This result** | **Excel** · **PDF** | Directly under the table they belong to. Reuses the existing shared print-and-export capability |
| **This result** | **Word** | Same place. ⚠ **New capability** — see below |
| **The whole conversation** | **Build report** | In the left rail, once. Composes every question, its resolved window, the written answers, the rows and the provenance into one titled document rather than a bare grid |

The distinction matters in use: a supervisor who has refined a question three times usually wants
*one* of those tables in a spreadsheet, but wants *the whole thread* when they are recording how a
conclusion was reached.

⚠ **Word is not free, and we are not going to imply that it is.** The shared print-and-export
capability the other report screens use supports printing, PDF and Excel. **It has no Word path at
all.** Two of your three requested formats are reuse; the third is new work wherever it is built.
This is Section 12, item 6 — accept PDF and Excel, or fund Word deliberately.

---

# 8. Access, safety and audit

## 8.1 It sees exactly what the person signed in can see

`[PROPOSED]` Retrieval runs **as the signed-in user**, never under a service account. This screen
must not become a way to read something a role could not otherwise open. Which roles may reach the
fallback of §4.3 at all is a separate question — Section 12, item 2.

## 8.2 Notes typed on the floor are data, not instructions

`[PROPOSED]` Inspection notes, observation notes, weld failure reasons and checkpoint descriptions
are free text typed by people, and they are returned to the system as part of an answer. Anyone who
can type a note can therefore put words in front of the language model.

Three rules contain that, and the first is the one that matters:

1. Because the table is built from retrieval output and not from the model's text (§4.2), text in a
   note **cannot forge a row**. At worst it misleads a sentence.
2. Retrieved text may **never** select or shape a fallback query. That path is reachable only from
   the question a person typed.
3. Free-text values are returned truncated and clearly delimited.

## 8.3 Every answer is logged

`[PROPOSED]` The question, how it was understood, which retrieval operations ran, the query if the
fallback was used, the number of rows returned, and any export — with who and when. Your existing
requirements already oblige us to retain actions for quality audit, and an exported report may reach
a customer, so **whether to log is not the open question. How long to keep it is** — Section 12,
item 3.

## 8.4 It never goes blank

`[PROPOSED]` If the language service is unreachable, the screen says so plainly and **keeps
everything already on it** — the last answer, its rows and its interpretation all remain, and all
four export actions still work. Asking and refining are disabled until it returns. This is the same
resilience rule every other screen in the suite follows.

---

# 9. When it cannot answer

`[PROPOSED]` Three outcomes are distinguished, because collapsing them into one empty table is how a
tool like this loses a user's confidence:

| Outcome | What the screen says |
|---|---|
| **No rows matched** | The question was understood and ran; there is genuinely nothing. Offers to widen the window |
| **Not understood** | The question could not be read. Shows what it could make out and asks for a rephrase |
| **Out of scope** | Understood, but not answerable from records — a forecast, or something no retrieval operation covers. Says which, and offers the nearest question it *can* answer |

---

# 10. Rules Summary

| # | Rule |
|---|---|
| **AQ-1** | The table is rendered from retrieval output. The language model's text is never parsed to produce a row |
| **AQ-2** | Retrieval runs as the signed-in user, never a service account |
| **AQ-3** | The tool path is the normal path. The generated-query fallback is used only when no retrieval operation can express the question |
| **AQ-4** | A fallback query is displayed before it runs, is read-only, is restricted to reporting views, and is subject to a row cap and a time limit |
| **AQ-5** | Fallback results are visibly marked as not validated, and are never styled as equal to tool-path results |
| **AQ-6** | Text retrieved from records may never select or shape a fallback query |
| **AQ-7** | Footage is never converted between run, coil and spool frames by the screen; conversions are performed by the retrieval operation using recorded anchors |
| **AQ-8** | Across the spool boundary, quantities are attributed by **weight**. Footage is not comparable across it and must not be shown as though it were |
| **AQ-9** | A relative time expression is resolved to an explicit range, and the range is displayed |
| **AQ-10** | The question, its interpretation, the operations used, any query, the row count and any export are logged with who and when |
| **AQ-11** | Loss of the language service does not clear the screen; existing results remain readable and exportable |
| **AQ-12** | No answer, report or export is a controlled document unless Section 12 item 4 says otherwise |
| **AQ-13** | The screen writes nothing, to any system, ever |
| **AQ-14** | Predictions are declined, not attempted |

---

# 11. Confirmed Decisions

| # | Decision | Date |
|---|---|---|
| 1 | The screen is proposed, not scoped. It has no story, phase or owner | 4 Sep 2026 |
| 2 | It carries a mnemonic, `ASK`, and no dashboard number | 4 Sep 2026 |
| 3 | Retrieval is tools-first with a guarded query fallback, rather than either alone | 4 Sep 2026 |
| 4 | Rows render from retrieval output, never from model text | 4 Sep 2026 |

---

# 12. Open Items Requiring Client Input

| # | Item | Why it matters here | Owner |
|---|---|---|---|
| 1 | **What is a shift?** Start and end times, names, the weekend and holiday pattern, and what happens to a run that crosses a boundary | Your own example question says "last shift". Until this is answered the screen must show an explicit range instead. It equally blocks every figure on the shift report | Operations |
| 2 | **Who may use the generated-query fallback?** All roles, supervisors and above, or engineering only | It is the one path not protected by construction | Operations / IT |
| 3 | **How long are questions, answers and exports retained?** | Logging is already obliged; the period is not set | Quality / IT |
| 4 | **Is an exported report a controlled document?** | Decides whether it needs a number, a revision and an approver, or is a working printout | Quality |
| 5 | **Is this wanted at all, and when?** | It is proposed, not planned. Parking it is a valid answer | Programme |
| 6 | **Word export** — accept PDF and Excel only, or fund Word as new capability | The shared capability does not do Word. See §7 | Operations |
| 7 | **Which questions actually matter?** A list of ten questions you would really ask would size the retrieval set properly | The set should be built from real questions, not our guesses | Operations / Quality |

**Two further items are ours to resolve, not yours, and are recorded so they are visible:**

- **The retrieval operations are mostly new.** There is no read path for coil genealogy today. This
  is build cost, and it has not been estimated.
- **Two internal design documents disagree** on how one traceability record counts its footage. The
  executable definition is correct and the descriptive one is stale. This screen would be the first
  thing built on top of that record, so the disagreement must be closed first.

---

# 13. Assumptions

1. The person asking is signed in, and their role is already established by the existing login.
2. Questions are asked in English.
3. The screen is used at a desk or a panel, not while operating a line.
4. Answers are read on screen far more often than they are exported.
5. `[PROPOSED]` Volumes are modest — tens of questions per shift, not thousands. If that is wrong,
   the cost model changes and item 5 above should be reconsidered.

---

# 14. Related Specifications

| Document | Relationship |
|---|---|
| AI Opportunities | The parent assessment. This screen is one catalogue item in it, taken from a line to a design |
| Supervisor Shift Summary | Shares the undefined-shift problem in Section 12 item 1. Whichever is built first should settle it |
| Output Coil Completion | Owns the coil record and its genealogy, which this screen reads and never writes |
| Weld Event | Owns the weld record, including the rule that a row is a weld *attempt* rather than a join |
| Spool Queue | Owns the distinction between a spool as a reusable article and the material in process, which this screen must not conflate in a column heading |

---

# Client Sign-off

## Part A — Rules for confirmation

☐ **AQ-1** The table is built from retrieved records, never from the assistant's prose
☐ **AQ-2** Retrieval runs as the signed-in person, seeing only what that role may see
☐ **AQ-5** Answers from the fallback are marked as not validated
☐ **AQ-8** Across the spool boundary, quantities are attributed by weight, not footage
☐ **AQ-9** A relative time expression is resolved to an explicit range, and the range is shown
☐ **AQ-13** The screen writes nothing to any system
☐ **AQ-14** Predictions are declined rather than attempted

## Part B — Information required

☐ **1.** Shift definition — times, names, pattern, and the boundary-crossing rule
☐ **2.** Which roles may use the generated-query fallback
☐ **3.** Retention period for questions, answers and exports
☐ **4.** Whether an exported report is a controlled document
☐ **5.** Whether this screen is wanted, and if so when
☐ **6.** Word export — accept PDF and Excel only, or fund Word
☐ **7.** Ten questions you would really ask

## Part C — Approval

| | Name | Signature | Date |
|---|---|---|---|
| **United Aluminum** | | | |
| **Nagarro** | | | |
