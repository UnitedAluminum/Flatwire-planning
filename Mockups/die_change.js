/* =============================================================================
   die_change.js — Die change dialog (was dashboard_die_change.html)
   =============================================================================
   Converted from a standalone screen to a popup on 1 Aug 2026. A die change is a
   run event logged against the run that is already on screen, so navigating away
   from the active-run monitor to record it threw away the operator's context and
   forced a round trip back. As a dialog the run stays behind it, and the die
   change can hand off directly to the SPC checkpoint it requires.

   Include AFTER fw-modal.js, before </body>:

       <script src="fw-modal.js"></script>
       <script src="die_change.js"></script>

   Open it with a context object (every key optional — the defaults reproduce the
   FL1 / FW-00421 demo state the standalone screen was authored with):

       openDieChange({
         line:       'FL1',
         orderNo:    'FW-00421',
         block:      'DB2',              // DB1 | DB2 | BOTH — initially selected
         footage:    '12,450 ft',        // footage at change
         outputCoil: 'FW-00421-C01',
         operator:   'Dave M.',
         dies:       { DB1: {...}, DB2: {...} },   // outgoing, see DEFAULT_DIES
         newDies:    { DB1: {...}, DB2: {...} },   // incoming
         onConfirm:  function (result) { … }
       });

   `result` is { block, reason, condition, newAlpha, qaHold, spcRequired }.

   CHAINING — when the reason is gauge drift or size change and "Require SPC on
   resume" is left on, confirming closes this dialog and opens the SPC checkpoint
   dialog pre-loaded with the die change as its trigger. That link is in the spec
   (the SPC screen's trigger banner is literally a die change) but was impossible
   while the two were separate pages. Dialogs are never stacked: this one closes
   first, so there is only ever one focus trap in play.

   Requires flat-wire-shopfloor.styles.css for the design tokens and the shared
   .gb-modal shell. spc_checkpoint.js is optional — without it the chain is
   skipped and the confirmation simply closes.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openDieChange) return;      /* guard against double-inclusion */

  /* ── Demo data ──────────────────────────────────────────────── */
  var DEFAULT_DIES = {
    DB1: {
      alpha: "D-340-087", size: '0.340"', footage: "18,420 ft",
      sched: "25,000 ft", remaining: "6,580 ft",
      pct: 73.7, pctClass: "amber", type: "TC Mono", installed: "06:18 AM"
    },
    DB2: {
      alpha: "D-310-034", size: '0.310"', footage: "18,420 ft",
      sched: "22,000 ft", remaining: "3,580 ft",
      pct: 83.7, pctClass: "red", type: "TC Mono", installed: "06:18 AM"
    }
  };
  var DEFAULT_NEW_DIES = {
    DB1: { alpha: "D-340-091", size: '0.340"' },
    DB2: { alpha: "D-310-091", size: '0.310"' }
  };

  /* ── Styles ─────────────────────────────────────────────────────
     Every rule is scoped under .fwdc. The standalone screen defined bare
     .section, .btn, .footer and .field at global scope; injected into an
     active-run monitor those would collide head-on with the host screen's own
     rules, so nothing here is left unprefixed. */
  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-die-change", "");
  styleEl.textContent = [
    '.fwdc .fwdc-body{display:flex;flex-direction:column;gap:12px}',

    '.fwdc .fwdc-section{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:16px 18px}',
    '.fwdc .fwdc-section-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}',
    '.fwdc .fwdc-section-title{font-size:15px;font-weight:500}',
    '.fwdc .fwdc-section-hint{font-size:14px;color:var(--color-text-tertiary)}',

    /* Die block selector */
    '.fwdc .fwdc-block-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}',
    '.fwdc .fwdc-block-card{display:flex;align-items:center;gap:14px;padding:14px 16px;border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);cursor:pointer;background:var(--color-background-primary);user-select:none;transition:all 0.15s;text-align:left;font-family:var(--font-sans)}',
    '.fwdc .fwdc-block-card:hover{background:var(--color-background-secondary)}',
    '.fwdc .fwdc-block-card.selected{border-color:var(--color-blue);background:var(--color-background-info)}',
    '.fwdc .fwdc-block-dot{width:20px;height:20px;border-radius:50%;border:2px solid var(--color-border-primary);flex-shrink:0;position:relative}',
    '.fwdc .fwdc-block-card.selected .fwdc-block-dot{border-color:var(--color-blue)}',
    '.fwdc .fwdc-block-card.selected .fwdc-block-dot::after{content:"";position:absolute;top:3px;left:3px;right:3px;bottom:3px;border-radius:50%;background:var(--color-blue)}',
    '.fwdc .fwdc-block-icon{width:46px;height:46px;border-radius:var(--border-radius-md);background:var(--color-background-secondary);display:flex;align-items:center;justify-content:center;flex-shrink:0;color:var(--color-text-secondary)}',
    '.fwdc .fwdc-block-card.selected .fwdc-block-icon{background:var(--color-blue);color:#fff}',
    '.fwdc .fwdc-block-icon svg{width:26px;height:26px}',
    '.fwdc .fwdc-block-body{flex:1;min-width:0}',
    '.fwdc .fwdc-block-name{font-size:15px;font-weight:500;margin-bottom:3px}',
    '.fwdc .fwdc-block-card.selected .fwdc-block-name{color:var(--color-text-info)}',
    '.fwdc .fwdc-block-meta{font-size:14px;color:var(--color-text-secondary)}',
    '.fwdc .fwdc-block-meta.mono{font-family:var(--font-mono)}',
    '.fwdc .fwdc-block-life{display:inline-flex;align-items:center;gap:6px;padding:3px 9px;border-radius:var(--border-radius-md);font-size:14px;font-weight:500;margin-top:6px}',
    '.fwdc .fwdc-block-life.amber{background:var(--color-background-warning);color:var(--color-text-warning)}',
    '.fwdc .fwdc-block-life.red{background:var(--color-background-danger);color:var(--color-text-danger)}',
    '.fwdc .fwdc-block-life .dot{width:5px;height:5px;border-radius:50%}',
    '.fwdc .fwdc-block-life.amber .dot{background:var(--color-amber)}',
    '.fwdc .fwdc-block-life.red .dot{background:var(--color-red)}',

    /* Die detail panels */
    '.fwdc .fwdc-die-details{display:grid;grid-template-columns:1fr 1fr;gap:12px}',
    '.fwdc .fwdc-die-panel{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:18px 20px;display:flex;flex-direction:column}',
    '.fwdc .fwdc-die-panel.current{border-left:3px solid var(--color-amber)}',
    '.fwdc .fwdc-die-panel.incoming{border-left:3px solid var(--color-blue)}',
    '.fwdc .fwdc-die-panel-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:12px;gap:12px}',
    '.fwdc .fwdc-die-panel-title{display:flex;align-items:baseline;gap:10px;flex-wrap:wrap}',
    '.fwdc .fwdc-die-panel-title h3{margin:0;font-size:16px;font-weight:500}',
    '.fwdc .fwdc-die-panel-role{font-size:14px;color:var(--color-text-tertiary)}',
    '.fwdc .fwdc-auto-badge{display:inline-flex;align-items:center;gap:5px;padding:3px 9px;background:var(--color-background-secondary);color:var(--color-text-secondary);border-radius:var(--border-radius-md);font-size:14px;font-weight:500;white-space:nowrap}',
    '.fwdc .fwdc-scan-badge{display:inline-flex;align-items:center;gap:5px;padding:3px 9px;background:var(--color-background-info);color:var(--color-text-info);border-radius:var(--border-radius-md);font-size:14px;font-weight:500;white-space:nowrap}',
    '.fwdc .fwdc-alpha-readout{font-size:28px;font-weight:500;font-family:var(--font-mono);margin-bottom:12px;line-height:1}',

    /* Die life bar */
    '.fwdc .fwdc-life-wrap{margin-bottom:14px}',
    '.fwdc .fwdc-life-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:6px;font-size:14px;color:var(--color-text-secondary)}',
    '.fwdc .fwdc-life-pct{font-family:var(--font-mono);font-weight:500}',
    '.fwdc .fwdc-life-pct.amber{color:var(--color-text-warning)}',
    '.fwdc .fwdc-life-pct.red{color:var(--color-text-danger)}',
    '.fwdc .fwdc-life-bar{height:10px;background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);border-radius:5px;overflow:hidden}',
    '.fwdc .fwdc-life-fill{height:100%;border-radius:5px;transition:width 0.3s}',
    '.fwdc .fwdc-life-fill.amber{background:var(--color-amber)}',
    '.fwdc .fwdc-life-fill.red{background:var(--color-red)}',
    '.fwdc .fwdc-life-fill.green{background:var(--color-green)}',

    /* Field grid */
    '.fwdc .fwdc-fields{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;flex:1}',
    '.fwdc .fwdc-field{background:var(--color-background-secondary);padding:10px 12px;border-radius:var(--border-radius-md);display:flex;flex-direction:column;justify-content:center}',
    '.fwdc .fwdc-field-label{font-size:14px;color:var(--color-text-secondary);margin-bottom:4px}',
    '.fwdc .fwdc-field-value{font-size:15px;font-weight:500;font-family:var(--font-mono)}',
    '.fwdc .fwdc-field-value.plain{font-family:var(--font-sans)}',
    '.fwdc .fwdc-field-value.amber{color:var(--color-text-warning)}',
    '.fwdc .fwdc-field-value.success{color:var(--color-text-success)}',
    '.fwdc .fwdc-field-value.sm{font-size:14px}',

    /* New die scan input */
    '.fwdc .fwdc-alpha-wrap{position:relative;margin-bottom:14px}',
    '.fwdc .fwdc-scan-icon{position:absolute;left:15px;top:50%;transform:translateY(-50%);color:var(--color-text-tertiary);pointer-events:none}',
    '.fwdc .fwdc-scan-icon svg{width:21px;height:21px}',
    '.fwdc .fwdc-alpha-input{width:100%;height:54px;padding:0 18px 0 46px;font-size:24px;font-weight:500;font-family:var(--font-mono);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none}',
    '.fwdc .fwdc-alpha-input:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,0.18)}',

    /* Condition toggle */
    '.fwdc .fwdc-condition{display:flex;gap:8px;margin-bottom:14px}',
    '.fwdc .fwdc-condition-btn{flex:1;height:40px;font-size:14px;font-weight:500;border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-secondary);border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);transition:all 0.15s}',
    '.fwdc .fwdc-condition-btn:hover{background:var(--color-background-secondary)}',
    '.fwdc .fwdc-condition-btn.selected.new{background:var(--color-background-success);border-color:var(--color-green);color:var(--color-text-success)}',
    '.fwdc .fwdc-condition-btn.selected.recond{background:var(--color-background-warning);border-color:var(--color-amber);color:var(--color-text-warning)}',

    /* Reason selector */
    '.fwdc .fwdc-reason-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:10px}',
    '.fwdc .fwdc-reason-btn{display:flex;flex-direction:column;align-items:center;justify-content:flex-start;gap:9px;padding:14px 10px;border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-secondary);border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);transition:all 0.15s;text-align:center}',
    '.fwdc .fwdc-reason-btn:hover{background:var(--color-background-secondary);color:var(--color-text-primary)}',
    '.fwdc .fwdc-reason-btn.selected{border-color:var(--color-blue);background:var(--color-background-info);color:var(--color-text-info)}',
    '.fwdc .fwdc-reason-btn svg{width:24px;height:24px;opacity:0.7;flex-shrink:0}',
    '.fwdc .fwdc-reason-btn.selected svg{opacity:1}',
    '.fwdc .fwdc-reason-label{font-size:14px;font-weight:500;line-height:1.25}',
    '.fwdc .fwdc-reason-desc{font-size:14px;color:var(--color-text-tertiary);line-height:1.3}',
    '.fwdc .fwdc-reason-btn.selected .fwdc-reason-desc{color:var(--color-text-info);opacity:0.8}',

    /* Conditional blocks */
    '.fwdc .fwdc-conditional{display:none}',
    '.fwdc .fwdc-conditional.visible{display:block}',

    '.fwdc .fwdc-hold{padding:16px 18px;background:var(--color-background-danger);border:0.5px solid rgba(216,90,48,0.30);border-radius:var(--border-radius-lg)}',
    '.fwdc .fwdc-hold-head{display:flex;align-items:center;gap:12px;margin-bottom:14px}',
    '.fwdc .fwdc-hold-head svg{width:20px;height:20px;color:var(--color-red);flex-shrink:0}',
    '.fwdc .fwdc-hold-title{font-size:15px;font-weight:500;color:var(--color-text-danger)}',
    '.fwdc .fwdc-hold-sub{font-size:14px;color:var(--color-text-danger);opacity:0.8;margin-top:1px}',
    '.fwdc .fwdc-hold-fields{display:grid;grid-template-columns:1fr 1fr auto;gap:12px;align-items:end}',
    '.fwdc .fwdc-hold-field{display:flex;flex-direction:column;gap:6px}',
    '.fwdc .fwdc-hold-label{font-size:14px;font-weight:500;color:var(--color-text-danger)}',
    '.fwdc .fwdc-hold-input{height:42px;padding:0 14px;font-size:15px;font-weight:500;font-family:var(--font-mono);color:var(--color-text-primary);background:var(--color-background-primary);border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none}',
    '.fwdc .fwdc-hold-input:focus{border-color:var(--color-red);box-shadow:0 0 0 3px rgba(216,90,48,0.15)}',
    '.fwdc .fwdc-flag-btn{height:42px;padding:0 18px;font-size:14px;font-weight:500;background:var(--color-red);border:1px solid var(--color-red);border-radius:var(--border-radius-md);color:#fff;cursor:pointer;font-family:var(--font-sans);white-space:nowrap;display:inline-flex;align-items:center;gap:8px;transition:all 0.15s}',
    '.fwdc .fwdc-flag-btn:hover{background:#b84a26}',
    '.fwdc .fwdc-flag-btn svg{width:15px;height:15px}',
    '.fwdc .fwdc-flag-btn.flagged{background:var(--color-background-danger);color:var(--color-text-danger)}',

    '.fwdc .fwdc-spc{padding:16px 18px;background:var(--color-background-info);border:0.5px solid rgba(24,95,165,0.30);border-radius:var(--border-radius-lg);display:flex;justify-content:space-between;align-items:center;gap:24px}',
    '.fwdc .fwdc-spc-left{display:flex;align-items:flex-start;gap:12px}',
    '.fwdc .fwdc-spc-left svg{width:20px;height:20px;color:var(--color-blue);flex-shrink:0;margin-top:1px}',
    '.fwdc .fwdc-spc-title{font-size:14px;font-weight:500;color:var(--color-text-info);margin-bottom:2px}',
    '.fwdc .fwdc-spc-sub{font-size:14px;color:var(--color-text-info);opacity:0.85}',
    '.fwdc .fwdc-spc-toggle-row{display:flex;align-items:center;gap:10px;flex-shrink:0}',
    '.fwdc .fwdc-spc-toggle-label{font-size:14px;font-weight:500;color:var(--color-text-info);white-space:nowrap}',
    '.fwdc .fwdc-toggle{position:relative;width:44px;height:26px;cursor:pointer;flex-shrink:0}',
    '.fwdc .fwdc-toggle input{opacity:0;width:0;height:0}',
    '.fwdc .fwdc-toggle-track{position:absolute;top:0;left:0;right:0;bottom:0;border-radius:13px;background:var(--color-border-secondary);transition:background 0.2s}',
    '.fwdc .fwdc-toggle input:checked + .fwdc-toggle-track{background:var(--color-blue)}',
    '.fwdc .fwdc-toggle-thumb{position:absolute;top:3px;left:3px;width:20px;height:20px;border-radius:50%;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,0.2);transition:transform 0.2s;pointer-events:none}',
    '.fwdc .fwdc-toggle input:checked ~ .fwdc-toggle-thumb{transform:translateX(18px)}',

    /* Footer buttons */
    '.fwdc .fwdc-btn{height:48px;padding:0 24px;font-size:14px;font-weight:500;border-radius:var(--border-radius-md);cursor:pointer;font-family:var(--font-sans);border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);transition:all 0.15s}',
    '.fwdc .fwdc-btn:hover{background:var(--color-background-secondary)}',
    '.fwdc .fwdc-btn:active{transform:scale(0.98)}',
    '.fwdc .fwdc-btn.primary{background:var(--color-blue);border-color:var(--color-blue);color:#fff;padding:0 28px;display:inline-flex;align-items:center;gap:10px}',
    '.fwdc .fwdc-btn.primary:hover{background:#13497d}',
    '.fwdc .fwdc-btn.primary svg{width:18px;height:18px}',
    '.fwdc .fwdc-btn .mono{font-family:var(--font-mono);font-weight:500}'
  ].join("\n");
  document.head.appendChild(styleEl);

  /* ── Icons ──────────────────────────────────────────────────── */
  var IC_DIE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><circle cx="12" cy="12" r="8"/><line x1="12" y1="2" x2="12" y2="4"/><line x1="12" y1="20" x2="12" y2="22"/><line x1="2" y1="12" x2="4" y2="12"/><line x1="20" y1="12" x2="22" y2="12"/></svg>';
  var IC_BOTH = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="9" height="10" rx="2"/><rect x="13" y="7" width="9" height="10" rx="2"/><line x1="8" y1="12" x2="16" y2="12"/></svg>';
  var IC_SCAN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7V5a2 2 0 0 1 2-2h2"/><path d="M16 3h2a2 2 0 0 1 2 2v2"/><path d="M20 17v2a2 2 0 0 1-2 2h-2"/><path d="M8 21H6a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/></svg>';
  var IC_WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>';
  var IC_FLAG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>';
  var IC_CHECK = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
  var IC_INFO = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>';

  var REASONS = [
    { id: "planned", label: "Planned life", desc: "Scheduled footage limit reached",
      icon: '<path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/><path d="M3 6h.01"/><path d="M3 12h.01"/><path d="M3 18h.01"/>' },
    { id: "gauge", label: "Gauge drift", desc: "Wear causing off-spec gauge",
      icon: '<line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>' },
    { id: "failure", label: "Die failure", desc: "Cracked, chipped, or broken",
      icon: '<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>' },
    { id: "size", label: "Size change", desc: "Different gauge target required",
      icon: '<polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/>' },
    { id: "other", label: "Other", desc: "See observation field",
      icon: '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>' }
  ];

  /* ── Markup ─────────────────────────────────────────────────── */
  function blockCard(id, name, meta, metaMono, lifeClass, lifeText) {
    return '' +
      '<button type="button" class="fwdc-block-card" data-block="' + id + '">' +
        '<span class="fwdc-block-dot"></span>' +
        '<span class="fwdc-block-icon">' + (id === "BOTH" ? IC_BOTH : IC_DIE) + '</span>' +
        '<span class="fwdc-block-body">' +
          '<span class="fwdc-block-name">' + name + '</span>' +
          '<span class="fwdc-block-meta' + (metaMono ? ' mono' : '') + '" data-block-meta="' + id + '">' + meta + '</span>' +
          '<span class="fwdc-block-life ' + lifeClass + '" data-block-life="' + id + '"><span class="dot"></span>' + lifeText + '</span>' +
        '</span>' +
      '</button>';
  }

  function reasonBtn(r) {
    return '' +
      '<button type="button" class="fwdc-reason-btn" data-reason="' + r.id + '">' +
        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + r.icon + '</svg>' +
        '<span class="fwdc-reason-label">' + r.label + '</span>' +
        '<span class="fwdc-reason-desc">' + r.desc + '</span>' +
      '</button>';
  }

  function field(label, id, cls) {
    return '<div class="fwdc-field"><div class="fwdc-field-label">' + label + '</div>' +
           '<div class="fwdc-field-value' + (cls ? ' ' + cls : '') + '" id="' + id + '">—</div></div>';
  }

  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    '<div class="gb-modal-overlay" id="dc-overlay">' +
      '<div class="gb-modal xwide fwdc" role="dialog" aria-modal="true" aria-labelledby="dc-title">' +

        '<div class="gb-modal-head">' +
          '<div>' +
            '<div class="gb-modal-title" id="dc-title">Die change</div>' +
            '<div class="gb-modal-ctx">' +
              '<span class="ctx-chip warning" id="dc-line-chip"><span class="dot"></span>FL1 paused &middot; die change</span>' +
              '<span class="ctx-chip">Order <span class="mono" id="dc-order">FW-00421</span></span>' +
              '<span class="ctx-chip">Footage <span class="mono" id="dc-footage-chip">12,450 ft</span></span>' +
            '</div>' +
          '</div>' +
          '<button class="gb-modal-close" type="button" data-close="dc-overlay" aria-label="Close">&times;</button>' +
        '</div>' +

        '<div class="gb-modal-body fwdc-body">' +

          '<div class="fwdc-section">' +
            '<div class="fwdc-section-head">' +
              '<span class="fwdc-section-title">Die block</span>' +
              '<span class="fwdc-section-hint">Select which die block is being replaced</span>' +
            '</div>' +
            '<div class="fwdc-block-grid" id="dc-block-grid">' +
              blockCard("DB1", "DB1 &mdash; Draw box 1", 'Die 0.340"&nbsp;&nbsp;D-340-087', true, "amber", "73.7% life used &middot; 6,580 ft left") +
              blockCard("DB2", "DB2 &mdash; Draw box 2", 'Die 0.310"&nbsp;&nbsp;D-310-034', true, "red", "83.7% life used &middot; 3,580 ft left") +
              blockCard("BOTH", "Both blocks", "DB1 + DB2 simultaneous change", false, "amber", "Log both in a single event") +
            '</div>' +
          '</div>' +

          '<div class="fwdc-die-details">' +

            '<div class="fwdc-die-panel current">' +
              '<div class="fwdc-die-panel-head">' +
                '<div class="fwdc-die-panel-title">' +
                  '<h3 id="dc-current-title">Outgoing die &mdash; DB2</h3>' +
                  '<span class="fwdc-die-panel-role">being removed</span>' +
                '</div>' +
                '<span class="fwdc-auto-badge">' +
                  '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 12l2 2 4-4"/></svg>' +
                  'Auto-identified' +
                '</span>' +
              '</div>' +
              '<div class="fwdc-alpha-readout" id="dc-current-alpha">—</div>' +
              '<div class="fwdc-life-wrap">' +
                '<div class="fwdc-life-head"><span>Die life consumed</span><span class="fwdc-life-pct red" id="dc-current-pct">—</span></div>' +
                '<div class="fwdc-life-bar"><div class="fwdc-life-fill red" id="dc-current-bar" style="width:0%"></div></div>' +
              '</div>' +
              '<div class="fwdc-fields">' +
                field("Die size", "dc-current-size") +
                field("Footage on die", "dc-current-footage", "amber") +
                field("Sched. life", "dc-current-sched") +
                field("Remaining", "dc-current-remaining", "amber") +
                field("Die type", "dc-current-type", "plain") +
                field("Installed", "dc-current-installed", "plain") +
              '</div>' +
            '</div>' +

            '<div class="fwdc-die-panel incoming">' +
              '<div class="fwdc-die-panel-head">' +
                '<div class="fwdc-die-panel-title">' +
                  '<h3 id="dc-incoming-title">New die &mdash; DB2</h3>' +
                  '<span class="fwdc-die-panel-role">being installed</span>' +
                '</div>' +
                '<span class="fwdc-scan-badge">' +
                  '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7V5a2 2 0 0 1 2-2h2"/><path d="M16 3h2a2 2 0 0 1 2 2v2"/><path d="M20 17v2a2 2 0 0 1-2 2h-2"/><path d="M8 21H6a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/></svg>' +
                  'Scan or enter' +
                '</span>' +
              '</div>' +
              '<div class="fwdc-alpha-wrap">' +
                '<span class="fwdc-scan-icon">' + IC_SCAN + '</span>' +
                '<input class="fwdc-alpha-input" type="text" id="dc-new-alpha" data-autofocus placeholder="Scan die alpha&hellip;">' +
              '</div>' +
              '<div class="fwdc-condition">' +
                '<button type="button" class="fwdc-condition-btn new selected" data-condition="new">New</button>' +
                '<button type="button" class="fwdc-condition-btn recond" data-condition="recond">Reconditioned</button>' +
              '</div>' +
              '<div class="fwdc-fields">' +
                field("Die size", "dc-new-size") +
                field("Condition", "dc-new-condition", "plain success") +
                field("Source", "dc-new-source", "plain sm") +
                field("Inspection", "dc-new-inspection", "plain success sm") +
                field("Die type", "dc-new-type", "plain") +
                field("Sched. life", "dc-new-sched") +
              '</div>' +
            '</div>' +

          '</div>' +

          '<div class="fwdc-section">' +
            '<div class="fwdc-section-head">' +
              '<span class="fwdc-section-title">Reason for change</span>' +
              '<span class="fwdc-section-hint">Select the primary reason this die is being replaced</span>' +
            '</div>' +
            '<div class="fwdc-reason-grid" id="dc-reason-grid">' +
              REASONS.map(reasonBtn).join("") +
            '</div>' +
          '</div>' +

          '<div class="fwdc-conditional" id="dc-hold-wrap">' +
            '<div class="fwdc-hold">' +
              '<div class="fwdc-hold-head">' + IC_WARN +
                '<div>' +
                  '<div class="fwdc-hold-title">Quality hold may be required</div>' +
                  '<div class="fwdc-hold-sub">WIP produced with a failed die may be off-spec. Flag the footage range for QA review.</div>' +
                '</div>' +
              '</div>' +
              '<div class="fwdc-hold-fields">' +
                '<div class="fwdc-hold-field">' +
                  '<span class="fwdc-hold-label">Hold from footage</span>' +
                  '<input class="fwdc-hold-input" type="text" id="dc-hold-from" value="8,200" placeholder="ft">' +
                '</div>' +
                '<div class="fwdc-hold-field">' +
                  '<span class="fwdc-hold-label">Hold to footage</span>' +
                  '<input class="fwdc-hold-input" type="text" id="dc-hold-to" placeholder="ft" readonly>' +
                '</div>' +
                '<button type="button" class="fwdc-flag-btn" id="dc-flag-btn">' + IC_FLAG + ' Flag WIP for QA hold</button>' +
              '</div>' +
            '</div>' +
          '</div>' +

          '<div class="fwdc-conditional" id="dc-spc-wrap">' +
            '<div class="fwdc-spc">' +
              '<div class="fwdc-spc-left">' + IC_INFO +
                '<div>' +
                  '<div class="fwdc-spc-title">SPC Checkpoint required on resume</div>' +
                  '<div class="fwdc-spc-sub">Operator must verify the new die is hitting gauge target before the run continues. The SPC Checkpoint opens as soon as this change is confirmed.</div>' +
                '</div>' +
              '</div>' +
              '<div class="fwdc-spc-toggle-row">' +
                '<span class="fwdc-spc-toggle-label">Require SPC on resume</span>' +
                '<label class="fwdc-toggle">' +
                  '<input type="checkbox" id="dc-spc-toggle" checked>' +
                  '<span class="fwdc-toggle-track"></span>' +
                  '<span class="fwdc-toggle-thumb"></span>' +
                '</label>' +
              '</div>' +
            '</div>' +
          '</div>' +

        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="gb-modal-stamp">' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Operator</span><span class="gb-modal-stamp-value" id="dc-operator">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Timestamp</span><span class="gb-modal-stamp-value mono" id="dc-stamp-time">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Footage at change</span><span class="gb-modal-stamp-value mono" id="dc-footage">—</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Output coil</span><span class="gb-modal-stamp-value mono" id="dc-coil">—</span></div>' +
          '</div>' +
          '<div class="modal-foot-actions">' +
            '<button type="button" class="fwdc-btn" data-close="dc-overlay">Cancel</button>' +
            '<button type="button" class="fwdc-btn primary" id="dc-confirm">' + IC_CHECK +
              'Confirm die change &middot; <span class="mono" id="dc-confirm-label">DB2</span>' +
            '</button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap);

  /* ── State ──────────────────────────────────────────────────── */
  var CTX = null;
  var currentBlock = "DB2";
  var currentReason = "planned";
  var currentCondition = "new";
  var flagged = false;
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

  /* ── Rendering ──────────────────────────────────────────────── */
  function renderBlockCards() {
    var dies = CTX.dies;
    ["DB1", "DB2"].forEach(function (id) {
      var d = dies[id];
      if (!d) return;
      var meta = document.querySelector('[data-block-meta="' + id + '"]');
      var life = document.querySelector('[data-block-life="' + id + '"]');
      if (meta) meta.innerHTML = "Die " + d.size + "&nbsp;&nbsp;" + d.alpha;
      if (life) {
        life.className = "fwdc-block-life " + d.pctClass;
        life.innerHTML = '<span class="dot"></span>' + d.pct + "% life used &middot; " + d.remaining + " left";
      }
    });
  }

  function selectBlock(block) {
    currentBlock = block;
    document.querySelectorAll("#dc-block-grid .fwdc-block-card").forEach(function (c) {
      c.classList.toggle("selected", c.getAttribute("data-block") === block);
    });
    $("dc-confirm-label").textContent = block;

    var isBoth = block === "BOTH";
    /* BOTH shows DB2 as the representative panel — it is the block that wears
       fastest, so it is the one whose remaining life the operator is judging. */
    var d = isBoth ? CTX.dies.DB2 : CTX.dies[block];
    var nd = isBoth ? CTX.newDies.DB2 : CTX.newDies[block];
    if (!d || !nd) return;

    $("dc-current-title").textContent = isBoth ? "Outgoing dies — DB1 + DB2" : "Outgoing die — " + block;
    $("dc-incoming-title").textContent = isBoth ? "New dies — DB1 + DB2" : "New die — " + block;
    $("dc-current-alpha").textContent = isBoth ? CTX.dies.DB1.alpha + " / " + CTX.dies.DB2.alpha : d.alpha;
    $("dc-current-size").textContent = isBoth ? CTX.dies.DB1.size + " / " + CTX.dies.DB2.size : d.size;
    $("dc-current-footage").textContent = d.footage;
    $("dc-current-sched").textContent = isBoth ? "—" : d.sched;
    $("dc-current-remaining").textContent = isBoth ? "—" : d.remaining;
    $("dc-current-type").textContent = d.type;
    $("dc-current-installed").textContent = d.installed;

    var bar = $("dc-current-bar"), pct = $("dc-current-pct");
    bar.style.width = d.pct + "%";
    bar.className = "fwdc-life-fill " + d.pctClass;
    pct.textContent = d.pct + "%";
    pct.className = "fwdc-life-pct " + d.pctClass;

    $("dc-new-alpha").value = isBoth ? "" : nd.alpha;
    $("dc-new-size").textContent = isBoth ? "—" : nd.size;
    $("dc-new-type").textContent = nd.type || d.type;
    $("dc-new-sched").textContent = isBoth ? "—" : (nd.sched || d.sched);
    $("dc-new-source").textContent = nd.source || "Die room";
    $("dc-new-inspection").innerHTML = nd.inspection || "&#x2713; 06:45 AM";
  }

  function selectReason(reason) {
    currentReason = reason;
    document.querySelectorAll("#dc-reason-grid .fwdc-reason-btn").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-reason") === reason);
    });
    $("dc-hold-wrap").classList.toggle("visible", reason === "failure");
    $("dc-spc-wrap").classList.toggle("visible", reason === "gauge" || reason === "size");
  }

  function selectCondition(val) {
    currentCondition = val;
    document.querySelectorAll(".fwdc-condition-btn").forEach(function (b) {
      b.classList.toggle("selected", b.getAttribute("data-condition") === val);
    });
    var f = $("dc-new-condition");
    f.textContent = val === "new" ? "New" : "Reconditioned";
    f.className = "fwdc-field-value plain " + (val === "new" ? "success" : "amber");
  }

  function setFlagged(next) {
    flagged = next;
    var btn = $("dc-flag-btn");
    btn.classList.toggle("flagged", flagged);
    btn.innerHTML = flagged
      ? IC_CHECK + " QA hold flagged"
      : IC_FLAG + " Flag WIP for QA hold";
  }

  /* ── Wiring ─────────────────────────────────────────────────── */
  document.querySelectorAll("#dc-block-grid .fwdc-block-card").forEach(function (card) {
    card.addEventListener("click", function () { selectBlock(card.getAttribute("data-block")); });
  });
  document.querySelectorAll("#dc-reason-grid .fwdc-reason-btn").forEach(function (btn) {
    btn.addEventListener("click", function () { selectReason(btn.getAttribute("data-reason")); });
  });
  document.querySelectorAll(".fwdc-condition-btn").forEach(function (btn) {
    btn.addEventListener("click", function () { selectCondition(btn.getAttribute("data-condition")); });
  });
  $("dc-flag-btn").addEventListener("click", function () { setFlagged(!flagged); });

  $("dc-confirm").addEventListener("click", function () {
    var result = {
      block: currentBlock,
      reason: currentReason,
      condition: currentCondition,
      newAlpha: $("dc-new-alpha").value.trim(),
      qaHold: currentReason === "failure" && flagged
        ? { from: $("dc-hold-from").value.trim(), to: $("dc-hold-to").value.trim() }
        : null,
      spcRequired: (currentReason === "gauge" || currentReason === "size") && $("dc-spc-toggle").checked
    };

    var outgoing = currentBlock === "BOTH" ? CTX.dies.DB2 : CTX.dies[currentBlock];
    var incoming = currentBlock === "BOTH" ? CTX.newDies.DB2 : CTX.newDies[currentBlock];

    close();
    if (typeof CTX.onConfirm === "function") CTX.onConfirm(result);

    /* Chain into the SPC checkpoint the change just made mandatory. Opened after
       close() so the two dialogs never overlap — two live focus traps fight each
       other and the operator ends up unable to reach either set of buttons. */
    if (result.spcRequired && typeof window.openSpcCheckpoint === "function") {
      window.openSpcCheckpoint({
        line: CTX.line,
        orderNo: CTX.orderNo,
        checkpointType: "post-die-change",
        footage: CTX.footage,
        operator: CTX.operator,
        trigger: {
          kind: "die-change",
          block: currentBlock,
          from: outgoing ? outgoing.size : null,
          to: result.newAlpha && incoming ? incoming.size : null,
          footage: CTX.footage,
          by: CTX.operator,
          at: $("dc-stamp-time").textContent.split(" · ")[0]
        }
      });
    }
  });

  /* ── Open / close ───────────────────────────────────────────── */
  function close() {
    if (clockTimer) { clearInterval(clockTimer); clockTimer = null; }
    window.FwModal.close("dc-overlay");
  }

  window.openDieChange = function (ctx) {
    ctx = ctx || {};
    CTX = {
      line: ctx.line || "FL1",
      orderNo: ctx.orderNo || "FW-00421",
      block: ctx.block || "DB2",
      footage: ctx.footage || "12,450 ft",
      outputCoil: ctx.outputCoil || "FW-00421-C01",
      operator: ctx.operator || "Dave M.",
      dies: ctx.dies || DEFAULT_DIES,
      newDies: ctx.newDies || DEFAULT_NEW_DIES,
      onConfirm: ctx.onConfirm
    };

    $("dc-line-chip").innerHTML = '<span class="dot"></span>' + CTX.line + " paused &middot; die change";
    $("dc-order").textContent = CTX.orderNo;
    $("dc-footage-chip").textContent = CTX.footage;
    $("dc-operator").textContent = CTX.operator;
    $("dc-footage").textContent = CTX.footage;
    $("dc-coil").textContent = CTX.outputCoil;
    $("dc-hold-to").value = CTX.footage.replace(/\s*ft$/, "");

    renderBlockCards();
    selectBlock(CTX.block);
    selectReason("planned");
    selectCondition("new");
    setFlagged(false);
    $("dc-spc-toggle").checked = true;

    $("dc-stamp-time").textContent = stamp();
    clockTimer = setInterval(function () { $("dc-stamp-time").textContent = stamp(); }, 1000);

    window.FwModal.register("dc-overlay");
    window.FwModal.open("dc-overlay");
  };

  window.closeDieChange = close;
})();
