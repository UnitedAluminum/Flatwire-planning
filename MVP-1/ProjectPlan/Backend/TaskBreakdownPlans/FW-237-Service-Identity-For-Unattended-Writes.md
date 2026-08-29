# FW-237 · Service identity for unattended PLC writes

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 29, 2026 — Change history is in [`CHANGELOG.md`](../../../../CHANGELOG.md)
**Document Type:** Implementation plan for a single backlog story
**Status:** **Buildable — blocked on a credential decision nobody owns yet.** `G59`'s **identity half only**
**Owner:** Backend (.NET) stream
**Audience:** The developer building `FW-237`
**Shortcode:** — *(implementation plan, derived from the specifications and the built code; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [Orchestration.md](Orchestration.md)

---

> **Why this document exists.** Twelve hours, and **four details decide whether it is right.**
>
> **`G59` is two gates, and reading it as one gets the near half missed** (`P-127`). The
> **identity** half is due **now** — the `Attempted` audit record is written before the simulate
> branch and `AuditEntry.OperatorId` is required, so **the first tag set cannot be written
> without an answer, in every environment, today.** The **token** half waits for commissioning.
> **A sentinel is already shipping, and it is documented as one.** `SystemOperatorId =
> "SYSTEM.ITINHIBIT"`. `FW-205` **carried** `G59`'s audit half rather than closing it, and said
> so — this story replaces the placeholder.
> **The failure is not `401`.** `RestClient` dereferences a null `HttpContext` and returns
> `"Object reference not set to an instance of an object."` **in-band, before the network**, in
> a message naming neither the identity nor the caller.
> **`CoolingChamber`'s badge-number login is a precedent, not a specification.**

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-237 · Service identity for unattended PLC writes
> **Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S2 · **Phase:** 4 · **Stream:** BE
>
> > `G59`'s **identity half**, which `P-127` split out precisely because reading the gap as one item
> > gets the near half missed. The `Attempted` audit record is written **before** the simulate branch
> > (`[PLC §11.1]` audits simulated writes) and `AuditEntry.OperatorId` is **required**, so the first
> > tag set cannot be written without an answer — **in every environment, today**. `FW-205` shipped a
> > named sentinel (`SystemOperatorId`) and **documented it as a sentinel** rather than pretending it
> > was a decision.
> >
> > ⚠ **`CoolingChamber` logs in by badge number; nothing owns that decision for FlatWire.** The
> > token half stays with commissioning: `PLCTagService`'s simulate branch returns before
> > `GetOPCInfo`, so nothing reaches the network until `SimulatePLCTagPush` goes false.
>
> **Acceptance Criteria:**
> - [ ] A named service identity exists for writes no operator initiated — the watchdog's `SetITInhibit`, hold/idle-and-restore, and any future hosted-service write
> - [ ] The sentinel `SystemOperatorId` in `FW-205` is **replaced**, and the code that documented it as a sentinel is updated so the trail no longer carries a placeholder
> - [ ] The audit trail attributes those writes to that identity and a reviewer can tell them from an operator's (`[PLC §11.3]`, the same reasoning as `P-110`'s `Compensate:` label)
> - [ ] ⚠ **The token half is explicitly out of scope and stays with `G59`/commissioning** — `RestClient` reads its bearer from `HttpContext`, and a hosted service has none (`P-120`)
> - [ ] The failure mode is documented: with no identity the call fails **before the network**, in-band, as `"Object reference not set to an instance of an object."` — a message naming neither the identity nor the caller
>
> **Rate-card basis (§2):** non-trivial business/integration service at the low end of the 12–24 h band — a service credential, its issuance and its wiring through `IAuditLog` and `PLCTagService` = **12 h**
> **Dependencies:** FW-143, FW-151, FW-205, FW-234
> **Blockers:** ⚠ Needs a decision from whoever owns service credentials in the UAL estate — `Login`'s badge-number route is the precedent, not a specification

### 1.1 Out of scope

| Concern | Owner |
|---|---|
| ⛔ **`G59`'s token half** | **Commissioning.** `RestClient` reads its bearer from `HttpContext`; a hosted service has none (`P-120`) |
| The audit trail's persistence target | [`FW-234`](FW-234-Audit-Log-Persistence-Target.md) — **a dependency**, and it is what makes AC 3 checkable |
| Per-tag write status | `FW-236` (`G58`) |
| Registering flat wire with `OPCConnection` | `FW-238` (`G60`) |
| The interlock's conditions | [`FW-205`](FW-205-ITInhibitService.md) built 3–5; [`FW-206`](FW-206-ITInhibit-Conditions-1-2.md) owns 1–2 |

### 1.2 What already exists

Read off the built code on 29 Aug 2026.

| Thing | Where | State |
|---|---|---|
| **The sentinel** | `FlatWire.Domain/Options/FlatWireOpcOptions.cs:112` — `SystemOperatorId { get; set; } = "SYSTEM.ITINHIBIT"` | ⚠ **Shipping, and documented as a sentinel** |
| Its one use | `FlatWire.Infrastructure/Services/ITInhibitService.cs:355` — `new PlcWriteContext(line, options.SystemOperatorId)` | ✅ Built (`FW-205`) |
| `AuditEntry.OperatorId` | `IAuditLog.cs:101` — **required**, *"an unattributable audit record has no compliance value"* | ✅ Built |
| The `Attempted`-before-push rule | `FR-072`, built in `PLCTagService` | ✅ Built — ⚠ **and it is why the identity is needed now** |
| `SerilogAuditLog`'s missing-operator branch | Logs a `Warning` and writes `"(unknown)"` rather than throwing | ✅ Built — a **safety net, not an answer** |
| A real service identity | — | ⛔ **Does not exist** |
| `RestClient` registration | ⛔ **Nothing registers it** in `FlatWire.Infrastructure` (`P-108`) | Token half's problem, not this story's |

⚠ **`SerilogAuditLog` will not throw on a missing operator** — it warns and writes
`"(unknown)"`. So the absence of this story does **not** crash anything; it silently degrades the
compliance trail, which is why it is `Critical` and still easy to miss.

---

## 2. The four details

### 2.1 Two gates, and only the near one is this story

`P-127` split `G59` because reading it as one item gets the near half missed:

| Half | Due | Why |
|---|---|---|
| **Identity** (`OperatorId`) | **Now** | The `Attempted` record is written **before** the simulate branch, and `[PLC §11.1]` audits simulated writes. Every environment, today |
| **Token** (bearer) | Commissioning | Simulate returns before `GetOPCInfo`, so **nothing reaches the network** until `SimulatePLCTagPush` goes false |

⛔ **Do not solve the token half here.** It needs `RestClient` registered in Infrastructure
(`P-108`), an `OPCConnection` registration (`G60`, `FW-238`) and a credential that survives
having no `HttpContext` — none of which the identity half needs.

### 2.2 What the identity must be, and what it must not be

AC 1 wants a name for writes no operator initiated: the watchdog's `SetITInhibit`, hold/idle
and restore, and future hosted-service writes.

⚠ **It must be distinguishable from an operator** (AC 3) — the same reasoning as `P-110`'s
`Compensate:` label, where a compensating clear had to be tellable from an ordinary one.

⛔ **It must not be a real operator's badge.** `CoolingChamber` logs in by badge number, and
that precedent is exactly the trap: reusing a person's badge for machine-initiated writes makes
the compliance trail attribute a machine's action to a human, which is worse than
`"(unknown)"`.

**The shape to aim for:** a reserved identity in the same namespace operators come from, so it
sorts and filters alongside them, but visibly not a person.

### 2.3 The failure message names nothing, which is why AC 5 exists

AC 5 asks for the failure mode to be **documented**, and `FW-151`'s harness (scenario 9)
established it: `RestClient` dereferences the null `HttpContext` and returns
`"Object reference not set to an instance of an object."` **in-band, before the network** — not
a `400`, not a `401`.

⚠ **That message names neither the identity nor the caller**, so a commissioning engineer
hitting it has nothing to search for. **Documenting it is a real deliverable**, not paperwork —
and it belongs with the token half's eventual fix.

### 2.4 `FW-234` is what makes AC 3 checkable

AC 3 says *"a reviewer can tell them from an operator's"*. Today the trail is Serilog-only, and
`P-15` is the finding that nothing can query it. **[`FW-234`](FW-234-Audit-Log-Persistence-Target.md)
gives the trail a queryable home**, and it is a listed dependency.

⚠ **Order matters:** without `FW-234`, AC 3 can only be demonstrated by grepping a log file,
which is exactly the *"met structurally, not materially"* outcome `FW-143` already had.

---

## 3. Build order

1. **Get the credential decision** (Blockers). ⚠ Frame it as §2.2 does — a reserved
   non-person identity — rather than *"which badge should we use"*, which invites the wrong
   answer.
2. **Land [`FW-234`](FW-234-Audit-Log-Persistence-Target.md) first** (§2.4), or AC 3 is
   demonstrable only against a log file.
3. Replace `FlatWireOpcOptions.SystemOperatorId`'s sentinel default (`:112`) with the decided
   identity. ⚠ **Update the comment that documents it as a sentinel** — AC 2 is explicit that
   the trail must no longer carry a placeholder, and a stale *"this is a sentinel"* comment is
   the same defect one level up.
4. Widen the surface beyond `ITInhibitService`: hold/idle and restore, and any future
   hosted-service write, resolve the **same** identity. ⚠ **One source**, not a constant per
   call site.
5. **Do not touch the token path** (§2.1). `PLCTagService`'s simulate branch still returns
   before `GetOPCInfo`.
6. **Document the failure mode** (AC 5) — in `[PLC]`'s commissioning material, where the
   engineer who hits it will be looking.
7. Verify the trail: a watchdog write and an operator write, told apart by a reviewer.

---

## 4. Decisions this plan makes

> `P-##` is continuous across the repository; `P-01`–`P-175` precede this story.

### `P-176` — the identity is a reserved non-person, not a badge

§2.2. Reusing a person's badge attributes a machine's action to a human — worse for compliance
than the `"(unknown)"` the code already writes. `CoolingChamber`'s badge route is a **precedent
for how a service authenticates**, not for **whose name it borrows**.

**Fallback:** if the estate has no mechanism for a non-person identity, a dedicated service
account **created for this purpose** is acceptable; a shared human badge is not.

### `P-177` — one source for the identity, resolved, never a constant per call site

§3 step 4. `FW-205` reads it from `FlatWireOpcOptions` and that is the right shape; the risk is
the next hosted-service write hard-coding its own string. **Every unattended write resolves the
same option.**

### `P-178` — `FW-234` is sequenced before this story's AC 3

§2.4. Otherwise *"a reviewer can tell them apart"* is demonstrated by grepping a log — the
structural-not-material outcome `P-15` already records against `FW-143`.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 walkthrough and against the audit trail.

| Check | Expected |
|---|---|
| **Sentinel gone** | `SystemOperatorId`'s default is the decided identity; **the sentinel comment is updated too** (AC 2) |
| **Not a person** | The identity is a reserved non-person, not an operator badge (`P-176`) |
| One source | Every unattended write resolves the same option — `grep` finds no second constant (`P-177`) |
| **Distinguishable** | A reviewer filters the trail and separates watchdog writes from operator writes (AC 3) |
| Queryable | Demonstrated against `FW-234`'s store, **not** a log file (`P-178`) |
| Surface covered | `SetITInhibit`, hold/idle, restore — all attributed |
| **Token half untouched** | `git diff` shows no change to `RestClient` wiring or the simulate branch (AC 4) |
| Failure documented | The in-band `"Object reference not set…"` mode is written down where a commissioning engineer will look (AC 5) |
| Regression | `FW-205`'s interlock still boots under Development scope validation; host stays up |

---

## 6. Handoff

`G59`'s **token half** stays with commissioning and needs `RestClient` registered in
Infrastructure (`P-108`), `FW-238`'s `OPCConnection` registration (`G60`), and a bearer that
survives having no `HttpContext` (`P-120`). [`FW-234`](FW-234-Audit-Log-Persistence-Target.md)
is the dependency that makes AC 3 material. [`FW-206`](FW-206-ITInhibit-Conditions-1-2.md) adds
conditions 1–2 to the same service and will write through the same identity — **it must not
introduce a second one** (`P-177`).

---

## 7. Open items

| Item | Effect here |
|---|---|
| ⚠ **The credential decision** | Unowned. `Login`'s badge-number route is a **precedent, not a specification** |
| **`G59`** | ⚠ **Two gates** (`P-127`). This story closes the **identity** half only |
| **`P-120`** | A hosted service has no `HttpContext`, so `RestClient` has no bearer — the token half |
| **`P-108`** | ⛔ Nothing registers `RestClient` in `FlatWire.Infrastructure`. Token half's blocker, not this one's |
| **`P-15` / `FW-234`** | The trail has no queryable home until `FW-234` lands (`P-178`) |
| **`G58`, `G33`** | A green trail is not proof the controller applied the value. **This story does not change that** |
