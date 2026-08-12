/* =============================================================================
   flat-wire-topbar.js
   Injects the shared Flat Wire chrome onto any dashboard:
     • Global application bar (logo · greeting/environment · signed-in operators
       with one active session · Help / Refresh / Login / Switch / Logout)
     • "More Options" button in the page header, opening a tile popup
   Requires flat-wire-shopfloor.styles.css (for tokens + injected styles) and
   mainlogo.gif in the same folder. Include once, just before </body>:
       <script src="flat-wire-topbar.js"></script>
   ============================================================================= */
(function () {
  "use strict";
  if (window.__fwTopbar) return;         /* guard against double-inclusion */
  window.__fwTopbar = true;

  /* Every asset and tile target below is written relative to THIS script's folder
     (MVP-1/Mockups/), not to the host page — the MVP-2 screens live in a separate tree at
     ../../MVP-2/Mockups/, and a bare "mainlogo.gif" would 404 for those. Derived from the
     script's own src so it holds wherever the page sits. */
  var BASE = (function () {
    var s = document.currentScript;
    if (!s) { var all = document.getElementsByTagName("script"); s = all[all.length - 1]; }
    return s && s.src ? s.src.replace(/[^/]*$/, "") : "";
  })();
  function at(path) { return BASE + path; }
  function baseName(path) { return (path.split("/").pop() || "").toLowerCase(); }

  var DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  var MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  var AVATAR_COLORS = ["#185FA5", "#1D9E75", "#6B3FA0", "#EF9F27", "#D85A30", "#0c447c"];
  var MAX_SESSIONS = 6;
  var colorIx = 3;

  var USER_DIRECTORY = {
    "Bob Scott":   { role: "FL1 Shift Lead",     phone: "+1 203 265 8010", email: "bob.scott@unitedaluminum.com",   color: "#185FA5" },
    "Dave Miller": { role: "FL1 Line Operator",  phone: "+1 203 265 8021", email: "dave.miller@unitedaluminum.com", color: "#1D9E75" },
    "Lena Ruiz":   { role: "Quality Technician", phone: "+1 203 265 8033", email: "lena.ruiz@unitedaluminum.com",   color: "#6B3FA0" },
    "Sam Patel":   { role: "FL2 Line Operator",  phone: "+1 203 265 8044", email: "sam.patel@unitedaluminum.com",   color: "#EF9F27" },
    "Nora Kim":    { role: "Maintenance Tech",   phone: "+1 203 265 8055", email: "nora.kim@unitedaluminum.com",    color: "#D85A30" },
    "Omar Diaz":   { role: "Furnace Operator",   phone: "+1 203 265 8066", email: "omar.diaz@unitedaluminum.com",   color: "#0c447c" },
    "Rita Vaughn": { role: "Packing Operator",   phone: "+1 203 265 8077", email: "rita.vaughn@unitedaluminum.com", color: "#185FA5" },
    "Carl Bishop": { role: "Shift Supervisor",   phone: "+1 203 265 8088", email: "carl.bishop@unitedaluminum.com", color: "#1D9E75" }
  };
  var SIGN_IN_POOL = ["Sam Patel", "Nora Kim", "Omar Diaz", "Rita Vaughn", "Carl Bishop"];

  function details(name) {
    return USER_DIRECTORY[name] || {
      role: "Line Operator", phone: "+1 203 265 8000",
      email: name.toLowerCase().replace(/[^a-z0-9]+/g, ".") + "@unitedaluminum.com"
    };
  }
  function resolveName(input) {
    var keys = Object.keys(USER_DIRECTORY), lc = input.toLowerCase();
    for (var i = 0; i < keys.length; i++) { if (keys[i].toLowerCase() === lc) return keys[i]; }
    return input;
  }
  function initials(name) {
    var p = name.trim().split(/\s+/);
    return (p[0][0] + (p.length > 1 ? p[p.length - 1][0] : "")).toUpperCase();
  }
  function shortName(name) {
    var p = name.trim().split(/\s+/);
    return p.length > 1 ? p[0] + " " + p[p.length - 1][0] + "." : name;
  }

  /* ── Icons ── */
  var IC = {
    help:    '<svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/><path d="M9.4 9a2.6 2.6 0 015.1 0.4c0 1.6-2.5 2-2.5 3.6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="12" cy="17" r="1" fill="currentColor"/></svg>',
    refresh: '<svg viewBox="0 0 24 24" fill="none"><path d="M20 11a8 8 0 10-2 5.3M20 5v5h-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    login:   '<svg viewBox="0 0 24 24" fill="none"><path d="M15 3h3a2 2 0 012 2v14a2 2 0 01-2 2h-3M10 17l5-5-5-5M15 12H3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    swap:    '<svg viewBox="0 0 24 24" fill="none"><path d="M7 4L3 8l4 4M3 8h13M17 20l4-4-4-4M21 16H8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    logout:  '<svg viewBox="0 0 24 24" fill="none"><path d="M9 3H6a2 2 0 00-2 2v14a2 2 0 002 2h3M16 17l5-5-5-5M21 12H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    phone:   '<svg viewBox="0 0 24 24" fill="none"><path d="M6.6 10.8a15 15 0 006.6 6.6l2.2-2.2a1 1 0 011-.24 11 11 0 003.4.55 1 1 0 011 1V20a1 1 0 01-1 1A17 17 0 013 4a1 1 0 011-1h3.5a1 1 0 011 1 11 11 0 00.55 3.4 1 1 0 01-.25 1z" fill="currentColor"/></svg>',
    mail:    '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M4 7l8 6 8-6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    add:     '<svg viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3.2" stroke="currentColor" stroke-width="2"/><path d="M3.5 19a5.5 5.5 0 0111 0M18 8v6M15 11h6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>',
    grid:    '<svg viewBox="0 0 24 24" fill="none" style="width:17px;height:17px;"><rect x="3" y="3" width="7" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/><rect x="14" y="3" width="7" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/><rect x="3" y="14" width="7" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/><rect x="14" y="14" width="7" height="7" rx="1.5" stroke="currentColor" stroke-width="2"/></svg>',
    chev:    '<svg viewBox="0 0 24 24" fill="none" style="width:13px;height:13px;"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  };
  function mt(paths) {
    return '<svg class="mt-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' + paths + '</svg>';
  }
  /* More Options tiles.
       href  — navigates to another screen
       act   — name of a global function to CALL instead of navigating. Added 1 Aug 2026 for
               the screens that became dialogs: navigating to one would throw away the very
               context the dialog needs. An `act` tile MAY also carry an href, used as a
               fallback when that dialog's script is not loaded on this screen — otherwise
               the tile would silently do nothing on the two-thirds of screens that do not
               load it.
       both null — a non-navigating placeholder tile */
  var TILES = [
    { t: "Pass Schedule",      s: "View schedule",         href: "../../MVP-2/Mockups/dashboard_9_pass_schedule.html", ic: mt('<line x1="8" y1="6" x2="20" y2="6"/><line x1="8" y1="12" x2="20" y2="12"/><line x1="8" y1="18" x2="20" y2="18"/><circle cx="4" cy="6" r="1"/><circle cx="4" cy="12" r="1"/><circle cx="4" cy="18" r="1"/>') },
    { t: "WIP Rejection",      s: "Reject material",       act: "openWipRejection", href: "dashboard_8_wip_rejection.html", ic: mt('<path d="M8 3h8l5 5v8l-5 5H8l-5-5V8z"/><path d="M15 9l-6 6M9 9l6 6"/>') },
    { t: "Rod Pre-Check-in",   s: "Stage at payoff",       href: "dashboard_2a_rod_precheckin.html", ic: mt('<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="2.5"/><path d="M12 3.5v3M12 17.5v3"/>') },
    { t: "Rod Checkout",       s: "Return rod",            act: "openRodCheckout", href: "dashboard_12_rod_checkout.html", ic: mt('<path d="M14 3h5a2 2 0 012 2v14a2 2 0 01-2 2h-5"/><path d="M9 16l4-4-4-4"/><path d="M13 12H3"/>') },
    { t: "Spool Queue",        s: "Spools for FL2",        href: "dashboard_5a_spool_queue.html", ic: mt('<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3.5"/><path d="M3.6 8.5h16.8M3.6 15.5h16.8"/>') },
    { t: "Shift Summary",      s: "Shift report",          href: "../../MVP-2/Mockups/dashboard_10_shift_summary.html", ic: mt('<path d="M7 3h7l5 5v13H7z"/><path d="M14 3v5h5"/><line x1="10" y1="13" x2="16" y2="13"/><line x1="10" y1="17" x2="16" y2="17"/>') },
    { t: "Downtime",           s: "Log downtime",          href: null, ic: mt('<circle cx="12" cy="12" r="9"/><line x1="10" y1="9" x2="10" y2="15"/><line x1="14" y1="9" x2="14" y2="15"/>') },
    { t: "Supervisor Monitor", s: "Supervisor view",       href: null, ic: mt('<rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8M12 17v4"/><path d="M8.5 11.5l2.5 2 4-4.5"/>') },
    { t: "Observation",        s: "Add observation",       href: null, ic: mt('<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/>') },
    { t: "Order Info",         s: "Order details",         href: null, ic: mt('<circle cx="12" cy="12" r="9"/><line x1="12" y1="11" x2="12" y2="16"/><circle cx="12" cy="8" r="0.7" fill="currentColor" stroke="none"/>') },
    { t: "Order Instruction",  s: "Special instructions",  href: null, ic: mt('<rect x="6" y="4" width="12" height="17" rx="2"/><path d="M9 4V3h6v1"/><line x1="9" y1="10" x2="15" y2="10"/><line x1="9" y1="14" x2="15" y2="14"/>') },
    { t: "Reprint Labels",     s: "Reprint labels",        href: null, ic: mt('<path d="M6 9V3h12v6"/><path d="M6 17H4a2 2 0 01-2-2v-3a2 2 0 012-2h16a2 2 0 012 2v3a2 2 0 01-2 2h-2"/><rect x="6" y="14" width="12" height="7"/>') }
  ];

  /* ── DOM-ready ── */
  if (document.readyState !== "loading") init();
  else document.addEventListener("DOMContentLoaded", init);

  function init() {
    var dash = document.querySelector(".dashboard") || document.body;

    /* ---- Global application bar ---- */
    if (!document.querySelector(".global-bar")) {
      var chips =
        chipHTML("Bob Scott", "BS", "#185FA5", true) +
        chipHTML("Dave Miller", "DM", "#1D9E75", false) +
        chipHTML("Lena Ruiz", "LR", "#6B3FA0", false);
      var bar = document.createElement("div");
      bar.className = "global-bar panel";
      bar.innerHTML =
        '<div class="gb-left"><div class="gb-logo">' +
          '<span class="gb-copyright">&copy; UAC 2005</span>' +
          '<img class="ua-logo" src="' + at("mainlogo.gif") + '" alt="United Aluminum" width="120" height="34">' +
        '</div></div>' +
        '<div class="gb-center">' +
          '<div class="gb-greeting"><span id="gb-greeting-text">Good Afternoon</span>, <strong id="gb-primary-user">Bob Scott</strong> &middot; <span id="gb-date">&mdash;</span></div>' +
          '<div class="gb-env">THIS IS TESTING ENVIRONMENT (DEV00164-003)</div>' +
        '</div>' +
        '<div class="gb-right">' +
          '<div class="gb-users" id="gb-users"><span class="gb-users-label">Signed in:</span>' + chips + '</div>' +
          '<div class="gb-actions">' +
            '<button class="gb-btn" id="gb-help" title="Help">' + IC.help + '<span>Help</span></button>' +
            '<button class="gb-btn" id="gb-refresh" title="Refresh">' + IC.refresh + '<span>Refresh</span></button>' +
            '<button class="gb-btn accent" id="gb-login" title="Sign in another operator">' + IC.login + '<span>Login</span></button>' +
            '<button class="gb-btn" id="gb-switch" title="Switch active operator">' + IC.swap + '<span>Switch</span></button>' +
            '<button class="gb-btn danger" id="gb-logout" title="Sign out active operator">' + IC.logout + '<span>Logout</span></button>' +
          '</div>' +
        '</div>';
      dash.insertBefore(bar, dash.firstChild);
    }
    var usersEl = document.getElementById("gb-users");

    /* ---- "More Options" button in the header ---- */
    var header = document.querySelector(".header");
    if (header && !document.getElementById("more-btn")) {
      var mb = document.createElement("button");
      mb.className = "btn";
      mb.id = "more-btn";
      mb.title = "More options";
      mb.style.cssText = "display:inline-flex;align-items:center;gap:8px;";
      mb.innerHTML = IC.grid + " More Options " + IC.chev;
      header.appendChild(mb);
    }

    /* ---- Modals appended to <body> ---- */
    if (!document.getElementById("switch-overlay")) {
      var so = document.createElement("div");
      so.className = "gb-modal-overlay";
      so.id = "switch-overlay";
      so.innerHTML =
        '<div class="gb-modal" role="dialog" aria-modal="true" aria-labelledby="switch-modal-title">' +
          '<div class="gb-modal-head"><div>' +
            '<div class="gb-modal-title" id="switch-modal-title">Switch active operator</div>' +
            '<div class="gb-modal-sub">Select an operator to make them the active session</div>' +
          '</div><button class="gb-modal-close" id="switch-close" aria-label="Close">&times;</button></div>' +
          '<div class="gb-modal-body"><div class="switch-grid" id="switch-grid"></div></div>' +
        '</div>';
      document.body.appendChild(so);
    }
    if (!document.getElementById("more-overlay")) {
      var here = (location.pathname.split("/").pop() || "").toLowerCase();
      var tiles = TILES.map(function (x) {
        var isActive = x.href && baseName(x.href) === here;
        var body = x.ic + '<span class="mt-title">' + x.t + '</span><span class="mt-sub">' + x.s + '</span>' +
                   (isActive ? '<span class="mt-badge">Current</span>' : "");
        if (isActive) return '<div class="more-tile active" role="button" tabindex="0" aria-current="page">' + body + '</div>';
        /* Action tiles close this popup first: two dialogs open at once means two focus
           traps, and the operator can reach neither set of buttons. Checked before href,
           since an act tile carries one only as its no-script fallback. */
        if (x.act)    return '<button class="more-tile" type="button" data-act="' + x.act + '"' +
                             (x.href ? ' data-fallback="' + at(x.href) + '"' : '') + '>' + body + '</button>';
        if (x.href)   return '<a class="more-tile" href="' + at(x.href) + '">' + body + '</a>';
        return '<div class="more-tile" role="button" tabindex="0">' + body + '</div>';
      }).join("");
      var mo = document.createElement("div");
      mo.className = "gb-modal-overlay";
      mo.id = "more-overlay";
      mo.innerHTML =
        '<div class="gb-modal wide" role="dialog" aria-modal="true" aria-labelledby="more-modal-title">' +
          '<div class="gb-modal-head"><div>' +
            '<div class="gb-modal-title" id="more-modal-title">More options</div>' +
            '<div class="gb-modal-sub">Jump to another Flat Wire station or task</div>' +
          '</div><button class="gb-modal-close" id="more-close" aria-label="Close">&times;</button></div>' +
          '<div class="gb-modal-body"><div class="more-grid">' + tiles + '</div></div>' +
        '</div>';
      document.body.appendChild(mo);
      mo.querySelectorAll("[data-act]").forEach(function (b) {
        b.addEventListener("click", function () {
          var fn = window[b.getAttribute("data-act")];
          mo.classList.remove("open");
          if (typeof fn === "function") { fn(); return; }
          /* The dialog's script is not loaded here — fall back to its launcher page
             rather than leaving the tile dead. */
          var href = b.getAttribute("data-fallback");
          if (href) window.location.href = href;
        });
      });
    }

    wire(usersEl);
  }

  function chipHTML(name, ini, color, active) {
    return '<span class="user-chip' + (active ? " active" : "") + '" data-user="' + name + '" title="' + name + (active ? " — active" : " — tap to activate") + '">' +
      '<span class="active-dot"></span>' +
      '<span class="avatar" style="background:' + color + ';">' + ini + '</span>' +
      '<span class="u-name">' + shortName(name) + '</span>' +
      '<button class="u-close" title="Sign out ' + shortName(name) + '" aria-label="Sign out ' + shortName(name) + '">&times;</button>' +
    '</span>';
  }

  function wire(usersEl) {
    /* ── Greeting + date ── */
    function updateGreeting() {
      var now = new Date(), h = now.getHours();
      var g = document.getElementById("gb-greeting-text");
      if (g) g.textContent = h < 12 ? "Good Morning" : (h < 17 ? "Good Afternoon" : "Good Evening");
      var d = document.getElementById("gb-date");
      if (d) d.textContent = DAYS[now.getDay()] + ", " + now.getDate() + " " + MONTHS[now.getMonth()] + " " + now.getFullYear();
    }
    updateGreeting();
    setInterval(updateGreeting, 30000);

    /* ── Operator sessions (exactly one active) ── */
    function syncPrimary() {
      var chips = usersEl.querySelectorAll(".user-chip");
      var active = usersEl.querySelector(".user-chip.active");
      if (!active && chips.length) { chips[0].classList.add("active"); active = chips[0]; }
      var p = document.getElementById("gb-primary-user");
      if (p) p.textContent = active ? shortName(active.getAttribute("data-user")) : "No active session";
    }
    function setActive(chip) {
      usersEl.querySelectorAll(".user-chip").forEach(function (c) { c.classList.remove("active"); });
      if (chip) chip.classList.add("active");
      syncPrimary();
    }
    function addUser(name) {
      var d = USER_DIRECTORY[name] || {};
      var color = d.color || AVATAR_COLORS[colorIx++ % AVATAR_COLORS.length];
      var span = document.createElement("span");
      span.innerHTML = chipHTML(name, initials(name), color, false);
      usersEl.appendChild(span.firstChild);
      syncPrimary();
    }

    usersEl.addEventListener("click", function (e) {
      var btn = e.target.closest(".u-close");
      if (btn) { e.stopPropagation(); var c = btn.closest(".user-chip"); if (c) { c.remove(); syncPrimary(); } return; }
      var t = e.target.closest(".user-chip");
      if (t && !t.classList.contains("active")) setActive(t);
    });

    on("gb-login", function () {
      var chips = usersEl.querySelectorAll(".user-chip");
      if (chips.length >= MAX_SESSIONS) { toast("Maximum concurrent operator sessions reached"); return; }
      var signed = Array.prototype.map.call(chips, function (c) { return c.getAttribute("data-user"); });
      var next = SIGN_IN_POOL.filter(function (n) { return signed.indexOf(n) === -1; })[0];
      if (next) addUser(next); else toast("All available operators are already signed in");
    });
    on("gb-logout", function () {
      var a = usersEl.querySelector(".user-chip.active") || usersEl.querySelector(".user-chip");
      if (a) { a.remove(); syncPrimary(); } else toast("No operator is currently signed in");
    });
    on("gb-refresh", function () {
      updateGreeting();
      var svg = document.querySelector("#gb-refresh svg");
      if (svg) { svg.style.transition = "transform 0.6s ease"; svg.style.transform = "rotate(360deg)"; setTimeout(function () { svg.style.transition = "none"; svg.style.transform = "rotate(0deg)"; }, 620); }
    });
    on("gb-help", function () { toast("Need help? Use More Options to jump between stations, or the operator chips to switch the active session."); });

    /* ── Switch modal ── */
    var switchOverlay = document.getElementById("switch-overlay");
    var grid = document.getElementById("switch-grid");
    function renderSwitchCards() {
      var chips = usersEl.querySelectorAll(".user-chip");
      grid.innerHTML = "";
      chips.forEach(function (chip) {
        var name = chip.getAttribute("data-user");
        var av = chip.querySelector(".avatar");
        var color = av ? av.style.background : "#185FA5";
        var ini = av ? av.textContent : initials(name);
        var isActive = chip.classList.contains("active");
        var d = details(name);
        var card = document.createElement("div");
        card.className = "switch-card" + (isActive ? " active" : "");
        card.setAttribute("data-user", name);
        card.setAttribute("role", "button");
        card.setAttribute("tabindex", "0");
        card.setAttribute("title", isActive ? name + " (active)" : "Make " + name + " the active operator");
        card.innerHTML =
          '<div class="sc-photo"><span class="avatar-lg" style="background:' + color + ';">' + ini + '</span>' +
            '<span class="sc-badge' + (isActive ? " active" : "") + '">' + (isActive ? "Active" : "Idle") + '</span></div>' +
          '<div class="sc-body">' +
            '<span class="sc-name">' + name + '</span>' +
            '<span class="sc-role">' + d.role + ' &middot; United Aluminum</span>' +
            '<span class="sc-contact">' + IC.phone + '<span>' + d.phone + '</span></span>' +
            '<span class="sc-contact">' + IC.mail + '<span>' + d.email + '</span></span>' +
            '<button class="sc-logout" type="button">' + IC.logout + 'Log out</button>' +
          '</div>';
        grid.appendChild(card);
      });
      var atCap = chips.length >= MAX_SESSIONS;
      var add = document.createElement("div");
      add.className = "switch-card add-card";
      add.innerHTML = '<div class="add-card-body"><div class="add-card-title">' + IC.add + 'Sign in operator</div>' +
        (atCap
          ? '<div class="add-error show">Maximum concurrent sessions reached (' + MAX_SESSIONS + ').</div>'
          : ('<input class="add-input" id="add-username" type="text" placeholder="User name" autocomplete="off" autocapitalize="words">' +
             '<input class="add-input" id="add-password" type="password" placeholder="Password" autocomplete="off">' +
             '<div class="add-error" id="add-error"></div>' +
             '<button class="add-login-btn" id="add-login-btn" type="button">' + IC.login + 'Log in</button>')) +
        '</div>';
      grid.appendChild(add);
    }
    function doModalLogin() {
      var u = document.getElementById("add-username"), p = document.getElementById("add-password"), err = document.getElementById("add-error");
      if (!u || !p) return;
      function fail(m) { if (err) { err.textContent = m; err.classList.add("show"); } }
      var raw = (u.value || "").trim();
      if (!raw) { fail("Enter a user name."); u.focus(); return; }
      if (!(p.value || "").length) { fail("Enter a password."); p.focus(); return; }
      var name = resolveName(raw);
      if (usersEl.querySelector('.user-chip[data-user="' + name + '"]')) { fail(name + " is already signed in."); return; }
      if (usersEl.querySelectorAll(".user-chip").length >= MAX_SESSIONS) { fail("Maximum concurrent sessions reached."); return; }
      addUser(name); renderSwitchCards(); toast(name + " signed in");
    }
    function openSwitch() { renderSwitchCards(); switchOverlay.classList.add("open"); }
    function closeSwitch() { switchOverlay.classList.remove("open"); }
    on("gb-switch", openSwitch);
    on("switch-close", closeSwitch);
    switchOverlay.addEventListener("click", function (e) { if (e.target === switchOverlay) closeSwitch(); });
    grid.addEventListener("click", function (e) {
      if (e.target.closest(".add-card")) { if (e.target.closest("#add-login-btn")) { e.stopPropagation(); doModalLogin(); } return; }
      var card = e.target.closest(".switch-card"); if (!card) return;
      var name = card.getAttribute("data-user");
      var chip = usersEl.querySelector('.user-chip[data-user="' + name + '"]');
      if (e.target.closest(".sc-logout")) { e.stopPropagation(); if (chip) { chip.remove(); syncPrimary(); } renderSwitchCards(); return; }
      if (chip) setActive(chip); closeSwitch();
    });
    grid.addEventListener("keydown", function (e) { if (e.key === "Enter" && e.target.closest(".add-card")) { e.preventDefault(); doModalLogin(); } });

    /* ── More Options modal ── */
    var moreOverlay = document.getElementById("more-overlay");
    function closeMore() { if (moreOverlay) moreOverlay.classList.remove("open"); }
    on("more-btn", function () { if (moreOverlay) moreOverlay.classList.add("open"); });
    on("more-close", closeMore);
    if (moreOverlay) moreOverlay.addEventListener("click", function (e) { if (e.target === moreOverlay) closeMore(); });

    document.addEventListener("keydown", function (e) {
      if (e.key !== "Escape") return;
      if (switchOverlay.classList.contains("open")) closeSwitch();
      if (moreOverlay && moreOverlay.classList.contains("open")) closeMore();
    });

    /* ── Toast ── */
    var toastEl;
    function toast(msg) {
      if (!toastEl) {
        toastEl = document.createElement("div");
        toastEl.style.cssText = "position:fixed;top:70px;left:50%;transform:translateX(-50%);z-index:9999;" +
          "background:var(--color-text-primary);color:var(--color-background-primary);padding:8px 16px;border-radius:8px;" +
          "font-size:14px;font-family:var(--font-sans);box-shadow:0 6px 20px rgba(0,0,0,0.25);opacity:0;transition:opacity 0.2s;pointer-events:none;max-width:520px;text-align:center;";
        document.body.appendChild(toastEl);
      }
      toastEl.textContent = msg; toastEl.style.opacity = "1";
      clearTimeout(toast._t); toast._t = setTimeout(function () { toastEl.style.opacity = "0"; }, 2600);
    }

    syncPrimary();
  }

  function on(id, fn) { var el = document.getElementById(id); if (el) el.addEventListener("click", fn); }
})();
