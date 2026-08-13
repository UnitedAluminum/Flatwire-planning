# Flat Wire Mill — Exception Handling

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
**Document Type:** Material leaving the normal path — checkout, carry-forward, scrap
**Status:** Baselined for build
**Owner:** BA / Analysis stream
**Audience:** Developers, QA, BA, operations
**Shortcode:** `[EX]`
**Part of:** `ProjectPlan/Business/` — index: [README.md](../README.md)

---

### 4.6 The three checkout modes

| | **Mode P — pre-check-out** | **Mode A — pre-run** | **Mode B — mid-run** |
|---|---|---|---|
| Rod was checked in? | **No** — only pre-checked-in | Yes | Yes |
| `RunId` | NULL | NULL | populated |
| Footage | 0 | 0 | > 0 |
| Pass-schedule acknowledgement | none to void | voided | voided |
| PLC tags | **none were pushed** | cleared | cleared **after confirmed stop** |
| Line-state gate | **not needed** | yes | yes |
| In-process material | none | none | requires a disposition |
| Approval | Operator *(OI-44 open)* | Operator | **Supervisor** |
| Screen | DB2A | DB12 | DB12, reached **only** via the Pause dialog |
| Resulting rod status | `RECEIVED` or `STAGED` | `STAGED` or `RECEIVED` | `HOLD`, `SCRAP` or `STAGED` |

**Mode B flow:** operator submits with locked footage, reason and rod disposition → the run closes as a partial run → a **PENDING DISPOSITION** record is created with the material **locked and carrying no alpha** → SignalR notifies the Supervisor role → the supervisor reviews the partial-run gauge trace, footage, reason, operator and timestamp from any connected terminal → **Accept** (partial spool alpha generated, enters the spool queue) · **Hold** (alpha generated with Hold status, QC must release) · **Reject** (WIP Rejection flow to scrap). **No alpha exists until the supervisor approves.**

**PLC gatekeeper rule (all modes with tags):** the application reads `FL{n}.LineState` before the dialog opens **and** before a confirm is accepted; if it reports Running the checkout is blocked. The application **never sends a stop command**. The footage counter is read and **locked at the moment the dialog opens**.

---

### 4.7 Partial-rod re-check-in (carry-forward)

A rod removed mid-run and returned to storage is only partly consumed. The design is **carry-forward on a single persistent rod record**:

- The rod record carries `FootageRunToDate` and `RemainingWeightEstimateLb`, initialised on first check-in and updated on every confirmed checkout.
- Re-check-in **retrieves the existing record by alpha**; it never creates a new one.
- If `FootageRunToDate > 0`, the **fresh-start path is removed from the DOM** and the operator sees the prior-run history with only *Proceed as partial re-check-in* and *Cancel*, plus an explicit physical-identity confirmation.
- A **new, independent run record** opens with its footage counter at zero. Each run segment produces **its own spool alpha**, and every partial spool alpha carries `SourceRodAlpha` back to the originating rod.
- Material drawn or rolled and left in the mill at removal is **scrapped** and does not carry forward.
- **The gate fires at the DB2A staging scan**, not only at check-in — staging is where the rod is first identified.

---

### 4.10 Scrap — the parallel path

| Scrap type | Source stage | Disposition |
|---|---|---|
| Wire rod scrap (end crop, entry scrap) | check-in, drawing | scrap box, then baled into a scrap unit |
| In-process flat wire scrap (FL1/FL2) | flattening, finishing | follows existing slit-material scrap procedures |
| Out-of-spec wire bundles | output QC | compacted in the baler *(max dimensions TBD — OI-83)* |
| Edge trim | FM2 edgers | scrap box **or scrap skid** — a new outlet selection required in the Scrap module |
| Material left in the mill at a mid-run rod removal | Mode B checkout | scrapped; does not return with the rod |

---
