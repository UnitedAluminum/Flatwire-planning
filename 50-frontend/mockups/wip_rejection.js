/* =============================================================================
   wip_rejection.js — WIP rejection dialog (was dashboard_8_wip_rejection.html)
   =============================================================================
   Converted from a standalone screen to a popup on 1 Aug 2026.

   WHY THIS ONE MATTERED MOST: rejection is reached from five different places —
   mid-run from the active-run monitors, from a failed staging inspection at the
   pre-check-in station, from an out-of-spec SPC checkpoint, from the resume
   dialog, and from the More Options tile. As a page it could only ever describe
   ONE of them, so its material banner was hard-coded to "R00042 at 8,220 ft" and
   the pre-check-in entry path (Q23, client 30 Jul 2026) could not be represented
   at all. As a dialog the caller passes its own context and the banner follows.

   Include AFTER fw-modal.js, before </body>:

       <script src="fw-modal.js"></script>
       <script src="wip_rejection.js"></script>

   Open it with a context object (every key optional):

       openWipRejection({
         materialAlpha:   'R00042',
         orderNo:         'FW-00421',
         stage:           'FL1 · active run',
         footagePosition: '8,220 ft',       // null when the material never ran
         runId:           'RUN-0118',       // null on the pre-check-in path
         operator:        'Dave M.',
         trigger:         'mid-run',        // mid-run | pre-checkin | spc-fail | pause-resume
         payoff:          2,                // pre-checkin only — the bay being released
         measurement:     { name, measured, targetMin, targetMax, deviation },
         reworkStages:    ['FL1 · draw bench 2 (re-draw)', …],
         onSubmit:        function (result) { … }
       });

   `result` is { materialAlpha, reason, group, specificReason, observation,
   disposition, reworkStage, releasesBay }.

   THE PRE-CHECK-IN PATH, in full (Q23 item 3 / gap G21):
     · stage reads "<line> · pre-check-in" and there is NO footage position —
       the rod never ran, so runId and footagePosition are both null.
     · submitting the rejection is what RELEASES THE BAY: RodStaging.Status ->
       'Unstaged' with UnstageKind = 'WipRejection' and WipRejectionId set, plus
       a PayoffStateChanged broadcast. Nothing else clears a Blocked bay, so the
       dialog says so on screen and reports releasesBay:true to the caller.
     · disposition defaults to Suspend (HOLD), the client's stated outcome.

   Requires flat-wire-shopfloor.styles.css.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openWipRejection) return;    /* guard against double-inclusion */

  /* ── Rejection reason vocabulary ─────────────────────────────────
     THE CLIENT'S LIST, VERBATIM. 72 reasons from "Reason Codes.xlsx"
     (Tim O'Brien, 1 Sep 2026), which closes action A5 of the 23 Jul call.
     Seeded in FlatWireDB.WipRejectionReason; WipRejection.RejectionReason
     carries the WREJ### code and FK_WipRejection_Reason enforces it.

     THE WORDING IS THE CLIENT'S AND IS NOT TIDIED -- "wavy ege" is their typo,
     the capitalisation is theirs, and "Bundle" / "Spool" are the operator's
     words for the rod and the material in process. Rewriting any of it breaks
     the match with the seed and with what the operator reads on the old screens.

     THE GROUPING IS OURS. The client's sheet is a flat list with no groups at
     all, so every assignment below is [PROPOSED] and mirrors
     WipRejectionReason.RejectionGroup, where IsProposedGroup = 1 records the
     same thing. If a group is reassigned, change it in BOTH places or the
     composite FK rejects the row.

     NOT SEEDED, DELIBERATELY: the 24 reasons the client marked as not applying
     -- mostly side-scrap and coil-form defects that do not exist on wire
     (Excess Side Scrap, Coil Set, Crossbow, Earing). Do not add them back.

     STILL MISSING: a THREADING reason. The same mail's answer 4 requires
     threading to be recorded as a WIPREJ/scrap and the client's list has no
     code for it. Owed back -- do not invent one. */
  var REASONS_BY_GROUP = {
    "Dimensional": [
      "Underproduced / Under Weight", "Wrong Incoming Diameter",
      "Bad Shape (wavy ege or buckle)", "Camber", "Collapsed ID", "Gauge Varies",
      "Off Weight", "Telescoped", "Telescoped, Oscillated Coil", "Twist",
      "Width Varies", "Wire Brk Due To Shape", "Wrong Gauge", "Wrong ID",
      "Wrong OD", "Wrong Width"
    ],
    "Surface quality": [
      "Burr, Rolled Edges", "Chatter", "Crossbreaks", "Cutter Mark",
      "Damaged Edges", "Dents", "Herringbone", "ID Damage", "Live Scratches",
      "OD Damage", "Oil Stain, Smut", "Oxidation, Magnesium Stain", "Roll Mark",
      "Rolled-in Scratches", "Rough or Cracked Edges", "Traffic Marks",
      "Water Stain", "Water Stain in Warranty / Vendor Issue"
    ],
    "Weld quality": [
      "Broken Welds", "Too Many Welds"
    ],
    "Material": [
      "Wrong Bundle / Spool", "Wrong Temper", "Grain", "Sliver, Holes, Inclusion",
      "Wire Brk Due To Edge Cracks",
      "Wire Brk Due To Holes, Laminations, Blisters, Inclusions", "Wrong Alloy"
    ],
    "Process": [
      "Cobble", "Tangle", "Wire Brk / Pull Apart", "Wire Brk Due To Tangle",
      "Broken Bands", "Damaged Packing", "Forced Recalculation (No Reason Assigned)",
      "Heads and Tails", "Incorrect Buildup / Plan Not Followed", "Loaded Wrong",
      "Loose Bands", "Loosewound Coil", "Machine / IT Problem", "No Appointment",
      "No Bands", "No Packing", "No Paperwork",
      "Order Cancelation / For acct. Purposes", "Other", "OVERPRODUCED ORDER",
      "Plan Required Head Scrap", "Plan Required Tail Scrap",
      "Planned Excess Tail Scrap", "SCRAP BALANCE", "Shipping Delay",
      "Wet At Receiving", "Wire Brk Due To Machine Problem", "Wrong Banding",
      "Wrong Skid Size"
    ]
  };
  var GROUPS = ["Dimensional", "Surface quality", "Weld quality", "Material", "Process"];

  /* The shortcut chips. Seven of the 72, chosen because they are what the
     operator reaches for from a measurement or an inspection failure -- the
     full list stays one dropdown away. Every string here MUST also appear in
     REASONS_BY_GROUP or selectReason() cannot sync the two controls. */
  var QUICK_REASONS = [
    "Gauge Varies", "Width Varies", "Rough or Cracked Edges",
    "Oxidation, Magnesium Stain", "Broken Welds", "Wire Brk / Pull Apart", "Other"
  ];

  function groupOf(reason) {
    for (var g in REASONS_BY_GROUP) {
      if (REASONS_BY_GROUP[g].indexOf(reason) !== -1) return g;
    }
    return GROUPS[0];
  }
  var DEFAULT_REWORK_STAGES = [
    'FL1 · draw bench 2 (re-draw)',
    'FL1 · FM1 (re-roll)',
    'FL2 · FM2 S2 (re-finish)'
  ];

  /* ── Styles ─────────────────────────────────────────────────────
     Scoped under .fwwip. The standalone screen defined bare .section, .field,
     .btn and .measurement-context — every one of which collides with either the
     active-run monitors or the SPC dialog this can be chained from. */
  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-wip-rejection", "");
  styleEl.textContent = [
    '.fwwip .fwwip-body{display:flex;flex-direction:column;gap:12px}',

    /* Material context banner */
    '.fwwip .fwwip-banner{padding:13px 18px;display:flex;justify-content:space-between;align-items:center;gap:22px;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);flex-wrap:wrap}',
    '.fwwip .fwwip-facts{display:flex;gap:24px;align-items:center;flex-wrap:wrap}',
    '.fwwip .fwwip-fact{display:flex;flex-direction:column;gap:3px}',
    '.fwwip .fwwip-fact-label{font-size:14px;color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:0.4px}',
    '.fwwip .fwwip-fact-value{font-size:17px;font-weight:500;font-family:var(--font-mono);color:var(--color-text-primary)}',
    '.fwwip .fwwip-fact-value.plain{font-family:var(--font-sans)}',
    '.fwwip .fwwip-divider{width:1px;height:30px;background:var(--color-border-tertiary)}',

    '.fwwip .fwwip-context{display:flex;gap:12px;align-items:center;padding:10px 14px;background:var(--color-background-danger);color:var(--color-text-danger);border-radius:var(--border-radius-md);font-size:14px;max-width:460px}',
    '.fwwip .fwwip-context.staging{background:var(--color-background-warning);color:var(--color-text-warning)}',
    '.fwwip .fwwip-context-icon{width:26px;height:26px;border-radius:50%;background:var(--color-red);color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0}',
    '.fwwip .fwwip-context.staging .fwwip-context-icon{background:var(--color-amber)}',
    '.fwwip .fwwip-context-icon svg{width:12px;height:12px}',
    '.fwwip .fwwip-context-body{flex:1;line-height:1.4}',
    '.fwwip .fwwip-context-body strong{font-weight:500}',
    '.fwwip .fwwip-context .badge{display:inline-block;padding:1px 7px;background:rgba(255,255,255,0.5);border-radius:4px;font-family:var(--font-mono);font-size:14px;font-weight:500}',

    /* Bay release notice (pre-check-in path) */
    '.fwwip .fwwip-bay{display:none;align-items:center;gap:12px;padding:11px 14px;background:var(--color-background-info);color:var(--color-text-info);border-radius:var(--border-radius-md);font-size:14px;line-height:1.4}',
    '.fwwip .fwwip-bay.visible{display:flex}',
    '.fwwip .fwwip-bay svg{width:18px;height:18px;flex-shrink:0}',
    '.fwwip .fwwip-bay strong{font-weight:500}',

    /* Two-column body */
    '.fwwip .fwwip-cols{display:grid;grid-template-columns:1.5fr 1fr;gap:12px;align-items:stretch}',
    '.fwwip .fwwip-section{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:16px 18px;display:flex;flex-direction:column}',
    '.fwwip .fwwip-section-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;gap:12px}',
    '.fwwip .fwwip-section-title{font-size:15px;font-weight:500}',
    '.fwwip .fwwip-section-hint{font-size:14px;color:var(--color-text-tertiary)}',
    '.fwwip .fwwip-required::after{content:" *";color:var(--color-red)}',

    /* Quick reasons */
    '.fwwip .fwwip-quick{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px}',
    '.fwwip .fwwip-quick-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 14px;background:var(--color-background-secondary);border:1px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);font-size:14px;font-weight:500;cursor:pointer;color:var(--color-text-primary);font-family:var(--font-sans);transition:all 0.15s}',
    '.fwwip .fwwip-quick-btn:hover{background:var(--color-background-tertiary)}',
    '.fwwip .fwwip-quick-btn.selected{background:var(--color-red);border-color:var(--color-red);color:#fff}',
    '.fwwip .fwwip-quick-btn .chip-dot{width:6px;height:6px;border-radius:50%;background:var(--color-text-tertiary)}',
    '.fwwip .fwwip-quick-btn.selected .chip-dot{background:rgba(255,255,255,0.85)}',

    '.fwwip .fwwip-fields{display:grid;grid-template-columns:1fr 1.4fr;gap:12px;margin-bottom:12px}',
    '.fwwip .fwwip-field{display:flex;flex-direction:column;gap:6px}',
    '.fwwip .fwwip-field-label{font-size:14px;color:var(--color-text-secondary)}',
    '.fwwip .fwwip-select{height:44px;padding:0 32px 0 14px;font-size:14px;font-family:var(--font-sans);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none;cursor:pointer;appearance:none;background-image:linear-gradient(45deg,transparent 50%,var(--color-text-secondary) 50%),linear-gradient(135deg,var(--color-text-secondary) 50%,transparent 50%);background-position:calc(100% - 16px) 50%,calc(100% - 11px) 50%;background-size:5px 5px,5px 5px;background-repeat:no-repeat}',
    '.fwwip .fwwip-select:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,0.18)}',

    /* Measured details */
    '.fwwip .fwwip-measured{display:none;padding:13px 15px;background:var(--color-background-secondary);border-radius:var(--border-radius-md);border-left:3px solid var(--color-red);margin-bottom:12px}',
    '.fwwip .fwwip-measured.visible{display:block}',
    '.fwwip .fwwip-measured-title{font-size:14px;color:var(--color-text-secondary);margin-bottom:10px;font-weight:500}',
    '.fwwip .fwwip-measured-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}',
    '.fwwip .fwwip-md{display:flex;flex-direction:column;gap:3px}',
    '.fwwip .fwwip-md-label{font-size:14px;color:var(--color-text-tertiary)}',
    '.fwwip .fwwip-md-value{font-size:16px;font-weight:500;font-family:var(--font-mono)}',
    '.fwwip .fwwip-md-value.danger{color:var(--color-text-danger)}',

    '.fwwip .fwwip-textarea{width:100%;padding:12px 14px;font-size:14px;font-family:var(--font-sans);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);resize:none;min-height:80px;outline:none;flex:1}',
    '.fwwip .fwwip-textarea:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,0.18)}',

    /* Disposition cards */
    '.fwwip .fwwip-disp-list{display:flex;flex-direction:column;gap:10px;flex:1}',
    '.fwwip .fwwip-disp{display:flex;gap:13px;padding:13px 15px;border:2px solid var(--color-border-secondary);border-radius:var(--border-radius-md);cursor:pointer;background:var(--color-background-primary);user-select:none;transition:all 0.15s;align-items:center;text-align:left;font-family:var(--font-sans);width:100%}',
    '.fwwip .fwwip-disp:hover{background:var(--color-background-secondary)}',
    '.fwwip .fwwip-disp.selected.suspend{border-color:var(--color-amber);background:var(--color-background-warning)}',
    '.fwwip .fwwip-disp.selected.scrap{border-color:var(--color-red);background:var(--color-background-danger)}',
    '.fwwip .fwwip-disp.selected.rework{border-color:var(--color-blue);background:var(--color-background-info)}',
    '.fwwip .fwwip-disp-dot{width:20px;height:20px;border-radius:50%;border:2px solid var(--color-border-primary);flex-shrink:0}',
    '.fwwip .fwwip-disp.selected .fwwip-disp-dot{border-width:6px}',
    '.fwwip .fwwip-disp.selected.suspend .fwwip-disp-dot{border-color:var(--color-amber)}',
    '.fwwip .fwwip-disp.selected.scrap .fwwip-disp-dot{border-color:var(--color-red)}',
    '.fwwip .fwwip-disp.selected.rework .fwwip-disp-dot{border-color:var(--color-blue)}',
    '.fwwip .fwwip-disp-icon{width:42px;height:42px;border-radius:var(--border-radius-md);background:var(--color-background-secondary);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:var(--color-text-secondary)}',
    '.fwwip .fwwip-disp.selected.suspend .fwwip-disp-icon{background:var(--color-amber);color:#fff}',
    '.fwwip .fwwip-disp.selected.scrap .fwwip-disp-icon{background:var(--color-red);color:#fff}',
    '.fwwip .fwwip-disp.selected.rework .fwwip-disp-icon{background:var(--color-blue);color:#fff}',
    '.fwwip .fwwip-disp-icon svg{width:21px;height:21px}',
    '.fwwip .fwwip-disp-body{flex:1;min-width:0}',
    '.fwwip .fwwip-disp-name{font-size:15px;font-weight:500;margin-bottom:2px}',
    '.fwwip .fwwip-disp-desc{font-size:14px;color:var(--color-text-secondary);line-height:1.35}',

    '.fwwip .fwwip-rework{display:none;margin-top:2px;padding:12px 14px;background:var(--color-background-info);border-radius:var(--border-radius-md);border-left:3px solid var(--color-blue)}',
    '.fwwip .fwwip-rework.visible{display:block}',
    '.fwwip .fwwip-rework-label{font-size:14px;color:var(--color-text-info);margin-bottom:6px;font-weight:500}',

    '.fwwip .fwwip-reviewer{margin-top:auto;padding:11px 14px;background:var(--color-background-warning);color:var(--color-text-warning);border-radius:var(--border-radius-md);font-size:14px;display:flex;align-items:center;gap:10px}',
    '.fwwip .fwwip-reviewer-icon{width:22px;height:22px;border-radius:50%;background:var(--color-amber);color:#fff;display:flex;align-items:center;justify-content:center;flex-shrink:0}',
    '.fwwip .fwwip-reviewer-icon svg{width:11px;height:11px}',
    '.fwwip .fwwip-reviewer-body{flex:1;line-height:1.4}',
    '.fwwip .fwwip-reviewer-body strong{font-weight:500}',

    /* Footer buttons */
    '.fwwip .fwwip-btn{height:48px;padding:0 22px;font-size:14px;font-weight:500;border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);transition:all 0.15s;display:inline-flex;align-items:center;gap:10px}',
    '.fwwip .fwwip-btn:hover{background:var(--color-background-secondary)}',
    '.fwwip .fwwip-btn:active{transform:scale(0.98)}',
    '.fwwip .fwwip-btn svg{width:16px;height:16px}',
    '.fwwip .fwwip-btn.primary{background:var(--color-red);border-color:var(--color-red);color:#fff;padding:0 28px}',
    '.fwwip .fwwip-btn.primary:hover{background:#bc4921}'
  ].join("\n");
  document.head.appendChild(styleEl);

  var IC_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
  var IC_WARN_LG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
  var IC_USER = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>';
  var IC_UNLOCK = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>';

  var DISPOSITIONS = [
    { id: "suspend", name: "Suspend &middot; hold for review",
      desc: "Status set to HOLD &middot; supervisor notified &middot; stays in WIP held queue until disposition decided",
      icon: '<rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/>' },
    { id: "rework", name: "Rework &middot; return to earlier stage",
      desc: "Material flagged for rework &middot; you pick the return stage",
      icon: '<path d="M3 12a9 9 0 0 1 15-6.7l3-3"/><path d="M21 3v6h-6"/><path d="M21 12a9 9 0 0 1-15 6.7l-3 3"/><path d="M3 21v-6h6"/>' },
    { id: "scrap", name: "Scrap &middot; send to scrap disposition",
      desc: "Alpha status set to SCRAP &middot; routed to scrap module for weight-out &amp; accounting",
      icon: '<polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>' }
  ];

  /* ── Markup ─────────────────────────────────────────────────── */
  function dispCard(d) {
    return '' +
      '<button type="button" class="fwwip-disp ' + d.id + '" data-disp="' + d.id + '">' +
        '<span class="fwwip-disp-dot"></span>' +
        '<span class="fwwip-disp-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + d.icon + '</svg></span>' +
        '<span class="fwwip-disp-body">' +
          '<span class="fwwip-disp-name" style="display:block">' + d.name + '</span>' +
          '<span class="fwwip-disp-desc" style="display:block">' + d.desc + '</span>' +
        '</span>' +
      '</button>';
  }

  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    '<div class="gb-modal-overlay" id="wip-overlay">' +
      '<div class="gb-modal xwide fwwip" role="dialog" aria-modal="true" aria-labelledby="wip-title">' +

        '<div class="gb-modal-head">' +
          '<div>' +
            '<div class="gb-modal-title" id="wip-title">Log rejection</div>' +
            '<div class="gb-modal-ctx">' +
              '<span class="ctx-chip danger">' + IC_WARN + ' WIP rejection in progress</span>' +
              '<span class="ctx-chip">Material <span class="mono" id="wip-alpha-chip">—</span></span>' +
              '<span class="ctx-chip" id="wip-stage-chip">—</span>' +
            '</div>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="wip-overlay" aria-label="Close">&times;</button>' +
        '</div>' +

        '<div class="gb-modal-body fwwip-body">' +

          '<div class="fwwip-banner">' +
            '<div class="fwwip-facts" id="wip-facts"></div>' +
            '<div class="fwwip-context" id="wip-context">' +
              '<span class="fwwip-context-icon">' + IC_WARN + '</span>' +
              '<span class="fwwip-context-body" id="wip-context-body"></span>' +
            '</div>' +
          '</div>' +

          '<div class="fwwip-bay" id="wip-bay">' + IC_UNLOCK +
            '<span id="wip-bay-body"></span>' +
          '</div>' +

          '<div class="fwwip-cols">' +

            '<div class="fwwip-section">' +
              '<div class="fwwip-section-head">' +
                '<span class="fwwip-section-title fwwip-required">Rejection reason</span>' +
                '<span class="fwwip-section-hint">Start with a common reason or select from full list</span>' +
              '</div>' +
              '<div class="fwwip-quick" id="wip-quick">' +
                QUICK_REASONS.map(function (r, i) {
                  return '<button type="button" class="fwwip-quick-btn' + (i === 0 ? " selected" : "") + '" data-reason="' + r + '">' +
                         '<span class="chip-dot"></span>' + r + '</button>';
                }).join("") +
              '</div>' +
              '<div class="fwwip-fields">' +
                '<div class="fwwip-field">' +
                  '<label class="fwwip-field-label fwwip-required" for="wip-group">Group</label>' +
                  '<select class="fwwip-select" id="wip-group">' +
                    GROUPS.map(function (g) { return '<option>' + g + '</option>'; }).join("") +
                  '</select>' +
                '</div>' +
                '<div class="fwwip-field">' +
                  '<label class="fwwip-field-label fwwip-required" for="wip-specific">Specific reason</label>' +
                  '<select class="fwwip-select" id="wip-specific">' +
                    /* Filled by fillSpecific() from the selected group -- 72 reasons in
                       one flat list is unusable at arm's length on a shopfloor panel. */
                    REASONS_BY_GROUP[GROUPS[0]].map(function (s) { return '<option>' + s + '</option>'; }).join("") +
                  '</select>' +
                '</div>' +
              '</div>' +
              '<div class="fwwip-measured" id="wip-measured">' +
                '<div class="fwwip-measured-title" id="wip-measured-title">Measured details</div>' +
                '<div class="fwwip-measured-grid">' +
                  '<div class="fwwip-md"><span class="fwwip-md-label" id="wip-md-1-label">Measured</span><span class="fwwip-md-value danger" id="wip-md-1">—</span></div>' +
                  '<div class="fwwip-md"><span class="fwwip-md-label">Target range</span><span class="fwwip-md-value" id="wip-md-2">—</span></div>' +
                  '<div class="fwwip-md"><span class="fwwip-md-label">Deviation</span><span class="fwwip-md-value danger" id="wip-md-3">—</span></div>' +
                '</div>' +
              '</div>' +
              '<div class="fwwip-field" style="flex:1">' +
                '<label class="fwwip-field-label" for="wip-observation">Observation (optional but recommended)</label>' +
                '<textarea class="fwwip-textarea" id="wip-observation" placeholder="Describe what was observed, when it started, any suspected cause, corrective action taken&hellip;"></textarea>' +
              '</div>' +
            '</div>' +

            '<div class="fwwip-section">' +
              '<div class="fwwip-section-head">' +
                '<span class="fwwip-section-title fwwip-required">Disposition</span>' +
                '<span class="fwwip-section-hint">Choose what happens to the material</span>' +
              '</div>' +
              '<div class="fwwip-disp-list">' +
                dispCard(DISPOSITIONS[0]) +
                dispCard(DISPOSITIONS[1]) +
                '<div class="fwwip-rework" id="wip-rework">' +
                  '<div class="fwwip-rework-label">Return to stage</div>' +
                  '<select class="fwwip-select" id="wip-rework-stage"></select>' +
                '</div>' +
                dispCard(DISPOSITIONS[2]) +
                '<div class="fwwip-reviewer">' +
                  '<span class="fwwip-reviewer-icon">' + IC_USER + '</span>' +
                  '<span class="fwwip-reviewer-body" id="wip-reviewer">' +
                    '<strong>Supervisor review required</strong> &middot; Marcus T. (day shift) will be notified' +
                  '</span>' +
                '</div>' +
              '</div>' +
            '</div>' +

          '</div>' +
        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="gb-modal-stamp">' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Operator</span><span class="gb-modal-stamp-value" id="wip-operator">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Timestamp</span><span class="gb-modal-stamp-value mono" id="wip-stamp-time">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Rejection ID</span><span class="gb-modal-stamp-value mono" id="wip-rej-id">—</span></div>' +
          '</div>' +
          '<div class="modal-foot-actions">' +
            '<button type="button" class="fwwip-btn" data-close="wip-overlay">Cancel</button>' +
            '<button type="button" class="fwwip-btn primary" id="wip-submit">' + IC_WARN_LG + 'Submit rejection</button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap);

  /* ── State ──────────────────────────────────────────────────── */
  var CTX = null;
  var currentReason = QUICK_REASONS[0];
  var currentDisposition = "suspend";
  var clockTimer = null;

  function $(id) { return document.getElementById(id); }
  function pad(n) { return String(n).padStart(2, "0"); }

  var MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  function stamp() {
    var now = new Date();
    var h = now.getHours(), ampm = h < 12 ? "AM" : "PM", h12 = h % 12 || 12;
    return pad(h12) + ":" + pad(now.getMinutes()) + ":" + pad(now.getSeconds()) + " " + ampm +
           " · " + MONTHS[now.getMonth()] + " " + now.getDate() + ", " + now.getFullYear();
  }
  function timeOnly() {
    var now = new Date();
    var h = now.getHours(), ampm = h < 12 ? "AM" : "PM", h12 = h % 12 || 12;
    return pad(h12) + ":" + pad(now.getMinutes()) + " " + ampm;
  }

  /* ── Banner ─────────────────────────────────────────────────── */
  function fact(label, value, plain) {
    return '<div class="fwwip-fact">' +
             '<span class="fwwip-fact-label">' + label + '</span>' +
             '<span class="fwwip-fact-value' + (plain ? " plain" : "") + '">' + value + '</span>' +
           '</div>';
  }

  function renderFacts() {
    var parts = [fact("Material", CTX.materialAlpha), fact("Stage", CTX.stage, true)];
    if (CTX.orderNo) parts.push(fact("Order", CTX.orderNo));
    /* No footage fact on the pre-check-in path — the rod never ran, so there is
       no position to report and an empty "0 ft" would read as a real reading. */
    if (CTX.footagePosition) parts.push(fact("Rejection at", CTX.footagePosition));
    parts.push(fact("Time", timeOnly()));
    $("wip-facts").innerHTML = parts.join('<div class="fwwip-divider"></div>');
  }

  function renderContext() {
    var box = $("wip-context");
    var body = $("wip-context-body");
    var m = CTX.measurement;

    box.classList.toggle("staging", CTX.trigger === "pre-checkin");

    if (m) {
      body.innerHTML = (CTX.trigger === "spc-fail"
          ? "SPC checkpoint failed &middot; "
          : "Deviation detected &middot; ") +
        m.name + " reading <strong>" + m.measured + "</strong> vs target " +
        '<span class="badge">' + m.targetMin + "&ndash;" + m.targetMax + "</span>";
    } else if (CTX.trigger === "pre-checkin") {
      body.innerHTML = "Rod failed its visual inspection at payoff" +
        (CTX.payoff ? " " + CTX.payoff : "") + " &middot; the bay is <strong>Blocked</strong> until this rejection is submitted";
    } else if (CTX.trigger === "pause-resume") {
      body.innerHTML = "Raised from the resume dialog &middot; the run stays <strong>paused</strong> while this is recorded";
    } else {
      body.innerHTML = "Material rejected mid-run &middot; record the reason and disposition";
    }
  }

  function renderBayNotice() {
    var el = $("wip-bay");
    var isStaging = CTX.trigger === "pre-checkin";
    el.classList.toggle("visible", isStaging);
    if (!isStaging) return;
    $("wip-bay-body").innerHTML =
      "<strong>Submitting releases the payoff bay.</strong> " +
      "Staging status becomes <strong>Unstaged</strong> (unstage kind <strong>WIP rejection</strong>) and the bay is " +
      "broadcast as free. Nothing else clears a blocked bay &mdash; this rejection is the record of why.";
  }

  function renderMeasured() {
    var m = CTX.measurement;
    var box = $("wip-measured");
    box.classList.toggle("visible", !!m);
    if (!m) return;
    $("wip-measured-title").textContent = "Measured details — " + m.name;
    $("wip-md-1-label").textContent = "Measured " + m.name.toLowerCase();
    $("wip-md-1").textContent = m.measured;
    $("wip-md-2").innerHTML = m.targetMin + " &ndash; " + m.targetMax;
    $("wip-md-3").textContent = m.deviation || "—";
  }

  function fillSpecific(group, select) {
    var list = REASONS_BY_GROUP[group] || [];
    select.innerHTML = list.map(function (s) {
      return '<option>' + s + '</option>';
    }).join("");
  }

  function selectReason(reason) {
    currentReason = reason;
    document.querySelectorAll("#wip-quick .fwwip-quick-btn").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-reason") === reason);
    });
    /* Keep the full-list selects in step with the shortcut chip — the two were
       independent on the standalone screen, so a chip choice and a dropdown
       choice could disagree and only one of them got submitted.
       Since 2 Sep 2026 the specific list is FILTERED BY GROUP, so the group has
       to move first or the reason will not be among the options to select. */
    var group = groupOf(reason);
    $("wip-group").value = group;
    var specific = $("wip-specific");
    fillSpecific(group, specific);
    for (var i = 0; i < specific.options.length; i++) {
      if (specific.options[i].text === reason) { specific.selectedIndex = i; break; }
    }
  }

  function selectDisposition(id) {
    currentDisposition = id;
    document.querySelectorAll(".fwwip-disp").forEach(function (c) {
      c.classList.toggle("selected", c.getAttribute("data-disp") === id);
    });
    $("wip-rework").classList.toggle("visible", id === "rework");
  }

  document.querySelectorAll("#wip-quick .fwwip-quick-btn").forEach(function (btn) {
    btn.addEventListener("click", function () { selectReason(btn.getAttribute("data-reason")); });
  });
  document.querySelectorAll(".fwwip-disp").forEach(function (card) {
    card.addEventListener("click", function () { selectDisposition(card.getAttribute("data-disp")); });
  });

  /* Changing the group refills the specific list -- the 72 client reasons are
     filtered by group, not shown flat. currentReason is re-pointed at the first
     reason of the new group so the chip highlight, the two selects and what
     actually gets submitted cannot disagree; leaving it on the old reason would
     submit a (reason, group) pair the composite FK rejects. */
  $("wip-group").addEventListener("change", function () {
    var group = $("wip-group").value;
    fillSpecific(group, $("wip-specific"));
    currentReason = $("wip-specific").value;
    document.querySelectorAll("#wip-quick .fwwip-quick-btn").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-reason") === currentReason);
    });
  });
  $("wip-specific").addEventListener("change", function () {
    currentReason = $("wip-specific").value;
    document.querySelectorAll("#wip-quick .fwwip-quick-btn").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-reason") === currentReason);
    });
  });

  $("wip-submit").addEventListener("click", function () {
    var result = {
      materialAlpha: CTX.materialAlpha,
      runId: CTX.runId,
      footagePosition: CTX.footagePosition,
      reason: currentReason,
      group: $("wip-group").value,
      specificReason: $("wip-specific").value,
      observation: $("wip-observation").value.trim(),
      disposition: currentDisposition,
      reworkStage: currentDisposition === "rework" ? $("wip-rework-stage").value : null,
      /* The pre-check-in path is the only one where submitting also frees a
         physical bay; the caller needs to know to redraw the payoff. */
      releasesBay: CTX.trigger === "pre-checkin",
      payoff: CTX.payoff || null
    };
    close();
    if (typeof CTX.onSubmit === "function") CTX.onSubmit(result);
  });

  /* ── Open / close ───────────────────────────────────────────── */
  function close() {
    if (clockTimer) { clearInterval(clockTimer); clockTimer = null; }
    window.FwModal.close("wip-overlay");
  }

  var rejSeq = 418;

  window.openWipRejection = function (ctx) {
    ctx = ctx || {};
    var trigger = ctx.trigger || "mid-run";
    CTX = {
      materialAlpha: ctx.materialAlpha || "R00042",
      orderNo: ctx.orderNo || "FW-00421",
      stage: ctx.stage || "FL1 · active run",
      footagePosition: trigger === "pre-checkin" ? null : (ctx.footagePosition || null),
      runId: trigger === "pre-checkin" ? null : (ctx.runId || null),
      operator: ctx.operator || "Dave M.",
      trigger: trigger,
      payoff: ctx.payoff || null,
      measurement: ctx.measurement || null,
      reworkStages: ctx.reworkStages || DEFAULT_REWORK_STAGES,
      onSubmit: ctx.onSubmit
    };

    $("wip-alpha-chip").textContent = CTX.materialAlpha;
    $("wip-stage-chip").textContent = CTX.stage;
    $("wip-operator").textContent = CTX.operator;
    $("wip-rej-id").textContent = "REJ-" + new Date().getFullYear() + "-" + pad(rejSeq++);

    $("wip-rework-stage").innerHTML = CTX.reworkStages.map(function (s) {
      return "<option>" + s + "</option>";
    }).join("");

    renderFacts();
    renderContext();
    renderBayNotice();
    renderMeasured();

    selectReason(CTX.measurement && /gauge/i.test(CTX.measurement.name) ? "Gauge Varies"
               : CTX.measurement && /width/i.test(CTX.measurement.name) ? "Width Varies"
               : trigger === "pre-checkin" ? "Oxidation, Magnesium Stain"
               : QUICK_REASONS[0]);
    /* Suspend (HOLD) is the default everywhere: on the pre-check-in path it is
       the client's stated outcome, and mid-run nothing should be scrapped
       without a supervisor seeing it first. */
    selectDisposition("suspend");
    $("wip-observation").value = "";

    $("wip-stamp-time").textContent = stamp();
    clockTimer = setInterval(function () { $("wip-stamp-time").textContent = stamp(); }, 1000);

    window.FwModal.register("wip-overlay");
    window.FwModal.open("wip-overlay");
  };

  window.closeWipRejection = close;
})();
