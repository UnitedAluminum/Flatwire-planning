/* =============================================================================
   pause_run.js — shared Pause / Resume dialogs for the FL1/FL2/FL3 run monitors
   =============================================================================
   Include before </body>, AFTER fw-modal.js:

       <script src="fw-modal.js"></script>
       <script src="pause_run.js"></script>

   Host contract — element IDs the dialogs drive on the screen behind them:
       #pause-btn            the action button (becomes Resume run while paused)
       #pause-timer-badge    header badge, shown while paused
       #pause-elapsed        the running duration inside that badge
       #checkout-btn         Checkout — DISABLED while running, ENABLED while
                             paused. Optional; screens without it are unaffected.
       .line-badge           the running/paused status pill

   `window.fwPauseFootage()` returns the footage frozen at the pause, or null when
   the line is running — so a host handing context to Rod Checkout reports where
   the line actually stopped rather than a counter that has moved since.

   Context. Both dialogs take the run they are acting on rather than scraping it
   out of the host DOM:

       openPauseDialog({ line, orderNo, alpha, runId, footage, operator })

   Every key is optional, and the caller's keys are LAYERED OVER the host's own
   `fwRunCtx()` if it defines one — which is how the existing argument-less
   `onclick="openPauseDialog()"` handlers keep working and still read live
   footage on every open.

   REDESIGNED 1 Aug 2026 to the supplied reference design:

     · An ICON BADGE + title + one-line purpose in the head, then a single row of
       CONTEXT CHIPS — status, order, alpha, footage, pause start — each with its
       own glyph. The run is stated once, horizontally, instead of twice.
     · REASONS AS ICON TILES. Every tile carries an icon, a name and a mono
       qualifier line; the reasons that lead somewhere carry a route line
       ("→ opens die change") so the operator knows before committing.
       ⚠ REWORKED 2 Sep 2026 — this was FIVE CATEGORY COLUMNS of tiles, one per
       semantic category, holding all fifteen reasons. The client's delay-code
       vocabulary has 47 codes on this dialog, and 47 tiles do not fit at the
       14px shopfloor floor on a 1280x1024 panel read at arm's length. It is now
       EIGHT QUICK TILES over a bucket select plus a code select carrying the
       full list — the same two-level shape wip_rejection.js already used, rather
       than a third interaction invented for this screen. A tile and the selects
       are ONE choice: selecting either moves the other.
     · `Other` is now a CODE PER BUCKET (SET23 / RUN12 / HDL15), not a category
       of its own — it is a reason like the rest, it just also needs typing.
     · NOTES on one row: label left, field right, with a 500-character counter.
     · Footage and clock TICK while the dialog is open, because the line is still
       running. Confirming freezes them and the footer shows the value the freeze
       actually took, not the one on screen when the operator reached for the
       button.

   DEVIATION FROM THE REFERENCE, deliberate: it sets type around 10–13px. The
   shopfloor floor is 14px (MIN_FONT in flat-wire-fit.js, and the shared sheet
   pins form controls to it) because these screens are read at arm's length on a
   1280x1024 panel. Every size here is lifted to at least 14px; the layout,
   iconography and hierarchy are the reference's.

   Behavioural rules carried forward from the earlier pass:
     · ROD CHECKOUT IS NOT A REASON, and since 2 Aug 2026 IT IS NOT A RESUME
       OUTCOME EITHER. It began as one of fifteen pause reasons — the only one
       that did not pause — and was moved to a fourth resume outcome (OI-14;
       FR-262 superseded). That was still the wrong shape: choosing it on the
       resume dialog meant answering "how does this pause end?" with an action
       that does not end the pause, alongside three that do.
       It is now a COMMAND-BAR BUTTON gated on paused state: `#checkout-btn` is
       disabled while running and enabled while paused. The precondition is the
       same one it always had — the line must be stopped — but it is now shown
       as a button that lights up rather than an option buried in a dialog.
       Resume therefore has THREE outcomes: ResumeRun, LogWipRejection,
       ContinuePause. `CheckOutRod` remains valid in `POST /run/{runId}/resume`
       and `CK_RunPauseEvent_Outcome`; it is simply no longer reachable from the
       resume dialog, and a checkout confirmed while paused should still close
       the pause with that outcome.
     · Reason CODES are carried, not labels: `RunPauseEvent` needs ReasonCode +
       ReasonCategory — since 2 Sep 2026 a DELAY CODE and a DELAY BUCKET, and
       FK_RunPauseEvent_DelayCode is COMPOSITE on the pair, so the two must
       agree or the insert is rejected. `Other` keeps its code and puts the
       prose in notes.
     · Notes are REQUIRED on Other, matching CK_RunPauseEvent_NotesOther — which
       was rewritten the same day to key on the three codes rather than on a
       category called "Other", which the delay-code model does not have.
     · THE FOURTH BUCKET IS NOT HERE. Downtime (25 DWN## codes) is LINE-down
       time and belongs to LineDowntimeEvent, whose RunId is nullable; this
       dialog pauses a RUN. Do not add a Downtime tab to it.
     · Duration reads h:mm:ss past an hour.
     · All CSS is scoped under .fwpause. The pre-redesign file defined a bare
       `.btn` globally, which overrode the shared 52px shopfloor button on every
       screen that loaded it.

   Requires flat-wire-shopfloor.styles.css. die_change.js / spc_checkpoint.js /
   wip_rejection.js / rod_checkout.js are optional — a hand-off to a dialog that
   is not loaded is simply skipped.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openPauseDialog) return;     /* guard against double-inclusion */

  function svg(paths, w) {
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="' +
           (w || 1.8) + '" stroke-linecap="round" stroke-linejoin="round">' + paths + '</svg>';
  }

  /* ── Icons ──────────────────────────────────────────────────── */
  var IC = {
    pause:   svg('<rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/>', 2),
    play:    svg('<polygon points="6 3 20 12 6 21 6 3"/>', 2),
    close:   svg('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>', 2.2),
    arrow:   svg('<path d="M5 12h13M13 6l6 6-6 6"/>', 2.2),
    check:   svg('<polyline points="20 6 9 17 4 12"/>', 2.2),
    warn:    svg('<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>', 2),

    /* context chips */
    doc:     svg('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>'),
    tag:     svg('<path d="M20.6 13.4L12 22l-9-9V4a1 1 0 0 1 1-1h9z"/><circle cx="8" cy="8" r="1.4"/>'),
    ruler:   svg('<path d="M12 3v18M8 6h8M8 12h8M8 18h8"/>'),
    clock:   svg('<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>'),
    user:    svg('<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>'),

    /* category heads */
    catEquip: svg('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1A1.7 1.7 0 0 0 9 19.4a1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1A1.7 1.7 0 0 0 4.6 9a1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>'),
    catMat:   svg('<path d="M21 16V8a2 2 0 0 0-1-1.7l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.7l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.3 7 12 12 20.7 7"/><line x1="12" y1="22" x2="12" y2="12"/>'),
    catQual:  svg('<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/>'),
    catOp:    svg('<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.9"/><path d="M16 3.1a4 4 0 0 1 0 7.8"/>'),
    catSafe:  svg('<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>'),

    /* reason tiles */
    die:      svg('<rect x="3" y="7" width="18" height="10" rx="3"/><circle cx="12" cy="12" r="2.2"/>'),
    roll:     svg('<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="2.5"/>'),
    drop:     svg('<path d="M12 3s6 6.4 6 10.2A6 6 0 0 1 6 13.2C6 9.4 12 3 12 3z"/>'),
    drawbox:  svg('<rect x="3" y="4" width="18" height="16" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="8" y1="14" x2="16" y2="14"/>'),
    inspect:  svg('<circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/><path d="M9 11h4M11 9v4"/>'),
    dots:     svg('<circle cx="12" cy="12" r="9"/><circle cx="8.5" cy="12" r=".9" fill="currentColor"/><circle cx="12" cy="12" r=".9" fill="currentColor"/><circle cx="15.5" cy="12" r=".9" fill="currentColor"/>'),
    payoff:   svg('<circle cx="10" cy="10" r="6"/><circle cx="10" cy="10" r="1.6"/><path d="M17 15l4 4M21 15l-4 4"/>'),
    blockage: svg('<circle cx="12" cy="12" r="8.5" stroke-dasharray="3 3"/><line x1="8" y1="12" x2="16" y2="12"/>'),
    gauge:    svg('<path d="M4 20V6"/><path d="M4 20h16"/><polyline points="8 15 12 10 16 13 20 7"/>'),
    chart:    svg('<path d="M3 17l5-6 4 3 4-6 5 5"/><path d="M3 21h18"/>'),
    eye:      svg('<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/>'),
    cup:      svg('<path d="M4 8h13v6a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5z"/><path d="M17 9h2.2a2.5 2.5 0 0 1 0 5H17"/><path d="M7 3v2M11 3v2"/>'),
    swap:     svg('<path d="M4 8h13l-3.5-3.5"/><path d="M20 16H7l3.5 3.5"/>'),
    supervisor: svg('<circle cx="9" cy="8" r="3.6"/><path d="M3 20a6 6 0 0 1 12 0"/><circle cx="18" cy="16" r="4"/><path d="M18 14.4V16l1.2.9"/>'),
    shieldAlert: svg('<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="8" x2="12" y2="12.5"/><line x1="12" y1="15.5" x2="12.01" y2="15.5"/>')
  };

  /* ── Reason taxonomy ────────────────────────────────────────────
     Codes and categories are the ones POST /run/{runId}/pause accepts; the
     labels are the ones the SRS lists. `opens` names a global dialog opener to
     hand off to once the pause is applied. */
  /* ── Delay-code vocabulary ────────────────────────────
     REPLACED 2 Sep 2026. This was 15 reasons in 5 SEMANTIC categories
     (EquipmentMechanical / MaterialHandling / QualityMeasurement / Operational
     / Safety) with codes like DieChangeMidRun. The client's "Reason Codes.xlsx"
     (Tim O'Brien, 1 Sep 2026) replaced that with UA's DELAY-CODE model: four
     TIME buckets keyed to the throughput standard-time model. Literal overlap
     with the old vocabulary was ZERO.

     ONLY THREE BUCKETS ARE HERE. The fourth, Downtime (25 DWN## codes), is
     LINE-down time -- Power Outage, Fire Drill, Waiting for Spool From Previous
     Operation -- which happens when no run is open. Those go to
     LineDowntimeEvent, not RunPauseEvent, whose RunId is NOT NULL.
     CK_RunPauseEvent_Bucket rejects a DWN code here.

     WORDING IS THE CLIENT'S, VERBATIM, including "Bundle" for the rod and
     "Spool" for the material in process. It must match DowntimeReason's seed:
     FK_RunPauseEvent_DelayCode is COMPOSITE on (code, bucket), so a mismatch
     is rejected rather than silently stored.

     STILL MISSING: OperatorBreak, ShiftChangeover, AwaitingSupervisor and
     SafetyObservation were reasons here until today and the client's list has
     NO equivalent -- SET11 "Prior Shift unaccountable" is not shift changeover
     and DWN07 "Fire Drill" is not a safety observation. Owed back to the
     client. DO NOT map them onto a nearby code. */
  var BUCKETS = {
    Setup: { label: "Setup", icon: IC.catEquip, codes: [
      { code: "SET10", label: "QC / Process Monitor Quality", opens: "spc", opensLabel: "opens SPC" },
      { code: "SET11", label: "Prior Shift unaccountable" },
      { code: "SET12", label: "Operator Training" },
      { code: "SET19", label: "Computer problems" },
      { code: "SET21", label: "Replace Banding Material" },
      { code: "SET23", label: "Other", requiresNotes: true },
      { code: "SET24", label: "Machine Demonstration" },
      { code: "SET28", label: "Active Inspection" },
      { code: "SET29", label: "Wire Break" },
      { code: "SET30", label: "Trouble Threading The Line" },
      { code: "SET31", label: "Change Straightener Rolls" },
      { code: "SET32", label: "Change Dies", opens: "die-change", opensLabel: "opens die change" },
      { code: "SET33", label: "Change Edger Rolls" },
      { code: "SET34", label: "Rewind Bundle" },
      { code: "SET35", label: "Cannot Find Bundle/Spool, Not Correct Bundle/Spool, Searching For Bundle/Spool" },
      { code: "SET36", label: "Searching For Next bundle/Spool" },
      { code: "SET37", label: "Digging Out Next Bundle/Spool" },
      { code: "SET38", label: "Refill Draw Lube" },
      { code: "SET39", label: "Cobble" },
      { code: "SET40", label: "Tangle" },
      { code: "SET41", label: "Wire Break Due to Bad Weld" }
    ]},
    RunTime: { label: "Run Time", icon: IC.catQual, codes: [
      { code: "RUN04", label: "Rough or Cracked Edges" },
      { code: "RUN05", label: "Shape Problems" },
      { code: "RUN06", label: "Operator Training" },
      { code: "RUN12", label: "Other", requiresNotes: true },
      { code: "RUN13", label: "Active Inspection" },
      { code: "RUN14", label: "Machine Demonstration" },
      { code: "RUN15", label: "Wire Break" },
      { code: "RUN16", label: "Traverse Problems" },
      { code: "RUN17", label: "Cobble" },
      { code: "RUN18", label: "Tangle" },
      { code: "RUN19", label: "Refill Draw Lube" },
      { code: "RUN20", label: "Wire Break Due to Bad Weld" }
    ]},
    Handling: { label: "Handling", icon: IC.catMat, codes: [
      { code: "HDL07", label: "Operator Training" },
      { code: "HDL11", label: "Replace Banding Material" },
      { code: "HDL14", label: "Edge Damage from Width Changes" },
      { code: "HDL15", label: "Other", requiresNotes: true },
      { code: "HDL16", label: "Machine Demonstration" },
      { code: "HDL17", label: "Active Inspection" },
      { code: "HDL18", label: "Wire Break" },
      { code: "HDL19", label: "Trouble Threading The Line" },
      { code: "HDL20", label: "Change Straightener Rolls" },
      { code: "HDL21", label: "Change Dies", opens: "die-change", opensLabel: "opens die change" },
      { code: "HDL22", label: "Change Edger Rolls" },
      { code: "HDL23", label: "Wire Break Due to Bad Weld" },
      { code: "HDL24", label: "Rewind Bundle" },
      { code: "HDL25", label: "Cleaning Scrap From Line" }
    ]}
  };
  var BUCKET_ORDER = ["Setup", "RunTime", "Handling"];

  /* THE TILE GRID DID NOT SURVIVE THE CHANGE, and this is why. 15 reasons work
     as icon tiles; 47 delay codes do not -- not at the 14px shopfloor minimum,
     read at arm's length on a 1280x1024 panel. Rather than invent a third
     interaction, this adopts the one wip_rejection.js already uses: a short row
     of QUICK TILES over a bucket select plus a code select holding the full 47.
     Eight tiles, chosen as what an operator reaches for mid-run, and both
     routing reasons are kept so the "-> opens ..." affordance survives. Every
     code here MUST exist in BUCKETS above. */
  var QUICK_CODES = ["SET32", "SET10", "RUN04", "RUN16", "SET38", "RUN15", "SET30", "RUN12"];

  function findReason(code) {
    for (var key in BUCKETS) {
      var b = BUCKETS[key];
      for (var i = 0; i < b.codes.length; i++) {
        if (b.codes[i].code === code) {
          var r = b.codes[i];
          /* The code/bucket PAIR is what the API stores and what
             FK_RunPauseEvent_DelayCode checks -- never the label. */
          return { code: r.code, category: key, label: r.label,
                   opens: r.opens, opensLabel: r.opensLabel,
                   requiresNotes: !!r.requiresNotes };
        }
      }
    }
    return null;
  }

  var NOTES_MAX = 500;

  /* ── Styles ─────────────────────────────────────────────────── */
  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-pause-run", "");
  styleEl.textContent = [
    /* Host-screen affordances — the only rules outside .fwpause, because they
       style the screen behind the dialog. */
    '.action-btn.warn{color:var(--color-text-warning)}',
    '.action-btn.warn:hover{background:var(--color-background-warning);border-color:var(--color-amber)}',
    '.line-badge.paused{background:var(--color-background-warning);color:var(--color-text-warning)}',
    '.line-badge.paused .dot{background:var(--color-amber);animation:none}',
    '.pause-timer-badge{display:none;align-items:center;gap:8px;padding:6px 14px;background:var(--color-background-warning);color:var(--color-text-warning);border-radius:var(--border-radius-md);font-size:14px;font-weight:500}',
    '.pause-timer-badge.visible{display:inline-flex}',
    '.pause-timer-badge .pause-reason{opacity:.85;font-weight:400}',

    /* ── Head: icon badge + title + purpose ── */
    '.fwpause .fwp-head{display:flex;align-items:center;gap:14px;width:100%}',
    '.fwpause .fwp-head-icon{width:44px;height:44px;border-radius:50%;background:var(--color-background-info);color:var(--color-blue);display:flex;align-items:center;justify-content:center;flex-shrink:0}',
    '.fwpause .fwp-head-icon svg{width:22px;height:22px}',
    '.fwpause .fwp-head-text{display:flex;flex-direction:column;gap:3px;min-width:0}',
    '.fwpause .fwp-head-text .gb-modal-title{font-size:20px;font-weight:600}',
    '.fwpause .fwp-head-sub{font-size:14px;color:var(--color-text-tertiary)}',

    /* ── Context chip row ── */
    '.fwpause .fwp-chips{display:flex;align-items:center;gap:10px;flex-wrap:wrap;padding:12px 20px;border-bottom:0.5px solid var(--color-border-tertiary)}',
    '.fwpause .fwp-chip{display:inline-flex;align-items:center;gap:8px;padding:7px 14px;border-radius:999px;background:var(--color-background-secondary);font-size:14px;color:var(--color-text-secondary);white-space:nowrap}',
    '.fwpause .fwp-chip svg{width:15px;height:15px;color:var(--color-text-tertiary);flex-shrink:0}',
    '.fwpause .fwp-chip .cv{font-family:var(--font-mono);font-weight:500;color:var(--color-text-primary);font-variant-numeric:tabular-nums}',
    '.fwpause .fwp-chip.status{background:var(--color-background-success);color:var(--color-text-success);font-weight:500}',
    '.fwpause .fwp-chip.status.paused{background:var(--color-background-warning);color:var(--color-text-warning)}',
    '.fwpause .fwp-chip.status .dot{width:9px;height:9px;border-radius:50%;background:var(--color-green);position:relative;flex-shrink:0}',
    '.fwpause .fwp-chip.status.paused .dot{background:var(--color-amber)}',
    '.fwpause .fwp-chip.status .dot::after{content:"";position:absolute;inset:-4px;border-radius:50%;background:inherit;opacity:.35;animation:fwpPing 1.6s ease-out infinite}',
    '.fwpause .fwp-chip.status.paused .dot::after{animation:none;opacity:0}',
    '@keyframes fwpPing{0%{transform:scale(.6);opacity:.5}100%{transform:scale(2.1);opacity:0}}',
    '.fwpause .fwp-chip.live .cv{color:var(--color-text-success)}',
    '.fwpause.frozen .fwp-chip.live .cv{color:var(--color-text-primary)}',

    /* ── Body ── */
    '.fwpause .fwp-body{display:flex;flex-direction:column;gap:0}',
    '.fwpause .fwp-prompt{display:flex;align-items:baseline;justify-content:space-between;gap:16px;margin:0 2px 14px;flex-wrap:wrap}',
    '.fwpause .fwp-prompt h3{font-size:15px;font-weight:600;margin:0}',
    '.fwpause .fwp-prompt .req{color:var(--color-red)}',
    '.fwpause .fwp-prompt p{margin:0;font-size:14px;color:var(--color-text-tertiary)}',

    '.fwpause .fwp-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;align-items:stretch}',
    /* The full-list picker. 47 codes will not fit as tiles at the 14px floor,
       so they live in two selects -- the same shape wip_rejection.js uses. */
    '.fwpause .fwp-full{margin-top:16px;padding-top:14px;border-top:1px solid var(--gb-border,#d4d9e0)}',
    '.fwpause .fwp-full-head{font-size:14px;font-weight:600;margin-bottom:8px}',
    '.fwpause .fwp-full-fields{display:flex;gap:14px;align-items:flex-end}',
    '.fwpause .fwp-full-field{display:flex;flex-direction:column;gap:5px}',
    '.fwpause .fwp-full-field.grow{flex:1 1 auto;min-width:0}',
    '.fwpause .fwp-full-label{font-size:14px;font-weight:600}',
    '.fwpause .fwp-select{font-size:14px;min-height:44px;padding:6px 10px;width:100%;'
      + 'border:1px solid var(--gb-border,#d4d9e0);border-radius:6px;background:#fff}',
    '.fwpause .fwp-col{display:flex;flex-direction:column;min-width:0}',
    /* Two lines reserved: 'Equipment / Mechanical' and 'Quality / Measurement' wrap at
       14px in a 200px column, and a one-line reservation left those columns' tiles
       starting a row lower than the rest. */
    '.fwpause .fwp-grouphead{display:flex;align-items:flex-start;gap:7px;margin:0 0 9px 2px;min-height:38px}',
    '.fwpause .fwp-grouphead svg{margin-top:1px}',
    '.fwpause .fwp-grouphead svg{width:15px;height:15px;color:var(--color-text-tertiary);flex-shrink:0}',
    '.fwpause .fwp-grouphead .lbl{font-size:14px;font-weight:600;letter-spacing:.06em;text-transform:uppercase;color:var(--color-text-secondary);line-height:1.15}',
    '.fwpause .fwp-tiles{display:flex;flex-direction:column;gap:8px}',

    /* ── Reason tile ── */
    '.fwpause .fwp-tile{display:flex;align-items:flex-start;gap:11px;text-align:left;font-family:var(--font-sans);cursor:pointer;border:1px solid var(--color-border-tertiary);background:var(--color-background-primary);border-radius:var(--border-radius-md);padding:11px 12px;transition:border-color .13s,background .13s,box-shadow .13s;width:100%}',
    '.fwpause .fwp-tile:hover{border-color:var(--color-blue);background:var(--color-background-secondary)}',
    '.fwpause .fwp-tile:active{transform:scale(.99)}',
    '.fwpause .fwp-tile-icon{width:20px;height:20px;color:var(--color-text-secondary);flex-shrink:0;margin-top:1px}',
    '.fwpause .fwp-tile-icon svg{width:20px;height:20px}',
    '.fwpause .fwp-tile-body{display:flex;flex-direction:column;gap:2px;min-width:0}',
    '.fwpause .fwp-tile .t-name{font-size:14px;font-weight:500;line-height:1.3;color:var(--color-text-primary)}',
    '.fwpause .fwp-tile .t-sub{font-size:14px;color:var(--color-text-tertiary);line-height:1.3}',
    /* Route line: says where the reason leads BEFORE the operator commits to it. */
    '.fwpause .fwp-tile .t-route{display:inline-flex;align-items:center;gap:5px;margin-top:4px;font-size:14px;font-weight:500;color:var(--color-text-info)}',
    '.fwpause .fwp-tile .t-route svg{width:12px;height:12px;flex-shrink:0}',
    '.fwpause .fwp-tile.selected{border-color:var(--color-blue);background:var(--color-background-info);box-shadow:inset 3px 0 0 var(--color-blue)}',
    '.fwpause .fwp-tile.selected .fwp-tile-icon{color:var(--color-blue)}',
    '.fwpause .fwp-tile.selected .t-name{color:var(--color-text-info)}',
    '.fwpause .fwp-tile.selected .t-sub{color:var(--color-text-info);opacity:.8}',

    /* ── Notes row ── */
    '.fwpause .fwp-notes{display:grid;grid-template-columns:170px 1fr;gap:16px;align-items:start;margin-top:16px}',
    '.fwpause .fwp-notes-label{font-size:14px;font-weight:600;color:var(--color-text-primary);padding-top:11px}',
    '.fwpause .fwp-notes-label .tag{font-weight:400;color:var(--color-text-tertiary)}',
    '.fwpause .fwp-notes-label .tag.required{color:var(--color-text-warning);font-weight:500}',
    '.fwpause .fwp-notes-field{position:relative;display:flex;flex-direction:column}',
    '.fwpause .fwp-notes-field textarea{width:100%;min-height:80px;resize:none;font-family:var(--font-sans);font-size:14px;color:var(--color-text-primary);padding:11px 13px 26px;border:1px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);background:var(--color-background-primary);line-height:1.45;outline:none;transition:.15s}',
    '.fwpause .fwp-notes-field textarea:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,.15)}',
    '.fwpause .fwp-notes.needs textarea{border-color:var(--color-amber);background:var(--color-background-warning)}',
    '.fwpause .fwp-notes.needs textarea:focus{box-shadow:0 0 0 3px rgba(239,159,39,.22)}',
    '.fwpause .fwp-notes-count{position:absolute;left:13px;bottom:8px;font-size:14px;font-family:var(--font-mono);color:var(--color-text-tertiary);pointer-events:none}',

    /* ── Resume: recap + outcomes ── */
    /* Three outcomes since 2 Aug 2026 (checkout left) — three columns, so the
       last one is not an orphan on a second row. */
    '.fwpause .fwp-outcomes{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}',
    '.fwpause .fwp-outcome{display:flex;align-items:flex-start;gap:12px;padding:13px 15px;border:1px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);background:var(--color-background-primary);cursor:pointer;text-align:left;font-family:var(--font-sans);transition:all .14s;width:100%}',
    '.fwpause .fwp-outcome:hover{border-color:var(--c);background:var(--color-background-secondary)}',
    '.fwpause .fwp-outcome-icon{width:38px;height:38px;border-radius:var(--border-radius-md);background:var(--color-background-secondary);color:var(--color-text-secondary);display:flex;align-items:center;justify-content:center;flex-shrink:0}',
    '.fwpause .fwp-outcome-icon svg{width:19px;height:19px}',
    '.fwpause .fwp-outcome.selected{border-color:var(--c);background:var(--t);box-shadow:inset 3px 0 0 var(--c)}',
    '.fwpause .fwp-outcome.selected .fwp-outcome-icon{background:var(--c);color:#fff}',
    '.fwpause .fwp-outcome.selected .fwp-outcome-label{color:var(--ct)}',
    '.fwpause .fwp-outcome.resume{--c:var(--color-green);--t:var(--color-background-success);--ct:var(--color-text-success)}',
    '.fwpause .fwp-outcome.reject{--c:var(--color-red);--t:var(--color-background-danger);--ct:var(--color-text-danger)}',
    '.fwpause .fwp-outcome.stay{--c:var(--color-amber);--t:var(--color-background-warning);--ct:var(--color-text-warning)}',
    '.fwpause .fwp-outcome-body{flex:1;min-width:0}',
    '.fwpause .fwp-outcome-label{font-size:15px;font-weight:500;margin-bottom:3px;display:block}',
    '.fwpause .fwp-outcome-desc{font-size:14px;color:var(--color-text-secondary);line-height:1.35;display:block}',

    /* ── Footer ── */
    '.fwpause .fwp-meta{display:flex;align-items:center;gap:24px;flex-wrap:wrap}',
    '.fwpause .fwp-meta-item{display:flex;align-items:center;gap:9px}',
    '.fwpause .fwp-meta-item > svg{width:17px;height:17px;color:var(--color-text-tertiary);flex-shrink:0}',
    '.fwpause .fwp-meta-text{display:flex;flex-direction:column;gap:1px}',
    '.fwpause .fwp-meta-k{font-size:14px;letter-spacing:.08em;text-transform:uppercase;color:var(--color-text-tertiary);font-weight:500;line-height:1.15}',
    '.fwpause .fwp-meta-v{font-family:var(--font-mono);font-size:15px;font-weight:500;color:var(--color-text-primary);font-variant-numeric:tabular-nums;line-height:1.2}',
    '.fwpause .fwp-meta-v.live{color:var(--color-text-success)}',
    '.fwpause.frozen .fwp-meta-v.live{color:var(--color-text-primary)}',
    '.fwpause .fwp-meta-divider{width:1px;height:30px;background:var(--color-border-tertiary)}',

    '.fwpause .fwp-btn{height:46px;padding:0 22px;font-size:14px;font-weight:500;border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);transition:all .14s;display:inline-flex;align-items:center;gap:9px;white-space:nowrap}',
    '.fwpause .fwp-btn:hover{background:var(--color-background-secondary)}',
    '.fwpause .fwp-btn:active{transform:scale(.98)}',
    '.fwpause .fwp-btn svg{width:16px;height:16px;flex-shrink:0}',
    '.fwpause .fwp-btn.primary{background:var(--color-blue);border-color:var(--color-blue);color:#fff;padding:0 26px}',
    '.fwpause .fwp-btn.primary:hover{background:#13497d}',
    '.fwpause .fwp-btn.green{background:var(--color-green);border-color:var(--color-green);color:#fff;padding:0 26px}',
    '.fwpause .fwp-btn.green:hover{background:#168962}',
    '.fwpause .fwp-btn:disabled{opacity:.4;cursor:not-allowed;filter:none;transform:none}'
  ].join("\n");
  document.head.appendChild(styleEl);

  var OUTCOMES = [
    { value: "ResumeRun", cls: "resume", icon: IC.play, label: "Resume the run",
      desc: "The line restarts, the run timer picks up and this pause closes with its duration." },
    { value: "LogWipRejection", cls: "reject", icon: IC.warn, label: "Reject the material",
      desc: "The WIP rejection opens to record a reason and a disposition. The line stays paused until it is." },
    /* "Check out the rod" was the fourth outcome until 2 Aug 2026. It is now the
       command bar's #checkout-btn, enabled while paused — see the header note.
       An outcome answers "how does this pause end?", and a checkout does not end
       it; the other three do. */
    { value: "ContinuePause", cls: "stay", icon: IC.pause, label: "Stay paused",
      desc: "Nothing changes. The line stays down, the pause stays open and the timer keeps counting." }
  ];

  /* ── Markup ─────────────────────────────────────────────────── */
  function tile(r) {
    return '' +
      '<button type="button" class="fwp-tile" data-code="' + r.code + '" role="radio" aria-checked="false">' +
        '<span class="fwp-tile-icon">' + (r.icon || IC.dots) + '</span>' +
        '<span class="fwp-tile-body">' +
          '<span class="t-name">' + r.label + '</span>' +
          (r.sub ? '<span class="t-sub">' + r.sub + '</span>' : '') +
          (r.opensLabel ? '<span class="t-route">' + IC.arrow + r.opensLabel + '</span>' : '') +
        '</span>' +
      '</button>';
  }

  function quickTiles() {
    return QUICK_CODES.map(function (code) {
      var r = findReason(code);
      return tile({ code: r.code, label: r.label, sub: BUCKETS[r.category].label,
                    opensLabel: r.opensLabel, requiresNotes: r.requiresNotes });
    }).join("");
  }

  function bucketOptions() {
    return BUCKET_ORDER.map(function (k) {
      return '<option value="' + k + '">' + BUCKETS[k].label + '</option>';
    }).join("");
  }

  function codeOptions(bucketKey) {
    return BUCKETS[bucketKey].codes.map(function (r) {
      return '<option value="' + r.code + '">' + r.code + ' \u00b7 ' + r.label + '</option>';
    }).join("");
  }

  function chip(id, icon, label, live) {
    return '<span class="fwp-chip' + (live ? " live" : "") + '">' + icon +
             label + ' <span class="cv" id="' + id + '">—</span>' +
           '</span>';
  }

  function outcomeBtn(o) {
    return '' +
      '<button type="button" class="fwp-outcome ' + o.cls + '" data-outcome="' + o.value + '" role="radio" aria-checked="false">' +
        '<span class="fwp-outcome-icon">' + o.icon + '</span>' +
        '<span class="fwp-outcome-body">' +
          '<span class="fwp-outcome-label">' + o.label + '</span>' +
          '<span class="fwp-outcome-desc">' + o.desc + '</span>' +
        '</span>' +
      '</button>';
  }

  function metaItem(icon, label, id, live) {
    return '<div class="fwp-meta-item">' + (icon || "") +
             '<span class="fwp-meta-text">' +
               '<span class="fwp-meta-k">' + label + '</span>' +
               '<span class="fwp-meta-v' + (live ? " live" : "") + '" id="' + id + '">—</span>' +
             '</span>' +
           '</div>';
  }

  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    /* ── Pause ── */
    '<div class="gb-modal-overlay" id="pause-overlay">' +
      '<div class="gb-modal xwide fwpause" role="dialog" aria-modal="true" aria-labelledby="pause-title">' +

        '<div class="gb-modal-head">' +
          '<div class="fwp-head">' +
            '<span class="fwp-head-icon">' + IC.pause + '</span>' +
            '<span class="fwp-head-text">' +
              '<span class="gb-modal-title" id="pause-title">Pause Run</span>' +
              '<span class="fwp-head-sub">Log the reason for pausing the run</span>' +
            '</span>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="pause-overlay" aria-label="Cancel and close">&times;</button>' +
        '</div>' +

        '<div class="fwp-chips">' +
          '<span class="fwp-chip status" id="pause-status"><span class="dot"></span><span id="pause-status-text">FL1 running</span></span>' +
          chip("pause-ro-order", IC.doc, "Order") +
          chip("pause-ro-alpha", IC.tag, "Alpha") +
          chip("pause-ro-footage", IC.ruler, "Footage", true) +
          chip("pause-ro-clock", IC.clock, "Pause Start", true) +
        '</div>' +

        '<div class="gb-modal-body fwp-body">' +
          '<div class="fwp-prompt">' +
            '<h3>Pause reason <span class="req">*</span></h3>' +
            '<p>Select one &middot; the reason is logged against the run, the alpha and the frozen footage</p>' +
          '</div>' +

          '<div class="fwp-grid" id="pause-grid" role="radiogroup" aria-label="Common pause reasons">' +
            quickTiles() +
          '</div>' +

          /* The full 47. The tiles above are a shortcut, not the vocabulary --
             a code reached here and a code reached by tile are the same row. */
          '<div class="fwp-full">' +
            '<div class="fwp-full-head">All delay codes</div>' +
            '<div class="fwp-full-fields">' +
              '<div class="fwp-full-field">' +
                '<label class="fwp-full-label" for="pause-bucket">Bucket</label>' +
                '<select class="fwp-select" id="pause-bucket">' + bucketOptions() + '</select>' +
              '</div>' +
              '<div class="fwp-full-field grow">' +
                '<label class="fwp-full-label" for="pause-code">Delay code</label>' +
                '<select class="fwp-select" id="pause-code">' + codeOptions(BUCKET_ORDER[0]) + '</select>' +
              '</div>' +
            '</div>' +
          '</div>' +

          '<div class="fwp-notes" id="pause-notes-wrap">' +
            '<label class="fwp-notes-label" for="pause-notes">Notes <span class="tag" id="pause-notes-tag">(optional)</span></label>' +
            '<div class="fwp-notes-field">' +
              '<textarea id="pause-notes" maxlength="' + NOTES_MAX + '" placeholder="Add additional details&hellip;"></textarea>' +
              '<span class="fwp-notes-count" id="pause-notes-count">0 / ' + NOTES_MAX + '</span>' +
            '</div>' +
          '</div>' +
        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="fwp-meta">' +
            metaItem(IC.user, "Operator", "pause-operator") +
            '<div class="fwp-meta-divider"></div>' +
            metaItem("", "Footage frozen at", "pause-freeze-ftg", true) +
            '<div class="fwp-meta-divider"></div>' +
            metaItem("", "Pause start", "pause-freeze-clk", true) +
          '</div>' +
          '<div class="modal-foot-actions">' +
            '<button type="button" class="fwp-btn" data-close="pause-overlay">Cancel</button>' +
            '<button type="button" class="fwp-btn primary" id="confirm-pause-btn" disabled>' + IC.pause + 'Confirm Pause</button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>' +

    /* ── Resume ── */
    '<div class="gb-modal-overlay" id="resume-overlay">' +
      '<div class="gb-modal fwpause" style="width:920px" role="dialog" aria-modal="true" aria-labelledby="resume-title">' +

        '<div class="gb-modal-head">' +
          '<div class="fwp-head">' +
            '<span class="fwp-head-icon" style="background:var(--color-background-warning);color:var(--color-amber)">' + IC.play + '</span>' +
            '<span class="fwp-head-text">' +
              '<span class="gb-modal-title" id="resume-title">Resume Run</span>' +
              '<span class="fwp-head-sub">Choose what happens to the line and the material</span>' +
            '</span>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="resume-overlay" aria-label="Close">&times;</button>' +
        '</div>' +

        '<div class="fwp-chips">' +
          '<span class="fwp-chip status paused"><span class="dot"></span><span id="resume-status-text">FL1 paused</span></span>' +
          chip("resume-ro-order", IC.doc, "Order") +
          chip("resume-ro-reason", IC.tag, "Reason") +
          chip("resume-ro-footage", IC.ruler, "Frozen at") +
          chip("resume-ro-elapsed", IC.clock, "Paused for") +
        '</div>' +

        '<div class="gb-modal-body fwp-body">' +
          '<div class="fwp-prompt">' +
            '<h3>What happens now? <span class="req">*</span></h3>' +
            '<p>One outcome closes this pause &middot; staying paused leaves it open</p>' +
          '</div>' +

          '<div class="fwp-outcomes" id="resume-outcomes" role="radiogroup" aria-label="Resume outcome">' +
            OUTCOMES.map(outcomeBtn).join("") +
          '</div>' +

          '<div class="fwp-notes">' +
            '<label class="fwp-notes-label" for="resume-notes">Activity completed <span class="tag">(optional)</span></label>' +
            '<div class="fwp-notes-field">' +
              '<textarea id="resume-notes" maxlength="' + NOTES_MAX + '" placeholder="e.g. Roll gap adjusted, coolant topped up&hellip;"></textarea>' +
              '<span class="fwp-notes-count" id="resume-notes-count">0 / ' + NOTES_MAX + '</span>' +
            '</div>' +
          '</div>' +
        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="fwp-meta">' +
            metaItem(IC.user, "Resumed by", "resume-operator") +
            '<div class="fwp-meta-divider"></div>' +
            metaItem("", "Paused since", "resume-since") +
            '<div class="fwp-meta-divider"></div>' +
            metaItem("", "Time", "resume-clock") +
          '</div>' +
          '<div class="modal-foot-actions">' +
            /* No Cancel: dismissing this dialog and choosing "Stay paused" are the
               same act, and two controls for one outcome invite the wrong one. */
            '<button type="button" class="fwp-btn green" id="confirm-resume-btn" disabled>' + IC.check + 'Confirm</button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap);
  window.FwModal.register("pause-overlay");
  window.FwModal.register("resume-overlay");

  /* ── State ──────────────────────────────────────────────────── */
  var CTX = null;
  var reason = null;              /* { code, category, label, opens } */
  var outcome = null;
  var pauseStartMs = null;
  var pauseFootage = null;
  var pauseStartLabel = null;
  var pauseTimer = null;
  var liveFootage = null;         /* ticks while the pause dialog is open */

  function $(id) { return document.getElementById(id); }
  function p2(n) { return String(n).padStart(2, "0"); }

  function elapsed(ms) {
    var s = Math.floor(ms / 1000);
    var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
    /* h:mm:ss past the hour — shift changeover and awaiting-supervisor pauses run
       long, and a bare mm:ss reported a 90-minute stop as "90:00". */
    return h ? h + ":" + p2(m) + ":" + p2(sec) : p2(m) + ":" + p2(sec);
  }

  function timeNow() {
    var d = new Date(), h = d.getHours(), ampm = h < 12 ? "AM" : "PM";
    return p2(h % 12 || 12) + ":" + p2(d.getMinutes()) + ":" + p2(d.getSeconds()) + " " + ampm;
  }

  function parseFt(txt) {
    var m = String(txt).replace(/,/g, "").match(/\d+/);
    return m ? parseInt(m[0], 10) : null;
  }
  function fmtFt(n) { return n.toLocaleString() + " ft"; }

  /* ── Context ────────────────────────────────────────────────────
     A plain object from the caller is LAYERED OVER the host's own fwRunCtx().
     The Event guard matters: the pause button's onclick is re-pointed at these
     functions directly, so they can be invoked with a MouseEvent. */
  function resolveCtx(ctx) {
    if (!ctx || typeof ctx !== "object" || typeof ctx.preventDefault === "function") ctx = {};
    var host = (typeof window.fwRunCtx === "function") ? window.fwRunCtx() : {};
    function pick(key) { return ctx[key] != null ? ctx[key] : host[key]; }

    var badge = document.querySelector(".line-badge");
    var fromBadge = badge && badge.textContent.match(/FL\d+/);
    var footEl = document.getElementById("footage-val");
    return {
      line: pick("line") || (fromBadge ? fromBadge[0] : "FL1"),
      orderNo: pick("orderNo") || "—",
      alpha: pick("alpha") || "—",
      runId: pick("runId") || null,
      footage: pick("footage") || (footEl ? footEl.textContent.trim() + " ft" : "—"),
      operator: pick("operator") || "Dave M.",
      onPause: ctx.onPause,
      onResume: ctx.onResume
    };
  }

  /* ── One ticker for both dialogs ─────────────────────────────────
     Reads whichever is open. Per-dialog intervals leaked whenever a dialog was
     dismissed with ESC or a backdrop click, neither of which routes through the
     close functions. */
  function tick() {
    var now = timeNow();
    if ($("pause-overlay").classList.contains("open")) {
      /* The line is still running while this dialog is open, so the read-out
         keeps moving. A frozen number here would be a lie, and the operator is
         about to commit to whatever it says. */
      if (liveFootage != null) {
        liveFootage += 2 + Math.round(Math.random() * 3);
        $("pause-ro-footage").textContent = fmtFt(liveFootage);
        $("pause-freeze-ftg").textContent = fmtFt(liveFootage);
      }
      $("pause-ro-clock").textContent = now;
    }
    if ($("resume-overlay").classList.contains("open")) {
      var e = pauseStartMs ? elapsed(Date.now() - pauseStartMs) : "00:00";
      $("resume-ro-elapsed").textContent = e;
      $("resume-clock").textContent = now;
    }
  }
  setInterval(tick, 1000);

  /* ── Notes counters ─────────────────────────────────────────── */
  function wireCounter(taId, countId, onInput) {
    var ta = $(taId), c = $(countId);
    ta.addEventListener("input", function () {
      c.textContent = ta.value.length + " / " + NOTES_MAX;
      if (onInput) onInput();
    });
  }

  /* ── Reason selection ───────────────────────────────────────── */

  function refreshPauseConfirm() {
    var notes = $("pause-notes").value.trim();
    var needsNotes = !!reason && reason.requiresNotes;
    /* CK_RunPauseEvent_NotesOther makes Notes NOT NULL when the category is
       Other, so Confirm cannot enable without them. */
    $("confirm-pause-btn").disabled = !reason || (needsNotes && !notes);
    $("pause-notes-wrap").classList.toggle("needs", needsNotes);
    $("pause-notes-tag").textContent = needsNotes ? "(required)" : "(optional)";
    $("pause-notes-tag").classList.toggle("required", needsNotes);
  }

  function fillCodes(bucketKey) {
    $("pause-code").innerHTML = codeOptions(bucketKey);
  }

  function selectReason(code) {
    reason = findReason(code);
    document.querySelectorAll("#pause-overlay .fwp-tile").forEach(function (b) {
      var on = b.getAttribute("data-code") === code;
      b.classList.toggle("selected", on);
      b.setAttribute("aria-checked", on ? "true" : "false");
    });
    /* Keep the full-list selects in step with the quick tiles. The two controls
       are one choice, not two: a tile and a dropdown that disagree mean the
       operator sees one reason highlighted and a different code is submitted.
       The bucket has to move BEFORE the code list is read, because the code
       options are filtered by bucket. */
    if (reason) {
      $("pause-bucket").value = reason.category;
      fillCodes(reason.category);
      $("pause-code").value = reason.code;
    }
    refreshPauseConfirm();
  }

  document.querySelectorAll("#pause-overlay .fwp-tile").forEach(function (btn) {
    btn.addEventListener("click", function () { selectReason(btn.getAttribute("data-code")); });
  });
  $("pause-bucket").addEventListener("change", function () {
    var b = $("pause-bucket").value;
    fillCodes(b);
    selectReason($("pause-code").value);
  });
  $("pause-code").addEventListener("change", function () {
    selectReason($("pause-code").value);
  });
  wireCounter("pause-notes", "pause-notes-count", refreshPauseConfirm);
  wireCounter("resume-notes", "resume-notes-count");

  /* ── Pause dialog ───────────────────────────────────────────── */
  window.openPauseDialog = function (ctx) {
    CTX = resolveCtx(ctx);

    var modal = document.querySelector("#pause-overlay .gb-modal");
    modal.classList.remove("frozen");

    $("pause-status").className = "fwp-chip status";
    $("pause-status-text").textContent = CTX.line + " running";
    $("pause-ro-order").textContent = CTX.orderNo;
    $("pause-ro-alpha").textContent = CTX.alpha;
    $("pause-ro-footage").textContent = CTX.footage;
    $("pause-ro-clock").textContent = timeNow();
    $("pause-operator").textContent = CTX.operator;
    $("pause-freeze-ftg").textContent = CTX.footage;
    $("pause-freeze-clk").textContent = "— running —";
    $("pause-freeze-clk").classList.add("live");

    liveFootage = parseFt(CTX.footage);

    reason = null;
    document.querySelectorAll("#pause-overlay .fwp-tile").forEach(function (b) {
      b.classList.remove("selected");
      b.setAttribute("aria-checked", "false");
    });
    $("pause-notes").value = "";
    $("pause-notes-count").textContent = "0 / " + NOTES_MAX;
    refreshPauseConfirm();

    window.FwModal.open("pause-overlay");
  };

  window.closePauseDialog = function () { window.FwModal.close("pause-overlay"); };

  $("confirm-pause-btn").addEventListener("click", function () {
    if (!reason) return;
    var notes = $("pause-notes").value.trim();
    var frozen = liveFootage != null ? fmtFt(liveFootage) : CTX.footage;

    /* The payload POST /run/{runId}/pause expects. `Other` keeps its CODE and
       puts the prose in notes. */
    var payload = {
      runId: CTX.runId,
      reasonCode: reason.code,
      reasonCategory: reason.category,
      notes: notes || null,
      footageAtPause: frozen
    };

    pauseStartMs = Date.now();
    pauseFootage = frozen;
    pauseStartLabel = timeNow();

    /* Show the freeze on the dialog before it closes: the operator sees which
       value the pause actually took, not the one that was on screen when they
       reached for the button. */
    var modal = document.querySelector("#pause-overlay .gb-modal");
    modal.classList.add("frozen");
    liveFootage = null;
    $("pause-freeze-clk").textContent = pauseStartLabel;
    $("pause-freeze-clk").classList.remove("live");
    $("pause-status").className = "fwp-chip status paused";
    $("pause-status-text").textContent = CTX.line + " paused";

    window.closePauseDialog();
    applyPausedState();
    if (typeof CTX.onPause === "function") CTX.onPause(payload);

    /* Hand off to the dialog the operator just said they were stopping to use,
       instead of leaving them to find it in the action bar. Opened after the
       pause is applied, so the run is genuinely paused behind it. */
    if (reason.opens === "die-change" && CTX.line !== "FL2" && typeof window.openDieChange === "function") {
      window.openDieChange({ line: CTX.line, orderNo: CTX.orderNo, footage: frozen, operator: CTX.operator });
    } else if (reason.opens === "spc" && typeof window.openSpcCheckpoint === "function") {
      window.openSpcCheckpoint({
        line: CTX.line, orderNo: CTX.orderNo, alpha: CTX.alpha,
        checkpointType: "spot-check", footage: frozen, operator: CTX.operator
      });
    } else if (reason.opens === "roll-adjust" && typeof window.openRollAdjust === "function") {
      /* The roll dialog needs the stand set, which only the host knows — FL2 and
         FL3 do not share one — so its context comes from the host's fwRollCtx()
         with the frozen footage layered on top. */
      var rollCtx = (typeof window.fwRollCtx === "function") ? window.fwRollCtx() : {
        line: CTX.line, orderNo: CTX.orderNo, alpha: CTX.alpha, operator: CTX.operator
      };
      rollCtx.footage = frozen;
      window.openRollAdjust(rollCtx);
    }
  });

  /* ── Host screen: paused presentation ───────────────────────── */
  function applyPausedState() {
    var badge = document.querySelector(".line-badge");
    if (badge) {
      badge.className = "line-badge paused";
      badge.innerHTML = '<span class="dot"></span>' + CTX.line + " paused";
    }
    var tb = $("pause-timer-badge");
    if (tb) {
      tb.classList.add("visible");
      /* The reason travels with the badge. FR-263 wants it visible to the
         supervisor; showing only elapsed time says a line is down without
         saying why, which is the half that matters. */
      var rs = tb.querySelector(".pause-reason");
      if (!rs) {
        rs = document.createElement("span");
        rs.className = "pause-reason";
        tb.appendChild(rs);
      }
      rs.textContent = "· " + reason.label;
    }
    var btn = $("pause-btn");
    if (btn) {
      btn.classList.add("warn");
      btn.innerHTML = IC.play + '<span class="action-btn-label">Resume run</span>';
      btn.onclick = window.openResumeDialog;
    }
    setCheckoutEnabled(true);
    pauseTimer = setInterval(function () {
      var el = $("pause-elapsed");
      if (el) el.textContent = elapsed(Date.now() - pauseStartMs);
    }, 1000);
  }

  function applyRunningState() {
    clearInterval(pauseTimer);
    pauseTimer = null;
    pauseStartMs = null;
    pauseFootage = null;
    reason = null;

    var tb = $("pause-timer-badge");
    if (tb) {
      tb.classList.remove("visible");
      var rs = tb.querySelector(".pause-reason");
      if (rs) rs.textContent = "";
    }
    var badge = document.querySelector(".line-badge");
    if (badge) {
      badge.className = "line-badge";
      badge.innerHTML = '<span class="dot"></span>' + CTX.line + " running";
    }
    var btn = $("pause-btn");
    if (btn) {
      btn.classList.remove("warn");
      btn.innerHTML = IC.pause + '<span class="action-btn-label">Pause run</span>';
      btn.onclick = window.openPauseDialog;
    }
    setCheckoutEnabled(false);
  }

  /* Rod Checkout needs the line stopped, so the command bar's #checkout-btn is
     disabled while running and enabled while paused — the precondition is shown
     rather than enforced after the fact. The button is optional: a screen that
     does not carry one is simply skipped. */
  function setCheckoutEnabled(on) {
    var b = $("checkout-btn");
    if (!b) return;
    b.disabled = !on;
    b.title = on
      ? "Check out the rod — the line is paused"
      : "Pause the run first — checking out a rod needs the line stopped";
  }

  /* The footage frozen at the pause, or null while running. A host building
     checkout context reads this rather than the live counter, which has moved on
     since the line stopped. */
  window.fwPauseFootage = function () { return pauseFootage; };

  /* ── Resume dialog ──────────────────────────────────────────── */
  document.querySelectorAll("#resume-outcomes .fwp-outcome").forEach(function (btn) {
    btn.addEventListener("click", function () {
      outcome = btn.getAttribute("data-outcome");
      document.querySelectorAll("#resume-outcomes .fwp-outcome").forEach(function (b) {
        var on = b === btn;
        b.classList.toggle("selected", on);
        b.setAttribute("aria-checked", on ? "true" : "false");
      });
      $("confirm-resume-btn").disabled = false;
    });
  });

  window.openResumeDialog = function () {
    if (!CTX) CTX = resolveCtx(null);

    $("resume-status-text").textContent = CTX.line + " paused";
    $("resume-ro-order").textContent = CTX.orderNo;
    $("resume-ro-reason").textContent = reason ? reason.label : "—";
    $("resume-ro-footage").textContent = pauseFootage || CTX.footage;
    $("resume-ro-elapsed").textContent = pauseStartMs ? elapsed(Date.now() - pauseStartMs) : "00:00";
    $("resume-operator").textContent = CTX.operator;
    $("resume-since").textContent = pauseStartLabel || "—";
    $("resume-clock").textContent = timeNow();

    outcome = null;
    document.querySelectorAll("#resume-outcomes .fwp-outcome").forEach(function (b) {
      b.classList.remove("selected");
      b.setAttribute("aria-checked", "false");
    });
    $("resume-notes").value = "";
    $("resume-notes-count").textContent = "0 / " + NOTES_MAX;
    $("confirm-resume-btn").disabled = true;

    window.FwModal.open("resume-overlay");
  };

  window.closeResumeDialog = function () { window.FwModal.close("resume-overlay"); };

  $("confirm-resume-btn").addEventListener("click", function () {
    if (!outcome) return;
    var payload = {
      runId: CTX.runId,
      outcome: outcome,
      activityCompleted: $("resume-notes").value.trim() || null
    };
    var frozen = pauseFootage || CTX.footage;
    window.closeResumeDialog();
    if (typeof CTX.onResume === "function") CTX.onResume(payload);

    if (outcome === "ResumeRun") {
      applyRunningState();

    } else if (outcome === "LogWipRejection") {
      /* The line stays paused behind the dialog and the timer keeps counting —
         the pause closes only once the material has been dispositioned. */
      if (typeof window.openWipRejection === "function") {
        window.openWipRejection({
          materialAlpha: CTX.alpha,
          orderNo: CTX.orderNo,
          stage: CTX.line + " · active run (paused)",
          footagePosition: frozen,
          runId: CTX.runId,
          operator: CTX.operator,
          trigger: "pause-resume"
        });
      }

    }
    /* ContinuePause: dialog closes, line stays down, timer keeps running — which
       is also how the operator reaches Rod Checkout, now that it is the command
       bar's #checkout-btn rather than a fourth outcome here. */
  });

})();
