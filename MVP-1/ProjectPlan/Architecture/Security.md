# Flat Wire Mill — Security, Roles and Permissions

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — **`OI-37`/`G6` confirmed**: all six roles exist as JWT claims on `ClaimTypes.Role`; §8's two *unverified* callouts restated. Residual: the claim **values** are coded and unmapped
**Document Type:** Authentication, authorisation, the role matrix
**Status:** Baselined for build
**Owner:** Architecture stream
**Audience:** Developers, QA, IT
**Shortcode:** `[SEC]`
**Part of:** `ProjectPlan/Architecture/` — index: [README.md](../README.md)

---

## 8. Security, roles and permissions

**Authentication** is JWT throughout, inherited from the existing `Login` service. Hub authentication uses `?access_token=`. **Every controller and endpoint carries `[Authorize]`.**

**Roles:** Operator · Supervisor · Operations Manager · Engineering/Maintenance · QA · Admin.

> ⚠ **Six roles are named and the matrix below now has six columns — the `Admin` column was added
> 15 Aug 2026.** It had been absent since the matrix was written, so a sixth role policy was declared
> repository-wide (`phase-01b`, `[API §3.2]`) with **no permissions defined anywhere to bind it to**.
> The only Admin-adjacent text was the parenthetical *"(Process Eng / Sys Admin)"* on the alloy-lookup
> row, which is a qualifier on Eng/Maint, not a column.
>
> **Admin is a platform role, not an operations role.** It owns user/role provisioning, configuration
> and reference-data administration; it deliberately owns **no production transaction** — an
> administrator does not check rod in, approve a checkout or dispose of WIP. That is why most cells
> below are `✗`, and the emptiness is the definition rather than an omission. ✅ **Confirmed 15 Aug 2026 — it exists as
> a JWT claim on the standard `ClaimTypes.Role`, as do the other five (`OI-37` / `G6`).** The
> earlier *"can block the build outright"* reading is spent.

| Action | Operator | Supervisor | Ops Manager | Eng/Maint | QA | **Admin** |
|---|---|---|---|---|---|---|
| Manual / auto login & logout | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor override for un-punched login | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| View pass schedule / acknowledge at check-in | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Create / edit pass schedule (DB9) | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Activate / deactivate pass schedule | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Override a pass-schedule setting mid-run | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ |
| One-for-one same-size die swap at run | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| Apply roll-gap override (DB11) | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| **Revert** a roll-gap override | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Approve mid-run rod checkout (Mode B) | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Approve partial-run material disposition | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Supervisor override for weld removal / reversal | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Authorise off-schedule / out-of-sequence staging | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Authorise an out-of-tolerance spool weight | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| Flag WIP rejection | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| **Dispose** WIP rejection | ✗ | ✓ | ✓ | ✗ | ✓ | ✗ |
| SPC disposition at transaction finalisation | ✓ (record) | ✓ | ✓ | ✗ | ✓ | ✗ |
| Die management / tooling life tracking | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Edit alloy lookup table | ✗ | ✗ | ✗ | ✓ (Process Eng) | ✗ | **✓** |
| View shift summary | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ |
| **User / role provisioning and account administration** | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| **Environment configuration — OPC tag-path map, cadences, feature flags** | ✗ | ✗ | ✗ | ✗ | ✗ | **✓** |
| **View the audit log** *(`NFR010`/`NFR011`)* | ✗ | ✓ | ✓ | ✗ | ✓ | **✓** |

Angular enforces this with `FlatWireAuthGuard` (authenticated) and `FlatWireRoleGuard` (Operations-Manager routes DB9/DB9A gated from operator routes). The API enforces it with role policies matching the endpoint authorization matrix in `[API §9]`.

**Supervisor PIN handling.** The PIN **authenticates only**. It is **never carried in the payload and never stored** — only the flag, the authorising supervisor's badge/ID, the timestamp and the reason are persisted. **Whether the PIN validates against the existing login/authorisation service or a separate supervisor credential store is undecided** and now gates three separate overrides (spool weight, off-schedule staging, out-of-sequence staging) — **OI-38**.

**Auditability.** See `NFR010` / `NFR011` in §6.1.

> ✅ **Confirmed 15 Aug 2026.** All six roles exist as JWT claims on the standard `ClaimTypes.Role`; **no provisioning is required** and `RequireRole()` reads them natively (**OI-37** / **G6**). ⚠ **Residual:** the six claim **values** are abbreviated or coded rather than the matrix's labels and the mapping is unsupplied — that gates **verification, not construction**. ⚠ **Unaffected:** `Engineering/Maintenance` and `QA` remain *inferred* role definitions — a claim existing does not make the capabilities attributed to it correct.

### 8.8b The simulator control surface — absent, not forbidden

The engineering control API specified at [`MachineSimulator.md`](MachineSimulator.md) `[SIM §8]`
(`/api/v1/flatwire/sim/**`, story `FW-215`) drives the machine model. With simulation **off**, the subsystem
it drives talks to a real mill.

| Control | Rule |
|---|---|
| **Registration** | ⚠ **When `SimulatePLCTagPush` is false the routes are not registered at all — `404`, not `403`** |
| **Authorisation** | `Engineer` / `Admin` only, **on top of** the above. Never `Operator` |
| **Console route** | `DB-S1` does not resolve when simulation is off |
| **Endpoint count** | These five are **not** among `[API]`'s 30 and must not be added to that count |

> **The 404 is the control; the role policy is the backstop, not the reverse.** A present-but-forbidden
> control plane is one misconfigured role away from driving a live line — and `OI-37` records that the role
> claims themselves are unverified, so a design resting on role enforcement alone rests on something not yet
> confirmed to exist. A route that was never registered cannot be reached by a misconfigured claim.
>
> This is the same class of rule as `[PLC §7.3]`'s standing prohibition — **never send a stop command** —
> applied to the simulation surface.

---

---

## 8.9 The Operations Manager role — copied in from MVP-2

> **Why this is here.** `MVP-2/RequirementDocuments/PassScheduleManagement.md` §3.3–§3.4 held the **only**
> definition of the Operations Manager role in the repository, and **MVP-1 enforces that role**: `FR-212`
> restricts reverting a roll-gap override to it on **DB11 Roll Adjust**, an MVP-1 screen. An MVP-1 build
> therefore had to reach into deferred scope to know what the role meant. Copied here on 13 Aug 2026; the
> MVP-2 original stays for its own screen. `[CONFIRMED]`

**Operations Manager and Supervisor are distinct roles.** They are frequently the same person in a small
operation, and the system still treats them as separate permission levels.

| Dimension | Supervisor | Operations Manager |
|---|---|---|
| Focus | People and shift management | Process configuration and machine parameters |
| Primary screen | Shift summary | Pass Schedule Management *(MVP-2)* |
| Approves | Run approvals, mid-run rod checkout | Schedule overrides and activation |
| May edit a pass schedule | No | Yes |

**Operations Manager is defined by what it can do that the other two cannot.** In practice it maps to a
Production or Process Engineer, or a Line Superintendent — someone who owns the pass schedules and machine
configuration without necessarily being on the floor for every run.

**What an Operations Manager does *not* control:**

| Area | Who owns it |
|---|---|
| **The alloy lookup table** | **Process Engineering / System Administration only** — not Operations Manager |
| Shift staffing and attendance | Supervisor |
| WIP rejection disposition | Any operator may raise it; a supervisor disposes |
| Rod check-in inspection | The line operator |
| **Reverting a roll gap override** | **Operations Manager** — operators may apply one but not undo it. This is the MVP-1 dependency: `FR-212`, DB11 Roll Adjust |
