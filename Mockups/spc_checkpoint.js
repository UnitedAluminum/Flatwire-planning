/* =============================================================================
   spc_checkpoint.js — SPC checkpoint dialog (was dashboard_6_spc_checkpoint.html)
   =============================================================================
   Converted from a standalone screen to a popup on 1 Aug 2026. A checkpoint is
   taken against the run that is already on screen and, when it fails, feeds
   straight into a WIP rejection — both of which were round trips through the
   browser while this was its own page.

   Include AFTER fw-modal.js, before </body>:

       <script src="fw-modal.js"></script>
       <script src="spc_checkpoint.js"></script>

   Open it with a context object (every key optional):

       openSpcCheckpoint({
         line:           'FL1',
         orderNo:        'FW-00421',
         alpha:          'R00042',
         checkpointType: 'post-die-change',   // pre-run | post-db1 | post-die-change | spot-check
         footage:        '12,450 ft',
         operator:       'Dave M.',
         trigger:        { kind:'die-change', block:'DB2', from:'0.310"', to:'0.308"',
                           footage:'12,450 ft', by:'Tim O.', at:'07:38 AM' },
         measurements:   [ { name, context, target, tolerance, value } ],
         readOnly:       false,               // true = review a recorded checkpoint
         onSubmit:       function (result) { … }
       });

   `result` is { checkpointType, outcome:'continue'|'suspend', measurements[],
   observation, allInSpec }.

   CHAINING — "Submit · suspend material" closes this dialog and opens the WIP
   rejection dialog pre-loaded with the first failing measurement, which is
   exactly what that screen's measurement-context banner is for. Dialogs are
   never stacked; this one closes first.

   READ-ONLY MODE — the line status board links to a completed checkpoint
   ("SPC · Last check 07:38 AM · In spec · View →"). That is a review of a
   recorded result, not a new entry, so readOnly locks the inputs and collapses
   the footer to a single Close.

   Requires flat-wire-shopfloor.styles.css. wip_rejection.js is optional —
   without it the suspend path just closes.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openSpcCheckpoint) return;   /* guard against double-inclusion */

  var DEFAULT_MEASUREMENTS = [
    { name: "Wire diameter", context: "post-DB2 draw", target: 0.308, tolerance: 0.003, value: 0.309 },
    { name: "Gauge",         context: "at FM1 output", target: 0.110, tolerance: 0.002, value: 0.110 },
    { name: "Width",         context: "at FM1 output", target: 0.625, tolerance: 0.005, value: 0.626 }
  ];

  var TYPES = [
    { id: "pre-run", name: "Pre-run", desc: "Incoming material before run start",
      icon: '<polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>' },
    { id: "post-db1", name: "Post DB1", desc: "Wire diameter after DB1 drawing stage",
      icon: '<circle cx="12" cy="12" r="3"/><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>' },
    { id: "post-die-change", name: "Post die change", desc: "Required after any die swap",
      icon: '<path d="M23 4v6h-6"/><path d="M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>' },
    { id: "spot-check", name: "Manual spot check", desc: "Operator discretion, any time",
      icon: '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>' }
  ];

  /* ── Styles ─────────────────────────────────────────────────────
     Scoped under .fwspc. The standalone screen used bare .section, .btn and
     .measurement-context, all of which exist with different meanings on the
     active-run monitors this now opens over. */
  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-spc-checkpoint", "");
  styleEl.textContent = [
    '.fwspc .fwspc-body{display:flex;flex-direction:column;gap:12px}',

    '.fwspc .fwspc-section{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:16px 18px}',
    '.fwspc .fwspc-section-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;gap:14px}',
    '.fwspc .fwspc-section-title{font-size:15px;font-weight:500}',
    '.fwspc .fwspc-section-hint{font-size:14px;color:var(--color-text-tertiary)}',

    /* Checkpoint type */
    '.fwspc .fwspc-type-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:12px}',
    '.fwspc .fwspc-type{display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);cursor:pointer;background:var(--color-background-primary);font-family:var(--font-sans);transition:all 0.15s;text-align:left;font-size:14px}',
    '.fwspc .fwspc-type:hover{background:var(--color-background-secondary)}',
    '.fwspc .fwspc-type:active{transform:scale(0.98)}',
    '.fwspc .fwspc-type.selected{border-color:var(--color-blue);background:var(--color-background-info)}',
    '.fwspc .fwspc-type-icon{width:34px;height:34px;border-radius:var(--border-radius-md);background:var(--color-background-secondary);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:var(--color-text-secondary)}',
    '.fwspc .fwspc-type.selected .fwspc-type-icon{background:var(--color-blue);color:#fff}',
    '.fwspc .fwspc-type-icon svg{width:19px;height:19px}',
    '.fwspc .fwspc-type-body{display:flex;flex-direction:column;gap:2px;min-width:0}',
    '.fwspc .fwspc-type-name{font-size:14px;font-weight:500;color:var(--color-text-primary)}',
    '.fwspc .fwspc-type.selected .fwspc-type-name{color:var(--color-text-info)}',
    '.fwspc .fwspc-type-desc{font-size:14px;color:var(--color-text-tertiary)}',

    /* Trigger banner */
    '.fwspc .fwspc-trigger{display:none;gap:12px;align-items:center;padding:11px 14px;background:var(--color-background-warning);color:var(--color-text-warning);border-radius:var(--border-radius-md);font-size:14px}',
    '.fwspc .fwspc-trigger.visible{display:flex}',
    '.fwspc .fwspc-trigger-icon{flex-shrink:0;width:24px;height:24px;border-radius:50%;background:var(--color-amber);color:#fff;display:flex;align-items:center;justify-content:center}',
    '.fwspc .fwspc-trigger-icon svg{width:13px;height:13px}',
    '.fwspc .fwspc-trigger-body{flex:1;display:flex;align-items:center;gap:8px;flex-wrap:wrap}',
    '.fwspc .fwspc-trigger-body strong{font-weight:500}',
    '.fwspc .fwspc-change-arrow{display:inline-flex;align-items:center;gap:6px;padding:2px 10px;background:rgba(255,255,255,0.55);border-radius:var(--border-radius-md);font-family:var(--font-mono);font-size:14px;font-weight:500}',
    '.fwspc .fwspc-trigger-dim{opacity:0.75;font-size:14px}',

    /* Measurement summary */
    '.fwspc .fwspc-summary{display:flex;gap:10px;align-items:center;padding:4px 12px;background:var(--color-background-success);color:var(--color-text-success);border-radius:var(--border-radius-md);font-size:14px;font-weight:500;white-space:nowrap}',
    '.fwspc .fwspc-summary.has-fail{background:var(--color-background-danger);color:var(--color-text-danger)}',
    '.fwspc .fwspc-summary .dot{width:7px;height:7px;border-radius:50%;background:var(--color-green)}',
    '.fwspc .fwspc-summary.has-fail .dot{background:var(--color-red)}',

    /* Measurement rows */
    '.fwspc .fwspc-list{display:flex;flex-direction:column;gap:10px}',
    '.fwspc .fwspc-meas{display:grid;grid-template-columns:230px 170px 1fr 165px;gap:16px;align-items:center;padding:13px 16px;background:var(--color-background-secondary);border-radius:var(--border-radius-md);border-left:3px solid var(--color-green);transition:border-left-color 0.2s}',
    '.fwspc .fwspc-meas.oos{border-left-color:var(--color-red);background:var(--color-background-danger)}',
    '.fwspc .fwspc-meas-info{display:flex;flex-direction:column;gap:3px;min-width:0}',
    '.fwspc .fwspc-meas-name{font-size:15px;font-weight:500}',
    '.fwspc .fwspc-meas-where{font-size:14px;color:var(--color-text-tertiary)}',
    '.fwspc .fwspc-meas-target{font-size:14px;color:var(--color-text-secondary);font-family:var(--font-mono);margin-top:2px}',
    '.fwspc .fwspc-meas-input-wrap{display:flex;flex-direction:column;gap:4px}',
    '.fwspc .fwspc-meas-input-label{font-size:14px;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:0.3px}',
    '.fwspc .fwspc-meas-input{width:100%;height:52px;padding:0 14px;font-size:21px;font-weight:500;font-family:var(--font-mono);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none;text-align:center}',
    '.fwspc .fwspc-meas-input:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,0.18)}',
    '.fwspc .fwspc-meas-input:disabled{background:var(--color-background-secondary);color:var(--color-text-secondary);cursor:default}',
    '.fwspc .fwspc-meas.oos .fwspc-meas-input{border-color:var(--color-red);color:var(--color-text-danger)}',

    /* Tolerance bar */
    '.fwspc .fwspc-tol{display:flex;flex-direction:column;gap:6px;padding:0 8px}',
    '.fwspc .fwspc-tol-track{position:relative;height:18px;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:9px;overflow:visible}',
    '.fwspc .fwspc-tol-range{position:absolute;top:0;left:10%;right:10%;height:100%;background:var(--color-green);opacity:0.22;border-radius:9px}',
    '.fwspc .fwspc-tol-center{position:absolute;top:-3px;bottom:-3px;left:50%;width:1px;background:var(--color-border-primary);opacity:0.6}',
    '.fwspc .fwspc-tol-marker{position:absolute;top:50%;width:22px;height:22px;background:var(--color-blue);border:3px solid var(--color-background-primary);border-radius:50%;transform:translate(-50%,-50%);box-shadow:0 0 0 1px var(--color-blue);transition:left 0.25s,background 0.2s,box-shadow 0.2s;z-index:2}',
    '.fwspc .fwspc-meas.oos .fwspc-tol-marker{background:var(--color-red);box-shadow:0 0 0 1px var(--color-red)}',
    '.fwspc .fwspc-tol-labels{display:flex;justify-content:space-between;font-size:14px;font-family:var(--font-mono);color:var(--color-text-tertiary);padding:0 4px}',
    '.fwspc .fwspc-tol-labels .center{color:var(--color-text-secondary);font-weight:500}',

    '.fwspc .fwspc-meas-result{display:flex;flex-direction:column;align-items:flex-end;gap:6px}',
    '.fwspc .fwspc-status{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:var(--border-radius-md);font-size:14px;font-weight:500;background:var(--color-background-success);color:var(--color-text-success);white-space:nowrap}',
    '.fwspc .fwspc-status.oos{background:var(--color-background-danger);color:var(--color-text-danger)}',
    '.fwspc .fwspc-status svg{width:11px;height:11px}',
    '.fwspc .fwspc-dev{font-size:14px;font-family:var(--font-mono);color:var(--color-text-success);font-weight:500}',
    '.fwspc .fwspc-meas.oos .fwspc-dev{color:var(--color-text-danger)}',

    /* Observation */
    '.fwspc .fwspc-obs-label{font-size:14px;color:var(--color-text-secondary);margin-bottom:8px}',
    '.fwspc .fwspc-obs{width:100%;height:58px;padding:10px 14px;font-size:14px;font-family:var(--font-sans);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);resize:none;outline:none}',
    '.fwspc .fwspc-obs:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,0.18)}',
    '.fwspc .fwspc-obs:disabled{background:var(--color-background-secondary);color:var(--color-text-secondary)}',

    /* Footer buttons */
    '.fwspc .fwspc-btn{height:50px;padding:0 22px;font-size:14px;font-weight:500;border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);transition:all 0.15s;display:inline-flex;align-items:center;gap:10px}',
    '.fwspc .fwspc-btn:hover{background:var(--color-background-secondary)}',
    '.fwspc .fwspc-btn:active{transform:scale(0.98)}',
    '.fwspc .fwspc-btn svg{width:16px;height:16px}',
    '.fwspc .fwspc-btn.primary{background:var(--color-green);border-color:var(--color-green);color:#fff;padding:0 26px}',
    '.fwspc .fwspc-btn.primary:hover{background:#168962}',
    '.fwspc .fwspc-btn.danger{background:var(--color-background-primary);border-color:var(--color-red);color:var(--color-text-danger);padding:0 26px}',
    '.fwspc .fwspc-btn.danger:hover{background:var(--color-background-danger)}',
    '.fwspc .fwspc-btn.danger.elevated{background:var(--color-red);color:#fff;border-color:var(--color-red)}',
    '.fwspc .fwspc-btn.danger.elevated:hover{background:#bc4921}',
    '.fwspc.read-only .fwspc-type{cursor:default;pointer-events:none}',
    '.fwspc.read-only .fwspc-type:not(.selected){opacity:0.5}'
  ].join("\n");
  document.head.appendChild(styleEl);

  var IC_OK = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><polyline points="13 4 6 11 3 8"/></svg>';
  var IC_BAD = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="4" x2="4" y2="12"/><line x1="4" y1="4" x2="12" y2="12"/></svg>';
  var IC_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
  var IC_CHECK = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
  var IC_REFRESH = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"/><path d="M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>';

  /* ── Markup ─────────────────────────────────────────────────── */
  function typeBtn(t) {
    return '' +
      '<button type="button" class="fwspc-type" data-type="' + t.id + '">' +
        '<span class="fwspc-type-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + t.icon + '</svg></span>' +
        '<span class="fwspc-type-body">' +
          '<span class="fwspc-type-name">' + t.name + '</span>' +
          '<span class="fwspc-type-desc">' + t.desc + '</span>' +
        '</span>' +
      '</button>';
  }

  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    '<div class="gb-modal-overlay" id="spc-overlay">' +
      '<div class="gb-modal xwide fwspc" role="dialog" aria-modal="true" aria-labelledby="spc-title">' +

        '<div class="gb-modal-head">' +
          '<div>' +
            '<div class="gb-modal-title" id="spc-title">SPC Checkpoint</div>' +
            '<div class="gb-modal-ctx">' +
              '<span class="ctx-chip success" id="spc-line-chip"><span class="dot"></span>FL1 running &middot; checkpoint</span>' +
              '<span class="ctx-chip">Order <span class="mono" id="spc-order">FW-00421</span></span>' +
              '<span class="ctx-chip">Alpha <span class="mono" id="spc-alpha">R00042</span></span>' +
            '</div>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="spc-overlay" aria-label="Close">&times;</button>' +
        '</div>' +

        '<div class="gb-modal-body fwspc-body">' +

          '<div class="fwspc-section">' +
            '<div class="fwspc-section-head">' +
              '<span class="fwspc-section-title">Checkpoint type</span>' +
              '<span class="fwspc-section-hint">Measurements required adjust based on checkpoint type</span>' +
            '</div>' +
            '<div class="fwspc-type-grid" id="spc-type-grid">' + TYPES.map(typeBtn).join("") + '</div>' +
            '<div class="fwspc-trigger" id="spc-trigger">' +
              '<span class="fwspc-trigger-icon">' + IC_REFRESH + '</span>' +
              '<span class="fwspc-trigger-body" id="spc-trigger-body"></span>' +
            '</div>' +
          '</div>' +

          '<div class="fwspc-section">' +
            '<div class="fwspc-section-head">' +
              '<div style="display:flex;gap:12px;align-items:baseline">' +
                '<span class="fwspc-section-title">Measurements</span>' +
                '<span class="fwspc-section-hint" id="spc-meas-hint">Measure each value and confirm in spec</span>' +
              '</div>' +
              '<span class="fwspc-summary" id="spc-summary"><span class="dot"></span><span id="spc-summary-text">—</span></span>' +
            '</div>' +
            '<div class="fwspc-list" id="spc-list"></div>' +
          '</div>' +

          '<div class="fwspc-section">' +
            '<div class="fwspc-obs-label" id="spc-obs-label">Observation (optional)</div>' +
            '<textarea class="fwspc-obs" id="spc-obs" placeholder="Notes on the die change, surface appearance, or anything unusual about this checkpoint&hellip;"></textarea>' +
          '</div>' +

        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="gb-modal-stamp">' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Operator</span><span class="gb-modal-stamp-value" id="spc-operator">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Footage at check</span><span class="gb-modal-stamp-value mono" id="spc-footage">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Timestamp</span><span class="gb-modal-stamp-value mono" id="spc-stamp-time">—</span></div>' +
          '</div>' +
          '<div class="modal-foot-actions" id="spc-actions">' +
            '<button type="button" class="fwspc-btn" id="spc-close-btn" data-close="spc-overlay" style="display:none">Close</button>' +
            '<button type="button" class="fwspc-btn danger" id="spc-suspend">' + IC_WARN + 'Submit &middot; suspend material</button>' +
            '<button type="button" class="fwspc-btn primary" id="spc-continue">' + IC_CHECK + 'Submit &middot; continue run</button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap);

  /* ── State ──────────────────────────────────────────────────── */
  var CTX = null;
  var currentType = "post-die-change";
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

  function inches(v) { return v.toFixed(3) + '"'; }
  function parseValue(str) {
    var m = String(str).match(/-?\d+(\.\d+)?/);
    return m ? parseFloat(m[0]) : NaN;
  }
  function fmtDeviation(v) { return (v >= 0 ? "+" : "") + v.toFixed(3) + '"'; }

  /* ── Measurement rows ───────────────────────────────────────── */
  function renderMeasurements() {
    var html = CTX.measurements.map(function (m, i) {
      return '' +
      '<div class="fwspc-meas" data-i="' + i + '" data-target="' + m.target + '" data-tolerance="' + m.tolerance + '">' +
        '<div class="fwspc-meas-info">' +
          '<div class="fwspc-meas-name">' + m.name + '</div>' +
          '<div class="fwspc-meas-where">' + (m.context || "") + '</div>' +
          '<div class="fwspc-meas-target">Target ' + inches(m.target) + ' &plusmn; ' + inches(m.tolerance) + '</div>' +
        '</div>' +
        '<div class="fwspc-meas-input-wrap">' +
          '<span class="fwspc-meas-input-label">Measured</span>' +
          '<input class="fwspc-meas-input" type="text" value="' + (m.value != null ? inches(m.value) : "") + '"' +
            (CTX.readOnly ? " disabled" : "") + (i === 0 && !CTX.readOnly ? " data-autofocus" : "") + '>' +
        '</div>' +
        '<div class="fwspc-tol">' +
          '<div class="fwspc-tol-track">' +
            '<div class="fwspc-tol-range"></div>' +
            '<div class="fwspc-tol-center"></div>' +
            '<div class="fwspc-tol-marker" style="left:50%"></div>' +
          '</div>' +
          '<div class="fwspc-tol-labels">' +
            '<span>' + inches(m.target - m.tolerance) + '</span>' +
            '<span class="center">' + inches(m.target) + '</span>' +
            '<span>' + inches(m.target + m.tolerance) + '</span>' +
          '</div>' +
        '</div>' +
        '<div class="fwspc-meas-result">' +
          '<span class="fwspc-status">' + IC_OK + ' In spec</span>' +
          '<span class="fwspc-dev">—</span>' +
        '</div>' +
      '</div>';
    }).join("");

    $("spc-list").innerHTML = html;
    $("spc-list").querySelectorAll(".fwspc-meas-input").forEach(function (input) {
      input.addEventListener("input", updateSummary);
      input.addEventListener("blur", updateSummary);
    });
  }

  function updateMeasurement(row) {
    var input = row.querySelector(".fwspc-meas-input");
    var target = parseFloat(row.getAttribute("data-target"));
    var tolerance = parseFloat(row.getAttribute("data-tolerance"));
    var measured = parseValue(input.value);

    var marker = row.querySelector(".fwspc-tol-marker");
    var status = row.querySelector(".fwspc-status");
    var dev = row.querySelector(".fwspc-dev");

    if (isNaN(measured)) {
      marker.style.left = "50%";
      status.classList.remove("oos");
      status.innerHTML = '<span style="font-size:14px">&mdash;</span>';
      dev.textContent = "—";
      row.classList.remove("oos");
      return { inSpec: false, measured: false, value: null };
    }

    var deviation = measured - target;
    var inSpec = Math.abs(deviation) <= tolerance;

    /* Map the reading onto a track 3.33x the tolerance wide, so the in-spec band
       occupies the middle 60% and an out-of-spec reading is visibly outside it
       rather than pinned to the end. */
    var pct = 50 + ((measured - target) / (tolerance * 1.67)) * 50;
    marker.style.left = Math.min(96, Math.max(4, pct)) + "%";

    row.classList.toggle("oos", !inSpec);
    status.classList.toggle("oos", !inSpec);
    status.innerHTML = inSpec ? IC_OK + " In spec" : IC_BAD + " Out of spec";
    dev.textContent = fmtDeviation(deviation);

    return { inSpec: inSpec, measured: true, value: measured };
  }

  function readMeasurements() {
    var rows = $("spc-list").querySelectorAll(".fwspc-meas");
    var out = [];
    for (var i = 0; i < rows.length; i++) {
      var r = updateMeasurement(rows[i]);
      var src = CTX.measurements[parseInt(rows[i].getAttribute("data-i"), 10)];
      out.push({
        name: src.name, context: src.context, target: src.target, tolerance: src.tolerance,
        value: r.value, inSpec: r.inSpec, measured: r.measured
      });
    }
    return out;
  }

  function updateSummary() {
    var results = readMeasurements();
    var total = results.length;
    var inSpec = results.filter(function (r) { return r.inSpec; }).length;

    var summary = $("spc-summary");
    var failed = total - inSpec;
    summary.classList.toggle("has-fail", failed > 0);
    $("spc-summary-text").textContent = failed > 0
      ? failed + " of " + total + " out of spec"
      : total + " of " + total + " in spec";
    $("spc-suspend").classList.toggle("elevated", failed > 0 && !CTX.readOnly);
    return results;
  }

  /* ── Trigger banner ─────────────────────────────────────────── */
  function renderTrigger() {
    var t = CTX.trigger;
    var el = $("spc-trigger");
    if (!t) { el.classList.remove("visible"); return; }
    el.classList.add("visible");

    var arrow = (t.from && t.to) ? '<span class="fwspc-change-arrow">' + t.from + ' &rarr; ' + t.to + '</span>' : "";
    var dim = [];
    if (t.footage) dim.push("logged at footage " + t.footage);
    if (t.by) dim.push("by " + t.by);
    if (t.at) dim.push(t.at);

    $("spc-trigger-body").innerHTML =
      '<strong>' + (t.block ? t.block + " die change" : "Die change") + '</strong>' + arrow +
      (dim.length ? '<span class="fwspc-trigger-dim">' + dim.join(" &middot; ") + '</span>' : "");
  }

  function selectType(id) {
    currentType = id;
    document.querySelectorAll("#spc-type-grid .fwspc-type").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-type") === id);
    });
  }

  document.querySelectorAll("#spc-type-grid .fwspc-type").forEach(function (btn) {
    btn.addEventListener("click", function () {
      if (CTX && CTX.readOnly) return;
      selectType(btn.getAttribute("data-type"));
    });
  });

  /* ── Submit ─────────────────────────────────────────────────── */
  function submit(outcome) {
    var results = updateSummary();
    var allInSpec = results.every(function (r) { return r.inSpec; });
    var result = {
      checkpointType: currentType,
      outcome: outcome,
      measurements: results,
      observation: $("spc-obs").value.trim(),
      allInSpec: allInSpec
    };

    var failing = results.filter(function (r) { return r.measured && !r.inSpec; })[0];
    close();
    if (typeof CTX.onSubmit === "function") CTX.onSubmit(result);

    /* Suspending the material IS a WIP rejection — hand the failing reading
       straight to that dialog rather than making the operator re-key it. */
    if (outcome === "suspend" && typeof window.openWipRejection === "function") {
      window.openWipRejection({
        materialAlpha: CTX.alpha,
        orderNo: CTX.orderNo,
        stage: CTX.line + " · active run",
        footagePosition: CTX.footage,
        operator: CTX.operator,
        trigger: "spc-fail",
        measurement: failing ? {
          name: failing.name,
          measured: inches(failing.value),
          targetMin: inches(failing.target - failing.tolerance),
          targetMax: inches(failing.target + failing.tolerance),
          deviation: fmtDeviation(failing.value - failing.target)
        } : null
      });
    }
  }

  $("spc-continue").addEventListener("click", function () { submit("continue"); });
  $("spc-suspend").addEventListener("click", function () { submit("suspend"); });

  /* ── Open / close ───────────────────────────────────────────── */
  function close() {
    if (clockTimer) { clearInterval(clockTimer); clockTimer = null; }
    window.FwModal.close("spc-overlay");
  }

  window.openSpcCheckpoint = function (ctx) {
    ctx = ctx || {};
    CTX = {
      line: ctx.line || "FL1",
      orderNo: ctx.orderNo || "FW-00421",
      alpha: ctx.alpha || "R00042",
      checkpointType: ctx.checkpointType || "post-die-change",
      footage: ctx.footage || "12,450 ft",
      operator: ctx.operator || "Dave M.",
      trigger: ctx.trigger || null,
      measurements: ctx.measurements || DEFAULT_MEASUREMENTS,
      readOnly: !!ctx.readOnly,
      onSubmit: ctx.onSubmit
    };

    var modal = document.querySelector("#spc-overlay .gb-modal");
    modal.classList.toggle("read-only", CTX.readOnly);

    $("spc-title").textContent = CTX.readOnly ? "SPC Checkpoint — recorded" : "SPC Checkpoint";
    $("spc-line-chip").innerHTML = '<span class="dot"></span>' + CTX.line +
      (CTX.readOnly ? " &middot; recorded checkpoint" : " running &middot; checkpoint");
    $("spc-line-chip").className = "ctx-chip " + (CTX.readOnly ? "info" : "success");
    $("spc-order").textContent = CTX.orderNo;
    $("spc-alpha").textContent = CTX.alpha;
    $("spc-operator").textContent = CTX.operator;
    $("spc-footage").textContent = CTX.footage;
    $("spc-meas-hint").textContent = CTX.readOnly
      ? "Recorded values — read only"
      : "Measure each value and confirm in spec";
    $("spc-obs-label").textContent = CTX.readOnly ? "Observation" : "Observation (optional)";

    var obs = $("spc-obs");
    obs.value = ctx.observation || "";
    obs.disabled = CTX.readOnly;

    selectType(CTX.checkpointType);
    renderTrigger();
    renderMeasurements();
    updateSummary();

    $("spc-close-btn").style.display = CTX.readOnly ? "" : "none";
    $("spc-suspend").style.display = CTX.readOnly ? "none" : "";
    $("spc-continue").style.display = CTX.readOnly ? "none" : "";

    $("spc-stamp-time").textContent = ctx.recordedAt || stamp();
    if (!CTX.readOnly) {
      clockTimer = setInterval(function () { $("spc-stamp-time").textContent = stamp(); }, 1000);
    }

    window.FwModal.register("spc-overlay");
    window.FwModal.open("spc-overlay");
  };

  window.closeSpcCheckpoint = close;
})();
