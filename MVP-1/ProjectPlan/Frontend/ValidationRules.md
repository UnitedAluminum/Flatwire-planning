# Flat Wire Mill — Validation and Shopfloor Input Constraints

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 28, 2026 — ⚠ **The Mockups folder is 38 files / 19 HTML** — `dashboard_3_active_run_ual.html`, a **styling comparison build** (DB3 in the host app’s CSS at 1920×1080) plus five generated assets. The folder is still **flat**. Counts and the "composed for 5:4" statements updated — **18 of 19**, not all 19. Earlier: August 27, 2026 — **the canvas is 1920 × 1080**, and this table is where it is defined. The change is one of **shape**: +640 px of width against +56 px of height, 5:4 → 16:9, so **the re-layout is horizontal and nothing gets taller** — which is why the sub-14 px chart-axis exception explicitly **survives** the change. ⚠ **The 14 px floor and ≥ 48 px tap targets are physical rules that track dpi, not resolution**, so they are carried forward on a **stated, unconfirmed assumption** and the section now asks for the panel's **diagonal**, which no document records. ⛔ **The Print row was wrong and four `Must` requirements contradicted it** — it read *"no print action on any operator screen"*, against `FR-336` (coil label preview before printing), `FR-146`, `FR-335` and `FR-340` (two label printers per line); the rule is *no **traveler** printing*. Added: a **Dialog height** row (no dialog scrolls), a note naming the four constraints the repository already satisfies, and **§7.5a**, which records that the client-side validation this document claims to own **has never been written**. *(previously August 13, 2026 — split out of `02-SRS.md` in the ProjectPlan restructure. **Section numbers are unchanged**, so every `§n` citation still resolves; numbering inside this file is deliberately non-contiguous)*
**Document Type:** Client-side validation and the shopfloor input constraints
**Status:** Baselined for build
**Owner:** Frontend (Angular) stream
**Audience:** Angular developers, QA
**Shortcode:** `[VAL]`
**Part of:** `ProjectPlan/Frontend/` — index: [README.md](../README.md)

---

### 7.5 Shopfloor constraints

> **Four of these constraints are already met by the repository — know which, so they are not built twice** *(added 27 Aug 2026)*.
>
> - **Data entry** — `ngx-touch-keyboard` is already a dependency, `NgxTouchKeyboardModule` is imported by `SharedModule`, and `shared` ships a `KeypadComponent`. Consume them; a foundational `shared` component is **not** a `D-06` violation.
> - **Transactional actions** and **supervisor overrides** — `shared`'s `CommonPopupService` opens **every** modal with `backdrop: 'static'` and `keyboard: false`, which satisfies both rows **by construction**. ⚠ **The failure mode is using `NgbModal` directly**, which carries neither option — and note the mechanism does not distinguish the two rows: everything blocks passive dismissal.
> - **Dialog height** — the mockups implement it in `fw-modal.js` via `--fw-modal-fit` (so `.gb-modal` carries no `max-height` and its body is `overflow: visible`). ⚠ **In Angular this half has no owner yet** — `NgbModal` covers the dialog runtime but not the scale-to-fit.

| Constraint | Value | Why |
|---|---|---|
| Authored canvas | **1920 × 1080** | The physical shopfloor panel |
| Minimum text size | **14 px** | Read at arm's length, standing, sometimes gloved |
| Form controls | pinned to 14 px for `input, select, textarea, button, option` | They do not inherit the body font, and the browser default is 13.333 px |
| Tap targets | **≥ 48 px** | Touch-first, gloved hands |
| Hover | **No action may depend on hover** | Touch screens have no hover |
| Numeric readings | rendered in `--font-mono` | Legibility and column alignment |
| Data entry | on-screen virtual keyboard and numeric keypad | No physical keyboard at the machine |
| Transactional actions | modal pop-ups that must be resolved or explicitly dismissed | Stop, Weld, Checkout, SPC entry |
| Supervisor overrides | **block passive dismissal** | An override must be a decision, not an accident |
| Dialog height | **No dialog scrolls** — an oversized dialog is **scaled to fit** | A scrollbar hides half a decision on a panel nobody scrolls |
| Print | **no *traveler* print action** — labels do print | The **traveler** is fully digital; coil, spool and skid **labels print** |

### The canvas changed on 27 Aug 2026 — 1280 × 1024 → 1920 × 1080

**This row is where the canvas is defined, and every other document derives it from here.** The change is one of **shape**, not of size, and that is the whole of its consequence:

| | was | now | change |
|---|---|---|---|
| Width | 1280 | **1920** | **+640 px · ×1.50** |
| Height | 1024 | **1080** | **+56 px · ×1.05** |
| Aspect | 5:4 | **16:9** | **the shape changes** |

⚠ **Nothing gets taller.** +56 px is one row of 14 px type with its padding, so **the re-layout is horizontal** — width is spent on columns, not on stretching. **18 of the 19** mockups are composed for 5:4, so they remain the authority on **content** and not on **composition** at this canvas. ⚠ The exception, `dashboard_3_active_run_ual.html` (28 Aug 2026), is composed for **1920×1080** — but it is a **styling comparison build** in the host application’s CSS, not a screen, so it is not a composition authority either. ⚠ **It does, however, measure this row’s hardest constraint**: the app’s own CSS sets `body { font-size: 12px !important }`, so a screen built on it holds the 14 px floor only by re-declaring it directly — and Bootstrap’s `.badge` (0.75em → 10.5 px) and `small` (0.875em) each need an explicit override.

⚠ **The 14 px floor and the ≥ 48 px tap targets are carried forward unchanged, on an assumption that has not been confirmed.** Both are **physical** legibility rules — arm's length, standing, gloved — so they track **dpi, not resolution**, and they hold only if the 1920 × 1080 panel is a **physically larger** panel of the same dpi class (a ~21.5″ 16:9 against a 17–19″ 5:4, both ~96–102 dpi). **If it is the same physical panel at higher density, every size in the token system scales ×1.5 and the floor becomes 21 px** — a change to the token system rather than to the layouts. **No document records the panel's diagonal**: `G23` and `Q26` asked about resolution only. **Ask for the diagonal.**

**On the 14 px figure's authority.** It was previously cited as *"`MIN_FONT` in `flat-wire-fit.js`"*. That script is a **mockup** asset, it hard-codes the old 1280 × 1024 design box, and **no Angular equivalent exists yet** — so the number is **this table's**, and the script is merely where the mockups implement it.

**The documented exception to the 14 px floor** is axis labels inside vertically compressed SVG charts — `dashboard_3_active_run`, `_fl2` and `_fl3` — where tick spacing cannot fit 14 px without dropping ticks or making the charts taller. **Do not "fix" these by shrinking text elsewhere.**

> ⚠ **The 1920 × 1080 canvas does not relieve this exception.** The reason above is *vertical* — tick spacing against chart height — and the canvas gained **56 px of height**. A reader who sees a bigger canvas and concludes the exception is closed will be wrong. **It stands, and it is still the only exception.**

---

### 7.5a Client-side validation — not yet written

⚠ **This document's title and Document Type both claim client-side validation, and it contains none.** The gap is recorded here rather than left implied, because four things have no home while it stands:

| Owed | Where it is needed |
|---|---|
| Toast versus inline field-error behaviour, and which errors go where | `FW-131` — and ⚠ note that `shared`'s error interceptor pops a **modal** on `errorDescription`, which `[API §1.2]` fills with machine codes like `BAY_OCCUPIED` |
| `.input` `.invalid` / `field-error` state rules | `FW-134` |
| Field formats and ranges — `R#####`, `SP-#####`, footage, gauge, width | `FW-132`'s models, which every screen binds to |
| **`G14`'s two unresolved halves** — 3- versus 4-item inspection, and `FootageFt` INT versus DECIMAL | `FW-132` bakes whichever it picks into those models |

**Nothing here should be inferred from the mockups' markup.** Until this section is written, the validation rules of record are the `FR-###` in `[REQ]` and the `CHECK` constraints in the DDL.
