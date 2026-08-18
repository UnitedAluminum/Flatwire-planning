# FW-143 · Serilog structured logging and the audit log

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — `G2`/`OI-39` dated to before T2 (`[TRP §6]` blocker 3) *(first issue, same day)*
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **the audit half has no persistence target (§5, `P-15`)**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-143`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** This story is two unlike halves under one title. The Serilog
> half is configuration and takes an afternoon. The audit half is a **compliance
> obligation** — *"so a machine configuration can be reconstructed after the fact"* — and its
> third acceptance criterion, *"queryable by run and by operator"*, **has no table to be
> queried from.** None of the 28 tables in `FlatWireDB` is an audit log. That is `P-15` and
> it needs a decision before the story can be finished, not while it is being closed.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-143 · Serilog structured logging and the audit log
> **Hours:** 12 h BE · **Priority:** High · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** compliance owner,
> **I want** every PLC push and schedule override written to an audit log,
> **So that** a machine configuration can be reconstructed after the fact.
>
> **Acceptance Criteria:**
> - [ ] Serilog wired to the inherited UAL configuration; structured logs throughout
> - [ ] **Audit log** entries for PLC pushes (tag, value, operator, result) and pass-schedule overrides
> - [ ] Audit entries are queryable by run and by operator
>
> **Rate-card basis:** logging + audit sink (12 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** —

### 1.2 Out of scope

| Concern | Story |
|---|---|
| `PLCTagService` — this story records what it does | `FW-151` |
| The tag-path map and log paths as configuration | [`FW-144`](FW-144-Configuration-Binding.md) |
| Exception→status mapping (a different concern from logging) | [`FW-146`](FW-146-Exception-Middleware-And-Envelope.md) |
| The `X-Correlation-Id` header itself — middleware is inherited | `FW-N04` step 6 |

---

## 2. The Serilog half

| Requirement | Detail |
|---|---|
| Host wiring | `builder.Host.UseSerilog(...)` — **`CoilCheckin` does not have this**; `UATemplate` does and `FW-N04` step 6 kept it |
| Configuration | Inherited UAL shape: `MinimumLevel` + overrides, `File` sink (compact JSON, daily rolling, `retainedFileCountLimit` 100), `GrafanaLoki` sink, enrichers `FromLogContext` · `WithMachineName` · `WithThreadId` · `WithProcessId` |
| Paths | `E:\Instance\Logs\FlatWire\log-.json`; Loki label `app` = `FlatWire.API` — `FW-N04` step 7 |
| Correlation | **`X-Correlation-Id` echoed back on every response and stamped on every log line** (`[API §1.4]`, `phase-01b` L88). The inherited `CorrelationIdMiddleware` takes the header name and the log-property name as constructor arguments |
| Enrichment | `.Enrich.WithProperty(ApplicationContext, ScopeName)` and `.Enrich.FromLogContext()`, as `UATemplate` does |

Serilog packages are already on the API project from `FW-N04` step 5. `[MON]` expects daily
rolling files and 100 retained.

---

## 3. The audit half

### 3.1 What must be recorded

| Event | Fields | Source |
|---|---|---|
| PLC push | tag, value, operator, result | the card; `phase-01b` L111 sinks `PlcTagsPushed` / `PlcTagWritten` / `PlcTagsCleared` |
| Pass-schedule override | who, what, when | the card |

### 3.2 Two rules that are easy to miss

**`FR-072`: the audit record is written *before* the push.** Not after, and not in a
`finally`. A push that fails must still leave evidence that it was attempted — which is the
whole point of reconstructing a machine configuration after the fact.

**OPC writes are not transactional.** `phase-01b` L111: model failure recovery as
**compensating re-clears**, not "rollback" (`G2`). So the audit trail is expected to contain
a push, a failure and a compensating clear as three records — not one record that was rolled
back.

### 3.3 Where the two overrides already have homes

Not everything here needs a new store:

- **Pass-schedule changes** — `PassScheduleChangeLog` exists in the schema. But MVP-1 never
  authors a schedule (`[SVC §3.2a]`, `OI-110`), so what MVP-1 records is the **snapshot of
  what it pushed**, held as `PassScheduleSnapshot` — *"so a certificate stays reproducible
  after the owning system later edits the schedule"* (`[PLC §11.2]`, `Q64`).
- **Roll-gap overrides** — `RollOverride` is a real table.

**PLC pushes have neither.** That is the gap.

---

## 4. Build order

1. Confirm `UseSerilog` from `FW-N04`; add enrichers and the sink configuration.
2. Verify the correlation id round-trips: inbound header → log property → response header.
3. **Settle `P-15`** before writing the audit sink.
4. Write the audit writer behind an interface — `IAuditLog` — so the destination in `P-15`
   can change without touching call sites.
5. Wire the three PLC sinks and the override sink, **before-the-push** per `FR-072`.
6. Prove the query path for whichever destination `P-15` chooses.

---

## 5. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-14` precede this story.

### `P-15` — the audit log needs a persistence target, and none exists

**This is an open finding, not a resolved decision. Raise it; do not absorb it.**

AC 3 requires audit entries **queryable by run and by operator**. The verified
`FlatWireDB` baseline is 28 tables (`[DBD §6.2]`) and **none of them is an audit log**.
Serilog's configured sinks are a rolling JSON file and Grafana Loki — neither is queryable
by run in the sense a compliance reconstruction needs, and neither is inside the database
whose backup and retention policy covers the traceability data.

Three options, with the recommendation first:

| Option | Cost | Consequence |
|---|---|---|
| **A new `PlcTagAudit` table in `FlatWireDB`** *(recommended)* | A 1C schema change — **it would be the 29th table** | Queryable by run and operator as written; inside the same backup and retention envelope as the traceability it supports. Changes the object baseline, so `[DBD §6.2]` and every count citing it move together |
| Loki + a saved query | none | Satisfies "logged", not "queryable by run". Retention is the log platform's, not the database's — a weak basis for *"reconstructed after the fact"* |
| Reuse `PassScheduleChangeLog` | none | Wrong grain. It is the schedule's change history, not a record of what was pushed to a controller, and MVP-1 does not author schedules |

**Recommendation: option A**, and it must go through 1C rather than being created by this
story — `FW-N04` and this plan both hold that the DDL is 1C's. Until it is decided, build
behind `IAuditLog` (step 4) so the choice is one implementation, not a refactor.

⚠ This is the same defect class as `G34` (wire break — *"a decided flow with **no
persistence target**"*). Worth registering as a gap on the same basis.

---

## 6. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| Serilog wired | Console and file sinks produce structured JSON; the Loki labels are right |
| Correlation | One request end-to-end: the inbound `X-Correlation-Id` appears on **every** log line for that request and on the response |
| Audit entries | A simulated PLC push (`SimulatePLCTagPush = true`) writes tag, value, operator and result — **and writes them before the push**, provable by forcing a failure and finding the record |
| Queryable by run and operator | **Blocked on `P-15`** |

> Under `SimulatePLCTagPush`, *"a simulated write **logs the write it would have made**"*
> (`phase-01b` L109) — so the audit path is fully exercisable in every environment before
> commissioning, which makes this story testable now rather than at `C1`.

---

## 7. Handoff

`FW-151` calls the audit writer from `PLCTagService`. `FW-144` supplies the log paths and
the tag map. `[MON]` consumes the output.

---

## 8. Open items and stale citations

| Item | Effect here |
|---|---|
| **`P-15`** | AC 3 cannot be met. The one thing to settle before closing the story |
| **`G2` / `OI-39`** | Check-in is not one ACID transaction — Critical, and **`[TRP §6]` blocker 3 dates it *before T2***. The audit trail is what makes a compensating recovery reconstructable, so this story is part of `G2`'s mitigation |
| **`G33` / `PLC-Q05`** | The measure segment of all 41 tag paths is ours. **A wrong path fails silently — the write reports success while the line keeps its previous settings.** The audit record will faithfully record a successful write that did nothing; do not read a green audit trail as proof the line was configured |

No stale citations found in this story's card.
