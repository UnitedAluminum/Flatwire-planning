/* =============================================================================
   roll_adjust.js - Roll adjust dialog (was dashboard_11_roll_adjust.html)
   =============================================================================
   Converted from a standalone screen to a popup on 2 Aug 2026. It is the last of
   the in-run event screens to make the move; die change, SPC checkpoint, WIP
   rejection and rod checkout went on 1 Aug 2026, for the same reason:

     recording a mid-run event should not mean navigating away from the run you
     are recording it against.

   Roll adjust had a second problem the others did not. As a page it hard-coded
   FL2's spool SP-00031, FL2's stand list and FL2's measurements - but it is the
   shared roll-adjust screen for FL2 AND FL3, which have different stand sets. A
   page cannot know which line opened it. A dialog is told.

   That is why `rolls` is caller-supplied rather than baked in. Everything the
   table shows comes from the context object.

   Include AFTER fw-modal.js, before </body>:

       <script src="fw-modal.js"></script>
       <script src="roll_adjust.js"></script>

   Open it with a context object (every key optional - defaults are FL2's):

       openRollAdjust({
         line:         'FL2',
         orderNo:      'FW-00421',
         alpha:        'SP-00031',        // spool on FL2, rod on FL3
         alphaLabel:   'Spool',           // what to call that alpha
         sourceRods:   'R00041, R00042',
         runId:        'RUN-0119',
         passSchedule: 'PS-1100-FL2-007',
         footage:      '13,060 ft',       // read live at click time, not page load
         targets:      { gauge: 0.110, gaugeTol: 0.002, gaugeDp: 4,
                         width: 0.625, widthTol: 0.005, widthDp: 3 },
         rolls:        [ { name: 'S1 (8")', scheduled: 0.0180, current: 0.0180 },
                         { name: 'S2 (6")', scheduled: 0.0162, current: 0.0162 },
                         { name: 'S3 (6")', scheduled: 0.0160, current: 0.0161, final: true } ],
         measurements: { gauge: 0.1135, width: 0.627 },
         history:      [ { time, user, roll, from, to, reason } ],
         operator:     'Sam Patel',
         onConfirm:    function (result) { ... }
       });

   `result` is { runId, line, alpha, adjustments: [{component, from, to, delta}],
   reason, notes, measurements, footage, operator }.

   Note the two vocabularies the screen deliberately keeps apart: roll GAP (the
   machine setting being changed, ~0.016") and product GAUGE (what the strip
   measures, ~0.110"). They are different numbers and the dialog now opens over a
   monitor showing the gauge trace, so conflating them would be visible.

   On Apply the backend writes a `RollOverride` (`OVR-####`) AND an `SpcCheckpoint`
   of type `RollAdjustTrigger` - see FlatWire_MasterSpecification.md section 4.8.
   (`RollAdjustTrigger` is missing from the API's four-value CheckpointType enum;
   that is REVIEW Tier 1 #2, not a bug in this file.) It is a RUN-LEVEL override:
   it never edits the pass schedule record.

   Two rules the page stated but never enforced, now implemented:
     - all-zero deltas relabel the action "No changes - return to run" and commit
       nothing (master spec section 4.8 event table);
     - a reason is required before Apply, so Apply stays disabled until one is
       picked.

   All CSS is scoped under .fwra and every id is prefixed ra-. The screen defined
   .header, .footer, .section, .btn, .delta, .main-row and .mono at global scope,
   which collide with every active-run monitor this now opens over. Its own
   @keyframes pulse is dropped - the shared stylesheet already carries one. The
   inline onclick navigations ("Back to run", Cancel) are gone: the run is still
   there behind the dialog.

   Requires flat-wire-shopfloor.styles.css.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openRollAdjust) return;      /* guard against double-inclusion */

  /* -- Styles --------------------------------------------------- */
  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-roll-adjust", "");
  styleEl.textContent = [
    '.gb-modal.fwra{width:1180px}',
    /* The shared chrome is tuned for short dialogs; this one carries a table, two
       measurements, a reason picker and a history list, so head and foot give up a
       few pixels to keep the whole thing inside 1024px at 1:1 on the panel rather
       than being scaled down through the 14px floor. */
    '.fwra .gb-modal-head{padding:13px 20px}',
    '.fwra .gb-modal-foot{padding:11px 20px}',
    '.fwra .fwra-body{display:flex;flex-direction:column;gap:10px}',

    /* Context banner - was the full-width .context-strip. nowrap, because
       allowed to wrap it becomes two rows and pushes the dialog past the panel. */
    '.fwra .context-strip{display:flex;align-items:center;flex-wrap:nowrap;gap:0;padding:8px 16px;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg)}',
    '.fwra .cs-cell{display:flex;flex-direction:column;gap:3px;justify-content:center;padding:0 18px;border-right:0.5px solid var(--color-border-tertiary);min-width:0}',
    '.fwra .cs-cell:first-child{padding-left:0}',
    '.fwra .cs-cell:last-child{border-right:none;padding-right:0}',
    '.fwra .cs-label{font-size:14px;color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:0.4px;white-space:nowrap}',
    '.fwra .cs-value{font-size:15px;font-weight:500;font-family:var(--font-mono);line-height:1.2;white-space:nowrap}',
    '.fwra .cs-sub{font-size:14px;color:var(--color-text-secondary);white-space:nowrap}',
    '.fwra .override-badge{display:inline-flex;align-items:center;gap:6px;padding:4px 10px;background:var(--color-background-warning);color:var(--color-text-warning);border-radius:var(--border-radius-md);font-size:14px;font-weight:500;width:fit-content;white-space:nowrap}',
    '.fwra .override-badge svg{width:11px;height:11px;flex-shrink:0}',

    /* Main row. The right column is the taller of the two — the reason chips wrap
       — so it gets more width than the roll table strictly needs, which buys a
       row of chips back and keeps the dialog inside 1024px at 1:1. */
    '.fwra .main-row{display:grid;grid-template-columns:1.45fr 1fr;gap:10px;flex:0 0 auto;min-height:0}',
    '.fwra .section{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);display:flex;flex-direction:column;overflow:hidden;padding:12px 14px}',
    '.fwra .section-header{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-bottom:9px;flex-shrink:0}',
    '.fwra .section-title{font-size:14px;font-weight:500}',
    '.fwra .section-hint{font-size:14px;color:var(--color-text-tertiary)}',

    /* Roll gap table */
    '.fwra .roll-table-wrap{flex:0 0 auto;border:1px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);overflow:hidden}',
    '.fwra .roll-table{width:100%;border-collapse:collapse;font-size:14px}',
    '.fwra .roll-table thead{background:var(--color-background-secondary)}',
    '.fwra .roll-table th{text-align:left;padding:8px 14px;font-weight:500;color:var(--color-text-secondary);font-size:14px;text-transform:uppercase;letter-spacing:0.3px}',
    '.fwra .roll-table th.right{text-align:right}',
    '.fwra .roll-table tbody tr{border-top:0.5px solid var(--color-border-tertiary)}',
    '.fwra .roll-table tbody tr:not(.bypass-row):hover{background:var(--color-background-secondary)}',
    '.fwra .roll-table tbody tr.has-change{background:var(--color-background-warning)}',
    '.fwra .roll-table tbody tr.has-change:hover{background:#f3dfc0}',
    '.fwra .roll-table td{padding:10px 14px;vertical-align:middle}',
    '.fwra .roll-name{display:flex;align-items:center;gap:7px;font-weight:500}',
    '.fwra .line-tag{display:inline-block;padding:1px 6px;background:var(--color-background-info);color:var(--color-text-info);border-radius:4px;font-size:14px;font-weight:500;font-family:var(--font-sans)}',
    '.fwra .final-tag{display:inline-block;padding:1px 6px;background:var(--color-background-tertiary);color:var(--color-text-secondary);border-radius:4px;font-size:14px;font-weight:500}',
    '.fwra .gap-ref{font-family:var(--font-mono);font-size:14px;color:var(--color-text-secondary)}',
    '.fwra .gap-input{width:108px;height:36px;padding:0 10px;font-size:14px;font-family:var(--font-mono);font-weight:500;color:var(--color-text-primary);background:var(--color-background-primary);border:1.5px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none;text-align:center;transition:border-color 0.15s,box-shadow 0.15s,background 0.15s}',
    '.fwra .gap-input:focus{border-color:var(--color-blue);box-shadow:0 0 0 2px rgba(24,95,165,0.18)}',
    '.fwra .gap-input.changed{border-color:var(--color-amber);background:rgba(239,159,39,0.08)}',
    '.fwra .gap-input.unchanged{background:var(--color-background-secondary);border-color:var(--color-border-tertiary);color:var(--color-text-secondary)}',
    '.fwra .delta-cell{text-align:right}',
    '.fwra .delta{font-family:var(--font-mono);font-size:14px;font-weight:600;display:inline-block;min-width:76px;text-align:right;color:var(--color-text-tertiary)}',
    '.fwra .delta.neg{color:var(--color-green)}',
    '.fwra .delta.pos{color:var(--color-red)}',
    '.fwra .bypass-row td{opacity:0.35}',
    '.fwra .bypass-label{font-size:14px;font-style:italic;color:var(--color-text-tertiary)}',

    /* Right column */
    '.fwra .right-col{display:flex;flex-direction:column;gap:10px;min-height:0}',
    '.fwra .meas-section{flex:1.4;min-height:0}',
    '.fwra .reason-section{flex:1;min-height:0}',

    /* Measurements */
    '.fwra .meas-list{display:flex;flex-direction:column;gap:7px;flex:1;min-height:0}',
    '.fwra .meas-item{padding:9px 12px;border-radius:var(--border-radius-md);display:flex;flex-direction:column;gap:4px;flex:1;min-height:0}',
    '.fwra .meas-item.oos{background:var(--color-background-warning);border:1px solid rgba(239,159,39,0.3)}',
    '.fwra .meas-item.ok{background:var(--color-background-success);border:1px solid rgba(29,158,117,0.25)}',
    '.fwra .meas-head{display:flex;justify-content:space-between;align-items:center;gap:8px;flex-shrink:0}',
    '.fwra .meas-name{font-size:14px;font-weight:500}',
    '.fwra .meas-badge{display:inline-flex;align-items:center;padding:2px 8px;border-radius:4px;font-size:14px;font-weight:600;letter-spacing:0.3px;color:#fff;white-space:nowrap}',
    '.fwra .meas-badge.oos{background:var(--color-amber)}',
    '.fwra .meas-badge.ok{background:var(--color-green)}',
    '.fwra .meas-vals{display:grid;grid-template-columns:1fr 1fr 1fr;gap:4px;flex-shrink:0}',
    '.fwra .meas-val-cell{display:flex;flex-direction:column;gap:1px}',
    '.fwra .meas-val-label{font-size:14px;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:0.3px}',
    '.fwra .meas-num{font-family:var(--font-mono);font-size:17px;font-weight:600;line-height:1.2}',
    '.fwra .meas-num.oos{color:var(--color-text-warning)}',
    '.fwra .meas-num.ok{color:var(--color-text-success)}',
    '.fwra .meas-num.ref{font-size:14px;color:var(--color-text-secondary);font-weight:500}',
    '.fwra .meas-deviation{font-size:14px;font-family:var(--font-mono);font-weight:500;flex-shrink:0}',
    '.fwra .meas-deviation.oos{color:var(--color-text-warning)}',
    '.fwra .meas-deviation.ok{color:var(--color-text-success)}',
    '.fwra .meas-bar-wrap{position:relative;height:8px;background:var(--color-background-tertiary);border-radius:4px;flex-shrink:0;overflow:visible}',
    '.fwra .meas-bar-zone{position:absolute;height:100%;border-radius:4px;background:var(--color-green);opacity:0.4}',
    '.fwra .meas-bar-marker{position:absolute;width:3px;height:14px;top:-3px;border-radius:2px;transform:translateX(-50%)}',
    '.fwra .meas-bar-marker.oos{background:var(--color-amber)}',
    '.fwra .meas-bar-marker.ok{background:var(--color-green)}',

    /* Reason */
    '.fwra .reason-chips{display:flex;flex-wrap:wrap;gap:7px;margin-bottom:10px;flex-shrink:0}',
    '.fwra .reason-chip{padding:5px 12px;font-size:14px;font-weight:500;border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-secondary);border-radius:20px;cursor:pointer;font-family:var(--font-sans);transition:all 0.15s;white-space:nowrap;line-height:1.4}',
    '.fwra .reason-chip:hover{background:var(--color-background-secondary);color:var(--color-text-primary)}',
    '.fwra .reason-chip.selected{background:var(--color-blue);border-color:var(--color-blue);color:#fff}',
    '.fwra .notes-label{font-size:14px;color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:0.4px;margin-bottom:5px;flex-shrink:0}',
    '.fwra .notes-input{width:100%;flex:1;min-height:46px;padding:8px 12px;font-size:14px;font-family:var(--font-sans);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none;resize:none;line-height:1.4}',
    '.fwra .notes-input:focus{border-color:var(--color-blue);box-shadow:0 0 0 2px rgba(24,95,165,0.18)}',
    '.fwra .notes-input::placeholder{color:var(--color-text-tertiary)}',

    /* History */
    '.fwra .history-section{flex-shrink:0;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:10px 14px;display:flex;flex-direction:column}',
    '.fwra .history-header{display:flex;justify-content:space-between;align-items:baseline;gap:12px;margin-bottom:8px;flex-shrink:0}',
    '.fwra .history-title{font-size:14px;font-weight:500}',
    '.fwra .history-meta{display:flex;gap:14px;font-size:14px;color:var(--color-text-tertiary);align-items:center}',
    '.fwra .history-meta a{color:var(--color-text-info);text-decoration:none;font-weight:500}',
    '.fwra .history-list{display:flex;flex-direction:column;gap:5px}',
    '.fwra .history-entry{display:grid;grid-template-columns:120px 130px 140px 1fr 150px;gap:10px;padding:5px 12px;background:var(--color-background-secondary);border-radius:var(--border-radius-md);font-size:14px;align-items:center;flex-shrink:0}',
    '.fwra .history-time{font-family:var(--font-mono);color:var(--color-text-secondary);font-size:14px}',
    '.fwra .history-user{font-weight:500}',
    '.fwra .history-roll{color:var(--color-text-secondary);font-size:14px}',
    '.fwra .history-change{font-family:var(--font-mono);font-size:14px}',
    '.fwra .history-change .from{color:var(--color-text-tertiary);text-decoration:line-through}',
    '.fwra .history-change .arrow{color:var(--color-text-tertiary);margin:0 3px}',
    '.fwra .history-change .to{font-weight:500}',
    '.fwra .history-reason{font-size:14px;padding:2px 8px;background:var(--color-background-primary);color:var(--color-text-secondary);border-radius:4px;text-align:center;font-weight:500;white-space:nowrap}',

    /* Footer action. .btn / .btn-primary come from the shared stylesheet - the
       page's own copies are dropped rather than re-scoped. */
    '.fwra .gb-modal-actions{display:flex;gap:10px;align-items:center}',
    '.fwra #ra-apply{display:inline-flex;align-items:center;gap:9px}',
    '.fwra #ra-apply svg{width:16px;height:16px}',
    '.fwra #ra-apply.no-changes{background:var(--color-background-primary);border-color:var(--color-border-secondary);color:var(--color-text-secondary)}',
    '.fwra #ra-apply.no-changes:hover{background:var(--color-background-secondary)}',
    '.fwra #ra-apply.no-changes svg{display:none}'
  ].join("\n");
  document.head.appendChild(styleEl);

  var IC_CHECK = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
  var IC_ROLL  = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="6" cy="12" r="3"/><circle cx="18" cy="12" r="3"/><line x1="9" y1="12" x2="15" y2="12"/></svg>';

  var REASONS = [
    "Gauge drift (high)", "Gauge drift (low)", "Width drift", "SPC flag",
    "Roll wear", "Post-weld correction", "Operator discretion"
  ];

  /* -- Markup ---------------------------------------------------- */
  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    '<div class="gb-modal-overlay" id="ra-overlay">' +
      '<div class="gb-modal xwide fwra" role="dialog" aria-modal="true" aria-labelledby="ra-title">' +

        '<div class="gb-modal-head">' +
          '<div>' +
            '<div class="gb-modal-title" id="ra-title">Roll adjust</div>' +
            '<div class="gb-modal-ctx">' +
              '<span class="ctx-chip success" id="ra-line-chip"><span class="dot"></span>FL2 running</span>' +
              '<span class="ctx-chip">Order <span class="mono" id="ra-order">&mdash;</span></span>' +
              '<span class="ctx-chip" id="ra-alpha-chip">Spool <span class="mono" id="ra-alpha">&mdash;</span></span>' +
              '<span class="ctx-chip">Footage <span class="mono" id="ra-footage-chip">&mdash;</span></span>' +
            '</div>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="ra-overlay" aria-label="Close">&times;</button>' +
        '</div>' +

        '<div class="gb-modal-body fwra-body">' +

          '<div class="context-strip">' +
            '<div class="cs-cell">' +
              '<span class="cs-label" id="ra-cs-alpha-label">Spool / Alpha</span>' +
              '<span class="cs-value" id="ra-cs-alpha">&mdash;</span>' +
              '<span class="cs-sub" id="ra-cs-source">&nbsp;</span>' +
            '</div>' +
            '<div class="cs-cell">' +
              '<span class="cs-label">Pass Schedule</span>' +
              '<span class="cs-value" id="ra-cs-schedule">&mdash;</span>' +
            '</div>' +
            '<div class="cs-cell">' +
              '<span class="cs-label">Footage at adjust</span>' +
              '<span class="cs-value" id="ra-cs-footage">&mdash;</span>' +
            '</div>' +
            '<div class="cs-cell">' +
              '<span class="cs-label">Output targets</span>' +
              '<span class="cs-value" id="ra-cs-target-gauge">&mdash;</span>' +
              '<span class="cs-sub" id="ra-cs-target-sub">&mdash;</span>' +
            '</div>' +
            '<div class="cs-cell">' +
              '<span class="cs-label">Override type</span>' +
              '<span class="override-badge">' + IC_ROLL + 'Run-level &middot; pass schedule unchanged</span>' +
            '</div>' +
          '</div>' +

          '<div class="main-row">' +

            '<div class="section">' +
              '<div class="section-header">' +
                '<span class="section-title">Roll gap adjustments</span>' +
                '<span class="section-hint">Edit New gap only &middot; scheduled values are read-only</span>' +
              '</div>' +
              '<div class="roll-table-wrap">' +
                '<table class="roll-table">' +
                  '<thead><tr>' +
                    '<th style="width:28%;">Component</th>' +
                    '<th style="width:17%;">Scheduled gap</th>' +
                    '<th style="width:17%;">Current gap</th>' +
                    '<th style="width:20%;">New gap</th>' +
                    '<th style="width:18%;" class="right">Delta</th>' +
                  '</tr></thead>' +
                  '<tbody id="ra-roll-body"></tbody>' +
                '</table>' +
              '</div>' +
            '</div>' +

            '<div class="right-col">' +

              '<div class="section meas-section">' +
                '<div class="section-header">' +
                  '<span class="section-title" id="ra-meas-title">Measurements</span>' +
                  '<span class="section-hint">Values that triggered this adjustment</span>' +
                '</div>' +
                '<div class="meas-list" id="ra-meas-list"></div>' +
              '</div>' +

              '<div class="section reason-section">' +
                '<div class="section-header">' +
                  '<span class="section-title">Reason for adjustment</span>' +
                  '<span class="section-hint">Required before applying</span>' +
                '</div>' +
                '<div class="reason-chips" id="ra-reason-chips"></div>' +
                '<div class="notes-label">Notes (optional)</div>' +
                '<textarea class="notes-input" placeholder="Add detail if needed&hellip;" id="ra-notes"></textarea>' +
              '</div>' +

            '</div>' +
          '</div>' +

          '<div class="history-section">' +
            '<div class="history-header">' +
              '<div style="display:flex;gap:12px;align-items:baseline;">' +
                '<span class="history-title">Recent roll adjustments</span>' +
                '<span style="font-size:14px;color:var(--color-text-tertiary);" id="ra-history-sub">&mdash;</span>' +
              '</div>' +
              '<div class="history-meta">' +
                '<span id="ra-history-count">&mdash;</span>' +
                '<a href="#">View all &rarr;</a>' +
              '</div>' +
            '</div>' +
            '<div class="history-list" id="ra-history-list"></div>' +
          '</div>' +

        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="gb-modal-stamp">' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Operator</span><span class="gb-modal-stamp-value" id="ra-operator">&mdash;</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Timestamp</span><span class="gb-modal-stamp-value mono" id="ra-stamp-time">&mdash;</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Changes</span><span class="gb-modal-stamp-value mono" id="ra-change-summary">No changes</span></div>' +
          '</div>' +
          '<div class="gb-modal-actions">' +
            '<button type="button" class="btn" data-close="ra-overlay">Cancel</button>' +
            '<button type="button" class="btn btn-primary" id="ra-apply">' + IC_CHECK + '<span id="ra-apply-label">Apply adjustment</span></button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap.firstChild);
  window.FwModal.register("ra-overlay");

  /* -- State ----------------------------------------------------- */
  var CTX = {};
  var reason = null;
  var stampTimer = null;

  function $(id) { return document.getElementById(id); }
  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) {
    return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
  }); }
  function pad(n) { return String(n).padStart(2, "0"); }
  function inches(v, dp) { return Number(v).toFixed(dp) + "″"; }
  function parseGap(str) { return parseFloat(String(str).replace(/[^0-9.]/g, "")) || 0; }

  /* Gap decimals follow the value's own precision: roll gaps are quoted to 4dp
     across the suite, but a caller working in thousandths should not be forced
     into a trailing zero. */
  function gapDp(rolls) {
    var dp = 3;
    rolls.forEach(function (r) {
      ["scheduled", "current"].forEach(function (k) {
        if (r[k] == null) return;
        var s = String(r[k]).split(".")[1];
        if (s && s.length > dp) dp = Math.min(s.length, 5);
      });
    });
    return dp;
  }

  /* -- Rendering ------------------------------------------------- */
  function renderRolls() {
    var dp = gapDp(CTX.rolls);
    CTX._gapDp = dp;
    $("ra-roll-body").innerHTML = CTX.rolls.map(function (r, i) {
      if (r.bypassed) {
        return '<tr class="bypass-row">' +
          '<td><span class="roll-name"><span class="line-tag">' + esc(CTX.line) + '</span>' + esc(r.name) + '</span></td>' +
          '<td><span class="bypass-label">Bypassed</span></td><td>&mdash;</td><td>&mdash;</td>' +
          '<td class="delta-cell">&mdash;</td></tr>';
      }
      return '<tr>' +
        '<td><span class="roll-name"><span class="line-tag">' + esc(CTX.line) + '</span>' + esc(r.name) +
          (r.final ? '<span class="final-tag">final</span>' : '') + '</span></td>' +
        '<td><span class="gap-ref">' + inches(r.scheduled, dp) + '</span></td>' +
        '<td><span class="gap-ref">' + inches(r.current, dp) + '</span></td>' +
        '<td><input class="gap-input unchanged" type="text" id="ra-gap-' + i + '" ' +
             'value=\'' + Number(r.current).toFixed(dp) + '"\' data-idx="' + i + '"></td>' +
        '<td class="delta-cell"><span class="delta" id="ra-delta-' + i + '">' + Number(0).toFixed(dp) + '″</span></td>' +
        '</tr>';
    }).join("");
  }

  /* Range bar maps the tolerance band onto a display window of target +/- 2.5x
     tolerance, so the in-spec zone is always the middle 40% and a marker outside
     it reads as out of spec at a glance regardless of the units involved. */
  function measBlock(name, measured, target, tol, dp) {
    var lo = target - tol, hi = target + tol;
    var ok = measured >= lo - 1e-12 && measured <= hi + 1e-12;
    var span = tol * 5, dispMin = target - tol * 2.5;
    var marker = Math.max(2, Math.min(98, ((measured - dispMin) / span) * 100));
    var dev = measured - target;
    var devText = ok
      ? (dev >= 0 ? "+" : "−") + Math.abs(dev).toFixed(dp) + "″ within range  (max " + inches(hi, dp) + ")"
      : (measured > hi
          ? "+" + (measured - hi).toFixed(dp) + "″ above maximum  (max " + inches(hi, dp) + ")"
          : "−" + (lo - measured).toFixed(dp) + "″ below minimum  (min " + inches(lo, dp) + ")");
    var cls = ok ? "ok" : "oos";
    var badge = ok ? "&#x2713;&nbsp;IN SPEC" : ("OUT OF SPEC " + (measured > hi ? "&uarr;" : "&darr;"));
    return '<div class="meas-item ' + cls + '">' +
      '<div class="meas-head"><span class="meas-name">' + esc(name) + '</span>' +
        '<span class="meas-badge ' + cls + '">' + badge + '</span></div>' +
      '<div class="meas-vals">' +
        '<div class="meas-val-cell"><span class="meas-val-label">Measured</span><span class="meas-num ' + cls + '">' + inches(measured, dp) + '</span></div>' +
        '<div class="meas-val-cell"><span class="meas-val-label">Target</span><span class="meas-num ref">' + inches(target, dp) + '</span></div>' +
        '<div class="meas-val-cell"><span class="meas-val-label">Tolerance</span><span class="meas-num ref">&plusmn;&thinsp;' + inches(tol, dp) + '</span></div>' +
      '</div>' +
      '<div class="meas-deviation ' + cls + '">' + devText + '</div>' +
      '<div class="meas-bar-wrap">' +
        '<div class="meas-bar-zone" style="left:30%;width:40%;"></div>' +
        '<div class="meas-bar-marker ' + cls + '" style="left:' + marker.toFixed(1) + '%;"></div>' +
      '</div></div>';
  }

  function renderMeasurements() {
    var t = CTX.targets, m = CTX.measurements;
    $("ra-meas-title").textContent = "Measurements at " + CTX.footage;
    $("ra-meas-list").innerHTML =
      measBlock("Output gauge", m.gauge, t.gauge, t.gaugeTol, t.gaugeDp) +
      measBlock("Output width", m.width, t.width, t.widthTol, t.widthDp);
  }

  function renderReasons() {
    $("ra-reason-chips").innerHTML = REASONS.map(function (r) {
      return '<button type="button" class="reason-chip" data-reason="' + esc(r) + '">' + esc(r) + '</button>';
    }).join("");
  }

  function renderHistory() {
    var h = CTX.history || [];
    $("ra-history-sub").textContent = CTX.passSchedule + " · all operators";
    $("ra-history-count").textContent = "Showing last " + h.length;
    $("ra-history-list").innerHTML = h.map(function (e) {
      return '<div class="history-entry">' +
        '<span class="history-time">' + esc(e.time) + '</span>' +
        '<span class="history-user">' + esc(e.user) + '</span>' +
        '<span class="history-roll">' + esc(e.roll) + '</span>' +
        '<span class="history-change"><span class="from">' + esc(e.from) + '</span>' +
          '<span class="arrow">&rarr;</span><span class="to">' + esc(e.to) + '</span></span>' +
        '<span class="history-reason">' + esc(e.reason) + '</span></div>';
    }).join("");
  }

  /* -- Deltas + the two enforced rules ---------------------------- */
  function collectChanges() {
    var dp = CTX._gapDp, out = [];
    CTX.rolls.forEach(function (r, i) {
      if (r.bypassed) return;
      var inp = $("ra-gap-" + i);
      if (!inp) return;
      var to = parseGap(inp.value), delta = to - r.current;
      if (Math.abs(delta) > 5e-6) {
        out.push({ component: r.name, from: +r.current.toFixed(dp), to: +to.toFixed(dp), delta: +delta.toFixed(dp) });
      }
    });
    return out;
  }

  function updateDelta(inp) {
    var dp = CTX._gapDp;
    var r = CTX.rolls[Number(inp.getAttribute("data-idx"))];
    var delta = parseGap(inp.value) - r.current;
    var el = $("ra-delta-" + inp.getAttribute("data-idx"));
    var abs = Math.abs(delta);
    var changed = abs > 5e-6;
    if (el) {
      el.textContent = (changed ? (delta > 0 ? "+" : "−") : "") + abs.toFixed(dp) + "″";
      el.className = "delta " + (changed ? (delta < 0 ? "neg" : "pos") : "");
    }
    inp.classList.toggle("changed", changed);
    inp.classList.toggle("unchanged", !changed);
    var row = inp.closest("tr");
    if (row) row.classList.toggle("has-change", changed);
    refreshAction();
  }

  /* Two rules the page stated but never enforced: an all-zero adjustment is not
     an adjustment, and a reason is mandatory. */
  function refreshAction() {
    var changes = collectChanges();
    var apply = $("ra-apply");
    var label = $("ra-apply-label");
    var dp = CTX._gapDp;

    $("ra-change-summary").textContent = changes.length
      ? changes.map(function (c) {
          return c.component + " " + (c.delta >= 0 ? "+" : "−") + Math.abs(c.delta).toFixed(dp) + "″";
        }).join(", ")
      : "No changes";

    if (!changes.length) {
      apply.classList.add("no-changes");
      apply.disabled = false;                 /* it is a valid way to leave */
      label.textContent = "No changes — return to run";
      apply.title = "Nothing to write — closes without recording an override";
    } else {
      apply.classList.remove("no-changes");
      apply.disabled = !reason;
      label.textContent = "Apply adjustment";
      apply.title = reason ? "" : "Select a reason first";
    }
  }

  function selectReason(chip) {
    document.querySelectorAll("#ra-reason-chips .reason-chip").forEach(function (c) {
      c.classList.remove("selected");
    });
    chip.classList.add("selected");
    reason = chip.getAttribute("data-reason");
    refreshAction();
  }

  /* -- Listeners (delegated - the page used global inline handlers) ---- */
  $("ra-reason-chips").addEventListener("click", function (e) {
    var chip = e.target.closest(".reason-chip");
    if (chip) selectReason(chip);
  });

  $("ra-roll-body").addEventListener("input", function (e) {
    var inp = e.target.closest(".gap-input");
    if (inp) updateDelta(inp);
  });

  $("ra-apply").addEventListener("click", function () {
    var changes = collectChanges();
    if (changes.length && !reason) return;
    var result = {
      runId: CTX.runId, line: CTX.line, alpha: CTX.alpha,
      adjustments: changes, reason: changes.length ? reason : null,
      notes: $("ra-notes").value.trim(),
      measurements: CTX.measurements, footage: CTX.footage, operator: CTX.operator
    };
    window.FwModal.close("ra-overlay");
    if (typeof CTX.onConfirm === "function") CTX.onConfirm(result);
  });

  /* The stamp is the commit time, so it ticks while the dialog is open and stops
     when it closes - FwModal has no close hook, so the timer checks the overlay. */
  function tickStamp() {
    var overlay = $("ra-overlay");
    if (!overlay.classList.contains("open") && stampTimer) {
      clearInterval(stampTimer);
      stampTimer = null;
      return;
    }
    var now = new Date();
    var h = now.getHours(), ampm = h < 12 ? "AM" : "PM", h12 = h % 12 || 12;
    var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    $("ra-stamp-time").textContent = pad(h12) + ":" + pad(now.getMinutes()) + ":" + pad(now.getSeconds()) +
      " " + ampm + " · " + months[now.getMonth()] + " " + now.getDate() + ", " + now.getFullYear();
  }

  /* -- Open ------------------------------------------------------ */
  window.openRollAdjust = function (ctx) {
    ctx = ctx || {};
    CTX = {
      line:         ctx.line         || "FL2",
      orderNo:      ctx.orderNo      || "FW-00421",
      alpha:        ctx.alpha        || "SP-00031",
      alphaLabel:   ctx.alphaLabel   || "Spool",
      sourceRods:   ctx.sourceRods   || "",
      runId:        ctx.runId        || "RUN-0119",
      passSchedule: ctx.passSchedule || "PS-1100-FL2-007",
      footage:      ctx.footage      || "13,060 ft",
      operator:     ctx.operator     || "Sam Patel",
      onConfirm:    ctx.onConfirm,
      targets: Object.assign(
        { gauge: 0.110, gaugeTol: 0.002, gaugeDp: 4, width: 0.625, widthTol: 0.005, widthDp: 3 },
        ctx.targets || {}),
      measurements: Object.assign({ gauge: 0.1135, width: 0.627 }, ctx.measurements || {}),
      // FM2 has THREE stands: S1 carries the 8" roller, S2 and S3 carry 6".
      // S3 is final and non-bypassable. Corrected 4 Aug 2026 (client) — this
      // fallback previously listed four rolls with a separate bypassed 8" entry,
      // and it reaches every screen that calls openRollAdjust without ctx.rolls.
      rolls: ctx.rolls || [
        { name: 'S1 (8")', scheduled: 0.0180, current: 0.0180 },
        { name: 'S2 (6")', scheduled: 0.0162, current: 0.0162 },
        { name: 'S3 (6")', scheduled: 0.0160, current: 0.0161, final: true }
      ],
      history: ctx.history || [
        { time: "Aug 01  06:15", user: "Dave M.", roll: 'S3 (6")', from: '0.0160″', to: '0.0161″', reason: "Roll warm-up" },
        { time: "Jul 31  14:30", user: "Bob S.",  roll: 'S3 (6")', from: '0.0162″', to: '0.0160″', reason: "SPC flag" },
        { time: "Jul 31  09:45", user: "Dave M.", roll: 'S1 (8")', from: '0.0184″', to: '0.0180″', reason: "Gauge drift (high)" }
      ]
    };

    var t = CTX.targets;
    $("ra-line-chip").innerHTML = '<span class="dot"></span>' + esc(CTX.line) + " running";
    $("ra-order").textContent = CTX.orderNo;
    $("ra-alpha-chip").innerHTML = esc(CTX.alphaLabel) + ' <span class="mono" id="ra-alpha">' + esc(CTX.alpha) + '</span>';
    $("ra-footage-chip").textContent = CTX.footage;

    $("ra-cs-alpha-label").textContent = CTX.alphaLabel + " / Alpha";
    $("ra-cs-alpha").textContent = CTX.alpha;
    $("ra-cs-source").innerHTML = CTX.sourceRods ? "Source: " + esc(CTX.sourceRods) : "&nbsp;";
    $("ra-cs-schedule").textContent = CTX.passSchedule;
    $("ra-cs-footage").textContent = CTX.footage;
    $("ra-cs-target-gauge").textContent = inches(t.gauge, t.gaugeDp);
    $("ra-cs-target-sub").innerHTML = "Gauge &plusmn;&thinsp;" + inches(t.gaugeTol, t.gaugeDp) +
      " &nbsp;&middot;&nbsp; Width " + inches(t.width, t.widthDp) + " &plusmn;&thinsp;" + inches(t.widthTol, t.widthDp);

    $("ra-operator").textContent = CTX.operator;
    $("ra-notes").value = "";
    reason = null;

    renderRolls();
    renderMeasurements();
    renderReasons();
    renderHistory();
    refreshAction();

    tickStamp();
    if (stampTimer) clearInterval(stampTimer);
    stampTimer = setInterval(tickStamp, 1000);

    window.FwModal.open("ra-overlay");
    /* The roll table is rebuilt per caller, so the dialog's height changes with
       the stand count - re-fit rather than trusting the height at registration. */
    if (window.FwModal.fit) window.FwModal.fit("ra-overlay");
  };
})();
