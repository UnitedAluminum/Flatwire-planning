# PHASE 13 (MVP-2 part) — Die Management


> ⛔ **SCOPE REVERSED 2 Sep 2026 by the die split (`Q91`) — the die domain is back in MVP-1.**
> The die inventory table now exists as **`ToolingInventoryDie`**, with **`DieHistory`** behind
> `FR-252`’s two history views, and both are built and seeded in **Phase 1**. `FR-240`–`FR-255`
> are MVP-1 requirements and **`DieManagement.md` is an MVP-1 specification**. `FW-N07`’s MoSCoW
> split is settled the way its own story text always read — the **table** is *Must*, the **screen**
> is *Should* — and both are in scope. **`OI-41` closes**; **Phase 6 depends on Phase 1, not Phase
> 13**; **`FR-233` / `D4` revert to their per-tool form**; **`TC-274` becomes executable**.
>
> ⚠ **The effort is NOT re-costed here.** The 8 h die table and the 66 h Die Management screen
> return to MVP-1 against a window closing 30 Sep 2026, and `CapacityAndEffortModel.md` §3b owns
> that. Re-derive additively; do not edit published totals in place.
>
> ⚠ **`OI-12` escalates to a live defect** — Die Change’s 60/85 % bands and Die Management’s
> 65/80 % bands now derive from one table. **`OI-141` stays open** on whether there is one die
> register or two. **`G77`** still owns edger and straightener inventory, which this does not cover.
>
> ⚠ **A FOURTH tool type landed 3 Sep 2026 — `D-42`.** The client's Tooling Inventory tab carries
> **Dies · Edgers · Straighteners · Roll Sets**, and `ToolingInventoryRollSet` (mill rolls and the
> DB1/DB2 capstan rolls) is built. **Dancers, entry guides, payoffs and spools are explicitly NOT
> tooling.** Stories [`FW-259`](../../30-database/tasks/FW-259.md) ·
> [`FW-260`](../../40-backend/tasks/FW-260.md) · [`FW-261`](../../50-frontend/tasks/FW-261.md),
> 27 h. ⛔ **Its column set is `[PROPOSED]`** — the only tool type that arrived without a pictured
> grid (**`G87`**; `Q92` is the send-back). ⚠ Tooling is maintained for **FL1/FL2 only, with FL3
> using a combination of the two**.
>
> Everything below predates the reversal. Read it as the record of the 11 Aug 2026 carve, not as
> current scope.

> **⚠ MVP-2 — deferred scope.** This is a **partial phase file**: only the Die Management content was carved out of the MVP-1 phase, **verbatim at bullet level**. The rest of that phase — the alloy lookup admin, the machine template tabs and role assignment — is MVP-1 and stays there. Read this alongside [`phase-13-administration-reference-data.md`](./phase-13-administration-reference-data.md), which remains the authority on the phase as a whole.
>
> **Effort: 66 h** (11 Aug 2026) — **and it is not the ladder's 99 h.** Rung 5 puts *"Phase 13 non-critical (Die Management screen, role assignment UI)"* at **99 h**, which bundles this screen with the **MVP-1** role-assignment UI and gives no split; quoting it here would silently move MVP-1 work into MVP-2. The figure below is re-priced from the rate card in [`CapacityAndEffortModel.md` §2](../CapacityAndEffortModel.md) instead: **Die Management screen 24 FE**, **die lifecycle service 16 BE**, **die inventory table 8 DB**, with QA and contingency **re-derived** from the reduced base. **MVP-1 keeps 143 h.**
>
> **The die inventory table moved here too, and that reverses an earlier instruction.** It was costed at 8 h in the MVP-1 phase on the reading that MVP-1's die change needed it to enforce `D4`. Die inventory and lifecycle are now **owned outside MVP-1 entirely**, so the table comes with the screen, and MVP-1's `D4` is restated at **die-size** level against the `Drawer` catalogue — see [`DieChangeAndManagement.md` §2.4a](../../10-requirements/screens/DieChangeAndManagement.md). `FW-N07` is therefore wholly MVP-2, not a story spanning both scopes. Full working in **§3b**.

---

**Project:** Flat Wire Mill Implementation
**Last Updated:** September 3, 2026 — **a fourth tool type landed (`D-42`)**: the Tooling Inventory tab carries Dies · Edgers · Straighteners · **Roll Sets**, with `FW-259`–`FW-261` (27 h). ⛔ Its column set is `[PROPOSED]` — `G87` / `Q92`. *(previously August 11, 2026)*
**Status:** **MVP-2 — deferred scope**
**Carved from:** [`phase-13-administration-reference-data.md`](./phase-13-administration-reference-data.md) on 11 Aug 2026, bullets copied verbatim

*The **Die Management** screen, the die lifecycle service and the die inventory table. The alloy lookup admin, machine template tabs and role assignment in this phase are MVP-1.*

## Business Overview

- **Objective (die portion):** maintain die inventory/life.
- **User roles:** Maintenance.
- **Entry conditions:** Phase 1 lookups seeded.
- **Exit conditions:** die life tracked.

## UI / Backend / Database

- **UI:** **Die Management** screen (`dashboard_die_management.html`) — inventory, life thresholds, reset/edit/retire/register. In [`../../Mockups/`](../../Mockups/).
- **Backend:** die lifecycle service (cumulative footage per die from PLC counter, configurable threshold, <10% banner, reset by Maintenance).
- **Database:** die inventory (status Active/Nearing/Overdue/Spare/Retired).

## Real-Time / Testing / Deliverables

- Die-life banner may use passive alert. Tests: die life thresholds + reset; register-before-scan rule. Deliverables: Die Management screen.

**OQ blockers:** OQ-83 (die life tracking — decided; threshold TBD), die-life threshold configurability. **Stories:** Die Management from [`DieManagement.md`](../../10-requirements/screens/DieManagement.md) (extracted from `DieChangeAndManagement.md` §4 on the same day); the *table* half of `FW-N07` is **MVP-1** — see below.

---

## ⚠ Three things this carve does not resolve

### 1. The die inventory table does not exist, and 8 h is costed for it in MVP-1

The MVP-1 phase file's own warning: **8 h is costed for a die inventory table that does not exist** in the `FlatWireDB` set — only the `Drawer` lookup and `DieChangeEvent` do. That costed work now sits in the MVP-1 file while the screen it serves is here.

`FW-N07` splits along the same seam and its MoSCoW already said so: the **table** is *Must*, the **screen** is *Should*. **The table is MVP-1's problem because MVP-1's die change needs it** — `FW-073` rejects a die not in inventory. Only the screen is deferred.

### 2. `Drawer` carries two columns that exist only for this file

`Drawer.LastGrindingFeet` and `Drawer.TotalFeetAllowed` — added 6 Aug 2026 — are the die-life counter and threshold, taken from `DieChangeAndManagement.md` §4.2/§4.4. **A table cannot be split**, so `Drawer` stays whole in MVP-1 with two columns nothing in MVP-1 populates.

The MVP-1 file also carries a standing instruction that survives this carve: **"Do not reduce the 8 h on the strength of those two columns."** They give the counter and threshold somewhere to live, but against a die **size**, not a physical tool — registration, condition, the Active/Nearing/Overdue/Spare/Retired status and disposition history are all still missing.

### 3. MVP-1's die change has no source for the values it reads

`DieManagement.md` §1.5 lists three values the MVP-1 die change reads from die management — die identity, footage counter, life threshold — and rule **D4** forbids installing an unregistered die. With this deferred, none has an MVP-1 source. That is one of the open consequences in [`../../95-archive/design-notes/MVP-2-scope-note.md`](../../95-archive/design-notes/MVP-2-scope-note.md), and it is not answered by moving files.

---

## What stayed in MVP-1

| Part | Scope |
|---|---|
| Die Management screen, die lifecycle service, die inventory status vocabulary | **MVP-2** (here) |
| Alloy lookup admin grid + alloy CRUD (`FW-004`), machine template tabs (`FW-003`), role assignment | **MVP-1** |
| `Stand` / `Drawer` / `Edger` / `SpoolConfiguration` lookups | **MVP-1** |
| The **30 Jul 2026 alloy reference-data client answers** — four min/max tolerance pairs on `AlloyProperty`, the values owed by e-mail, and the note that **`CHK007` cannot fire until they arrive** | **MVP-1, and it blocks Phase 4** |
