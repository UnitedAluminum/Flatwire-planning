# Flat Wire Mill — Security, Roles and Permissions

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — split out of `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous
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

| Action | Operator | Supervisor | Ops Manager | Eng/Maint | QA |
|---|---|---|---|---|---|
| Manual / auto login & logout | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor override for un-punched login | ✗ | ✓ | ✓ | ✗ | ✗ |
| View pass schedule / acknowledge at check-in | ✓ | ✓ | ✓ | ✓ | ✓ |
| Create / edit pass schedule (DB9) | ✗ | ✗ | ✓ | ✓ | ✗ |
| Activate / deactivate pass schedule | ✗ | ✗ | ✓ | ✓ | ✗ |
| Override a pass-schedule setting mid-run | ✗ | ✗ | ✓ | ✓ | ✗ |
| One-for-one same-size die swap at run | ✓ | ✓ | ✓ | ✓ | ✗ |
| Apply roll-gap override (DB11) | ✓ | ✓ | ✓ | ✓ | ✗ |
| **Revert** a roll-gap override | ✗ | ✗ | ✓ | ✓ | ✗ |
| Approve mid-run rod checkout (Mode B) | ✗ | ✓ | ✓ | ✗ | ✗ |
| Approve partial-run material disposition | ✗ | ✓ | ✓ | ✗ | ✗ |
| Supervisor override for weld removal / reversal | ✗ | ✓ | ✓ | ✗ | ✗ |
| Authorise off-schedule / out-of-sequence staging | ✗ | ✓ | ✓ | ✗ | ✗ |
| Authorise an out-of-tolerance spool weight | ✗ | ✓ | ✓ | ✗ | ✗ |
| Flag WIP rejection | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Dispose** WIP rejection | ✗ | ✓ | ✓ | ✗ | ✓ |
| SPC disposition at transaction finalisation | ✓ (record) | ✓ | ✓ | ✗ | ✓ |
| Die management / tooling life tracking | ✗ | ✗ | ✓ | ✓ | ✗ |
| Edit alloy lookup table | ✗ | ✗ | ✗ | ✓ (Process Eng / Sys Admin) | ✗ |
| View shift summary | ✗ | ✓ | ✓ | ✗ | ✗ |

Angular enforces this with `FlatWireAuthGuard` (authenticated) and `FlatWireRoleGuard` (Operations-Manager routes DB9/DB9A gated from operator routes). The API enforces it with role policies matching the endpoint authorization matrix in `[API §9]`.

**Supervisor PIN handling.** The PIN **authenticates only**. It is **never carried in the payload and never stored** — only the flag, the authorising supervisor's badge/ID, the timestamp and the reason are persisted. **Whether the PIN validates against the existing login/authorisation service or a separate supervisor credential store is undecided** and now gates three separate overrides (spool weight, off-schedule staging, out-of-sequence staging) — **OI-38**.

**Auditability.** See `NFR010` / `NFR011` in §6.1.

> **Unverified.** Whether these roles exist as JWT claims or need provisioning has never been confirmed — **OI-37**, and it can block the build outright.

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
