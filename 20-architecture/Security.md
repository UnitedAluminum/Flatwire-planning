# Flat Wire Mill — Security, Roles and Permissions

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 27, 2026 — ⛔ **the `G6` residual is two problems, not one, and this document said it was one.** *"Gates verification, not construction"* is true of the server and **false of the client**: measured in `Second-Branch/ual-angular`, there is **no role field on `LoginStatusDetails`, no role vocabulary in `shared.constants.ts` and no JWT decoder anywhere**, so **`FlatWireRoleGuard` cannot be built** — §8 now splits the two sides and tables the three ways to give the client a role, which **this document owes**. ⚠ **`FlatWireRoleGuard`'s stated MVP-1 subject was DB9/DB9A, which are MVP-2** — the live MVP-1 gate is `FR-212` on DB11, as §8.9's own last row already said. ⚠ **The API citation was wrong** — `[API §9]` is Traceability; the per-endpoint roles are `[API §3.2]`'s. ⚠ **§8.8b's endpoint count was 30** against `[API §3.2]`'s **32**, and its `Engineer` role name is not one of the matrix's six. ⚠ **§8.9's Supervisor primary screen is also MVP-2** and only the Operations Manager's was marked. *(previously August 15, 2026 — **`OI-37`/`G6` confirmed**: all six roles exist as JWT claims on `ClaimTypes.Role`; §8's two *unverified* callouts restated. Residual: the claim **values** are coded and unmapped)*
**Document Type:** Authentication, authorisation, the role matrix
**Status:** Baselined for build
**Owner:** Architecture stream
**Audience:** Developers, QA, IT
**Shortcode:** `[SEC]`
**Part of:** `ProjectPlan/Architecture/` — index: [README.md](../DOCUMENTS.md)

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

Angular enforces this with `FlatWireAuthGuard` (authenticated) and `FlatWireRoleGuard` (role-gated routes). **The API is the enforcement point** — every controller and endpoint carries `[Authorize]`, and the per-endpoint roles are the **Roles column of `[API §3.2]`'s endpoint index**. The Angular guards are **UX and defence-in-depth, not the gate.**

> ⚠ **The MVP-1 subject of `FlatWireRoleGuard` is not DB9/DB9A** *(corrected 27 Aug 2026)*. This sentence read *"Operations-Manager routes DB9/DB9A gated from operator routes"* — but **DB9 and DB9A are MVP-2 and are not built in MVP-1**, so the only concrete example it gave was of a screen that does not exist in the scope the guard ships in. **The live MVP-1 role gate is `FR-212`: reverting a roll-gap override on DB11 Roll Adjust is Operations-Manager-only, and an operator may apply one but not undo it** — which §8.9's last row already stated correctly while this sentence pointed at deferred scope.
>
> ⚠ **The API citation was also wrong.** `[API §9]` is **Traceability** (endpoint → requirement → screen → phase) and contains no authorisation matrix; the roles live in **`[API §3.2]`**, which is where this now points.

**Supervisor PIN handling.** The PIN **authenticates only**. It is **never carried in the payload and never stored** — only the flag, the authorising supervisor's badge/ID, the timestamp and the reason are persisted. **Whether the PIN validates against the existing login/authorisation service or a separate supervisor credential store is undecided** and now gates three separate overrides (spool weight, off-schedule staging, out-of-sequence staging) — **OI-38**.

**Auditability.** See `NFR010` / `NFR011` in §6.1.

> ✅ **Confirmed 15 Aug 2026.** All six roles exist as JWT claims on the standard `ClaimTypes.Role`; **no provisioning is required** and `RequireRole()` reads them natively (**OI-37** / **G6**). ⚠ **Unaffected:** `Engineering/Maintenance` and `QA` remain *inferred* role definitions — a claim existing does not make the capabilities attributed to it correct.

> ### ⛔ The residual is not one problem. It is two, and they sit on opposite sides of the wire
>
> This entry read *"the claim **values** are coded rather than the matrix's labels and the mapping is unsupplied — that gates **verification, not construction**."* **That is true of the server and false of the client**, and the sentence covered both *(corrected 27 Aug 2026)*.
>
> | | State |
> |---|---|
> | **Server (`FlatWire.API`)** | ✅ **Construction is unblocked** — the claim exists on `ClaimTypes.Role` and `RequireRole()` reads it. ⚠ **Verification is blocked**: the six claim *values* are coded and the mapping to this matrix's labels is unsupplied, so the matrix walk cannot pass. Bind them to **one constants class**, as `FW-145` does |
> | **Client (`ual-angular`)** | ⛔ **Construction is blocked. There is no role source at all.** Measured in `Second-Branch/ual-angular` on 27 Aug 2026: **`LoginStatusDetails` carries no role field**, **`shared.constants.ts` has no role vocabulary**, and **the repository contains no JWT decoder** — no `atob`, no decode utility, nothing. The live authorisation primitive is **per-module `ACCESS` / `WRITE`** (`UserPermissionModel`, `USER_PERMISSIONS`), which is a different shape from six named roles. **`FlatWireRoleGuard` cannot be built until a source is chosen**; `FlatWireAuthGuard` is unaffected and builds today |
>
> **Three ways to give the client a role, and this document owes the choice:**
>
> | | Option | Cost |
> |---|---|---|
> | **(a)** | **Decode the JWT the client already holds.** The roles are in the token, confirmed above | A few lines, no new dependency, no second team. **No precedent in the repository** |
> | **(b)** | Extend the login response with the six roles | Touches the shared `Login` service and `LoginStatusDetails` — another team, another release |
> | **(c)** | Map the six onto the existing per-module `ACCESS` / `WRITE` primitive | No new mechanism, but **loses `FR-212`'s granularity** — apply-versus-revert on one screen is not an `ACCESS`/`WRITE` distinction |
>
> ⚠ **`FR-212` is what makes this a real gate rather than a tidiness question**: it is an MVP-1 requirement on an MVP-1 screen, and it is the *only* live MVP-1 role gate.
>
> **[`Phase-01A-ImplementationPlan.md`](../50-frontend/tasks/Phase-01A-ImplementationPlan.md) `F-12` recommends (a)** — the token already carries the roles, and because the API is the enforcement point (above), the guard is UX and defence-in-depth, which is where the cheap self-contained option belongs. **That is a recommendation, not a decision: this document owns it.** Either way the guard binds to **one constants class**.

### 8.8b The simulator control surface — absent, not forbidden

The engineering control API specified at [`MachineSimulator.md`](MachineSimulator.md) `[SIM §8]`
(`/api/v1/flatwire/sim/**`, story `FW-215`) drives the machine model. With simulation **off**, the subsystem
it drives talks to a real mill.

| Control | Rule |
|---|---|
| **Registration** | ⚠ **When `SimulatePLCTagPush` is false the routes are not registered at all — `404`, not `403`** |
| **Authorisation** | **`Engineering/Maintenance`** / `Admin` only, **on top of** the above. Never `Operator` *(this said `Engineer`, which is not one of the matrix's six role names — and the constants class the guards bind to has to use the matrix's spelling)* |
| **Console route** | `DB-S1` does not resolve when simulation is off |
| **Endpoint count** | These five are **not** among `[API]`'s **32** and must not be added to that count *(this said 30 until 27 Aug 2026; `[API §3.2]` indexes **32 endpoints, of which MVP-1 implements 25**)* |

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

> **Why this is here.** `../10-requirements/screens/PassScheduleManagement.md` §3.3–§3.4 held the **only**
> definition of the Operations Manager role in the repository, and **MVP-1 enforces that role**: `FR-212`
> restricts reverting a roll-gap override to it on **DB11 Roll Adjust**, an MVP-1 screen. An MVP-1 build
> therefore had to reach into deferred scope to know what the role meant. Copied here on 13 Aug 2026; the
> MVP-2 original stays for its own screen. `[CONFIRMED]`

**Operations Manager and Supervisor are distinct roles.** They are frequently the same person in a small
operation, and the system still treats them as separate permission levels.

| Dimension | Supervisor | Operations Manager |
|---|---|---|
| Focus | People and shift management | Process configuration and machine parameters |
| Primary screen | Shift summary *(DB10 — **MVP-2**)* | Pass Schedule Management *(DB9 — **MVP-2**)* |
| Approves | Run approvals, mid-run rod checkout | Schedule overrides and activation |
| May edit a pass schedule | No | Yes |

⚠ **Both primary screens are MVP-2, and neither role is therefore reachable through its own screen in MVP-1** *(marked 27 Aug 2026 — only the Operations Manager's was)*. The roles are still enforced: the Operations Manager's MVP-1 surface is **`FR-212`** on DB11, and the Supervisor's is the approval and disposition set below.

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
