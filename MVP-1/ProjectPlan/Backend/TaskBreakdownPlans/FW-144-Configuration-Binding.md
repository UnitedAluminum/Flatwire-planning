# FW-144 · Configuration binding

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 15, 2026 — first issue
**Document Type:** Implementation plan for a single backlog story
**Status:** Ready to build — **blocked on `PLC-Q05` / `G33` for the tag map's *contents*, not its shape**
**Owner:** Backend (.NET) stream
**Audience:** The .NET developer building `FW-144`
**Shortcode:** — *(implementation plan, derived from the specifications; **not citable as a requirement**)*
**Part of:** `ProjectPlan/Backend/TaskBreakdownPlans/` — index: [README.md](../../README.md)

---

> **Why this document exists.** Four things here are decided and non-obvious. **(1)** There
> are **two distinct cadence knobs** and this layer owns both — confusing them produces a
> hub that drains at the OPC poll rate or an OPC poll at 10 Hz. **(2)** Options binding
> **fails fast at boot**, and emits **one** warning naming the *count* of unconfirmed tag
> paths — not one per path. **(3)** The `ITInhibit` key lives **inside each line's `Tags`
> block, never at the root**. **(4)** This story **binds** the tag map; `[PLC]` **owns** it,
> and writing a tag path into any other file creates the seventh copy of a surface that was
> deliberately reduced to one.

---

## 1. The story

From `[TB §7]` — verbatim:

> ###### FW-144 · Configuration binding
> **Hours:** 12 h BE · **Priority:** Critical · **Sprint:** S0 · **Phase:** 1B · **Stream:** BE
>
> **As a** deployer,
> **I want** every environment-specific value bound from configuration,
> **So that** no tag path, connection string or cadence is compiled in.
>
> **Acceptance Criteria:**
> - [ ] `appsettings.{Environment}.json` carries the **`FlatWireDB`** connection string, JWT settings and SignalR settings (MessagePack, keep-alive/timeout, cadence)
> - [ ] **OPC tag-path map is config-driven, not hardcoded** — the map's contents are owned by [`PLCTagSpecification.md`](../../Architecture/PLCTagSpecification.md); this story binds it, it does not author it
> - [ ] `SimulatePLCTagPush` is a configuration flag, switchable without a rebuild
>
> **Rate-card basis:** configuration binding across four concern groups (12 h, §2)
> **Dependencies:** FW-N04
> **Blockers:** **`PLC-Q05`** (the measure segment of every tag path is ours, not the controller's — **G33**)

### 1.2 Out of scope

| Concern | Story |
|---|---|
| The `appsettings` files themselves — created with `PATH_BASE`, `SqlSetting`, Serilog | `FW-N04` step 7 |
| What the tag paths **are** | `[PLC]` — the only tag map in the repository |
| Consuming the map to read and write tags | `FW-151`, `FW-N05` |
| The JWT values being *used* | [`FW-145`](FW-145-JWT-And-Role-Policies.md) |
| The hub consuming the cadence | [`FW-080`](FW-080-FlatWireHub.md) |

---

## 2. The four concern groups

From `[DEP §2.1]` and `phase-01b` L89:

| Setting | Source | Note |
|---|---|---|
| `FlatWireDB` connection string | `UA_Connection_String_Variable` → the named variable | Same double indirection as every other UAL service; **plus the `united_db` read/write grant** |
| JWT settings | `UA_JWT_Environment_Variable`, `UA_JWT_Token_Expiration_Minutes` | Inherited from `Login` |
| **OPC tag-path map** | `appsettings.{Environment}.json` | **Config-driven, never hardcoded** — *"so a wrong path found at commissioning is a config edit, not a redeploy"* |
| SignalR settings | `appsettings.{Environment}.json` | MessagePack on/off, keep-alive, client timeout, broadcast cadence |
| `SimulatePLCTagPush` | `appsettings.{Environment}.json` | **`true` everywhere until PLC commissioning completes** |

> `useMockData` is **Angular's** (`environment.*.ts`); the backend swap of the same name is
> [`FW-140`](FW-140-DI-Registration-And-Stub-Swap.md) `P-11`. Both exist; they are not the
> same file.

### 2.1 ⚠ Two cadences, and this layer owns both

`phase-01b` L89:

| Knob | Value | Belongs to |
|---|---|---|
| **OPC publish interval** | `NFR005`: **1 s default**, configurable 5 / 10 / 30 s — `[PLCC]`'s `PublishIntervalMs` | the ingest side |
| **Hub drain cadence** | **~100 ms / 10 Hz** | the broadcast loop |

They are unrelated numbers on opposite sides of the bounded channel, which is exactly what
decouples them. Bind them as two settings with two names; never derive one from the other.

### 2.2 ⚠ `ITInhibit`'s key placement is a rule, not a preference

`phase-01b` L112: the config key lives **inside each line's `Tags` block, never at the
root**. One tag per line — `FL1.ITInhibit`, `FL2.ITInhibit`, `FL3.ITInhibit` — built for
**three** lines. It is **written, never read**, and there must be **no operator clear path
anywhere in the surface**, enforced by the *absence* of any endpoint, command or hub method.
A root-level key would imply one interlock across all three lines, which is the opposite of
the line-scoped behaviour `TC-017a` tests.

### 2.3 The anti-drift rule

`[PLC]` is the **only** tag map in the repository, after six partial and mutually
contradictory copies were reduced to one. `PLCCommunication.md` carries **no tag path
strings by rule**.

> **If you are about to write a tag path into a `.cs` file, a comment or a second
> `appsettings` fragment, you are creating the seventh copy.** The paths belong in the
> environment configuration, sourced from `[PLC]`.

---

## 3. Build order

1. **Strongly-typed options classes** — one per concern group. Bind with
   `services.Configure<T>` / `AddOptions<T>().Bind(...)`.
2. **`ValidateOnStart()` with `DataAnnotations` or a validator** — see `P-16`.
3. **The tag map** as a nested structure keyed by line, each line carrying a `Tags` block
   (with `ITInhibit` inside it, §2.2). Shape it from `[PLC §7.2]`'s six value groups:
   component active/bypass state · die sizes · roll gaps · edge type · speed · gauge and
   width targets.
4. **The two cadences** as separate settings (§2.1).
5. **`SimulatePLCTagPush`** — a plain flag, `true` in every environment for now, selected
   **by configuration, not by call site**.
6. **The unconfirmed-path warning** — `P-16`.

---

## 4. Decisions this plan makes

> `P-##` is continuous across this folder; `P-01`–`P-15` precede this story.

### `P-16` — fail fast at boot; warn **once**, with a count

`phase-01b` L89 states both halves and they pull against each other, so the resolution needs
writing down:

> **Options binding is validated at startup and fails fast at boot**, emitting **one**
> warning naming the *count* of unconfirmed tag paths — not one warning per path.

**Fail fast** applies to *structural* problems: a missing connection string, an absent JWT
variable, a line with no `Tags` block, a cadence outside its allowed set. The service must
not start.

**Warn once** applies to *confirmation status*. Under `[PLC]` v1.0 **no tag path is
confirmed** — the reading convention is `[PROPOSED]` and `[CLIENT INPUT REQUIRED]` only, and
a path becomes confirmed when commissioning test `C1`/`C11` says the controller accepted it.
There are **41 paths**. One warning per path would emit 41 lines at every boot, in every
environment, for weeks — noise that trains operators and developers to ignore startup
warnings. **One line naming the count** stays legible and still falls to zero as
commissioning proceeds.

**So: unconfirmed is not a startup failure.** If it were, the service could not boot until
commissioning, and `SimulatePLCTagPush = true` exists precisely so it can.

---

## 5. Verification

**No automated tests** — `[TS §1.2]`. Verified in the QA0 manual walkthrough.

| AC | How it is checked |
|---|---|
| The four groups bound | Each resolves from `appsettings.{Environment}.json` with no compiled-in default |
| Tag map config-driven | **`grep` the solution for a tag path string — zero hits outside configuration.** This is the check that matters |
| `SimulatePLCTagPush` | Flipping it changes behaviour with no rebuild |
| Fail fast | Remove a required setting → the service refuses to start and names it |
| Warn once | Boot with unconfirmed paths → **exactly one** warning line, carrying the count |
| `ITInhibit` placement | Three keys, each inside its line's `Tags` block; **none at the root** |
| Cadences | Two independent settings; changing the publish interval does not move the drain cadence |

---

## 6. Handoff

`FW-151` and `FW-N05` consume the tag map. `FW-080` consumes the SignalR settings and the
drain cadence. `FW-145` consumes the JWT settings. `FW-142` consumes the connection string.
`FW-143` consumes the log paths.

---

## 7. Open items

| Item | Effect here |
|---|---|
| **`PLC-Q05` / `G33`** *(the card's blocker)* | **The measure segment of all 41 tag paths is ours, not the controller's**, and **a wrong path fails silently** — the write reports success while the line keeps its previous settings. It blocks the map's *contents*, not its shape: build the binding now, and treat the values as provisional until `C1`/`C11` |
| **`G31`** | Read tags with no remaining consumer — the ingest subscription list is this decision, and it shapes what the map must carry |
| **`G29`** | **No edger tag path exists on any line, yet edge type is in the push payload.** The map has a hole where a required value goes |
| **`G32` / `PLC-Q04`** | FM2 station names (`FL2.FM2.S1/S2/S3`) are ours, pending sign-off |
| **`G30`** | FM2's controller namespace on FL3 — decides whether there are one or two failure domains |
| **`G35`** | Dancer tags read-only, `[PROPOSED]` |
| **`PLC-Q12`** | Blocks `FW-206` only, not this story |

No stale citations found in this story's card — it is one of the few that already points at
the right owning document for the tag map.
