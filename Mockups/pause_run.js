/* pause_run.js — Shared Pause / Resume dialog for FL1 and FL2 active run monitors.
 * Include via <script src="pause_run.js"></script> before </body>.
 * Requires: id="pause-btn" on the action button, id="pause-timer-badge" + id="pause-elapsed"
 * in the header, and the standard CSS custom properties from the dashboard design system.
 */
(function () {

  /* ── Inject CSS ─────────────────────────────────────────────── */
  var styleEl = document.createElement('style');
  styleEl.textContent = [
    '.action-btn.warn{color:var(--color-text-warning)}',
    '.action-btn.warn:hover{background:var(--color-background-warning);border-color:var(--color-amber)}',

    '.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:200;align-items:center;justify-content:center}',
    '.modal-overlay.open{display:flex}',
    '.modal{background:var(--color-background-primary);border-radius:var(--border-radius-lg);border:.5px solid var(--color-border-secondary);width:560px;max-height:88vh;overflow-y:auto;box-shadow:0 24px 64px rgba(0,0,0,.28);display:flex;flex-direction:column}',
    '.modal-header{padding:20px 24px 14px;border-bottom:.5px solid var(--color-border-tertiary);flex-shrink:0}',
    '.modal-header h2{margin:0 0 8px;font-size:18px;font-weight:500}',
    '.modal-context{display:flex;gap:18px;font-size:13px;color:var(--color-text-secondary);flex-wrap:wrap}',
    '.modal-context .mono{color:var(--color-text-primary);font-weight:500}',
    '.modal-body{padding:18px 24px;overflow-y:auto;flex:1}',
    '.modal-footer{padding:14px 24px;border-top:.5px solid var(--color-border-tertiary);display:flex;justify-content:flex-end;gap:10px;flex-shrink:0}',

    '.reason-group{margin-bottom:14px}',
    '.reason-group-label{font-size:11px;font-weight:600;color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;padding-left:4px}',
    '.reason-option{display:flex;align-items:center;gap:10px;padding:9px 12px;border-radius:var(--border-radius-md);cursor:pointer;font-size:14px;border:1px solid transparent;transition:background .1s,border-color .1s;margin-bottom:3px}',
    '.reason-option:hover{background:var(--color-background-secondary)}',
    '.reason-option.selected{background:var(--color-background-info);border-color:rgba(24,95,165,.4);color:var(--color-text-info)}',
    '.reason-option input[type=radio]{accent-color:var(--color-blue);width:15px;height:15px;flex-shrink:0;cursor:pointer}',

    '.notes-field{margin-top:14px}',
    '.notes-field label{display:block;font-size:12px;color:var(--color-text-secondary);margin-bottom:6px}',
    '.notes-field textarea{width:100%;border:1px solid var(--color-border-secondary);border-radius:var(--border-radius-md);background:var(--color-background-secondary);color:var(--color-text-primary);font-family:var(--font-sans);font-size:14px;padding:10px 12px;resize:none;outline:none;line-height:1.4}',
    '.notes-field textarea:focus{border-color:var(--color-blue)}',

    '.btn{padding:10px 22px;border-radius:var(--border-radius-md);font-family:var(--font-sans);font-size:14px;font-weight:500;cursor:pointer;border:1px solid var(--color-border-secondary);background:var(--color-background-primary);color:var(--color-text-primary);transition:background .1s}',
    '.btn:hover{background:var(--color-background-secondary)}',
    '.btn-amber{background:var(--color-amber);border-color:var(--color-amber);color:#fff}',
    '.btn-amber:hover{filter:brightness(.9)}',
    '.btn-amber:disabled{opacity:.35;cursor:not-allowed;filter:none}',
    '.btn-green{background:var(--color-green);border-color:var(--color-green);color:#fff}',
    '.btn-green:hover{filter:brightness(.9)}',
    '.btn-green:disabled{opacity:.35;cursor:not-allowed;filter:none}',

    '.resume-info{background:var(--color-background-secondary);border-radius:var(--border-radius-md);padding:12px 16px;margin-bottom:18px;display:flex;gap:28px;font-size:13px}',
    '.resume-info-label{color:var(--color-text-secondary);margin-bottom:3px}',
    '.resume-info-value{font-weight:500}',
    '.section-label{font-size:12px;font-weight:600;color:var(--color-text-secondary);text-transform:uppercase;letter-spacing:.4px;margin-bottom:10px}',
    '.outcome-option{display:flex;align-items:flex-start;gap:12px;padding:13px 14px;border-radius:var(--border-radius-md);cursor:pointer;border:1px solid var(--color-border-tertiary);transition:background .1s,border-color .1s;margin-bottom:8px}',
    '.outcome-option:hover{background:var(--color-background-secondary)}',
    '.outcome-option.selected{background:var(--color-background-info);border-color:rgba(24,95,165,.4)}',
    '.outcome-option input[type=radio]{accent-color:var(--color-blue);width:15px;height:15px;flex-shrink:0;margin-top:2px;cursor:pointer}',
    '.outcome-label{font-size:14px;font-weight:500}',
    '.outcome-desc{font-size:12px;color:var(--color-text-secondary);margin-top:3px}',

    '.line-badge.paused{background:var(--color-background-warning);color:var(--color-text-warning)}',
    '.line-badge.paused .dot{background:var(--color-amber);animation:none}',
    '.pause-timer-badge{display:none;align-items:center;gap:8px;padding:6px 14px;background:var(--color-background-warning);color:var(--color-text-warning);border-radius:var(--border-radius-md);font-size:14px;font-weight:500}',
    '.pause-timer-badge.visible{display:inline-flex}'
  ].join('\n');
  document.head.appendChild(styleEl);

  /* ── Inject modal HTML ──────────────────────────────────────── */
  var wrap = document.createElement('div');
  wrap.innerHTML = '' +
    '<div class="modal-overlay" id="pause-overlay">' +
      '<div class="modal">' +
        '<div class="modal-header">' +
          '<h2>Pause run — confirmation</h2>' +
          '<div class="modal-context">' +
            '<span id="pause-line-ctx">—</span>' +
            '<span>Footage <span class="mono" id="pause-footage-ctx">—</span></span>' +
            '<span id="pause-time-ctx" class="mono">—</span>' +
          '</div>' +
        '</div>' +
        '<div class="modal-body">' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Equipment / Mechanical</div>' +
            opt('Die change (mid-run, no weld)') +
            opt('Roll adjustment') +
            opt('Lubrication / coolant') +
            opt('Draw box inspection') +
            opt('Component inspection (non-fault)') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Material Handling</div>' +
            opt('Payoff 2 loading / weld preparation') +
            opt('Downstream blockage (TKUP-2 full / FL2 not ready)') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Quality / Measurement</div>' +
            opt('Gauge / width investigation') +
            opt('Manual SPC measurement') +
            opt('Surface inspection') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Operational</div>' +
            opt('Operator break') +
            opt('Shift changeover') +
            opt('Awaiting supervisor instruction') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Safety</div>' +
            opt('Safety observation (non-fault)') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Rod Checkout</div>' +
            opt('__checkout__', 'Check out rod — remove rod from payoff') +
          '</div>' +
          '<div class="reason-group">' +
            '<div class="reason-group-label">Other</div>' +
            opt('__other__', 'Other (describe in notes below)') +
          '</div>' +
          '<div class="notes-field">' +
            '<label>Notes (optional)</label>' +
            '<textarea id="pause-notes" rows="3" placeholder="Additional detail…"></textarea>' +
          '</div>' +
        '</div>' +
        '<div class="modal-footer">' +
          '<button class="btn" onclick="closePauseDialog()">Cancel</button>' +
          '<button class="btn btn-amber" id="confirm-pause-btn" disabled onclick="confirmPause()">Confirm pause</button>' +
        '</div>' +
      '</div>' +
    '</div>' +

    '<div class="modal-overlay" id="resume-overlay">' +
      '<div class="modal">' +
        '<div class="modal-header">' +
          '<h2>Resume run — confirmation</h2>' +
          '<div class="modal-context"><span id="resume-line-ctx">—</span></div>' +
        '</div>' +
        '<div class="modal-body">' +
          '<div class="resume-info">' +
            '<div><div class="resume-info-label">Pause reason</div><div class="resume-info-value" id="resume-reason-display">—</div></div>' +
            '<div><div class="resume-info-label">Paused for</div><div class="resume-info-value" style="font-family:var(--font-mono)" id="resume-duration-display">00:00</div></div>' +
          '</div>' +
          '<div class="section-label">Was the issue resolved?</div>' +
          outcome('resume',      'Yes — resume run',        'Line restarts; run timer continues; pause event closed with duration logged.') +
          outcome('wip-reject',  'No — log WIP rejection',  'Pause event closed; WIP Rejection screen opened to record and disposition the material.') +
          outcome('stay-paused', 'No — continue pause',     'Dialog dismissed; line remains paused; pause timer continues.') +
          '<div class="notes-field">' +
            '<label>Activity completed during pause (optional)</label>' +
            '<textarea id="resume-notes" rows="2" placeholder="e.g. Roll gap adjusted, coolant topped up…"></textarea>' +
          '</div>' +
        '</div>' +
        '<div class="modal-footer">' +
          '<button class="btn" onclick="closeResumeDialog()">Cancel</button>' +
          '<button class="btn btn-green" id="confirm-resume-btn" disabled onclick="confirmResume()">Confirm</button>' +
        '</div>' +
      '</div>' +
    '</div>';
  document.body.appendChild(wrap);

  /* ── HTML builder helpers ───────────────────────────────────── */
  function opt(value, label) {
    var display = label || value;
    return '<div class="reason-option" onclick="selectReason(this,\'' + value.replace(/'/g, "\\'") + '\')">' +
           '<input type="radio" name="pause-reason"> ' + display + '</div>';
  }
  function outcome(value, label, desc) {
    return '<div class="outcome-option" data-value="' + value + '" onclick="selectOutcome(this)">' +
           '<input type="radio" name="resume-outcome">' +
           '<div><div class="outcome-label">' + label + '</div>' +
           '<div class="outcome-desc">' + desc + '</div></div></div>';
  }

  /* ── State ──────────────────────────────────────────────────── */
  var pauseStartMs = null;
  var pauseReason  = null;
  var pauseTimer   = null;

  /* ── Helpers ────────────────────────────────────────────────── */
  function p2(n) { return String(n).padStart(2, '0'); }

  function elapsed(ms) {
    var s = Math.floor(ms / 1000);
    return p2(Math.floor(s / 60)) + ':' + p2(s % 60);
  }

  function lineName() {
    var badge = document.querySelector('.line-badge');
    if (!badge) return '—';
    var m = badge.textContent.match(/FL\d+/);
    return m ? m[0] : '—';
  }

  function footageVal() {
    var el = document.getElementById('footage-val');
    return el ? el.textContent + ' ft' : '—';
  }

  function clockVal() {
    var el = document.getElementById('clock');
    return el ? el.textContent : '—';
  }

  /* ── Pause dialog ───────────────────────────────────────────── */
  window.openPauseDialog = function () {
    document.getElementById('pause-line-ctx').textContent    = lineName();
    document.getElementById('pause-footage-ctx').textContent = footageVal();
    document.getElementById('pause-time-ctx').textContent    = clockVal();
    document.getElementById('pause-overlay').classList.add('open');
  };

  window.closePauseDialog = function () {
    document.getElementById('pause-overlay').classList.remove('open');
    document.querySelectorAll('.reason-option').forEach(function (el) {
      el.classList.remove('selected');
      el.querySelector('input').checked = false;
    });
    document.getElementById('pause-notes').value = '';
    document.getElementById('confirm-pause-btn').disabled = true;
    pauseReason = null;
  };

  window.selectReason = function (el, value) {
    document.querySelectorAll('.reason-option').forEach(function (o) { o.classList.remove('selected'); });
    el.classList.add('selected');
    el.querySelector('input').checked = true;
    pauseReason = (value === '__other__') ? 'Other' : (value === '__checkout__') ? '__checkout__' : value;
    document.getElementById('confirm-pause-btn').disabled = false;
  };

  window.confirmPause = function () {
    var notes = document.getElementById('pause-notes').value.trim();
    if (pauseReason === 'Other' && notes) pauseReason = notes;

    if (pauseReason === '__checkout__') {
      window.closePauseDialog();
      window.location.href = 'dashboard_12_rod_checkout.html';
      return;
    }

    pauseStartMs = Date.now();
    window.closePauseDialog();

    var line = lineName();

    var badge = document.querySelector('.line-badge');
    badge.className = 'line-badge paused';
    badge.innerHTML = '<span class="dot"></span>' + line + ' paused';

    var tb = document.getElementById('pause-timer-badge');
    if (tb) tb.classList.add('visible');

    var btn = document.getElementById('pause-btn');
    if (btn) {
      btn.classList.add('warn');
      btn.innerHTML =
        '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
        '<polygon points="5 3 19 12 5 21 5 3"/></svg>' +
        '<span class="action-btn-label">Resume run</span>';
      btn.onclick = window.openResumeDialog;
    }

    pauseTimer = setInterval(function () {
      var el = document.getElementById('pause-elapsed');
      if (el) el.textContent = elapsed(Date.now() - pauseStartMs);
    }, 1000);
  };

  /* ── Resume dialog ──────────────────────────────────────────── */
  window.openResumeDialog = function () {
    document.getElementById('resume-line-ctx').textContent       = lineName();
    document.getElementById('resume-reason-display').textContent = pauseReason || '—';
    document.getElementById('resume-duration-display').textContent =
      pauseStartMs ? elapsed(Date.now() - pauseStartMs) : '00:00';
    document.getElementById('resume-overlay').classList.add('open');
  };

  window.closeResumeDialog = function () {
    document.getElementById('resume-overlay').classList.remove('open');
    document.querySelectorAll('.outcome-option').forEach(function (el) {
      el.classList.remove('selected');
      el.querySelector('input').checked = false;
    });
    document.getElementById('resume-notes').value = '';
    document.getElementById('confirm-resume-btn').disabled = true;
  };

  window.selectOutcome = function (el) {
    document.querySelectorAll('.outcome-option').forEach(function (o) { o.classList.remove('selected'); });
    el.classList.add('selected');
    el.querySelector('input').checked = true;
    document.getElementById('confirm-resume-btn').disabled = false;
  };

  window.confirmResume = function () {
    var sel = document.querySelector('.outcome-option.selected');
    if (!sel) return;
    var val = sel.getAttribute('data-value');
    window.closeResumeDialog();

    if (val === 'resume') {
      clearInterval(pauseTimer);
      pauseStartMs = null;
      pauseReason  = null;

      var tb = document.getElementById('pause-timer-badge');
      if (tb) tb.classList.remove('visible');

      var line = lineName();
      var badge = document.querySelector('.line-badge');
      badge.className = 'line-badge';
      badge.innerHTML = '<span class="dot"></span>' + line + ' running';

      var btn = document.getElementById('pause-btn');
      if (btn) {
        btn.classList.remove('warn');
        btn.innerHTML =
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
          '<rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>' +
          '<span class="action-btn-label">Pause run</span>';
        btn.onclick = window.openPauseDialog;
      }

    } else if (val === 'wip-reject') {
      window.location.href = 'dashboard_8_wip_rejection.html';
    }
    /* stay-paused: dialog closes, timer keeps running */
  };

})();
