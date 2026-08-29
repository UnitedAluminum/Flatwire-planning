/* =============================================================================
   fw-modal.js — shared dialog plumbing for every Flat Wire shopfloor modal
   =============================================================================
   One implementation of the behaviour that every `.gb-modal-overlay` needs:
   open/close, focus restore, backdrop dismissal, ESC, and a focus trap.

   Extracted from dashboard_2a_rod_precheckin.html, which carried the original
   copy. It is now shared by the pre-check-in dialogs, the pause/resume dialogs
   and the three converted screens (die change, SPC checkpoint, WIP rejection),
   so the trap behaves identically everywhere instead of drifting per screen.

   Include ONCE, before any script that opens a dialog:

       <script src="fw-modal.js"></script>

   API (all on window.FwModal, with thin globals for inline handlers):

       FwModal.open(id)        open an overlay by element id
       FwModal.close(id)       close it and restore focus to the opener
       FwModal.closeAll()      close every open overlay
       FwModal.isOpen()        true while any overlay is open
       FwModal.register(el)    wire up an overlay injected after page load
       FwModal.fit(el)         re-fit one overlay after its content changes

   NO DIALOG EVER SCROLLS. A shopfloor operator on a touch panel with gloves on
   cannot be asked to find and drag a scrollbar to reach a Confirm button, and a
   half-visible dialog reads as a broken screen. So instead of letting the body
   scroll, a dialog too tall for the window is scaled down until all of it fits —
   the same trick flat-wire-fit.js plays on whole screens, for the same reason.
   Fitting re-runs on open, on resize, and whenever the dialog's own content
   changes size (a conditional section appearing, a list growing), which is what
   the ResizeObserver below is for. Opt a dialog out with class="no-fit".

   Markup contract — the same one the existing dialogs already use:

       <div class="gb-modal-overlay" id="my-overlay">
         <div class="gb-modal" role="dialog" aria-modal="true"> … </div>
       </div>

   Any element inside carrying data-close="my-overlay" closes it.

   WHY A FOCUS TRAP: aria-modal alone does not stop Tab from walking out of the
   dialog and into the dashboard behind it, which on a touch panel means the
   operator loses the modal with no visible way back.
   ========================================================================== */
(function () {
  "use strict";
  if (window.FwModal) return;            /* guard against double-inclusion */

  var FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]),' +
                  ' textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

  /* A stack, not a single value: chained dialogs (die change -> SPC checkpoint)
     close one and open the next, and focus must land back on the control that
     began the chain rather than on <body>. */
  var focusStack = [];

  function el(id) {
    return typeof id === "string" ? document.getElementById(id) : id;
  }

  function visibleFocusables(root) {
    return Array.prototype.filter.call(root.querySelectorAll(FOCUSABLE), function (node) {
      return node.offsetParent !== null && !node.classList.contains("link-disabled");
    });
  }

  /* ── Fit-to-window ───────────────────────────────────────────────
     The overlay is position:fixed inside a <body> that flat-wire-fit.js may have
     scaled, so its box is in DESIGN pixels, not viewport pixels. Dividing the
     viewport by --fw-page-scale converts the window back into the same design
     units the dialog is laid out in; without that the dialog would think it has
     far less room than it does and shrink itself for no reason. */
  var MARGIN = 0.96;                     /* leave a sliver of backdrop visible */

  function pageScale() {
    var v = parseFloat(getComputedStyle(document.documentElement).getPropertyValue("--fw-page-scale"));
    return v > 0 ? v : 1;
  }

  function fit(overlay) {
    overlay = el(overlay);
    if (!overlay) return;
    var modal = overlay.querySelector(".gb-modal");
    if (!modal || modal.classList.contains("no-fit")) return;

    /* Measure unscaled. offsetWidth/Height report the pre-transform layout box,
       so the previous scale does not feed back into the next measurement. */
    var naturalW = modal.offsetWidth;
    var naturalH = modal.offsetHeight;
    if (!naturalW || !naturalH) return;

    var s = pageScale();
    var availW = (window.innerWidth / s) * MARGIN;
    var availH = (window.innerHeight / s) * MARGIN;

    /* Never above 1:1 — on the real 1280x1024 panel a dialog that fits is left
       exactly as designed. */
    var scale = Math.min(1, availW / naturalW, availH / naturalH);
    /* Set as a custom property, not as an inline transform. .gb-modal's entrance
       animation animates transform, and a running animation overrides the element's
       own transform outright — an inline scale here would simply be ignored for the
       first 220ms. The keyframes multiply this var in instead. */
    modal.style.setProperty("--fw-modal-fit", scale);
  }

  function fitOpen() {
    document.querySelectorAll(".gb-modal-overlay.open").forEach(fit);
  }

  /* Content-driven re-fit: conditional blocks (the die change quality hold, the
     WIP rework stage picker) appear after the dialog is already open and change
     its height. Without this the dialog would keep the scale it opened at and
     the new content would sit off the bottom of the window. */
  var RO = typeof ResizeObserver === "function" ? new ResizeObserver(function (entries) {
    for (var i = 0; i < entries.length; i++) {
      var overlay = entries[i].target.closest(".gb-modal-overlay");
      if (overlay && overlay.classList.contains("open")) fit(overlay);
    }
  }) : null;

  function open(id) {
    var overlay = el(id);
    if (!overlay || overlay.classList.contains("open")) return;
    focusStack.push(document.activeElement);
    overlay.classList.add("open");
    fit(overlay);

    /* Focus the first real control so a keyboard or barcode-scanner operator can
       type straight into the dialog. Deferred one frame: the overlay is display
       none until the class lands, and offsetParent is null until it paints. */
    requestAnimationFrame(function () {
      fit(overlay);                      /* re-measure once it has painted */
      var items = visibleFocusables(overlay);
      var preferred = overlay.querySelector("[data-autofocus]");
      var target = preferred || items[0];
      if (target) target.focus();
    });
  }

  function restoreFocus() {
    var last = focusStack.pop();
    if (last && document.contains(last) && typeof last.focus === "function") last.focus();
  }

  function close(id) {
    var overlay = el(id);
    if (!overlay || !overlay.classList.contains("open")) return;
    overlay.classList.remove("open");
    restoreFocus();
  }

  function closeAll() {
    var open = document.querySelectorAll(".gb-modal-overlay.open");
    for (var i = 0; i < open.length; i++) open[i].classList.remove("open");
    while (focusStack.length) restoreFocus();
  }

  function topOverlay() {
    var open = document.querySelectorAll(".gb-modal-overlay.open");
    return open.length ? open[open.length - 1] : null;
  }

  function isOpen() {
    return !!document.querySelector(".gb-modal-overlay.open");
  }

  /* Backdrop click. Bound per overlay rather than globally so that a click that
     starts inside the dialog and ends on the backdrop (a drag off a text field)
     does not dismiss it. */
  function register(overlay) {
    overlay = el(overlay);
    if (!overlay || overlay.__fwModalBound) return;
    overlay.__fwModalBound = true;
    overlay.addEventListener("click", function (e) {
      if (e.target === overlay) close(overlay);
    });
    overlay.querySelectorAll("[data-close]").forEach(function (btn) {
      if (btn.__fwCloseBound) return;
      btn.__fwCloseBound = true;
      btn.addEventListener("click", function () { close(btn.getAttribute("data-close")); });
    });
    var modal = overlay.querySelector(".gb-modal");
    if (RO && modal && !modal.classList.contains("no-fit")) RO.observe(modal);
  }

  function registerAll() {
    document.querySelectorAll(".gb-modal-overlay").forEach(register);
    /* data-close targets living outside their own overlay (rare, but the
       pre-check-in screen has a couple) still need binding. */
    document.querySelectorAll("[data-close]").forEach(function (btn) {
      if (btn.__fwCloseBound) return;
      btn.__fwCloseBound = true;
      btn.addEventListener("click", function () { close(btn.getAttribute("data-close")); });
    });
  }

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") {
      var top = topOverlay();
      if (top) { e.preventDefault(); close(top); }
      return;
    }
    if (e.key !== "Tab") return;

    var overlay = topOverlay();
    if (!overlay) return;
    var items = visibleFocusables(overlay);
    if (!items.length) return;
    var first = items[0], last = items[items.length - 1];
    if (!overlay.contains(document.activeElement)) { e.preventDefault(); first.focus(); return; }
    if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
    else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
  });

  window.addEventListener("resize", fitOpen);
  /* flat-wire-fit.js re-fits the page on load too, which changes --fw-page-scale
     under any dialog already open. */
  window.addEventListener("load", fitOpen);

  if (document.readyState !== "loading") registerAll();
  else document.addEventListener("DOMContentLoaded", registerAll);

  window.FwModal = {
    open: open,
    close: close,
    closeAll: closeAll,
    isOpen: isOpen,
    register: register,
    registerAll: registerAll,
    fit: fit,
    fitOpen: fitOpen
  };
})();
