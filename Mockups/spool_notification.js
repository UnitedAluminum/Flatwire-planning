/* spool_notification.js — Shared "spool approaching target weight" operator notification.
 *
 * Non-blocking corner card raised automatically while the line is running, at 75% / 90% / 100%
 * of the target spool weight. See Analysis/SpoolCompletionNotification.md for the requirement.
 *
 * Behavior:
 *   · 75% / 90% / 100% of target → notification raised automatically
 *   · Acknowledge → dismissed, and the NEXT milestone is armed
 *   · Not acknowledged → stays visible and keeps updating with live production data
 *   · Next milestone reached while unacknowledged → the card escalates IN PLACE (never stacks)
 *   · Never modal — no backdrop, no focus trap; every control behind it stays operable
 *   · After acknowledgement a compact pill keeps live spool progress visible (no second alert)
 *
 * Include via <script src="spool_notification.js"></script> before </body>, after the dashboard's
 * own scripts. Configure per screen with an optional FW_SPOOL_CONFIG object declared BEFORE this
 * file (all keys optional):
 *
 *   <script>
 *     var FW_SPOOL_CONFIG = {
 *       label:        'Spool',      // 'Spool' on FL1 (TKUP-1) · 'Coil' on FL2/FL3 (TKUP-2)
 *       takeup:       'TKUP-1',
 *       targetLb:     2000,         // order "Max Wgt of Spool", capped by take-up capacity
 *       startLb:      1440,         // simulated weight already on the take-up
 *       gaugeIn:      0.110,
 *       widthIn:      0.625,
 *       densityLbIn3: 0.098,        // alloy 1100
 *       speedFpm:     1620,
 *       spoolAlpha:   'SP-00031',
 *       demo:         true          // show the mockup-only milestone jump controls
 *     };
 *   </script>
 *
 * Requires the flat wire shopfloor design tokens (flat-wire-shopfloor.styles.css).
 */
(function () {

  /* ── Config ─────────────────────────────────────────────────── */
  var user = (typeof window.FW_SPOOL_CONFIG === 'object' && window.FW_SPOOL_CONFIG) || {};
  var CFG = {
    label:        user.label        || 'Spool',
    takeup:       user.takeup       || 'TKUP-1',
    targetLb:     user.targetLb     || 2000,   // default target spool weight (lb)
    startLb:      user.startLb      != null ? user.startLb : 1440,
    gaugeIn:      user.gaugeIn      || 0.110,
    widthIn:      user.widthIn      || 0.625,
    densityLbIn3: user.densityLbIn3 || 0.098,
    speedFpm:     user.speedFpm     || 1620,
    spoolAlpha:   user.spoolAlpha   || 'SP-00031',
    demo:         user.demo !== false,
    tickMs:       user.tickMs       || 1000,

    /* Part B — PLC-confirmed stop → spool removal confirmation */
    line:         user.line         || null,          // 'FL1' · derived from the line badge when null
    stopDwellSec: user.stopDwellSec != null ? user.stopDwellSec : 5,
    spoolTareLb:  user.spoolTareLb  || 120,
    sourceRods:   user.sourceRods   || 'R00041, R00042',
    weldFt:       user.weldFt       || 8120,
    printer:      user.printer      || 'FL1-LBL-01',
    labelCopies:  user.labelCopies  || 2,

    /* Scale-vs-calculated reconciliation on the completion step */
    scaleTolerancePct: user.scaleTolerancePct != null ? user.scaleTolerancePct : 2
  };

  /* lb per foot of flat wire = gauge × width × 12 in/ft × alloy density */
  var LB_PER_FT = CFG.gaugeIn * CFG.widthIn * 12 * CFG.densityLbIn3;

  var MILESTONES = [
    { pct: 75,  key: 'm75',  tone: 'info',    badge: '75%',  title: CFG.label + ' nearing completion',
      lead: 'Approaching target ' + CFG.label.toLowerCase() + ' weight.' },
    { pct: 90,  key: 'm90',  tone: 'warn',    badge: '90%',  title: CFG.label + ' nearly full',
      lead: 'Prepare to close the ' + CFG.label.toLowerCase() + ' — target is close.' },
    { pct: 100, key: 'm100', tone: 'success', badge: '100%', title: 'Target ' + CFG.label.toLowerCase() + ' weight reached',
      lead: 'Ready to close the ' + CFG.label.toLowerCase() + ' at ' + CFG.takeup + '.' },
    { pct: 101, key: 'over', tone: 'danger',  badge: 'OVER', title: 'Over target ' + CFG.label.toLowerCase() + ' weight',
      lead: 'Take-up should be stopped — weight is past target.' }
  ];

  /* ── Styles ─────────────────────────────────────────────────── */
  var styleEl = document.createElement('style');
  styleEl.textContent = [
    /* Card — corner overlay, deliberately NOT a modal: no overlay element exists at all */
    '.fwn-card{position:fixed;right:20px;bottom:124px;z-index:600;width:400px;',
      'background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);',
      'border-radius:var(--border-radius-lg);box-shadow:0 14px 40px rgba(0,0,0,.20);',
      'font-family:var(--font-sans);overflow:hidden;display:none}',
    '.fwn-card.open{display:block;animation:fwnIn .26s cubic-bezier(.4,0,.2,1)}',
    '.fwn-card.leaving{animation:fwnOut .2s ease forwards}',
    '@keyframes fwnIn{from{opacity:0;transform:translateY(14px) scale(.985)}to{opacity:1;transform:none}}',
    '@keyframes fwnOut{to{opacity:0;transform:translateY(10px) scale(.99)}}',
    '@keyframes fwnPulse{0%,100%{box-shadow:0 14px 40px rgba(0,0,0,.20)}',
      '45%{box-shadow:0 14px 40px rgba(0,0,0,.20),0 0 0 5px var(--fwn-glow)}}',
    '.fwn-card.escalate{animation:fwnPulse 1.1s ease 2}',

    /* Tone strip + header */
    '.fwn-accent{height:4px;background:var(--fwn-accent)}',
    '.fwn-head{display:flex;align-items:flex-start;gap:11px;padding:13px 16px 10px}',
    '.fwn-ic{width:34px;height:34px;border-radius:50%;flex-shrink:0;display:flex;align-items:center;',
      'justify-content:center;background:var(--fwn-bg);color:var(--fwn-fg)}',
    '.fwn-ic svg{width:19px;height:19px}',
    '.fwn-head-txt{flex:1;min-width:0}',
    '.fwn-title{font-size:15px;font-weight:600;color:var(--color-text-primary);line-height:1.25}',
    '.fwn-lead{font-size:14px;color:var(--color-text-secondary);margin-top:3px;line-height:1.35}',
    '.fwn-badge{flex-shrink:0;font-family:var(--font-mono);font-size:14px;font-weight:700;',
      'padding:3px 9px;border-radius:999px;background:var(--fwn-bg);color:var(--fwn-fg)}',

    /* Primary reading — the actual processed weight */
    '.fwn-body{padding:0 16px 14px}',
    '.fwn-read{display:flex;align-items:flex-end;justify-content:space-between;gap:12px;',
      'padding:11px 14px;background:var(--color-background-secondary);',
      'border-radius:var(--border-radius-md);margin-bottom:11px}',
    '.fwn-read-k{font-size:14px;font-weight:600;letter-spacing:.4px;text-transform:uppercase;',
      'color:var(--color-text-tertiary);margin-bottom:4px}',
    '.fwn-actual{font-family:var(--font-mono);font-size:30px;font-weight:600;line-height:1;',
      'color:var(--fwn-fg)}',
    '.fwn-actual .u{font-family:var(--font-sans);font-size:14px;font-weight:500;',
      'color:var(--color-text-secondary);margin-left:4px}',
    '.fwn-target{text-align:right;font-size:14px;color:var(--color-text-secondary);white-space:nowrap}',
    '.fwn-target strong{display:block;font-family:var(--font-mono);font-size:16px;font-weight:600;',
      'color:var(--color-text-primary);margin-top:3px}',

    /* Progress with milestone ticks */
    '.fwn-bar-wrap{position:relative;margin-bottom:7px}',
    '.fwn-bar{height:11px;background:var(--color-background-tertiary);border-radius:999px;overflow:hidden}',
    '.fwn-fill{display:block;height:100%;border-radius:999px;background:var(--fwn-accent);',
      'transition:width .5s ease}',
    '.fwn-ticks{position:absolute;inset:0;pointer-events:none}',
    '.fwn-tick{position:absolute;top:-1px;width:1.5px;height:13px;background:var(--color-background-primary);opacity:.85}',
    '.fwn-tick-labels{position:relative;height:13px;margin-bottom:9px;font-family:var(--font-mono);',
      'font-size:14px;color:var(--color-text-tertiary)}',
    '.fwn-tick-labels span{position:absolute;transform:translateX(-50%);top:0}',
    '.fwn-tick-labels span.hit{color:var(--fwn-fg);font-weight:700}',

    /* Live secondary data */
    '.fwn-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px 14px;font-size:14px;margin-bottom:11px}',
    '.fwn-cell{display:flex;align-items:baseline;justify-content:space-between;gap:8px}',
    '.fwn-cell .k{color:var(--color-text-secondary)}',
    '.fwn-cell .v{font-family:var(--font-mono);font-weight:600;color:var(--color-text-primary);white-space:nowrap}',

    '.fwn-foot{display:flex;align-items:center;justify-content:space-between;gap:12px;',
      'padding-top:11px;border-top:0.5px solid var(--color-border-tertiary)}',
    '.fwn-live{display:inline-flex;align-items:center;gap:6px;font-size:14px;color:var(--color-text-tertiary)}',
    '.fwn-live .dot{width:7px;height:7px;border-radius:50%;background:var(--color-green);',
      'animation:fwnBlink 1.8s infinite}',
    '@keyframes fwnBlink{0%,100%{opacity:1}50%{opacity:.25}}',
    '.fwn-ack{border:none;border-radius:var(--border-radius-md);padding:9px 20px;cursor:pointer;',
      'font-family:var(--font-sans);font-size:14px;font-weight:600;color:#fff;',
      'background:var(--fwn-accent);transition:filter .12s,transform .1s}',
    '.fwn-ack:hover{filter:brightness(.92)}',
    '.fwn-ack:active{transform:scale(.97)}',

    /* Tone tokens — all from the existing semantic palette */
    '.fwn-card.t-info{--fwn-accent:var(--color-blue);--fwn-bg:var(--color-background-info);',
      '--fwn-fg:var(--color-text-info);--fwn-glow:rgba(24,95,165,.28)}',
    '.fwn-card.t-warn{--fwn-accent:var(--color-amber);--fwn-bg:var(--color-background-warning);',
      '--fwn-fg:var(--color-text-warning);--fwn-glow:rgba(239,159,39,.32)}',
    '.fwn-card.t-success{--fwn-accent:var(--color-green);--fwn-bg:var(--color-background-success);',
      '--fwn-fg:var(--color-text-success);--fwn-glow:rgba(29,158,117,.30)}',
    '.fwn-card.t-danger{--fwn-accent:var(--color-red);--fwn-bg:var(--color-background-danger);',
      '--fwn-fg:var(--color-text-danger);--fwn-glow:rgba(216,90,48,.32)}',

    /* Docked pill — passive visibility after acknowledgement */
    '.fwn-pill{position:fixed;right:20px;bottom:124px;z-index:599;display:none;align-items:center;gap:9px;',
      'padding:7px 13px;border:0.5px solid var(--color-border-tertiary);border-radius:999px;',
      'background:var(--color-background-primary);box-shadow:0 6px 18px rgba(0,0,0,.13);',
      'font-family:var(--font-sans);font-size:14px;color:var(--color-text-secondary);cursor:default}',
    '.fwn-pill.open{display:inline-flex}',
    '.fwn-pill .ok{display:inline-flex;align-items:center;justify-content:center;width:17px;height:17px;',
      'border-radius:50%;background:var(--color-background-success);color:var(--color-text-success);flex-shrink:0}',
    '.fwn-pill .ok svg{width:11px;height:11px}',
    '.fwn-pill strong{font-family:var(--font-mono);font-weight:600;color:var(--color-text-primary)}',
    '.fwn-pill-btn{display:none;border:1px solid var(--color-blue);background:var(--color-background-info);',
      'color:var(--color-text-info);border-radius:var(--border-radius-md);padding:4px 11px;margin-left:3px;',
      'font-family:var(--font-sans);font-size:14px;font-weight:600;cursor:pointer}',
    '.fwn-pill-btn:hover{background:var(--color-blue);color:#fff}',
    '.fwn-pill-btn.on{display:inline-block}',
    '.fwn-pill .mini{width:74px;height:6px;background:var(--color-background-tertiary);border-radius:999px;overflow:hidden}',
    '.fwn-pill .mini span{display:block;height:100%;background:var(--color-green);border-radius:999px;transition:width .5s ease}',

    /* Mockup-only demo controls */
    '.fwn-demo{position:fixed;left:96px;bottom:16px;z-index:598;display:none;align-items:center;gap:7px;',
      'padding:6px 11px;border:1px dashed var(--color-border-secondary);border-radius:var(--border-radius-md);',
      'background:var(--color-background-primary);box-shadow:0 4px 12px rgba(0,0,0,.10);',
      'font-family:var(--font-sans);font-size:14px;color:var(--color-text-tertiary)}',
    '.fwn-demo.on{display:inline-flex}',
    '.fwn-demo button{border:1px solid var(--color-border-secondary);background:var(--color-background-secondary);',
      'color:var(--color-text-secondary);border-radius:6px;padding:4px 9px;font-size:14px;font-weight:600;',
      'font-family:var(--font-mono);cursor:pointer}',
    '.fwn-demo button:hover{background:var(--color-background-info);color:var(--color-text-info);border-color:var(--color-blue)}',
    '.fwn-demo .sep{width:1px;height:16px;background:var(--color-border-tertiary)}',
    '.fwn-demo button.plc{border-color:var(--color-amber);color:var(--color-text-warning);background:var(--color-background-warning)}',
    '.fwn-demo button.plc:hover{background:var(--color-amber);color:#fff;border-color:var(--color-amber)}',

    /* ── Part B — PLC stop confirmation dialog (reuses the .gb-modal shell) ── */

    /* Colored identity band: what happened + the one number that matters */
    '.fwsc-band{display:flex;align-items:center;gap:16px;padding:17px 22px;color:#fff;background:var(--fwsc-band)}',
    '.fwsc-band-ic{width:46px;height:46px;border-radius:50%;flex-shrink:0;display:flex;align-items:center;',
      'justify-content:center;background:rgba(255,255,255,.18)}',
    '.fwsc-band-ic svg{width:25px;height:25px}',
    '.fwsc-band-txt{flex:1;min-width:0}',
    '.fwsc-band-title{font-size:19px;font-weight:600;line-height:1.2}',
    '.fwsc-band-sub{font-size:14px;opacity:.88;margin-top:3px;font-family:var(--font-mono)}',
    '.fwsc-band-num{text-align:right;flex-shrink:0}',
    '.fwsc-hero{font-family:var(--font-mono);font-size:33px;font-weight:600;line-height:1}',
    '.fwsc-hero-sub{font-size:14px;opacity:.88;margin-top:5px;white-space:nowrap}',
    '.fwsc-band.t-target{--fwsc-band:var(--color-green)}',
    '.fwsc-band.t-over{--fwsc-band:var(--color-red)}',
    '.fwsc-band.t-confirm{--fwsc-band:var(--color-blue)}',

    /* The dialog sizes to its content — nothing here is allowed to scroll */
    '.fwsc-modal{max-height:none}',
    '.fwsc-modal .gb-modal-body{overflow:visible;padding:16px 20px}',
    /* Step 2 is two columns: verification on the left, what-is-committed on the right */
    '.fwsc-cols{display:grid;grid-template-columns:1.3fr 1fr;gap:14px;align-items:start}',

    /* Weight verification — system-calculated vs scale, and which one to record */
    '.fwsc-verify{border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);',
      'padding:13px 15px;margin-bottom:0}',
    '.fwsc-verify-head{font-size:14px;font-weight:700;letter-spacing:.5px;text-transform:uppercase;',
      'color:var(--color-text-tertiary);margin-bottom:10px}',
    '.fwsc-wrow{display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px;align-items:start}',
    '.fwsc-wcell{display:flex;flex-direction:column;gap:5px;min-width:0}',
    '.fwsc-wcell .wk{font-size:14px;color:var(--color-text-secondary)}',
    '.fwsc-wcell .wv{font-family:var(--font-mono);font-size:19px;font-weight:600;color:var(--color-text-primary);line-height:1.1}',
    '.fwsc-wcell .wm{font-size:14px;color:var(--color-text-tertiary);line-height:1.35}',
    '.fwsc-wcell .wm strong{font-family:var(--font-mono);color:var(--color-text-primary)}',
    '.fwsc-winput{display:flex;align-items:center;gap:7px}',
    '.fwsc-winput input{width:104px;height:42px;padding:0 10px;font-family:var(--font-mono);font-size:19px;',
      'font-weight:600;color:var(--color-text-primary);background:var(--color-background-primary);',
      'border:1.5px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none}',
    '.fwsc-winput input:focus{border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,.14)}',
    '.fwsc-winput .u{font-size:14px;color:var(--color-text-secondary)}',
    '.fwsc-var{font-family:var(--font-mono);font-size:19px;font-weight:600;line-height:1.1;color:var(--color-text-tertiary)}',
    '.fwsc-var.ok{color:var(--color-text-success)}',
    '.fwsc-var.off{color:var(--color-text-danger)}',
    '.fwsc-tol{display:none;align-items:center;gap:9px;margin-top:12px;padding:10px 13px;',
      'border-radius:var(--border-radius-md);font-size:14px;line-height:1.4;font-weight:500}',
    '.fwsc-tol.on{display:flex}',
    '.fwsc-tol.ok{background:var(--color-background-success);color:var(--color-text-success)}',
    '.fwsc-tol.off{background:var(--color-background-danger);color:var(--color-text-danger)}',
    '.fwsc-basis-q{font-size:14px;font-weight:600;color:var(--color-text-primary);margin:12px 0 8px}',
    '.fwsc-basis{display:grid;grid-template-columns:1fr 1fr;gap:10px}',
    '.fwsc-bopt{display:flex;flex-direction:column;gap:3px;align-items:flex-start;text-align:left;',
      'padding:11px 13px;cursor:pointer;font-family:var(--font-sans);background:var(--color-background-primary);',
      'border:1.5px solid var(--color-border-secondary);border-radius:var(--border-radius-md);',
      'transition:border-color .13s,background .13s}',
    '.fwsc-bopt:hover:not(:disabled){border-color:var(--color-blue)}',
    '.fwsc-bopt:disabled{opacity:.45;cursor:not-allowed}',
    '.fwsc-bopt.selected{border-color:var(--color-blue);background:var(--color-background-info)}',
    '.fwsc-bopt .bt{display:flex;align-items:center;gap:7px;font-size:14px;font-weight:600;color:var(--color-text-primary)}',
    '.fwsc-bopt.selected .bt{color:var(--color-text-info)}',
    '.fwsc-bopt .bt i{width:13px;height:13px;border-radius:50%;flex-shrink:0;',
      'border:1.5px solid var(--color-border-primary);background:var(--color-background-primary)}',
    '.fwsc-bopt.selected .bt i{border-color:var(--color-blue);background:var(--color-blue);box-shadow:inset 0 0 0 2.5px #fff}',
    '.fwsc-bopt .bv{font-family:var(--font-mono);font-size:17px;font-weight:600;color:var(--color-text-primary)}',
    '.fwsc-bopt .bd{font-size:14px;color:var(--color-text-tertiary);line-height:1.35}',
    /* Supervisor override — shown when the variance is out of tolerance. It authorises the
       completion; it never blocks it, and the commit button is never disabled. */
    '.fwsc-ovr{display:none;margin:12px 0 0;padding:13px 15px;border-radius:var(--border-radius-md);',
      'background:var(--color-background-warning);border:1px solid var(--color-amber)}',
    '.fwsc-ovr.on{display:block}',
    '.fwsc-ovr-head{display:flex;align-items:flex-start;gap:11px;margin-bottom:12px}',
    '.fwsc-ovr-head svg{width:22px;height:22px;flex-shrink:0;color:var(--color-text-warning)}',
    '.fwsc-ovr-head .ovr-t{font-size:14px;font-weight:600;color:var(--color-text-warning)}',
    '.fwsc-ovr-head .ovr-s{font-size:14px;color:var(--color-text-warning);opacity:.9;margin-top:3px;line-height:1.4}',
    '.fwsc-ovr-grid{display:grid;grid-template-columns:1fr 150px 110px;gap:10px}',
    '.fwsc-ovr-foot{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:11px}',
    '.fwsc-remote{border:1px solid var(--color-border-secondary);background:var(--color-background-primary);',
      'color:var(--color-text-secondary);border-radius:var(--border-radius-md);padding:7px 13px;',
      'font-family:var(--font-sans);font-size:14px;font-weight:500;cursor:pointer}',
    '.fwsc-remote:hover{background:var(--color-background-secondary);color:var(--color-text-primary)}',
    '.fwsc-remote-note{font-size:14px;color:var(--color-text-warning);font-weight:500}',

    '.fwsc-reason{display:none;margin-top:12px}',
    '.fwsc-reason.on{display:block}',
    '.fwsc-reason label{display:block;font-size:14px;color:var(--color-text-secondary);margin-bottom:5px}',
    '.fwsc-reason.err input{border-color:var(--color-red)}',
    '.fwsc-reason .fe{display:none;margin-top:4px;font-size:14px;font-weight:600;color:var(--color-text-danger)}',
    '.fwsc-reason.err .fe{display:block}',
    '.fwsc-reason input{width:100%;height:40px;padding:0 12px;font-family:var(--font-sans);font-size:14px;',
      'color:var(--color-text-primary);background:var(--color-background-primary);',
      'border:1.5px solid var(--color-border-secondary);border-radius:var(--border-radius-md);outline:none}',
    '.fwsc-reason input:focus{border-color:var(--color-blue)}',
    /* Flowing sentence, NOT a flex row — under display:flex each <strong> and each bare text
       run becomes its own flex item and the line breaks after every value. */
    '.fwsc-record{display:block;margin-top:10px;padding:9px 12px;',
      'border-radius:var(--border-radius-md);background:var(--color-background-info);',
      'color:var(--color-text-info);font-size:14px;font-weight:500;line-height:1.5}',
    '.fwsc-record strong{font-family:var(--font-mono);font-weight:600;white-space:nowrap}',

    /* The question — the largest text in the body, stated once */
    '.fwsc-ask{font-size:17px;font-weight:600;color:var(--color-text-primary);line-height:1.35}',
    '.fwsc-ask-sub{font-size:14px;color:var(--color-text-secondary);margin-top:6px;line-height:1.45}',

    /* Two full-width choice rows — gloved-hand targets, consequence stated on each */
    '.fwsc-choices{display:flex;flex-direction:column;gap:10px;margin:16px 0 14px}',
    '.fwsc-choice{display:grid;grid-template-columns:44px 1fr auto;align-items:center;gap:15px;',
      'width:100%;min-height:78px;padding:14px 16px;text-align:left;cursor:pointer;',
      'font-family:var(--font-sans);background:var(--color-background-primary);',
      'border:1.5px solid var(--color-border-secondary);border-radius:var(--border-radius-lg);',
      'transition:border-color .13s,background .13s,box-shadow .13s,transform .08s}',
    '.fwsc-choice:hover{box-shadow:0 5px 16px rgba(0,0,0,.11)}',
    '.fwsc-choice:active{transform:scale(.995)}',
    '.fwsc-choice .ci{width:44px;height:44px;border-radius:50%;display:flex;align-items:center;',
      'justify-content:center;flex-shrink:0;background:var(--color-background-secondary);color:var(--color-text-secondary)}',
    '.fwsc-choice .ci svg{width:23px;height:23px}',
    '.fwsc-choice .ct{font-size:16px;font-weight:600;color:var(--color-text-primary);display:block}',
    '.fwsc-choice .cd{font-size:14px;color:var(--color-text-secondary);margin-top:4px;display:block;line-height:1.4}',
    '.fwsc-choice .ck{font-family:var(--font-mono);font-size:14px;font-weight:700;color:var(--color-text-tertiary);',
      'border:1px solid var(--color-border-tertiary);border-radius:5px;padding:3px 7px;flex-shrink:0}',
    '.fwsc-choice.yes:hover{border-color:var(--color-green);background:var(--color-background-success)}',
    '.fwsc-choice.yes:hover .ci{background:var(--color-green);color:#fff}',
    '.fwsc-choice.yes:hover .ct{color:var(--color-text-success)}',
    '.fwsc-choice.no:hover{border-color:var(--color-border-primary);background:var(--color-background-secondary)}',
    '.fwsc-choice.no:hover .ci{background:var(--color-gray);color:#fff}',
    '.fwsc-choice:focus-visible{outline:none;border-color:var(--color-blue);box-shadow:0 0 0 3px rgba(24,95,165,.22)}',

    /* PLC provenance — evidence belongs at the bottom, not competing with the question */
    '.fwsc-evidence{display:flex;align-items:center;gap:10px;flex-wrap:wrap;padding-top:13px;',
      'border-top:0.5px solid var(--color-border-tertiary);font-size:14px;color:var(--color-text-tertiary)}',
    '.fwsc-evidence code{font-family:var(--font-mono);font-size:14px;padding:2px 7px;border-radius:4px;',
      'background:var(--color-background-secondary);color:var(--color-text-secondary)}',
    '.fwsc-evidence .e-dot{width:7px;height:7px;border-radius:50%;background:var(--color-green);flex-shrink:0}',
    '.fwsc-evidence .e-sep{width:1px;height:12px;background:var(--color-border-tertiary)}',

    '.fwsc-sum.one{grid-template-columns:1fr;margin-bottom:10px}',
    '.fwsc-sum{display:grid;grid-template-columns:1fr 1fr;gap:8px 18px;padding:13px 16px;',
      'border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-md);margin-bottom:12px}',
    '.fwsc-sum .row{display:flex;align-items:baseline;justify-content:space-between;gap:10px;font-size:14px}',
    '.fwsc-sum .row.full{grid-column:1 / -1}',
    '.fwsc-sum .k{color:var(--color-text-secondary)}',
    '.fwsc-sum .v{font-family:var(--font-mono);font-weight:600;color:var(--color-text-primary);text-align:right}',
    '.fwsc-sum .v.big{font-size:15px}',
    '.fwsc-over{display:none;align-items:center;gap:10px;padding:11px 14px;margin-top:14px;',
      'border-radius:var(--border-radius-md);background:var(--color-background-danger);',
      'color:var(--color-text-danger);font-size:14px;font-weight:500;line-height:1.4}',
    '.fwsc-over.on{display:flex}',
    '.fwsc-over svg{width:18px;height:18px;flex-shrink:0}',
    '.fwsc-lbl{display:flex;align-items:center;gap:10px;padding:11px 14px;border-radius:var(--border-radius-md);',
      'background:var(--color-background-info);color:var(--color-text-info);font-size:14px;margin-bottom:14px}',
    '.fwsc-lbl svg{width:17px;height:17px;flex-shrink:0}',
    '.fwsc-lbl strong{font-family:var(--font-mono)}',
    '.fwsc-note{font-size:14px;color:var(--color-text-tertiary);line-height:1.45;margin-bottom:14px}',
    '.fwsc-act{display:flex;justify-content:flex-end;gap:10px;margin-top:14px}',
    '.fwsc-act .grow{margin-right:auto}',
    '.fwsc-print{display:flex;align-items:center;gap:10px;padding:11px 14px;margin-bottom:12px;',
      'border-radius:var(--border-radius-md);background:var(--color-background-success);',
      'color:var(--color-text-success);font-size:14px;font-weight:500}',
    '.fwsc-print .pd{width:8px;height:8px;border-radius:50%;background:var(--color-green);flex-shrink:0}',

    /* Line badge while the simulated PLC tag reads STOPPED */
    '.line-badge.fwn-plc-stopped{background:var(--color-background-tertiary);color:var(--color-text-secondary)}',
    '.line-badge.fwn-plc-stopped .dot{background:var(--color-gray);animation:none}'
  ].join('');
  document.head.appendChild(styleEl);

  /* ── Markup ─────────────────────────────────────────────────── */
  var wrap = document.createElement('div');
  wrap.innerHTML =
    '<div class="fwn-card t-info" id="fwn-card" role="status" aria-live="polite" aria-atomic="false">' +
      '<div class="fwn-accent"></div>' +
      '<div class="fwn-head">' +
        '<span class="fwn-ic" id="fwn-ic" aria-hidden="true">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">' +
          '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg>' +
        '</span>' +
        '<div class="fwn-head-txt">' +
          '<div class="fwn-title" id="fwn-title">—</div>' +
          '<div class="fwn-lead" id="fwn-lead">—</div>' +
        '</div>' +
        '<span class="fwn-badge" id="fwn-badge">—</span>' +
      '</div>' +
      '<div class="fwn-body">' +
        '<div class="fwn-read">' +
          '<div>' +
            '<div class="fwn-read-k">Actual processed weight</div>' +
            '<div class="fwn-actual" id="fwn-actual">0<span class="u">lb</span></div>' +
          '</div>' +
          '<div class="fwn-target">Target ' + CFG.label.toLowerCase() + ' weight<strong id="fwn-target">—</strong></div>' +
        '</div>' +
        '<div class="fwn-bar-wrap">' +
          '<div class="fwn-bar"><span class="fwn-fill" id="fwn-fill" style="width:0%"></span></div>' +
          '<div class="fwn-ticks">' +
            '<span class="fwn-tick" style="left:75%"></span>' +
            '<span class="fwn-tick" style="left:90%"></span>' +
          '</div>' +
        '</div>' +
        '<div class="fwn-tick-labels">' +
          '<span id="fwn-lb75" style="left:75%">75</span>' +
          '<span id="fwn-lb90" style="left:90%">90</span>' +
          '<span id="fwn-lb100" style="left:100%;transform:translateX(-100%)">100%</span>' +
        '</div>' +
        '<div class="fwn-grid">' +
          '<div class="fwn-cell"><span class="k">Complete</span><span class="v" id="fwn-pct">—</span></div>' +
          '<div class="fwn-cell"><span class="k">Remaining</span><span class="v" id="fwn-remain">—</span></div>' +
          '<div class="fwn-cell"><span class="k">' + CFG.label + ' footage</span><span class="v" id="fwn-ft">—</span></div>' +
          '<div class="fwn-cell"><span class="k">Fill rate</span><span class="v" id="fwn-rate">—</span></div>' +
          '<div class="fwn-cell"><span class="k">Est. to target</span><span class="v" id="fwn-eta">—</span></div>' +
          '<div class="fwn-cell"><span class="k">' + CFG.takeup + '</span><span class="v" id="fwn-alpha">—</span></div>' +
        '</div>' +
        '<div class="fwn-foot">' +
          '<span class="fwn-live">Live &middot; updated <span id="fwn-stamp">—</span><span class="dot"></span></span>' +
          '<button class="fwn-ack" id="fwn-ack" type="button">Acknowledge</button>' +
        '</div>' +
      '</div>' +
    '</div>' +

    '<div class="fwn-pill" id="fwn-pill" role="status" aria-live="off">' +
      '<span class="ok" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" ' +
        'stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>' +
      CFG.label + ' <strong id="fwn-pill-pct">—</strong>' +
      '<span class="mini"><span id="fwn-pill-fill" style="width:0%"></span></span>' +
      '<strong id="fwn-pill-wt">—</strong>' +
      '<span id="fwn-pill-note"></span>' +
      /* Manual entry point — always available at/over target, incl. after answering No (S-13) */
      '<button class="fwn-pill-btn" id="fwn-pill-complete" type="button">Complete ' + CFG.label.toLowerCase() + '</button>' +
    '</div>' +

    '<div class="fwn-demo" id="fwn-demo">' +
      'mockup demo &mdash; jump to' +
      '<button type="button" data-pct="70">70%</button>' +
      '<button type="button" data-pct="76">76%</button>' +
      '<button type="button" data-pct="91">91%</button>' +
      '<button type="button" data-pct="100">100%</button>' +
      '<button type="button" data-pct="104">104%</button>' +
      '<span class="sep"></span>' +
      'PLC' +
      '<button type="button" class="plc" data-plc="STOPPED">&#9632; stop</button>' +
      '<button type="button" class="plc" data-plc="RUNNING">&#9654; start</button>' +
    '</div>' +

    /* ── Part B — spool removal confirmation (PLC-confirmed stop) ── */
    '<div class="gb-modal-overlay" id="fwsc-overlay">' +
      '<div class="gb-modal fwsc-modal" style="width:840px" role="dialog" aria-modal="true" aria-labelledby="fwsc-title">' +

        /* Identity band — state, context, and the latched weight in one glance */
        '<div class="fwsc-band t-target" id="fwsc-band">' +
          '<span class="fwsc-band-ic" aria-hidden="true">' +
            '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<rect x="3" y="4" width="18" height="4" rx="1"/><rect x="3" y="16" width="18" height="4" rx="1"/>' +
            '<path d="M7 8v8M12 8v8M17 8v8"/></svg>' +
          '</span>' +
          '<div class="fwsc-band-txt">' +
            '<div class="fwsc-band-title" id="fwsc-title">—</div>' +
            '<div class="fwsc-band-sub" id="fwsc-sub">—</div>' +
          '</div>' +
          '<div class="fwsc-band-num">' +
            '<div class="fwsc-hero" id="fwsc-latched">—</div>' +
            '<div class="fwsc-hero-sub">of <span id="fwsc-target">—</span> target &middot; <span id="fwsc-pctv">—</span></div>' +
          '</div>' +
        '</div>' +

        '<div class="gb-modal-body">' +

          /* Step 1 — the Yes / No question */
          '<div id="fwsc-step1">' +
            '<div class="fwsc-ask" id="fwsc-question">—</div>' +
            '<div class="fwsc-ask-sub" id="fwsc-question-sub">—</div>' +
            '<div class="fwsc-over" id="fwsc-over">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
              '<path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>' +
              '<path d="M12 9v4"/><path d="M12 17h.01"/></svg>' +
              '<span id="fwsc-over-txt">—</span>' +
            '</div>' +

            '<div class="fwsc-choices">' +
              '<button class="fwsc-choice yes" id="fwsc-yes" type="button">' +
                '<span class="ci" aria-hidden="true">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                  '<polyline points="20 6 9 17 4 12"/></svg>' +
                '</span>' +
                '<span><span class="ct">Yes &mdash; ' + CFG.label.toLowerCase() + ' removed, complete it</span>' +
                  '<span class="cd" id="fwsc-yes-desc">—</span></span>' +
                '<span class="ck">Y</span>' +
              '</button>' +
              '<button class="fwsc-choice no" id="fwsc-no" type="button">' +
                '<span class="ci" aria-hidden="true">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                  '<path d="M3 12a9 9 0 1 0 9-9"/><polyline points="3 4 3 12 11 12"/></svg>' +
                '</span>' +
                '<span><span class="ct">No &mdash; stopped for another reason</span>' +
                  '<span class="cd">Nothing is recorded &mdash; no transaction, no alpha, no labels. The ' +
                  CFG.label.toLowerCase() + ' stays open and can be completed later.</span></span>' +
                '<span class="ck">N</span>' +
              '</button>' +
            '</div>' +

            '<div class="fwsc-evidence">' +
              '<span class="e-dot"></span><span>Stop confirmed &mdash; <code id="fwsc-tag">—</code></span>' +
              '<span class="e-sep"></span><span id="fwsc-dwell">—</span>' +
              '<span class="e-sep"></span><span>Stopped <span id="fwsc-stoptime">—</span></span>' +
              '<span class="e-sep"></span><span id="fwsc-alpha">—</span>' +
            '</div>' +
          '</div>' +

          /* Step 2 — what the completion transaction will commit */
          '<div id="fwsc-step2" style="display:none">' +

            '<div class="fwsc-cols">' +

              /* Left column — capture the scale weight, reconcile, choose the basis */
              '<div class="fwsc-verify">' +
              '<div class="fwsc-verify-head">Weight verification</div>' +
              '<div class="fwsc-wrow">' +
                '<div class="fwsc-wcell">' +
                  '<span class="wk">System calculated &mdash; net</span>' +
                  '<span class="wv" id="fwsc2-calc">—</span>' +
                  '<span class="wm" id="fwsc2-calc-basis">—</span>' +
                '</div>' +
                '<div class="fwsc-wcell">' +
                  '<span class="wk">Scale weight &mdash; gross</span>' +
                  '<span class="fwsc-winput">' +
                    '<input id="fwsc2-scale" type="number" inputmode="decimal" step="1" min="0" ' +
                      'placeholder="0" aria-label="Scale weight, gross pounds">' +
                    '<span class="u">lb</span>' +
                  '</span>' +
                  '<span class="wm">&minus; tare <span id="fwsc2-tare">—</span> = net <strong id="fwsc2-scale-net">—</strong></span>' +
                '</div>' +
                '<div class="fwsc-wcell">' +
                  '<span class="wk">Variance vs calculated</span>' +
                  '<span class="fwsc-var" id="fwsc2-var">—</span>' +
                  '<span class="wm" id="fwsc2-var-note">Enter the scale weight to compare</span>' +
                '</div>' +
              '</div>' +
              '<div class="fwsc-tol" id="fwsc2-tol"><span id="fwsc2-tol-txt">—</span></div>' +

              '<div class="fwsc-basis-q">Which weight should be recorded for this ' + CFG.label.toLowerCase() + '?</div>' +
              '<div class="fwsc-basis">' +
                '<button class="fwsc-bopt" id="fwsc2-basis-scale" data-basis="scale" type="button" disabled>' +
                  '<span class="bt"><i></i>Scale weight</span>' +
                  '<span class="bv" id="fwsc2-basis-scale-v">—</span>' +
                  '<span class="bd">Physically weighed &mdash; overrides the calculation</span>' +
                '</button>' +
                '<button class="fwsc-bopt selected" id="fwsc2-basis-calc" data-basis="calc" type="button">' +
                  '<span class="bt"><i></i>System calculated</span>' +
                  '<span class="bv" id="fwsc2-basis-calc-v">—</span>' +
                  '<span class="bd">Footage &times; cross-section &times; density</span>' +
                '</button>' +
              '</div>' +
              '<div class="fwsc-record" id="fwsc2-record">—</div>' +
              '</div>' +   /* /fwsc-verify */

              /* Right column — the identity of what is being committed */
              '<div>' +
                '<div class="fwsc-sum one">' +
                  '<div class="row"><span class="k">' + CFG.label + ' alpha</span><span class="v big" id="fwsc2-alpha">—</span></div>' +
                  '<div class="row"><span class="k">Footage</span><span class="v" id="fwsc2-ft">—</span></div>' +
                  '<div class="row"><span class="k">Gauge</span><span class="v" id="fwsc2-gauge">—</span></div>' +
                  '<div class="row"><span class="k">Width</span><span class="v" id="fwsc2-width">—</span></div>' +
                  '<div class="row"><span class="k">Source rods</span><span class="v" id="fwsc2-rods">—</span></div>' +
                  '<div class="row"><span class="k">Weld point</span><span class="v" id="fwsc2-weld">—</span></div>' +
                '</div>' +
                '<div class="fwsc-lbl" style="margin-bottom:0">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                  '<polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>' +
                  '<span><strong id="fwsc2-copies">—</strong> labels to <strong id="fwsc2-printer">—</strong> after the transaction commits &mdash; ' +
                    'alpha, alloy, width, gauge, temper, gross/net weight, source rods</span>' +
                '</div>' +
              '</div>' +
            '</div>' +   /* /fwsc-cols */
              '<div class="fwsc-ovr" id="fwsc2-ovr">' +
                '<div class="fwsc-ovr-head">' +
                  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
                  '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>' +
                  '<div>' +
                    '<div class="ovr-t">Supervisor override to proceed</div>' +
                    '<div class="ovr-s">The variance is outside tolerance. The ' + CFG.label.toLowerCase() +
                      ' can still be created &mdash; a supervisor authorises it here and the override is recorded ' +
                      'on the ' + CFG.label.toLowerCase() + '.</div>' +
                  '</div>' +
                '</div>' +
                '<div class="fwsc-ovr-grid">' +
                  '<div class="fwsc-reason on" id="fwsc2-reason-wrap" style="margin-top:0">' +
                    '<label for="fwsc2-reason">Reason for the variance</label>' +
                    '<input id="fwsc2-reason" type="text" placeholder="e.g. scale calibration due, wet lube carry-over…">' +
                    '<span class="fe">Required for the override</span>' +
                  '</div>' +
                  '<div class="fwsc-reason on" id="fwsc2-sup-wrap" style="margin-top:0">' +
                    '<label for="fwsc2-sup">Supervisor badge / ID</label>' +
                    '<input id="fwsc2-sup" type="text" placeholder="e.g. SR-104">' +
                    '<span class="fe">Required</span>' +
                  '</div>' +
                  '<div class="fwsc-reason on" id="fwsc2-pin-wrap" style="margin-top:0">' +
                    '<label for="fwsc2-pin">PIN</label>' +
                    '<input id="fwsc2-pin" type="password" inputmode="numeric" placeholder="••••">' +
                    '<span class="fe">Required</span>' +
                  '</div>' +
                '</div>' +
                '<div class="fwsc-ovr-foot">' +
                  '<button class="fwsc-remote" id="fwsc2-remote" type="button">No supervisor on the floor? Request remote approval</button>' +
                  '<span class="fwsc-remote-note" id="fwsc2-remote-note"></span>' +
                '</div>' +
              '</div>' +
            '<div class="fwsc-act">' +
              '<button class="btn grow" id="fwsc-back" type="button">Back</button>' +
              '<button class="btn btn-primary" id="fwsc-commit" type="button">Complete ' + CFG.label.toLowerCase() + ' &amp; print labels</button>' +
            '</div>' +
          '</div>' +

          /* Step 3 — committed */
          '<div id="fwsc-step3" style="display:none">' +
            '<div class="fwsc-sum">' +
              '<div class="row"><span class="k">' + CFG.label + ' alpha</span><span class="v big" id="fwsc3-alpha">—</span></div>' +
              '<div class="row"><span class="k">Net weight</span><span class="v big" id="fwsc3-net">—</span></div>' +
              '<div class="row"><span class="k">Gross weight</span><span class="v" id="fwsc3-gross">—</span></div>' +
              '<div class="row"><span class="k">Weight basis</span><span class="v" id="fwsc3-basis">—</span></div>' +
              '<div class="row full"><span class="k">Committed at</span><span class="v" id="fwsc3-time">—</span></div>' +
            '</div>' +
            '<div class="fwsc-print"><span class="pd"></span><span id="fwsc3-print">—</span></div>' +
            '<div class="fwsc-over" id="fwsc3-ovr">' +
              '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
              '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>' +
              '<span id="fwsc3-ovr-txt">—</span>' +
            '</div>' +
            '<div class="fwsc-note">' + CFG.label + ' status set to ACTIVE and available to planning. Milestone tracking has re-armed for the next ' +
              CFG.label.toLowerCase() + ' on this run.</div>' +
            '<div class="fwsc-act">' +
              '<button class="btn btn-primary" id="fwsc-close" type="button">Close</button>' +
            '</div>' +
          '</div>' +

        '</div>' +
      '</div>' +
    '</div>';
  document.body.appendChild(wrap);

  /* ── Element refs ───────────────────────────────────────────── */
  var $ = function (id) { return document.getElementById(id); };
  var card = $('fwn-card'), pill = $('fwn-pill');

  /* ── State ──────────────────────────────────────────────────── */
  var actualLb  = CFG.startLb;          // live actual processed weight on the take-up
  var shown     = null;                 // milestone currently displayed (object) or null
  var acked     = {};                   // milestone.key → true once acknowledged
  var ackedAny  = false;                // any milestone acknowledged → pill is eligible
  var lastMs    = Date.now();

  /* ── Formatting ─────────────────────────────────────────────── */
  function lb(n)  { return Math.round(n).toLocaleString('en-US'); }
  function pct()  { return (actualLb / CFG.targetLb) * 100; }
  function p2(n)  { return String(n).padStart(2, '0'); }
  function stamp() {
    var d = new Date();
    return p2(d.getHours()) + ':' + p2(d.getMinutes()) + ':' + p2(d.getSeconds());
  }
  function mmss(minutes) {
    if (!isFinite(minutes) || minutes <= 0) return '—';
    var s = Math.round(minutes * 60);
    return p2(Math.floor(s / 60)) + ':' + p2(s % 60);
  }

  /* Highest milestone reached by the current weight, honouring the ack ladder:
     an acknowledged milestone is finished — only a HIGHER one may be raised again. */
  function dueMilestone() {
    var p = pct(), found = null;
    for (var i = 0; i < MILESTONES.length; i++) {
      if (p >= MILESTONES[i].pct && !acked[MILESTONES[i].key]) found = MILESTONES[i];
    }
    return found;
  }

  /* Acknowledging a milestone closes it AND everything below it — an operator who acks the
     escalated 90% card is not shown the 75% card again. Acking 100% ends the ladder (R-4),
     so the over-target state can only appear if 100% was never acknowledged. */
  function closeLadderThrough(m) {
    var idx = MILESTONES.indexOf(m);
    for (var i = 0; i <= idx; i++) acked[MILESTONES[i].key] = true;
    if (m.key === 'm100') acked.over = true;
  }

  /* ── Render ─────────────────────────────────────────────────── */
  function paint(escalated) {
    var p = pct();
    var remaining = CFG.targetLb - actualLb;
    var rate = CFG.speedFpm * LB_PER_FT;                       // lb per minute
    var footage = actualLb / LB_PER_FT;

    if (shown) {
      card.className = 'fwn-card open t-' + shown.tone + (escalated ? ' escalate' : '');
      $('fwn-badge').textContent = shown.badge;
      $('fwn-title').textContent = shown.title;
      $('fwn-lead').textContent  = shown.tone === 'danger'
        ? shown.lead + ' Over by ' + lb(actualLb - CFG.targetLb) + ' lb.'
        : shown.lead;

      $('fwn-actual').innerHTML = lb(actualLb) + '<span class="u">lb</span>';
      $('fwn-target').textContent = lb(CFG.targetLb) + ' lb';
      $('fwn-fill').style.width  = Math.min(100, p).toFixed(1) + '%';
      $('fwn-pct').textContent    = p.toFixed(1) + '%';
      $('fwn-remain').textContent = remaining > 0 ? lb(remaining) + ' lb' : '0 lb';
      $('fwn-ft').textContent     = lb(footage) + ' ft';
      $('fwn-rate').textContent   = Math.round(rate) + ' lb/min';
      $('fwn-eta').textContent    = remaining > 0 ? mmss(remaining / rate) : 'reached';
      $('fwn-alpha').textContent  = CFG.spoolAlpha;
      $('fwn-stamp').textContent  = stamp();
      $('fwn-ack').textContent    = 'Acknowledge';

      $('fwn-lb75').className  = p >= 75  ? 'hit' : '';
      $('fwn-lb90').className  = p >= 90  ? 'hit' : '';
      $('fwn-lb100').className = p >= 100 ? 'hit' : '';
    }

    /* Optional host-screen readouts — kept in step with the notification when present */
    var hostLb = $('fw-spool-lb'), hostTarget = $('fw-spool-target');
    if (hostLb) hostLb.textContent = lb(actualLb);
    if (hostTarget) hostTarget.textContent = lb(CFG.targetLb);

    /* Pill is only for the acknowledged state — never shown alongside the card */
    var pillOn = ackedAny && !shown;
    pill.classList.toggle('open', pillOn);
    if (pillOn) {
      $('fwn-pill-pct').textContent  = p.toFixed(0) + '%';
      $('fwn-pill-fill').style.width = Math.min(100, p).toFixed(1) + '%';
      $('fwn-pill-wt').textContent   = lb(actualLb) + ' / ' + lb(CFG.targetLb) + ' lb';
      $('fwn-pill-note').textContent = p >= 100 ? '· target reached' : '· acknowledged';
      /* Manual completion path (S-13) — at/over target and the line not running, since a
         spool cannot be removed from a turning take-up */
      $('fwn-pill-complete').classList.toggle('on', p >= 100 && lineState !== 'RUNNING');
    }
  }

  /* ── Milestone evaluation, run on every telemetry tick ──────── */
  function evaluate() {
    var due = dueMilestone();

    if (due && !shown) {                       // raise
      shown = due;
      paint(false);
      return;
    }
    if (due && shown && due !== shown) {       // supersede IN PLACE (R-6)
      shown = due;
      card.classList.remove('escalate');
      void card.offsetWidth;                   // restart the pulse animation
      paint(true);
      return;
    }
    paint(false);                              // live refresh (R-5) / pill refresh
  }

  /* ── Acknowledge ────────────────────────────────────────────── */
  $('fwn-ack').addEventListener('click', function () {
    if (!shown) return;
    closeLadderThrough(shown);
    ackedAny = true;
    /* Audit event the real implementation persists against the run (R-11) */
    if (window.console && console.info) {
      console.info('[FlatWire] ' + CFG.label + ' milestone acknowledged', {
        milestone: shown.badge, actualLb: Math.round(actualLb),
        targetLb: CFG.targetLb, spool: CFG.spoolAlpha, at: new Date().toISOString()
      });
    }
    shown = null;
    card.classList.add('leaving');
    setTimeout(function () {
      card.className = 'fwn-card';
      paint(false);
    }, 190);
  });

  /* ═══════════════════════════════════════════════════════════════
     PART B — PLC-confirmed stop → "remove completed spool?" prompt
     ═══════════════════════════════════════════════════════════════ */

  /* Simulated FL{n}.LineState. In the real implementation this is the OPC tag value
     arriving on FlatWireHub; the evaluator that raises the prompt lives server-side. */
  var lineState      = 'RUNNING';
  var stoppedSinceMs = null;    // when the tag first read STOPPED (dwell timer, S-3)
  var stopHandled    = false;   // edge latch — one prompt per stop event (S-5)
  var promptOpen     = false;
  var manualPath     = false;   // opened from the pill rather than by the PLC prompt
  var latchedLb      = null;    // weight frozen at the PLC stop timestamp (S-4)
  var latchedAtStr   = '—';

  var overlay = $('fwsc-overlay');

  function lineId() {
    if (CFG.line) return CFG.line;
    var badge = document.querySelector('.line-badge');
    var m = badge && badge.textContent.match(/FL\d+/);
    return m ? m[0] : 'FL1';
  }

  /* Close the 75/90/100 ladder without arming/clearing the over-target state: if the
     operator declines and restarts the line, an actual overfill must still be flagged. */
  function systemCloseThroughTarget() {
    acked.m75 = acked.m90 = acked.m100 = true;
    ackedAny = true;
  }

  function audit(event, extra) {
    if (!window.console || !console.info) return;
    var payload = { line: lineId(), spool: CFG.spoolAlpha, at: new Date().toISOString() };
    for (var k in extra) if (Object.prototype.hasOwnProperty.call(extra, k)) payload[k] = extra[k];
    console.info('[FlatWire] ' + event, payload);
  }

  /* Reflect the simulated tag on the screen chrome so the demo reads coherently */
  function paintLineState() {
    var running = lineState === 'RUNNING';
    var badge = document.querySelector('.line-badge');
    if (badge && !badge.classList.contains('paused')) {
      badge.classList.toggle('fwn-plc-stopped', !running);
      badge.innerHTML = '<span class="dot"></span>' + lineId() + (running ? ' running' : ' stopped (PLC)');
    }
    /* "Machine · FL1 Running" header on the status card, when present */
    var heads = document.querySelectorAll('.mpc-card-head');
    for (var i = 0; i < heads.length; i++) {
      if (/Machine/i.test(heads[i].textContent)) {
        heads[i].innerHTML = heads[i].innerHTML.replace(/Running|Stopped/i, running ? 'Running' : 'Stopped');
      }
    }
  }

  var step = 1;

  /* The band carries the step identity: what state we are in, and the latched weight */
  function showStep(n) {
    step = n;
    $('fwsc-step1').style.display = n === 1 ? '' : 'none';
    $('fwsc-step2').style.display = n === 2 ? '' : 'none';
    $('fwsc-step3').style.display = n === 3 ? '' : 'none';

    var over = latchedLb != null && (latchedLb - CFG.targetLb) > 0.5;
    var tone = n === 2 ? 't-confirm' : (over && n === 1 ? 't-over' : 't-target');
    $('fwsc-band').className = 'fwsc-band ' + tone;

    var L = CFG.label.toLowerCase();
    $('fwsc-title').textContent =
      n === 3 ? CFG.label + ' completed'
      : n === 2 ? 'Confirm ' + L + ' completion'
      : over ? 'Over target ' + L + ' weight — machine stopped'
      : 'Target ' + L + ' weight reached — machine stopped';
    $('fwsc-sub').textContent =
      n === 2 ? 'Review what will be committed and printed'
      : lineId() + ' · ' + CFG.takeup + ' · ' + CFG.spoolAlpha;
  }

  /* Open the confirmation — only ever called after a PLC-confirmed stop (S-1),
     or from the manual "Complete spool" path which skips straight to step 2 (S-13). */
  function openPrompt(manual) {
    if (promptOpen) return;
    promptOpen   = true;
    manualPath   = !!manual;
    latchedLb    = latchedLb != null ? latchedLb : actualLb;
    latchedAtStr = manual ? stamp() : latchedAtStr;

    /* The advisory card gives way to the decision dialog — system dismissal, not an ack */
    if (shown) { shown = null; card.className = 'fwn-card'; }
    systemCloseThroughTarget();
    paint(false);

    var L = CFG.label.toLowerCase();
    var over = latchedLb - CFG.targetLb;

    /* Band — hero weight and percent of target */
    $('fwsc-latched').textContent = lb(latchedLb) + ' lb';
    $('fwsc-target').textContent  = lb(CFG.targetLb) + ' lb';
    $('fwsc-pctv').textContent    = ((latchedLb / CFG.targetLb) * 100).toFixed(0) + '%';

    /* The question, asked once, in the operator's terms */
    $('fwsc-question').textContent = 'Was the machine stopped to remove the completed ' + L + '?';
    $('fwsc-question-sub').textContent =
      'Confirming runs the ' + L + ' completion transaction and prints the ' + L + ' labels.';
    $('fwsc-yes-desc').textContent =
      'Completes ' + CFG.spoolAlpha + ' at ' + lb(latchedLb) + ' lb net, records the transaction and prints ' +
      CFG.labelCopies + ' labels.';

    /* PLC provenance line */
    $('fwsc-tag').textContent      = lineId() + '.LineState = STOPPED';
    $('fwsc-dwell').textContent    = 'held ' + CFG.stopDwellSec + 's · 0 FPM';
    $('fwsc-stoptime').textContent = latchedAtStr;
    $('fwsc-alpha').textContent    = CFG.spoolAlpha;

    $('fwsc-over').classList.toggle('on', over > 0.5);
    if (over > 0.5) {
      $('fwsc-over-txt').textContent = 'Over target by ' + lb(over) + ' lb — the overage is recorded on the ' +
        L + ' completion record.';
    }

    /* Step 2 values — all from the latched weight, never the live one */
    var footage = latchedLb / LB_PER_FT;
    $('fwsc2-alpha').textContent   = CFG.spoolAlpha;
    $('fwsc2-ft').textContent      = lb(footage) + ' ft';
    $('fwsc2-gauge').textContent   = CFG.gaugeIn.toFixed(3) + '"';
    $('fwsc2-width').textContent   = CFG.widthIn.toFixed(3) + '"';
    $('fwsc2-rods').textContent    = CFG.sourceRods;
    $('fwsc2-weld').textContent    = lb(CFG.weldFt) + ' ft';
    $('fwsc2-copies').textContent  = CFG.labelCopies;
    $('fwsc2-printer').textContent = CFG.printer;

    /* Weight verification starts empty: calculated weight only, scale not yet taken */
    basis = 'calc';
    scaleGrossLb = null;
    $('fwsc2-scale').value = '';
    $('fwsc2-reason').value = '';
    $('fwsc2-sup').value = '';
    $('fwsc2-pin').value = '';
    $('fwsc2-remote-note').textContent = '';
    clearOverrideErrors();
    $('fwsc2-calc').textContent = lb(latchedLb) + ' lb';
    $('fwsc2-calc-basis').innerHTML = lb(footage) + ' ft &times; ' + LB_PER_FT.toFixed(4) + ' lb/ft';
    $('fwsc2-tare').textContent = lb(CFG.spoolTareLb) + ' lb';
    renderVerify();

    showStep(manual ? 2 : 1);
    overlay.classList.add('open');
    audit(manual ? 'spool completion started manually' : 'spool removal prompt raised', {
      latchedLb: Math.round(latchedLb), targetLb: CFG.targetLb, stoppedAt: latchedAtStr
    });
  }

  function closePrompt() {
    promptOpen = false;
    manualPath = false;
    overlay.classList.remove('open');
    showStep(1);
    paint(false);
  }

  /* No — stopped for another reason: nothing is transacted, nothing is printed (S-7) */
  $('fwsc-no').addEventListener('click', function () {
    audit('spool removal prompt answered', { answer: 'No', transaction: 'none', labelsPrinted: 0 });
    closePrompt();
  });

  $('fwsc-yes').addEventListener('click', function () { showStep(2); });
  $('fwsc-back').addEventListener('click', function () {
    /* The manual path has no question step to go back to — Back closes instead */
    if (manualPath) { audit('manual spool completion cancelled', {}); closePrompt(); }
    else showStep(1);
  });

  /* ── Weight verification: system-calculated vs scale, and which one is recorded ──
     The calculated net is the latched weight (footage x cross-section x density). The scale
     reading is entered as GROSS, so net = gross - spool tare. Variance is scale-net minus
     calculated-net, expressed against the calculated value. */
  var basis        = 'calc';   // 'calc' | 'scale' — what gets recorded
  var scaleGrossLb = null;

  function scaleNet() { return scaleGrossLb == null ? null : scaleGrossLb - CFG.spoolTareLb; }
  function variance() { var n = scaleNet(); return n == null ? null : n - latchedLb; }
  function variancePct() {
    var v = variance();
    return v == null || !latchedLb ? null : (v / latchedLb) * 100;
  }
  function beyondTolerance() {
    var p = variancePct();
    return p != null && Math.abs(p) > CFG.scaleTolerancePct;
  }
  /* What the transaction and the label will carry */
  function recorded() {
    if (basis === 'scale' && scaleNet() != null) {
      return { net: scaleNet(), gross: scaleGrossLb, label: 'Scale weight' };
    }
    return { net: latchedLb, gross: latchedLb + CFG.spoolTareLb, label: 'System calculated' };
  }

  function renderVerify() {
    var net = scaleNet(), v = variance(), p = variancePct(), off = beyondTolerance();
    var hasScale = net != null;

    $('fwsc2-scale-net').textContent = hasScale ? lb(net) + ' lb' : '—';
    $('fwsc2-var').textContent = hasScale ? (v >= 0 ? '+' : '\u2212') + lb(Math.abs(v)) + ' lb' : '—';
    $('fwsc2-var').className = 'fwsc-var' + (hasScale ? (off ? ' off' : ' ok') : '');
    $('fwsc2-var-note').textContent = hasScale
      ? (p >= 0 ? '+' : '\u2212') + Math.abs(p).toFixed(2) + '% of calculated'
      : 'Enter the scale weight to compare';

    var tol = $('fwsc2-tol');
    tol.className = 'fwsc-tol' + (hasScale ? (off ? ' on off' : ' on ok') : '');
    if (hasScale) {
      $('fwsc2-tol-txt').textContent = off
        ? 'Variance exceeds the \u00b1' + CFG.scaleTolerancePct + '% tolerance — record a reason before completing, ' +
          'and check the scale and the gauge/width used in the calculation.'
        : 'Within the \u00b1' + CFG.scaleTolerancePct + '% tolerance.';
    }

    /* Basis options */
    var bs = $('fwsc2-basis-scale'), bc = $('fwsc2-basis-calc');
    bs.disabled = !hasScale;
    if (!hasScale && basis === 'scale') basis = 'calc';
    $('fwsc2-basis-scale-v').textContent = hasScale ? lb(net) + ' lb' : '—';
    $('fwsc2-basis-calc-v').textContent  = lb(latchedLb) + ' lb';
    bs.className = 'fwsc-bopt' + (basis === 'scale' ? ' selected' : '');
    bc.className = 'fwsc-bopt' + (basis === 'calc'  ? ' selected' : '');

    /* Out of tolerance asks for a supervisor override — it does NOT stop the operator */
    $('fwsc2-ovr').classList.toggle('on', off);
    if (!off) clearOverrideErrors();

    var rec = recorded();
    $('fwsc2-record').innerHTML = 'Will record <strong>' + lb(rec.net) + ' lb</strong> net &middot; ' +
      '<strong>' + lb(rec.gross) + ' lb</strong> gross &middot; basis <strong>' + rec.label + '</strong>' +
      ' &mdash; this is what prints on the label.';

    /* The commit button is never disabled (S-20): out of tolerance it simply asks for the
       override, and the label says so. */
    var commit = $('fwsc-commit');
    commit.disabled = false;
    commit.title = '';
    commit.innerHTML = off
      ? 'Override &amp; complete ' + CFG.label.toLowerCase()
      : 'Complete ' + CFG.label.toLowerCase() + ' &amp; print labels';
  }

  $('fwsc2-scale').addEventListener('input', function () {
    var raw = this.value.trim();
    var n = raw === '' ? NaN : Number(raw);
    var wasNull = scaleGrossLb == null;
    scaleGrossLb = (isFinite(n) && n > CFG.spoolTareLb) ? n : null;
    /* First valid reading wins by default — a physical weighing outranks the calculation */
    if (wasNull && scaleGrossLb != null) basis = 'scale';
    renderVerify();
  });

  /* ── Supervisor override (out-of-tolerance weight) ──────────────────────────────
     Grounded in the approval model already used for mid-run rod checkout: a supervisor
     authorises at the machine, the completion proceeds, and the override is recorded. */
  var OVR_FIELDS = [
    { id: 'fwsc2-reason', wrap: 'fwsc2-reason-wrap' },
    { id: 'fwsc2-sup',    wrap: 'fwsc2-sup-wrap' },
    { id: 'fwsc2-pin',    wrap: 'fwsc2-pin-wrap' }
  ];

  function clearOverrideErrors() {
    OVR_FIELDS.forEach(function (f) { $(f.wrap).classList.remove('err'); });
  }

  /* Returns the override payload, or null after marking what is missing. */
  function collectOverride() {
    var firstBad = null;
    OVR_FIELDS.forEach(function (f) {
      var bad = !$(f.id).value.trim();
      $(f.wrap).classList.toggle('err', bad);
      if (bad && !firstBad) firstBad = f.id;
    });
    if (firstBad) { $(firstBad).focus(); return null; }
    return {
      reason: $('fwsc2-reason').value.trim(),
      supervisor: $('fwsc2-sup').value.trim(),
      authenticated: true            // PIN is never carried in the payload
    };
  }

  OVR_FIELDS.forEach(function (f) {
    $(f.id).addEventListener('input', function () { $(f.wrap).classList.remove('err'); });
  });

  /* When no supervisor is on the floor, fall back to the remote approval model (Q50). */
  $('fwsc2-remote').addEventListener('click', function () {
    $('fwsc2-remote-note').textContent = 'Approval requested at ' + stamp() +
      ' — supervisor notified. Enter the override here once authorised.';
    audit('spool weight override requested remotely', {
      varianceLb: variance() != null ? Math.round(variance()) : null,
      variancePct: variancePct() != null ? Number(variancePct().toFixed(2)) : null
    });
  });

  $('fwsc2-basis-scale').addEventListener('click', function () {
    if (this.disabled) return;
    basis = 'scale'; renderVerify();
  });
  $('fwsc2-basis-calc').addEventListener('click', function () { basis = 'calc'; renderVerify(); });

  /* Commit — the transaction on the CHOSEN weight basis, then the labels (S-11, S-19) */
  $('fwsc-commit').addEventListener('click', function () {
    var btn = this;
    var rec = recorded();
    var off = beyondTolerance();

    /* Out of tolerance the completion is authorised, not prevented (S-20, S-22) */
    var ovr = null;
    if (off) {
      ovr = collectOverride();
      if (!ovr) return;               // fields flagged and focused — nothing committed yet
    }

    btn.disabled = true;
    btn.textContent = 'Committing…';
    setTimeout(function () {
      $('fwsc3-alpha').textContent = CFG.spoolAlpha;
      $('fwsc3-net').textContent   = lb(rec.net) + ' lb';
      $('fwsc3-gross').textContent = lb(rec.gross) + ' lb';
      $('fwsc3-basis').textContent = rec.label;
      $('fwsc3-time').textContent  = stamp();
      $('fwsc3-print').textContent = CFG.labelCopies + ' label copies sent to ' + CFG.printer;
      $('fwsc3-ovr').classList.toggle('on', !!ovr);
      if (ovr) {
        $('fwsc3-ovr-txt').textContent = 'Completed under supervisor override — authorised by ' +
          ovr.supervisor + '. Variance ' + (variance() >= 0 ? '+' : '\u2212') +
          lb(Math.abs(variance())) + ' lb (' + variancePct().toFixed(2) + '%): ' + ovr.reason;
      }
      showStep(3);
      btn.disabled = false;
      btn.innerHTML = 'Complete ' + CFG.label.toLowerCase() + ' &amp; print labels';
      audit('spool completed', {
        answer: 'Yes', weightBasis: basis, netLb: Math.round(rec.net), grossLb: Math.round(rec.gross),
        calculatedNetLb: Math.round(latchedLb),
        scaleGrossLb: scaleGrossLb != null ? Math.round(scaleGrossLb) : null,
        scaleNetLb: scaleNet() != null ? Math.round(scaleNet()) : null,
        varianceLb: variance() != null ? Math.round(variance()) : null,
        variancePct: variancePct() != null ? Number(variancePct().toFixed(2)) : null,
        beyondTolerance: beyondTolerance(),
        varianceReason: ovr ? ovr.reason : null,
        supervisorOverride: !!ovr,
        overrideBy: ovr ? ovr.supervisor : null,
        footage: Math.round(latchedLb / LB_PER_FT), labelsPrinted: CFG.labelCopies
      });
    }, 650);
  });

  /* Closing the result re-arms everything for the next spool (R-9 / AC-20) */
  $('fwsc-close').addEventListener('click', function () {
    closePrompt();
    window.fwSpoolNotification.reset();
  });

  $('fwn-pill-complete').addEventListener('click', function () { openPrompt(true); });

  /* Y / N shortcuts on the question step — the keys are printed on the choice rows.
     Escape is deliberately NOT bound: the question must be answered (S-10). */
  document.addEventListener('keydown', function (e) {
    if (!promptOpen || step !== 1 || e.altKey || e.ctrlKey || e.metaKey) return;
    var k = (e.key || '').toLowerCase();
    if (k === 'y') { e.preventDefault(); $('fwsc-yes').click(); }
    else if (k === 'n') { e.preventDefault(); $('fwsc-no').click(); }
  });

  /* No backdrop-click handler is registered on purpose (S-10) — clicking outside holds
     the dialog open, and the question step carries no × affordance. */

  /* PLC tag transitions — the only thing that raises the prompt */
  function setLineState(next) {
    if (next === lineState) return;
    lineState = next;
    if (next === 'STOPPED') {
      stoppedSinceMs = Date.now();
      stopHandled = false;
    } else {
      stoppedSinceMs = null;
      stopHandled = false;
      latchedLb = null;
      if (promptOpen) {                       // line resumed under an open prompt (S-8)
        audit('spool removal prompt auto-dismissed', { reason: 'line resumed' });
        closePrompt();
      }
    }
    paintLineState();
  }

  /* ── Simulated live production data + PLC evaluation ────────── */
  setInterval(function () {
    var now = new Date();
    var mins = (now - lastMs) / 60000;
    lastMs = now;

    if (lineState === 'RUNNING') {
      /* actual weight climbs at the current line speed, with a little jitter */
      actualLb += mins * CFG.speedFpm * LB_PER_FT * (0.97 + Math.random() * 0.06);
    }

    /* Armed by weight (S-2), fired by the stop edge once the dwell has elapsed (S-3, S-5) */
    if (lineState === 'STOPPED' && !stopHandled && stoppedSinceMs &&
        (now - stoppedSinceMs) >= CFG.stopDwellSec * 1000) {
      stopHandled = true;
      if (actualLb >= CFG.targetLb) {
        latchedLb    = actualLb;
        latchedAtStr = stamp();
        openPrompt(false);
      } else {
        audit('stop confirmed below target — no prompt', {
          actualLb: Math.round(actualLb), targetLb: CFG.targetLb
        });
      }
    }

    if (!promptOpen) evaluate();
  }, CFG.tickMs);

  /* ── Mockup-only demo controls ──────────────────────────────── */
  if (CFG.demo) {
    var demo = $('fwn-demo');
    demo.classList.add('on');
    demo.addEventListener('click', function (e) {
      var b = e.target.closest('button');
      if (!b) return;

      if (b.hasAttribute('data-plc')) {       // simulate the physical stop / restart
        setLineState(b.getAttribute('data-plc'));
        return;
      }

      var target = Number(b.getAttribute('data-pct'));
      if (!target) return;
      /* Jump = "pretend the spool just reached X%": clear the ladder and re-evaluate,
         so the milestone card for that weight is raised fresh. */
      actualLb = CFG.targetLb * target / 100;
      acked = {};
      ackedAny = false;
      shown = null;
      latchedLb = null;
      stopHandled = false;
      card.className = 'fwn-card';
      pill.classList.remove('open');
      if (promptOpen) closePrompt();
      evaluate();
    });
  }

  /* Expose for the dashboard / future hub wiring */
  window.fwSpoolNotification = {
    setActualWeight: function (v) { actualLb = v; evaluate(); },
    setTargetWeight: function (v) { CFG.targetLb = v; evaluate(); },
    setLineState: setLineState,          // real wiring point for FL{n}.LineState
    reset: function () {                 /* new spool started on the same run (R-9) */
      actualLb = 0; acked = {}; ackedAny = false; shown = null;
      latchedLb = null; stopHandled = false;
      card.className = 'fwn-card'; pill.classList.remove('open');
      $('fwn-pill-complete').classList.remove('on');
    }
  };

  paintLineState();
  evaluate();

})();
