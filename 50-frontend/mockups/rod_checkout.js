/* =============================================================================
   rod_checkout.js - Rod checkout dialog (was dashboard_12_rod_checkout.html)
   =============================================================================
   Converted from a standalone screen to a popup on 1 Aug 2026, with the other
   run-event screens.

   Rod checkout has two modes, reached from opposite directions:

     Mode A - PRE-RUN. The rod was checked in but the run never started, so no
              footage exists. Two columns: why, and where the rod goes.
     Mode B - MID-RUN. The run produced footage, so there is a third decision the
              pre-run case does not have: what happens to the material already
              made. Reached only from a paused run.

   As a page it could not know which. It defaulted to Mode B behind a toggle, and
   arriving from a pause meant navigating away from the paused run and losing it.
   As a dialog the caller states the mode and supplies the rod, so Mode B opens
   over the pause that raised it and the footage frozen at that pause carries
   straight through.

   Include AFTER fw-modal.js, before </body>:

       <script src="fw-modal.js"></script>
       <script src="rod_checkout.js"></script>

   Open it with a context object (every key optional):

       openRodCheckout({
         mode:         'b',              // 'a' pre-run | 'b' mid-run
         line:         'FL1',
         orderNo:      'FW-00421',
         rodAlpha:     'R00042',
         payoff:       2,
         runId:        'RUN-0118',
         footage:      '8,220 ft',       // Mode B - footage frozen at the pause
         checkinTime:  '08:14 AM',       // Mode A - when the rod was checked in
         passSchedule: 'PS-1100-FL1-003',
         operator:     'Dave M.',
         onConfirm:    function (result) { ... }
       });

   `result` is { mode, runId, rodAlpha, payoff, reason, otherReason,
   rodDisposition, remainingWeightLb, materialDisposition, footage, notes }.

   The mode toggle is kept - a pre-run and a mid-run checkout are the same
   transaction seen at two moments, and operators asked to see both - but the
   caller sets the starting mode, so the toggle corrects a mistake rather than
   being how the screen gets configured.

   All CSS is scoped under .fwrc and every id is prefixed rc-: the screen defined
   bare .section, .btn, .option-card and .input at global scope, which collide
   with the active-run monitors this now opens over. The inline onclick handlers
   (selectOption / selectMatOption) were globals for the same reason and are now
   delegated listeners.

   Requires flat-wire-shopfloor.styles.css.
   ========================================================================== */
(function () {
  "use strict";
  if (window.openRodCheckout) return;     /* guard against double-inclusion */

  var styleEl = document.createElement("style");
  styleEl.setAttribute("data-fw-rod-checkout", "");
  styleEl.textContent = [
    '.fwrc .warning-chip{display: inline-flex; align-items: center; gap: 8px; padding: 8px 14px; background: var(--color-background-warning); color: var(--color-text-warning); border-radius: var(--border-radius-md); font-size: 14px; font-weight: 500;}',
    '.fwrc .warning-chip svg{width: 13px; height: 13px;}',
    '.fwrc .mode-toggle{display: flex; background: var(--color-background-secondary); border: 1px solid var(--color-border-secondary); border-radius: var(--border-radius-md); padding: 3px; gap: 2px;}',
    '.fwrc .mode-btn{padding: 7px 0; width: 148px; text-align: center; font-size: 14px; font-weight: 500; border-radius: 6px; cursor: pointer; font-family: var(--font-sans); border: none; background: transparent; color: var(--color-text-secondary); transition: background 0.15s, color 0.15s; flex-shrink: 0;}',
    '.fwrc .mode-btn.active{background: var(--color-background-primary); color: var(--color-text-primary); box-shadow: 0 1px 3px rgba(0,0,0,0.12);}',
    '.fwrc .context-banner{padding: 14px 22px; display: flex; justify-content: space-between; align-items: center; height: 94px;}',
    '.fwrc .context-facts{display: flex; gap: 28px; align-items: center;}',
    '.fwrc .context-fact{display: flex; flex-direction: column; gap: 3px;}',
    '.fwrc .context-fact-label{font-size: 14px; color: var(--color-text-tertiary); text-transform: uppercase; letter-spacing: 0.4px;}',
    '.fwrc .context-fact-value{font-size: 17px; font-weight: 500; font-family: var(--font-mono); color: var(--color-text-primary);}',
    '.fwrc .context-fact-value.plain{font-family: var(--font-sans);}',
    '.fwrc .context-fact-value.warn{color: var(--color-text-warning);}',
    '.fwrc .context-divider{width: 1px; height: 32px; background: var(--color-border-tertiary);}',
    '.fwrc .consequence-box{display: flex; gap: 12px; padding: 12px 16px; background: var(--color-background-warning); color: var(--color-text-warning); border-radius: var(--border-radius-md); font-size: 14px; max-width: 420px; align-items: flex-start;}',
    '.fwrc .consequence-box.pre-run{background: var(--color-background-info); color: var(--color-text-info);}',
    '.fwrc .consequence-icon{width: 26px; height: 26px; border-radius: 50%; background: var(--color-amber); color: #ffffff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 1px;}',
    '.fwrc .consequence-box.pre-run .consequence-icon{background: var(--color-blue);}',
    '.fwrc .consequence-icon svg{width: 12px; height: 12px;}',
    '.fwrc .consequence-body{line-height: 1.5;}',
    '.fwrc .consequence-body strong{font-weight: 600; display: block; margin-bottom: 2px;}',
    '.fwrc .consequence-body ul{margin: 4px 0 0 0; padding-left: 14px;}',
    '.fwrc .consequence-body ul li{margin-bottom: 1px;}',
    '.fwrc .main-row{display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; flex: 1; min-height: 0;}',
    '.fwrc .main-row.three-col{grid-template-columns: 1fr 1fr 1fr;}',
    '.fwrc .section{background: var(--color-background-primary); border: 0.5px solid var(--color-border-tertiary); border-radius: var(--border-radius-lg); padding: 18px 22px; display: flex; flex-direction: column;}',
    '.fwrc .section-header{display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;}',
    '.fwrc .section-title{font-size: 15px; font-weight: 500;}',
    '.fwrc .section-hint{font-size: 14px; color: var(--color-text-tertiary);}',
    '.fwrc .required::after{content: " *"; color: var(--color-red);}',
    '.fwrc .option-list{display: flex; flex-direction: column; gap: 8px; flex: 1;}',
    '.fwrc .option-card{display: flex; align-items: center; gap: 14px; padding: 13px 16px; border: 2px solid var(--color-border-secondary); border-radius: var(--border-radius-md); cursor: pointer; background: var(--color-background-primary); user-select: none; transition: all 0.15s;}',
    '.fwrc .option-card:hover{background: var(--color-background-secondary);}',
    '.fwrc .option-card.selected{border-color: var(--color-amber); background: var(--color-background-warning);}',
    '.fwrc .option-card.selected.blue-sel{border-color: var(--color-blue); background: var(--color-background-info);}',
    '.fwrc .option-card.selected.red-sel{border-color: var(--color-red); background: var(--color-background-danger);}',
    '.fwrc .option-card.selected.green-sel{border-color: var(--color-green); background: var(--color-background-success);}',
    '.fwrc .option-radio{width: 20px; height: 20px; border-radius: 50%; border: 2px solid var(--color-border-primary); flex-shrink: 0; position: relative;}',
    '.fwrc .option-card.selected .option-radio{border-width: 6px;}',
    '.fwrc .option-card.selected .option-radio{border-color: var(--color-amber);}',
    '.fwrc .option-card.selected.blue-sel .option-radio{border-color: var(--color-blue);}',
    '.fwrc .option-card.selected.red-sel .option-radio{border-color: var(--color-red);}',
    '.fwrc .option-card.selected.green-sel .option-radio{border-color: var(--color-green);}',
    '.fwrc .option-icon{width: 40px; height: 40px; border-radius: var(--border-radius-md); background: var(--color-background-secondary); display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: var(--color-text-secondary);}',
    '.fwrc .option-card.selected .option-icon{background: var(--color-amber); color: #ffffff;}',
    '.fwrc .option-card.selected.blue-sel .option-icon{background: var(--color-blue); color: #ffffff;}',
    '.fwrc .option-card.selected.red-sel .option-icon{background: var(--color-red); color: #ffffff;}',
    '.fwrc .option-card.selected.green-sel .option-icon{background: var(--color-green); color: #ffffff;}',
    '.fwrc .option-icon svg{width: 20px; height: 20px;}',
    '.fwrc .option-body{flex: 1;}',
    '.fwrc .option-name{font-size: 14px; font-weight: 500; margin-bottom: 2px;}',
    '.fwrc .option-desc{font-size: 14px; color: var(--color-text-secondary); line-height: 1.4;}',
    '.fwrc .option-card.selected .option-desc{color: inherit; opacity: 0.8;}',
    '.fwrc .other-wrap{display: none; margin-top: 4px; padding: 12px 14px; background: var(--color-background-secondary); border-radius: var(--border-radius-md); border-left: 3px solid var(--color-amber);}',
    '.fwrc .other-wrap.visible{display: block;}',
    '.fwrc .other-label{font-size: 14px; color: var(--color-text-secondary); margin-bottom: 6px; font-weight: 500;}',
    '.fwrc .weight-row{display: none; margin-top: 6px; padding: 12px 14px; background: var(--color-background-secondary); border-radius: var(--border-radius-md); gap: 12px; align-items: center;}',
    '.fwrc .weight-row.visible{display: flex;}',
    '.fwrc .weight-label{font-size: 14px; color: var(--color-text-secondary); white-space: nowrap;}',
    '.fwrc .weight-input-wrap{position: relative; flex: 1;}',
    '.fwrc .weight-input{width: 100%; height: 40px; padding: 0 40px 0 14px; font-size: 14px; font-family: var(--font-mono); color: var(--color-text-primary); background: var(--color-background-primary); border: 1px solid var(--color-border-secondary); border-radius: var(--border-radius-md); outline: none;}',
    '.fwrc .weight-input:focus{border-color: var(--color-blue); box-shadow: 0 0 0 3px rgba(24, 95, 165, 0.18);}',
    '.fwrc .weight-unit{position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-size: 14px; color: var(--color-text-tertiary); pointer-events: none;}',
    '.fwrc .weight-optional{font-size: 14px; color: var(--color-text-tertiary); white-space: nowrap;}',
    '.fwrc .textarea{width: 100%; padding: 12px 14px; font-size: 14px; font-family: var(--font-sans); color: var(--color-text-primary); background: var(--color-background-primary); border: 1px solid var(--color-border-secondary); border-radius: var(--border-radius-md); resize: none; outline: none; flex: 1; min-height: 70px;}',
    '.fwrc .textarea:focus{border-color: var(--color-blue); box-shadow: 0 0 0 3px rgba(24, 95, 165, 0.18);}',
    '.fwrc .input{width: 100%; height: 46px; padding: 0 14px; font-size: 14px; font-family: var(--font-sans); color: var(--color-text-primary); background: var(--color-background-primary); border: 1px solid var(--color-border-secondary); border-radius: var(--border-radius-md); outline: none;}',
    '.fwrc .input:focus{border-color: var(--color-blue); box-shadow: 0 0 0 3px rgba(24, 95, 165, 0.18);}',
    '.fwrc .footage-callout{display: flex; align-items: center; gap: 16px; padding: 12px 16px; background: var(--color-background-secondary); border-radius: var(--border-radius-md); margin-bottom: 12px; border-left: 3px solid var(--color-amber);}',
    '.fwrc .footage-callout-label{font-size: 14px; color: var(--color-text-secondary);}',
    '.fwrc .footage-callout-value{font-size: 22px; font-weight: 600; font-family: var(--font-mono); color: var(--color-text-primary);}',
    '.fwrc .footage-callout-sub{font-size: 14px; color: var(--color-text-tertiary);}',
    '.fwrc .partial-note{display: none; margin-top: 6px; padding: 10px 14px; background: var(--color-background-success); color: var(--color-text-success); border-radius: var(--border-radius-md); font-size: 14px; border-left: 3px solid var(--color-green); line-height: 1.5;}',
    '.fwrc .partial-note.visible{display: block;}',
    '.fwrc .partial-note strong{font-weight: 600;}',
    '.fwrc .btn{height: 52px; padding: 0 24px; font-size: 14px; font-weight: 500; border-radius: var(--border-radius-md); cursor: pointer; font-family: var(--font-sans); border: 1px solid var(--color-border-secondary); background: var(--color-background-primary); color: var(--color-text-primary); transition: all 0.15s; display: inline-flex; align-items: center; gap: 10px;}',
    '.fwrc .btn:hover{background: var(--color-background-secondary);}',
    '.fwrc .btn:active{transform: scale(0.98);}',
    '.fwrc .btn svg{width: 16px; height: 16px;}',
    '.fwrc .btn-confirm{background: var(--color-amber); border-color: var(--color-amber); color: #ffffff; padding: 0 30px;}',
    '.fwrc .btn-confirm:hover{background: #d18a1a;}',
    '.fwrc .mode-a-only{display: none;}',
    '.fwrc .mode-b-only{display: flex;}',
    '.fwrc.mode-a .mode-a-only{display: flex;}',
    '.fwrc.mode-a .mode-b-only{display: none;}',
    '.fwrc.mode-a .main-row{grid-template-columns: 1fr 1fr;}',
    '.fwrc .hide{display: none !important;}',
    /* Dialog-shell overrides: the screen's own header and footer are replaced by
       the shared .gb-modal chrome, and the grid no longer sits in a 1024px page. */
    /* Wider than .xwide's 1120px. Three decision columns at 1120 leave ~340px each,
       which wraps almost every option description onto a third line; at 1220 they get
       ~370px and the dialog fits the 1280x1024 panel at 1:1 instead of being scaled
       down through the 14px shopfloor floor. */
    '.gb-modal.fwrc{width:1220px}',
    '.fwrc .fwrc-body{display:flex;flex-direction:column;gap:12px}',
    /* nowrap + a shrinkable facts row: allowed to wrap, the banner became two rows
       (207px) and pushed the dialog past what the 1280x1024 panel can show at 1:1. */
    '.fwrc .context-banner{height:auto;padding:12px 16px;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);gap:16px;flex-wrap:nowrap}',
    '.fwrc .context-facts{flex:1;min-width:0;gap:18px}',
    '.fwrc .consequence-box{flex:0 1 440px;min-width:0}',
    /* The three consequences read as one line rather than a bulleted stack. As a
       stack they were the tallest thing in the banner, and they are a short list of
       facts, not steps to follow in order. */
    '.fwrc .consequence-body ul{display:flex;flex-wrap:wrap;gap:4px 12px;margin:3px 0 0;padding:0;list-style:none}',
    '.fwrc .consequence-body ul li{margin:0;white-space:nowrap}',
    '.fwrc .consequence-body ul li + li::before{content:"\\00b7";margin-right:12px;opacity:.55}',
    '.fwrc .main-row{flex:0 0 auto}',
    '.fwrc .section{padding:14px 16px}',
    '.fwrc .option-list{flex:0 0 auto;gap:7px}',
    /* Trimmed from 13px/40px: the three columns carry up to six cards each, so a few
       pixels per card is the difference between fitting the panel and being scaled. */
    '.fwrc .option-card{padding:10px 14px;gap:12px}',
    '.fwrc .option-icon{width:36px;height:36px}',
    '.fwrc .textarea{flex:0 0 auto;min-height:52px}',
    /* The footage callout stacked label / value / source over three lines and
       restated the figure already in the banner two rows above. Kept — it anchors
       this column's question — but laid out on one line. It was the tallest thing
       in the tallest column, and so what pushed the dialog off the panel. */
    '.fwrc .footage-callout{padding:9px 14px;margin-bottom:10px;gap:10px;flex-wrap:wrap}',
    '.fwrc .footage-callout > div{display:flex;align-items:baseline;gap:10px;flex-wrap:wrap}',
    '.fwrc .footage-callout-value{font-size:18px}',
    '.fwrc .partial-note{padding:8px 12px;line-height:1.45}',
    '.fwrc.mode-a .mode-b-only{display:none}',
    '.fwrc.mode-b .mode-a-only{display:none}'
  ].join("\n");
  document.head.appendChild(styleEl);

  var IC_CHECK = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';

  /* -- Markup -------------------------------------------------- */
  var wrap = document.createElement("div");
  wrap.innerHTML = '' +
    '<div class="gb-modal-overlay" id="rc-overlay">' +
      '<div class="gb-modal xwide fwrc mode-b" role="dialog" aria-modal="true" aria-labelledby="rc-title">' +

        '<div class="gb-modal-head">' +
          '<div>' +
            '<div class="gb-modal-title" id="rc-title">Checkout</div>' +
            '<div class="gb-modal-ctx">' +
              '<span class="ctx-chip warning" id="rc-line-chip"><span class="dot"></span>FL1 paused &middot; mid-run checkout</span>' +
              '<span class="ctx-chip">Order <span class="mono" id="rc-order">&mdash;</span></span>' +
              '<span class="ctx-chip">Rod <span class="mono" id="rc-alpha">&mdash;</span></span>' +
              '<span class="ctx-chip">Payoff <span class="mono" id="rc-payoff">&mdash;</span></span>' +
            '</div>' +
          '</div>' +
          '<div style="display:flex;align-items:center;gap:12px">' +
            '<div class="mode-toggle">' +
              '<button class="mode-btn" type="button" id="rc-btn-mode-a" data-mode="a">Mode A &middot; Pre-Run</button>' +
              '<button class="mode-btn active" type="button" id="rc-btn-mode-b" data-mode="b">Mode B &middot; Mid-Run</button>' +
            '</div>' +
            '<button class="gb-modal-close" type="button" data-close="rc-overlay" aria-label="Close">&times;</button>' +
          '</div>' +
        '</div>' +

        '<div class="gb-modal-body fwrc-body">' +

          '<div class="context-banner">' +
            '<div class="context-facts">' +
              '<div class="context-fact">' +
                '<span class="context-fact-label">Rod alpha</span>' +
                '<span class="context-fact-value" id="rc-fact-alpha">&mdash;</span>' +
              '</div>' +
              '<div class="context-divider"></div>' +
              '<div class="context-fact">' +
                '<span class="context-fact-label">Payoff position</span>' +
                '<span class="context-fact-value plain" id="rc-fact-payoff">&mdash;</span>' +
              '</div>' +
              '<div class="context-divider"></div>' +
              '<div class="context-fact">' +
                '<span class="context-fact-label">Order</span>' +
                '<span class="context-fact-value" id="rc-fact-order">&mdash;</span>' +
              '</div>' +
              '<div class="context-divider mode-b-only"></div>' +
              '<div class="context-fact mode-b-only">' +
                '<span class="context-fact-label">Footage at checkout</span>' +
                '<span class="context-fact-value warn" id="rc-fact-footage">&mdash;</span>' +
              '</div>' +
              '<div class="context-divider mode-a-only"></div>' +
              '<div class="context-fact mode-a-only">' +
                '<span class="context-fact-label">Check-in time</span>' +
                '<span class="context-fact-value plain" style="font-size:15px" id="rc-fact-checkin">&mdash;</span>' +
              '</div>' +
              '<div class="context-divider"></div>' +
              '<div class="context-fact">' +
                '<span class="context-fact-label">Pass schedule</span>' +
                '<span class="context-fact-value plain" style="font-size:14px" id="rc-fact-schedule">&mdash;</span>' +
              '</div>' +
            '</div>' +
      '<!-- Mode B consequence -->' +
      '<div class="consequence-box" id="rc-consequence-b">' +
      '<span class="consequence-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>' +
      '</span>' +
      '<span class="consequence-body">' +
      '<strong>This checkout closes the partial run</strong>' +
      '<ul>' +
      '<li>Pass schedule acknowledgment voided</li>' +
      '<li>PLC tags cleared for Payoff 2</li>' +
      '<li>Line returns to idle &mdash; Dashboard 2 ready</li>' +
      '</ul>' +
      '</span>' +
      '</div>' +
      '<!-- Mode A consequence -->' +
      '<div class="consequence-box pre-run" id="rc-consequence-a" style="display:none;">' +
      '<span class="consequence-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>' +
      '</span>' +
      '<span class="consequence-body">' +
      '<strong>No footage produced &mdash; safe to void</strong>' +
      '<ul>' +
      '<li>Pass schedule acknowledgment voided</li>' +
      '<li>PLC tags cleared for Payoff 2</li>' +
      '<li>Rod returned to inventory (status updated)</li>' +
      '</ul>' +
      '</span>' +
      '</div>' +
          '</div>' +

      '<div class="main-row" id="rc-main-grid">' +
      '<!-- Column 1: Checkout reason -->' +
      '<div class="section">' +
      '<div class="section-header">' +
      '<span class="section-title required">Checkout reason</span>' +
      '<span class="section-hint" id="rc-reason-hint">Why is this rod being removed?</span>' +
      '</div>' +
      '<!-- Mode B reasons -->' +
      '<div class="option-list" id="rc-reasons-b">' +
      '<div class="option-card" data-group="reason-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Equipment failure</div>' +
      '<div class="option-desc">Machine fault, component failure, or unplanned downtime</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card" data-group="reason-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Quality hold</div>' +
      '<div class="option-desc">Out-of-spec gauge / width / surface — supervisor hold required</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card" data-group="reason-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Order quantity reached</div>' +
      '<div class="option-desc">Required footage or weight for the order is complete</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card selected" data-group="reason-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Shift deferral</div>' +
      '<div class="option-desc">Continuing on next shift or scheduled restart</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card" data-group="reason-b" data-other="true">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Other</div>' +
      '<div class="option-desc">Enter reason below</div>' +
      '</div>' +
      '</div>' +
      '<div class="other-wrap" id="rc-other-b">' +
      '<div class="other-label">Specify reason (required)</div>' +
      '<input type="text" class="input" placeholder="Describe the reason for checkout...">' +
      '</div>' +
      '</div>' +
      '<!-- Mode A reasons (hidden by default) -->' +
      '<div class="option-list" id="rc-reasons-a" style="display:none;">' +
      '<div class="option-card selected blue-sel" data-group="reason-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7V5a2 2 0 0 1 2-2h2"/><path d="M16 3h2a2 2 0 0 1 2 2v2"/><path d="M20 17v2a2 2 0 0 1-2 2h-2"/><path d="M8 21H6a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Wrong rod / mis-scan</div>' +
      '<div class="option-desc">Incorrect rod scanned or loaded into payoff position</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card blue-sel" data-group="reason-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Order cancelled / deferred</div>' +
      '<div class="option-desc">Job is no longer active; rod not needed on this line now</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card blue-sel" data-group="reason-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Failed re-inspection</div>' +
      '<div class="option-desc">Rod failed visual inspection after being staged at payoff</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card blue-sel" data-group="reason-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Relocated to different line</div>' +
      '<div class="option-desc">Rod reassigned to FL1 / FL3 by supervisor</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card blue-sel" data-group="reason-a" data-other="true">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Other</div>' +
      '<div class="option-desc">Enter reason below</div>' +
      '</div>' +
      '</div>' +
      '<div class="other-wrap" id="rc-other-a">' +
      '<div class="other-label">Specify reason (required)</div>' +
      '<input type="text" class="input" placeholder="Describe the reason for checkout...">' +
      '</div>' +
      '</div>' +
      '</div>' +
      '<!-- Column 2: Rod disposition -->' +
      '<div class="section">' +
      '<div class="section-header">' +
      '<span class="section-title required">Rod disposition</span>' +
      '<span class="section-hint">Where does this rod go after checkout?</span>' +
      '</div>' +
      '<!-- Mode B rod disposition -->' +
      '<div class="option-list" id="rc-rod-disp-b">' +
      '<div class="option-card" data-group="rod-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Hold — return to storage</div>' +
      '<div class="option-desc">Partial rod is re-usable &middot; status &rarr; <span class="mono" style="font-size:14px;">STAGED</span></div>' +
      '</div>' +
      '</div>' +
      '<div class="weight-row" id="rc-weight-hold">' +
      '<span class="weight-label">Remaining weight estimate</span>' +
      '<div class="weight-input-wrap">' +
      '<input type="text" class="weight-input" placeholder="0" value="">' +
      '<span class="weight-unit">lb</span>' +
      '</div>' +
      '<span class="weight-optional">optional</span>' +
      '</div>' +
      '<div class="option-card selected" data-group="rod-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2z"/><path d="M8 12l2 2 4-4"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Defer — continue later on this line</div>' +
      '<div class="option-desc">Rod stays staged at FL1 &middot; status &rarr; <span class="mono" style="font-size:14px;">STAGED</span> &middot; resumes on next check-in</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card red-sel" data-group="rod-b">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Scrap — rod not re-usable</div>' +
      '<div class="option-desc">Rod too short or damaged &middot; status &rarr; <span class="mono" style="font-size:14px;">SCRAP</span> &middot; routes to scrap module</div>' +
      '</div>' +
      '</div>' +
      '<div class="section" style="margin-top:auto; padding:14px 16px; background:var(--color-background-secondary); border:none; flex:0;">' +
      '<div class="section-header" style="margin-bottom:6px;">' +
      '<span class="section-title" style="font-size:14px;">Notes</span>' +
      '<span class="section-hint">optional</span>' +
      '</div>' +
      '<textarea class="textarea" style="min-height:56px;" placeholder="Any additional context about the rod condition, remaining weight, or reason for disposition..."></textarea>' +
      '</div>' +
      '</div>' +
      '<!-- Mode A rod disposition -->' +
      '<div class="option-list" id="rc-rod-disp-a" style="display:none;">' +
      '<div class="option-card selected blue-sel" data-group="rod-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Return to floor storage</div>' +
      '<div class="option-desc">Rod placed back in storage area &middot; status &rarr; <span class="mono" style="font-size:14px;">STAGED</span></div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card blue-sel" data-group="rod-a">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Return to warehouse</div>' +
      '<div class="option-desc">Rod returned to main stock &middot; status &rarr; <span class="mono" style="font-size:14px;">RECEIVED</span></div>' +
      '</div>' +
      '</div>' +
      '<div class="section" style="margin-top:auto; padding:14px 16px; background:var(--color-background-secondary); border:none; flex:0;">' +
      '<div class="section-header" style="margin-bottom:6px;">' +
      '<span class="section-title" style="font-size:14px;">Notes</span>' +
      '<span class="section-hint">optional</span>' +
      '</div>' +
      '<textarea class="textarea" style="min-height:80px;" placeholder="Any additional context about this checkout..."></textarea>' +
      '</div>' +
      '</div>' +
      '</div>' +
      '<!-- Column 3: In-process material disposition (Mode B only) -->' +
      '<div class="section" id="rc-material-disp-col">' +
      '<div class="section-header">' +
      '<span class="section-title required">In-process material</span>' +
      '<span class="section-hint">What happens to footage already produced?</span>' +
      '</div>' +
      '<div class="footage-callout">' +
      '<div>' +
      '<div class="footage-callout-label">Footage produced before checkout</div>' +
      '<div class="footage-callout-value" id="rc-footage-value">8,220 ft</div>' +
      '<div class="footage-callout-sub" id="rc-footage-sub">&mdash;</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-list">' +
      '<div class="option-card" data-group="mat">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Hold — pending supervisor review</div>' +
      '<div class="option-desc">Material placed in WIP held queue &middot; supervisor notified</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card red-sel" data-group="mat">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Scrap — discard all footage</div>' +
      '<div class="option-desc"><span id="rc-scrap-ft">8,220 ft</span> scrapped &middot; material routed to scrap module</div>' +
      '</div>' +
      '</div>' +
      '<div class="option-card selected green-sel" data-group="mat" data-partial="true">' +
      '<div class="option-radio"></div>' +
      '<div class="option-icon">' +
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>' +
      '</div>' +
      '<div class="option-body">' +
      '<div class="option-name">Accept as partial run</div>' +
      '<div class="option-desc">Generate spool alpha for <span id="rc-partial-ft">8,220 ft</span> &middot; available for FL2 check-in</div>' +
      '</div>' +
      '</div>' +
      '<div class="partial-note visible" id="rc-partial-note">' +
      '<strong>Spool alpha will be generated on confirm</strong>' +
      'System will create a partial spool alpha linked to rod <span id="rc-partial-rod">R00042</span> &middot; footage 0&ndash;<span id="rc-partial-range">8,220 ft</span> &middot; available in FL2 check-in queue. Supervisor acknowledgment is required before the spool enters the FL2 queue.' +
      '</div>' +
      '</div>' +
      '</div>' +

        '</div>' +

        '<div class="gb-modal-foot">' +
          '<div class="gb-modal-stamp">' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Operator</span><span class="gb-modal-stamp-value" id="rc-operator">&mdash;</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Timestamp</span><span class="gb-modal-stamp-value mono" id="rc-stamp-time">&mdash;</span></div>' +
            '<div class="gb-modal-stamp-item"><span class="gb-modal-stamp-label">Rod alpha</span><span class="gb-modal-stamp-value mono" id="rc-stamp-alpha">&mdash;</span></div>' +
            '<div class="gb-modal-stamp-item mode-b-only"><span class="gb-modal-stamp-label">Footage at checkout</span><span class="gb-modal-stamp-value mono" id="rc-stamp-footage">&mdash;</span></div>' +
          '</div>' +
          '<div class="modal-foot-actions">' +
            '<button type="button" class="btn" data-close="rc-overlay">Cancel</button>' +
            '<button type="button" class="btn btn-confirm" id="rc-confirm">' + IC_CHECK + '<span id="rc-confirm-label">Confirm checkout</span></button>' +
          '</div>' +
        '</div>' +

      '</div>' +
    '</div>';
  document.body.appendChild(wrap);
  window.FwModal.register("rc-overlay");

  /* -- State --------------------------------------------------- */
  var CTX = null;
  var mode = "b";
  var clockTimer = null;

  function $(id) { return document.getElementById(id); }
  function pad(n) { return String(n).padStart(2, "0"); }
  var MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  function stamp() {
    var d = new Date(), h = d.getHours(), ampm = h < 12 ? "AM" : "PM";
    return pad(h % 12 || 12) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds()) + " " + ampm +
           " \u00b7 " + MONTHS[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear();
  }
  function modal() { return document.querySelector("#rc-overlay .gb-modal"); }

  /* -- Mode -------------------------------------------------------
     Mode A has no in-process material to disposition, so its grid is two columns
     rather than three; .mode-a-only / .mode-b-only carry the rest. */
  function setMode(next) {
    mode = next;
    modal().classList.toggle("mode-a", next === "a");
    modal().classList.toggle("mode-b", next === "b");
    $("rc-btn-mode-a").classList.toggle("active", next === "a");
    $("rc-btn-mode-b").classList.toggle("active", next === "b");

    $("rc-reasons-a").style.display  = next === "a" ? "" : "none";
    $("rc-reasons-b").style.display  = next === "a" ? "none" : "";
    $("rc-rod-disp-a").style.display = next === "a" ? "" : "none";
    $("rc-rod-disp-b").style.display = next === "a" ? "none" : "";
    $("rc-material-disp-col").style.display = next === "a" ? "none" : "";
    $("rc-consequence-a").style.display = next === "a" ? "" : "none";
    $("rc-consequence-b").style.display = next === "a" ? "none" : "";
    $("rc-main-grid").style.gridTemplateColumns = next === "a" ? "1fr 1fr" : "1fr 1fr 1fr";

    $("rc-line-chip").innerHTML = '<span class="dot"></span>' + (CTX ? CTX.line : "FL1") +
      (next === "a" ? " &middot; pre-run checkout" : " paused &middot; mid-run checkout");
    if (window.FwModal.fit) window.FwModal.fit("rc-overlay");
  }
  document.querySelectorAll("#rc-overlay .mode-btn").forEach(function (b) {
    b.addEventListener("click", function () { setMode(b.getAttribute("data-mode")); });
  });

  /* -- Option cards -----------------------------------------------
     Delegated by data-group, replacing the screen's inline onclick handlers. */
  function selectIn(group, card) {
    document.querySelectorAll('#rc-overlay [data-group="' + group + '"]').forEach(function (c) {
      c.classList.remove("selected");
    });
    card.classList.add("selected");

    if (group === "reason-b" || group === "reason-a") {
      var other = $(group === "reason-b" ? "rc-other-b" : "rc-other-a");
      if (other) other.classList.toggle("visible", !!card.getAttribute("data-other"));
    }
    if (group === "rod-b") {
      var wh = $("rc-weight-hold");
      /* The remaining-weight estimate only means anything for a rod going back to
         storage; Defer and Scrap have nothing to weigh. */
      if (wh) wh.classList.toggle("visible", card.querySelector(".option-name").textContent.indexOf("Hold") === 0);
    }
    if (group === "mat") {
      var note = $("rc-partial-note");
      if (note) note.classList.toggle("visible", !!card.getAttribute("data-partial"));
    }
    if (window.FwModal.fit) window.FwModal.fit("rc-overlay");
  }
  document.querySelectorAll("#rc-overlay [data-group]").forEach(function (card) {
    card.addEventListener("click", function () { selectIn(card.getAttribute("data-group"), card); });
  });

  function selectedIn(group) {
    var el = document.querySelector('#rc-overlay [data-group="' + group + '"].selected');
    return el ? el.querySelector(".option-name").textContent.trim() : null;
  }

  /* -- Confirm ------------------------------------------------- */
  $("rc-confirm").addEventListener("click", function () {
    var otherWrap = $(mode === "a" ? "rc-other-a" : "rc-other-b");
    var otherInput = otherWrap ? otherWrap.querySelector("input") : null;
    var weightWrap = $("rc-weight-hold");
    var weightInput = weightWrap ? weightWrap.querySelector("input") : null;
    var notesEl = document.querySelector("#rc-" + (mode === "a" ? "rod-disp-a" : "rod-disp-b") + " textarea");

    var result = {
      mode: mode,
      runId: CTX.runId,
      rodAlpha: CTX.rodAlpha,
      payoff: CTX.payoff,
      reason: selectedIn(mode === "a" ? "reason-a" : "reason-b"),
      otherReason: otherWrap && otherWrap.classList.contains("visible") && otherInput
        ? otherInput.value.trim() : null,
      rodDisposition: selectedIn(mode === "a" ? "rod-a" : "rod-b"),
      remainingWeightLb: weightWrap && weightWrap.classList.contains("visible") && weightInput
        ? (weightInput.value.trim() || null) : null,
      /* Mode A produced no footage, so there is nothing to disposition. */
      materialDisposition: mode === "b" ? selectedIn("mat") : null,
      footage: mode === "b" ? CTX.footage : null,
      notes: notesEl ? (notesEl.value.trim() || null) : null
    };
    close();
    if (typeof CTX.onConfirm === "function") CTX.onConfirm(result);
  });

  /* -- Open / close -------------------------------------------- */
  function close() {
    if (clockTimer) { clearInterval(clockTimer); clockTimer = null; }
    window.FwModal.close("rc-overlay");
  }

  window.openRodCheckout = function (ctx) {
    ctx = (ctx && typeof ctx === "object" && typeof ctx.preventDefault !== "function") ? ctx : {};
    var host = (typeof window.fwRunCtx === "function") ? window.fwRunCtx() : {};
    function pick(k, fallback) { return ctx[k] != null ? ctx[k] : (host[k] != null ? host[k] : fallback); }

    CTX = {
      mode: ctx.mode || "b",
      line: pick("line", "FL1"),
      orderNo: pick("orderNo", "FW-00421"),
      rodAlpha: ctx.rodAlpha || host.alpha || "R00042",
      payoff: ctx.payoff != null ? ctx.payoff : 2,
      runId: pick("runId", null),
      footage: pick("footage", "8,220 ft"),
      checkinTime: ctx.checkinTime || "08:14 AM",
      passSchedule: ctx.passSchedule || "PS-1100-FL1-003",
      operator: pick("operator", "Dave M."),
      onConfirm: ctx.onConfirm
    };

    $("rc-order").textContent = CTX.orderNo;
    $("rc-alpha").textContent = CTX.rodAlpha;
    $("rc-payoff").textContent = CTX.payoff;
    $("rc-fact-alpha").textContent = CTX.rodAlpha;
    $("rc-fact-payoff").textContent = "Payoff " + CTX.payoff;
    $("rc-fact-order").textContent = CTX.orderNo;
    $("rc-fact-footage").textContent = CTX.footage;
    $("rc-fact-checkin").textContent = CTX.checkinTime;
    $("rc-fact-schedule").textContent = CTX.passSchedule;
    $("rc-operator").textContent = CTX.operator;
    $("rc-stamp-alpha").textContent = CTX.rodAlpha;
    $("rc-stamp-footage").textContent = CTX.footage;

    $("rc-footage-value").textContent = CTX.footage;
    $("rc-footage-sub").innerHTML = "from rod " + CTX.rodAlpha + " &middot; order " + CTX.orderNo;
    $("rc-scrap-ft").textContent = CTX.footage;
    $("rc-partial-ft").textContent = CTX.footage;
    $("rc-partial-rod").textContent = CTX.rodAlpha;
    $("rc-partial-range").textContent = CTX.footage;

    setMode(CTX.mode);

    $("rc-stamp-time").textContent = stamp();
    clockTimer = setInterval(function () { $("rc-stamp-time").textContent = stamp(); }, 1000);

    window.FwModal.open("rc-overlay");
  };

  window.closeRodCheckout = close;
})();
