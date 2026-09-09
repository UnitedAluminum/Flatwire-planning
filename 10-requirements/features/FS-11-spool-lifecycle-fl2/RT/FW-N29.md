---
id: FW-N29
legacy_id:
title: FL2 live gauge and width trace at 4 s
status: not-started
status_confirmed: true
status_note: "✅ **UNBLOCKED AND DECIDED 9 Sep 2026 — FL2 PUBLISHES A LIVE TRACE at a 4 s update rate.** `A3` retired, `FR-120` superseded, `G120` resolved. The decisive evidence was **internal**: FL3 is FL1 feeding FL2 on the **same FM2** in real time, and `FW-181` already conceded FL2-within-FL3 has live gauge — so `A3` claimed one instrument stops existing when the upstream feed changes. `Decisions.md` Case 4 had also recorded it client-confirmed, predating both questions. Build: two `AGC` tag paths (values-only config), unbatched 4 s broadcast, `Fl2LineModel.ReadGaugeInstrument()` un-suppressed, no client branch. ⛔ **The out-of-spec consecutive-reading threshold must be PER LINE** — 4 readings is <0.5 s on FL1 and 16 s of production on FL2. ⚠ Paths stay `[PROPOSED]` until `C1`; `PLC-Q19` decides whether there are one or two gauging stands, i.e. two tags or four. **HISTORICAL NOTE — the position this story held until 9 Sep 2026:** *(⛔ BLOCKED, deliberately unresolved. Answering a question about notifications the client remarked: *'the FL2 does have a gauge stand that tracks thickness and width throughout the production run'*. Six documents say the opposite — that the finishing line broadcasts no live gauge or width and its trace is a stored profile. `G120` holds the contradiction. **Nothing was edited on the strength of a passing remark.** [9 Sep 2026, re-weighted] THE SIX SITES ALL TRACE TO ONE ASSUMPTION OF OURS - A3 in the machine interface specification - and no client source has ever stated it. Q1 is a second, stronger contradiction that was missed when this story was written: automatic position control on FL2-S3 via gauging stands downstream is a closed control loop, which cannot run off a measurement nobody takes. So the equipment almost certainly measures it, and the real question is narrower - is the reading exposed to us as an OPC tag, and at what cadence. A yes is a TAG-SURFACE ADDITION, not just a requirement flip: FL2 has no gauge or width tag at all today.)*"
owner: Real-time stream
jira:
mvp: 1
phase: "8"
stream: RT
streams: [RT]
priority: high
hours: 8
sprint: S2
depends_on: [FW-081]
blocked_by: []
has_plan: false
started:
completed:
---

# FW-N29 - FL2 gauge trace - live stream or post-check-in profile

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

**Hours:** 8 h RT · **Priority:** High · **Sprint:** S2 · **Phase:** 8 · **Stream:** RT

> ✅ **UNBLOCKED AND DECIDED, 9 Sep 2026. FL2 publishes a live trace.** This story was blocked on `G120` while the contradiction stood. It is resolved: assumption **`A3`** of `[PLC §14]` is **retired** and **`FR-120` is superseded**. The decisive evidence turned out to be **internal** — FL3 is *"FL1 feeding FL2 continuously… Real-time. **Same FM2**"*, and `FW-181` already conceded that *"FL2 standalone has no live gauge; FL2 running as part of an FL3 hybrid does"*, so `A3` claimed the same instrument on the same mill stops existing when the upstream feed changes. [`Decisions.md`](../../../../90-registers/Decisions.md) Case 4 had also recorded, **client-confirmed and predating both questions**, that *"both FL1 and FL2 mills have automatic gauge control… via output of gauge/width trace devices"*.

**As a** FL2 operator watching a run,
**I want** the gauge and width traces to show what the mill is actually producing right now,
**So that** I can react to drift before it becomes scrap, as an FL1 operator already can.

**Acceptance Criteria:**
- [ ] Two tag paths bound in the FL2 `Tags` block: **`FL2.PLC.AGC.Gauge`** and **`FL2.PLC.AGC.Width`** — `REAL`, **inches**, **4 s**. ⚠ **Values-only config change**; ingest and broadcast need no code (`P-37`)
- [ ] `GaugeReading` and `WidthReading` are broadcast on `FL2Data` at ≈4 s, **unbatched** — there is nothing to coalesce at one sample per 4 s, and batching only adds latency
- [ ] `Fl2LineModel.ReadGaugeInstrument()` returns real values instead of `(null, null)`. ⚠ **Its 40-line header comment forbids exactly this change and must be rewritten with it** — the comment is the code expression of the retired assumption
- [ ] The trace renders against target and tolerance band on FL2, using the **same** components as FL1/FL3 — ⛔ **no line branch, and no trace flag added to `LINE_PROFILES`**; `D-55` removed that branch deliberately
- [ ] **Footage gaps render as gaps, never interpolated.** At 4 s and line speed there is real unmeasured wire between points; a straight line through it shows in-spec material that was never measured
- [ ] `RunReading` rows for FL2 carry **both** gauge and width from the **same sample** (`TC-030`). ✅ **No DDL change** — both columns are already nullable and the table has no line column
- [ ] ⛔ **The out-of-spec consecutive-reading threshold is read PER LINE, not shared.** Four readings is <0.5 s on FL1 and **16 s of production on FL2**. Inheriting FL1's value multiplies the scrap window ~40×; this is the one part of this story that can produce bad product
- [ ] `TC-140`, `TC-141` and `TC-492` inverted; `TC-494` widened to all three lines; `TC-168` still passes — proving the weight derivation **ignores** the new live readings, because `Q10` fixed the basis as nominal (`D17`)

⚠ **Still `[PROPOSED]`, like every other row in `[PLC §5.2]`:** the client has confirmed the stands *measure*, not that the readings are *exposed* to us. The paths confirm at commissioning `C1`; the unit (inches, not mils) is `PLC-Q15`; and **whether there is one gauging stand or two is `PLC-Q19` — if two, `R6` makes these `AGC1`/`AGC2` and this story builds four tags, not two.**

**Rate-card basis:** **8 h RT** stands — the config and broadcast work is genuinely small, and the estimate was sized for whichever answer arrived. ⚠ **The cadence tuning is NOT in these 8 h**: re-choosing the consecutive-reading threshold needs trial data (`Q66` / `Q67`) and is carried as a trial-run item.
**Dependencies:** FW-081
**Blockers:** none — `G120` resolved 9 Sep 2026
