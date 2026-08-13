# Flat Wire Mill — Reference Data

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** August 13, 2026 — lifted out of `Analysis/FlatWireShopfloorDashboards.md` in the ProjectPlan restructure
**Document Type:** Seed and reference data
**Status:** Active — MVP-1 seed data
**Owner:** BA / Analysis stream
**Audience:** DBA, .NET developers, BA
**Shortcode:** `[REF]`
**Part of:** `ProjectPlan/Database/` — index: [README.md](../README.md)

> **This is MVP-1 seed data, and it sat inside an MVP-2 screen section until 13 Aug 2026.** It feeds `AlloyProperty`
> and the Phase-13 alloy-lookup admin grid, and is cited from `Schema/FlatWireSchema_Lookup.md` and `phase-13`.
>
> ⚠ **The `Spring-back factor` column is flagged, not removed.** Master spec §10.5 arbitrates springback as
> **machine stiffness misfiled as a material property** — the roll gap sits *below* gauge by a load-dependent
> mill-spring term, not above it by a fixed alloy multiplier. `AlloyProperty` carries the column and the
> generation that consumes it is MVP-2, so it is harmless where it stands — but it is seeded with values that
> will be read as authoritative. `GapAnalysis.md` **D2** records the same finding against the DDL.

---

## Alloy Reference Data

**Scope: MVP-1.** Seeded in Phase 1 and maintained through the Phase-13 alloy-lookup admin grid, which is the
**non-deferrable** half of that phase.

This table lived inside the **Dashboard 9** section until 11 Aug 2026 — MVP-1 reference data buried in an
MVP-2 screen. Two live citations depend on it and neither is about Dashboard 9:

- `LatestDocument/FlatWire_MasterSpecification.md` — *"maintained via an admin screen"*, carrying its own copy of these values
- `MVP-1/ProjectPlan/Development/Phases/phase-13-administration-reference-data.md` — cites this table for the Process-Engineering sign-off caveat

Its six columns map 1:1 onto the **`AlloyProperty`** table (`Alloy`, `MaxReductionPerPass`, `SpringbackFactor`,
`GaugeToleranceDefault`, `WidthToleranceDefault`, `SpeedRangeMinFPM`, `SpeedRangeMaxFPM`) seeded by
`FlatWire_SampleData_Lookup.sql`.

### Alloy Lookup Table (required in database)

| Alloy | Max reduction / pass | Spring-back factor | Gauge tol. default | Width tol. default | Speed range (FPM) |
|-------|---------------------|-------------------|--------------------|--------------------|--------------------|
| 1100  | 26% | 0.98 | ± 0.003" | ± 0.010" | 800 – 2,000 |
| 1350  | 22% | 0.97 | ± 0.002" | ± 0.008" | 600 – 1,600 |
| 3003  | 24% | 0.98 | ± 0.004" | ± 0.012" | 700 – 1,800 |
| 5052  | 20% | 0.97 | ± 0.003" | ± 0.010" | 500 – 1,400 |
| 6061  | 18% | 0.96 | ± 0.003" | ± 0.010" | 400 – 1,200 |

> These values must be confirmed and maintained by Process Engineering (Tim O.). They are editable via an admin table — not hardcoded.

> **⚠ `Spring-back factor` is a contested quantity — do not build physics on it.** Master specification
> **§10.5** arbitrates the springback model as wrong: the roll gap sits **below** gauge by a **load-dependent
> mill-spring** term (`h₁ = S₀ + F/K`), not above it by a fixed per-alloy multiplier, and springback
> (material) has been conflated with mill spring (machine stiffness). The column stays because
> `AlloyProperty` carries it and the schema is seeded from this table; **the pass-schedule generation that
> consumes it is MVP-2**, and `PassScheduleGenerationSpec.md` is the authority on the physics.

> **Rod diameter and ovality tolerances are deliberately absent.** They are owed by e-mail (`Q22`) and are
> seeded `NULL` in `AlloyProperty` rather than guessed — see `FlatWireSchema_Lookup.md`.

---
