/* =============================================================================
   flat-wire-fit.js — make a fixed-size shopfloor screen fit the browser window
   =============================================================================
   Every mockup is authored at the 1280x1024 shopfloor panel size. A normal
   (non-fullscreen) browser window only offers ~600-950px of viewport height, so
   without help these screens need F11 or they scroll.

   This scales the whole screen down by the height ratio so all of it is visible,
   with no scrollbar and no fullscreen. It never scales above 1:1, so on the real
   1280x1024 panel nothing is resized.

   Include ONCE, at the end of <body> and AFTER flat-wire-topbar.js — the top bar
   is injected on DOMContentLoaded and changes the content height, so this must
   measure after that has happened:

       <script src="flat-wire-topbar.js"></script>
       <script src="flat-wire-fit.js"></script>

   Two modes, chosen with a data-fit attribute on the script tag:

     data-fit="fill"   (default) Also widens the design box to fill the window's
                       full width, so there are no empty side margins. Only safe
                       when the layout is fluid — proportional grids, flex rows,
                       100%-width tables.

     data-fit="scale"  Keeps the 1280px design width and centres the screen,
                       letterboxing the leftover space. Kept as an escape hatch;
                       no screen currently needs it.

   Charts drawn with preserveAspectRatio="none" stretch with the box, which is
   what you want for the plot itself (grid lines, spec bands, the trace) but not
   for anything with a readable shape. unstretchCharts() therefore feeds each
   such chart a counter-scale factor that keeps its labels, live dots and label
   chips in proportion. See the CSS block below for how that is applied.

   The transform is applied to <body>, not to .dashboard, so overlays that other
   scripts append to the body (top-bar modals, pause_run.js, spool_notification.js)
   scale along with the screen instead of floating over it at full size.
   ========================================================================== */
(function () {
  "use strict";

  var DESIGN_W  = 1280;  // authored panel width
  var MIN_H     = 1024;  // authored panel height; taller screens measure larger
  var MIN_FONT  = 14;    // smallest on-panel text size, in design px

  /* currentScript is only readable while this script is executing. */
  var self = document.currentScript;
  var mode = (self && self.getAttribute("data-fit")) === "scale" ? "scale" : "fill";

  var body = document.body;
  var dash = null;
  var designH = MIN_H;

  /* ── Shell overrides.
     !important is deliberate: each screen pins its own html/body/.dashboard box
     in its inline <style>, and this has to win regardless of source order. Only
     the outer box is touched — per-screen padding, gap and flex rules survive. */
  var style = document.createElement("style");
  style.setAttribute("data-flat-wire-fit", "");
  style.textContent = [
    "html{width:100%!important;height:100%!important;min-width:0!important;",
    "overflow:hidden!important;background:var(--color-background-secondary);}",
    "body{position:absolute!important;top:0!important;left:0!important;",
    "margin:0!important;min-width:0!important;min-height:0!important;",
    "transform-origin:top left!important;}",

    /* Chart un-stretch. --fw-unstretch is set per chart by unstretchCharts()
       and is 1 (a no-op) whenever the chart's own aspect is undistorted.
       transform-box:fill-box scales each element around its own box rather than
       the SVG origin, so this stays correct even while page scripts move the
       live dots by setting cy — no coordinates are rewritten.
       rect[rx] targets the rounded event chips; plot bands carry no rx. */
    "svg[preserveAspectRatio=none] circle,",
    "svg[preserveAspectRatio=none] rect[rx]{",
    "transform:scaleX(var(--fw-unstretch,1));transform-box:fill-box;",
    "transform-origin:center center;}",
    /* Labels in ANY viewBox'd SVG carry --fw-textgrow, which lifts any label
       whose on-panel size would fall under MIN_FONT px. An SVG font-size is in
       viewBox user units, so a "14" in the markup renders at 14 x the viewBox's
       scale — often nearer 9px. This grows the glyphs uniformly (both axes) on
       top of the horizontal un-stretch, which is 1 for unstretched charts. */
    "svg[viewBox] text{",
    "transform:scale(calc(var(--fw-unstretch,1) * var(--fw-textgrow,1)),var(--fw-textgrow,1));",
    "transform-box:fill-box;transform-origin:center center;}",
    /* Anchor the scale to whichever edge text-anchor pins the label to. */
    "svg[viewBox] text{transform-origin:left center;}",
    "svg[viewBox] text[text-anchor=middle]{transform-origin:center center;}",
    "svg[viewBox] text[text-anchor=end]{transform-origin:right center;}"
  ].join("");
  document.head.appendChild(style);

  /* ── Feed each stretched chart its counter-scale factor, and lift any label
     that would render under MIN_FONT.
     kx / ky are the px-per-user-unit ratios the viewBox is mapped with; their
     quotient is exactly how much the chart distorts horizontally, so ky / kx
     undoes it. clientWidth/Height are used rather than getBoundingClientRect so
     both ratios are in design px — the outer page scale must not feed back into
     the font floor, or charts would redraw differently in every window size. */
  function unstretchCharts() {
    var charts = document.querySelectorAll("svg[viewBox]");
    for (var i = 0; i < charts.length; i++) {
      var svg = charts[i];
      var vb = svg.viewBox && svg.viewBox.baseVal;
      if (!vb || !vb.width || !vb.height) continue;
      var box = svg.getBoundingClientRect();
      var lw = svg.clientWidth || box.width;
      var lh = svg.clientHeight || box.height;
      if (!lw || !lh) continue;

      var kx = lw / vb.width;
      var ky = lh / vb.height;

      /* Stretched charts map x and y independently; every other SVG keeps its
         aspect, so one uniform scale (the smaller ratio — "meet") applies. */
      var stretched = svg.getAttribute("preserveAspectRatio") === "none";
      var unstretch = stretched && kx ? ky / kx : 1;
      var textScale = stretched ? ky : Math.min(kx, ky);
      svg.style.setProperty("--fw-unstretch", unstretch);

      /* Group labels by their x so each axis column can be checked for crowding:
         a y-axis label may only grow into the gap to its nearest neighbour. */
      var labels = svg.querySelectorAll("text");
      var columns = {};
      for (var j = 0; j < labels.length; j++) {
        var key = labels[j].getAttribute("x") || "0";
        (columns[key] = columns[key] || []).push(labels[j]);
      }

      for (var key2 in columns) {
        var column = columns[key2];
        column.sort(function (a, b) {
          return (parseFloat(a.getAttribute("y")) || 0) - (parseFloat(b.getAttribute("y")) || 0);
        });

        /* One factor for the whole column: an axis whose labels came out at
           different sizes reads as a rendering fault, so the tightest pair sets
           the limit for all of them. */
        var grow = Infinity;
        for (var k = 0; k < column.length; k++) {
          var units = parseFloat(getComputedStyle(column[k]).fontSize) || 0;
          if (!units) continue;
          var rendered = units * textScale;
          var want = rendered < MIN_FONT ? MIN_FONT / rendered : 1;

          /* Room available before this label would collide with its neighbour. */
          var y = parseFloat(column[k].getAttribute("y")) || 0;
          var gap = Infinity;
          if (k > 0) gap = Math.min(gap, y - (parseFloat(column[k - 1].getAttribute("y")) || 0));
          if (k < column.length - 1) gap = Math.min(gap, (parseFloat(column[k + 1].getAttribute("y")) || 0) - y);

          grow = Math.min(grow, gap === Infinity ? want : Math.min(want, Math.max(1, (gap * 0.92) / units)));
        }
        if (grow === Infinity) grow = 1;

        for (var k2 = 0; k2 < column.length; k2++) {
          column[k2].style.setProperty("--fw-textgrow", grow);
        }
      }
    }
  }

  /* ── Design height of the screen at a given design width.
     The screen's OWN height rule is restored for the measurement (height:"" ,
     not height:auto) — several screens pin .dashboard to 1024px and rely on
     flex-shrink to compress panels into it, and releasing the height to auto
     would let those expand and report a taller box than the screen is really
     designed to be. Reading scrollHeight against the screen's own height
     therefore returns 1024 for screens that fit, and the true content height for
     screens that currently overflow it. min-height is zeroed so that viewport
     units (min-height:100vh) don't leak the current window size into the result. */
  function measure(width) {
    var prevW = dash.style.width, prevH = dash.style.height, prevMin = dash.style.minHeight;
    dash.style.width = width + "px";
    dash.style.height = "";
    dash.style.minHeight = "0";
    var content = dash.scrollHeight;
    dash.style.width = prevW;
    dash.style.height = prevH;
    dash.style.minHeight = prevMin;
    return Math.max(MIN_H, content);
  }

  function apply(boxW, boxH, scale, offsetX, offsetY) {
    dash.style.width = boxW + "px";
    dash.style.height = boxH + "px";
    dash.style.margin = "0";
    body.style.width = boxW + "px";
    body.style.height = boxH + "px";
    body.style.transform =
      "translate(" + offsetX + "px, " + offsetY + "px) scale(" + scale + ")";
  }

  function fit() {
    dash = dash || document.querySelector(".dashboard");
    if (!dash) return;                       // component demo, nothing to fit

    var vw = document.documentElement.clientWidth;
    var vh = document.documentElement.clientHeight;

    if (mode === "scale") {
      designH = measure(DESIGN_W);
      var s = Math.min(1, vh / designH, vw / DESIGN_W);
      apply(DESIGN_W, designH,
            s,
            Math.max(0, (vw - DESIGN_W * s) / 2),
            Math.max(0, (vh - designH * s) / 2));
      unstretchCharts();
      return;
    }

    /* Fill: scale by height, then widen the design box to `vw / scale` so the
       rendered result is exactly the viewport. Measured twice because the
       content height can itself depend on the width. */
    designH = measure(Math.max(DESIGN_W, vw));
    var scale = Math.min(1, vh / designH, vw / DESIGN_W);

    designH = measure(Math.max(DESIGN_W, vw / scale));
    scale = Math.min(1, vh / designH, vw / DESIGN_W);

    apply(Math.max(DESIGN_W, vw / scale), Math.max(designH, vh / scale), scale, 0, 0);
    unstretchCharts();
  }

  fit();
  /* The top bar is injected on DOMContentLoaded and images settle on load, both
     of which change the content height — re-fit after each. */
  document.addEventListener("DOMContentLoaded", fit);
  window.addEventListener("load", fit);
  window.addEventListener("resize", fit);
})();
