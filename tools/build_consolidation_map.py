#!/usr/bin/env python3
"""Generate 90-registers/StoryConsolidationMap.md - the story -> category ledger.

This is the keystone of the FS-## consolidation and it MUST run, and be reviewed,
BEFORE any task file is deleted: after deletion the source data is gone. It is
simultaneously

  * the consolidation mapping (which FW-### becomes part of which FS-##),
  * the id-retirement ledger - every id retired WITH A FORWARDING ADDRESS, never
    reused, which is how the repo's "ids are never renumbered" rule is honoured,
  * the title lookup the two client workbook builders repoint to, which is what
    keeps their "every allocated story must resolve to a title" guards passing,
  * the forwarding address for the FW-### ids the client has already imported
    from FlatWire_TrialRunPlan.xlsx, which [TRP] declares frozen.

Only the block between the GENERATED markers is rewritten; the surrounding prose
and the sign-off section are hand-owned, because a generated file that also has
to carry a human sign-off would lose it on every regeneration.

    python tools/build_consolidation_map.py             # write the map
    python tools/build_consolidation_map.py --check     # exit 1 if stale (CI)

Category membership is defined HERE and nowhere else. 10-requirements/features/
README.md carries the human-readable copy and cites this file rather than
restating it.
"""
import os
import re
import sys
from collections import OrderedDict, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fwtasks as F  # noqa: E402

OUT = '90-registers/StoryConsolidationMap.md'
BEGIN = '<!-- BEGIN GENERATED: map -->'
END = '<!-- END GENERATED: map -->'

# --------------------------------------------------------------------------- categories
# Numbered in operator-journey order, because FS-## ids are never renumbered once minted.
CATEGORIES = OrderedDict([
    ('FS-01', ('Angular Application Shell and Foundation', ['1A'])),
    ('FS-02', ('Backend Service Foundation', ['1B'])),
    ('FS-03', ('Database Foundation and Deployment', ['1C'])),
    ('FS-04', ('Real-Time and PLC Backbone', ['1A', '1B', '3', '4', '5'])),
    ('FS-05', ('Pass Schedule - the consumer contract and ownership boundary', ['2'])),
    ('FS-06', ('Line Visibility and Alerting', ['3'])),
    ('FS-07', ('Rod Staging, Check-In, PLC Configuration and Weld Capture', ['4'])),
    ('FS-08', ('Active Run Monitoring and Gauge/Width Trace', ['5'])),
    ('FS-09', ('In-Run Production Events', ['6'])),
    ('FS-10', ('Exceptions and Off-Ramps', ['7'])),
    ('FS-11', ('Spool Lifecycle and FL2 Finishing Run', ['8'])),
    ('FS-12', ('Output Completion, Labelling and Packing', ['9'])),
    ('FS-13', ('FL3 Hybrid Continuous Route', ['10'])),
    ('FS-14', ('Order Allocation and Fulfilment', ['4', '9'])),
    ('FS-15', ('The Shared-Schema Boundary', ['4', '9'])),
    ('FS-16', ('Reporting and Certification', ['11'])),
    ('FS-17', ('Yield, Cost Ledger and Scrap', ['12'])),
    ('FS-18', ('Administration, Reference Data and Tooling Inventory', ['13'])),
    ('FS-19', ('Integration Testing, Commissioning and Go-Live', ['14'])),
    ('FS-20', ('Unscheduled and Unhosted Requirements', [])),
])

# Default: a story's phase decides its category.
PHASE_CATEGORY = {
    '1A': 'FS-01', '1B': 'FS-02', '1C': 'FS-03', '2': 'FS-05', '3': 'FS-06',
    '4': 'FS-07', '5': 'FS-08', '6': 'FS-09', '7': 'FS-10', '8': 'FS-11',
    '9': 'FS-12', '10': 'FS-13', '11': 'FS-16', '12': 'FS-17', '13': 'FS-18',
    '14': 'FS-19',
}

# The real-time/PLC pipeline is the one genuinely functional cross-phase grouping:
# the hub, the OPC ingest, the tag push and the machine simulator, carved by stream
# RT across phases 1A/1B/3/4/5 plus the simulator's BE control surface.
RT_BACKBONE = set("""
FW-080 FW-135 FW-136 FW-137 FW-149 FW-150 FW-151 FW-N05 FW-203 FW-205
FW-210 FW-211 FW-212 FW-213 FW-214 FW-215 FW-218 FW-236 FW-238 FW-239
FW-082 FW-N25
""".split())

# [REQ 5.25/5.26/5.27/5.30] - reads and writes against the shared schema as it
# stands. Declared an integration contract, not a user-facing feature.
SHARED_SCHEMA = set("FW-219 FW-220 FW-221 FW-223 FW-231".split())

# [REQ 5.28] - rod<->order allocation, sequencing and the order-boundary handoff.
ORDER_ALLOC = set("FW-225 FW-226 FW-227 FW-229 FW-240 FW-243".split())

# Stories whose phase field does not decide their category. Each is a deliberate
# override with a stated reason, which is why `category` is an independent axis
# and is never derived from `phase`.
#
# There are FOUR of these, not the fourteen an earlier draft carried: ten of those
# entries were no-ops whose phase-derived default already gave the same answer.
# Dead configuration that looks active is a liability, so `_audit_rules()` now
# refuses to build if any entry here fails to change the default.
OVERRIDES = {
    # [REQ 5.6] is titled "Weld Event - captured at the Pre-Check-In station".
    # DB4 was retired 1 Aug 2026 and FR-160..175 now lands in Dashboard 2A's
    # "Mark as welded" dialog, which belongs to check-in. phase: 6 is the stale side.
    'FW-063': ('FS-07', 'weld capture is a Dashboard 2A dialog per [REQ 5.6]; phase 6 is stale'),
    'FW-222': ('FS-08', 'single-active-run index serves the active-run read'),
    'FW-228': ('FS-12', 'footage-to-weight converter serves coil completion'),
    'FW-254': ('FS-18', 'reason-code lookups are reference data, not schema foundation'),
    # CRUD services for a tooling REGISTER, not in-run events. Their phase 6 records
    # when the register is read (during a run), not what the work is. Left on the
    # phase default they split one tool type across three categories - the exact
    # fragmentation this consolidation exists to remove.
    'FW-260': ('FS-18', 'roll-set register CRUD is reference data, not an in-run event'),
    'FW-269': ('FS-18', 'edger register CRUD is reference data, not an in-run event'),
}

# Ids referenced as a delivering story by [TB 11] / 11.1 / B.4 / B.5 that have NO
# card and NO task file. A map built only from task files loses the FR ranges they
# own, so they are carried here explicitly. Sourced from the backlog, not measured.
#   (id, title, FR range, category, action, disposition)
FILELESS = [
    ('FW-010', 'Pass schedule authoring', 'FR-060-084, FR-360-391', 'FS-05', 'Retain',
     'MVP-2 (B.5). A live dependency of FW-082'),
    ('FW-011', 'Pass schedule list', 'FR-400-410', 'FS-05', 'Retain', 'MVP-2 (B.5)'),
    ('FW-012', 'Pass schedule generation', 'FR-360-391', 'FS-05', 'Retain', 'MVP-2 (B.5)'),
    ('FW-013', 'Pass schedule change log', 'FR-360-391', 'FS-05', 'Retain', 'MVP-2 (B.5)'),
    ('FW-014', 'Roll override sink', 'FR-360-391', 'FS-09', 'Retire',
     'Subsumed by FW-169 for its MVP-1 half (B.5)'),
    ('FW-068', 'Pass schedule list, second half', 'FR-400-410', 'FS-05', 'Retain',
     'MVP-2 (B.5)'),
    ('FW-069', 'Shift summary', 'FR-480-490', 'FS-16', 'Retain', 'MVP-2 (B.5)'),
    ('FW-N07', 'Die master table', 'FR-240-255', 'FS-18', 'Retain',
     'CONTESTED. B.4 says "wholly MVP-2, uncosted"; `phase-13` says `Q91` (2 Sep 2026) '
     'returned the die domain to MVP-1 and settled the split as table=Must, screen=Should, '
     '**both in scope**, with `ToolingInventoryDie` and `DieHistory` already built in Phase 1. '
     'B.4 is the stale side. Recorded, not repaired'),
    ('FW-N08', 'Wire break', 'FR-280-282', 'FS-20', 'Retain',
     'BLOCKED, no persistence target. B.4 cites G34 and 11.1 cites OI-13 - '
     'a pre-existing contradiction, not resolved here'),
    ('FW-N09', 'OEE dashboard', 'FR-500-508', 'FS-20', 'Retain',
     'MVP-2, no phase and no owner (PP-03), uncosted (B.4)'),
    ('FW-N10', 'Stop popup', 'FR-270-277', 'FS-20', 'Retain',
     'Uncosted, no phase assignment (B.4)'),
    ('FW-N11', 'Operator session', 'FR-001-022', 'FS-20', 'Retain',
     'Cited against Phase 6, still uncosted (B.4)'),
    ('FW-N12', 'De-stub pass', '-', 'FS-20', 'Retire',
     'Absorbed in practice by FW-166 and FW-201 (B.4)'),
]


# Which category owns each [REQ] requirement section. Sourced from [REQ]'s own
# section headings, NOT from [TB 11]'s coverage matrix: that matrix's live ranges
# stop at FR-508 and it has no row for 5.3a or 5.25-5.30, so 64 live requirements
# fall outside every range while it claims "All 363 requirements map to a story".
# Building the index here instead is what makes the coverage complete.
SECTION_CATEGORY = {
    '5.0': 'FS-20', '5.1': 'FS-07', '5.2': 'FS-07', '5.3': 'FS-11', '5.3a': 'FS-11',
    '5.4': 'FS-08', '5.5': 'FS-11', '5.6': 'FS-07', '5.7': 'FS-09', '5.8': 'FS-09',
    '5.9': 'FS-09', '5.11': 'FS-09', '5.12': 'FS-20', '5.13': 'FS-20', '5.14': 'FS-10',
    '5.15': 'FS-10', '5.16': 'FS-12', '5.17': 'FS-12', '5.20': 'FS-06',
    '5.25': 'FS-15', '5.26': 'FS-15', '5.27': 'FS-15', '5.28': 'FS-14', '5.29': 'FS-11',
    '5.30': 'FS-15',
}

# Sections whose requirements are NOT DECLARED in [REQ] any more, though the range
# and its owning category are both real - the ranges still appear in [TB 11]'s
# matrix. There is no heading to measure, so the range is quoted from the matrix.
#
# The scope note is per entry and is NOT uniformly "MVP-2": 5.10's requirements
# were returned to MVP-1 by Q91 on 2 Sep 2026 and DieManagement.md v1.2 carries
# "Status: MVP-1" in its own header, while [REQ]'s index row still folds 5.10 in
# with the deferred set. That staleness is recorded here, not repaired.
#   section: (category, FR range as [TB 11] states it, count, subject, scope note)
SECTION_MVP2 = {
    # 5.10 still HAS a heading, but only because that heading was repurposed as the
    # index row for the whole moved set ("5.10 - 5.18 - 5.19 - 5.23 - 5.24 - moved to
    # MVP-2"). It declares no requirement of its own, so it belongs here and not in
    # SECTION_EXCLUDED - without this row, Die Management's FR-240-255 has no category.
    '5.10': ('FS-18', 'FR-240-255', 16, 'Die Management - tooling inventory',
             '**MVP-1** by `Q91`, 2 Sep 2026 - `DieManagement.md` v1.2 says so in its own '
             'header. ⚠ `[REQ]` still folds this section into its MVP-2 index row, so '
             '**these 16 MVP-1 requirements have no `[REQ]` section at all**'),
    '5.18': ('FS-05', 'FR-360-391', 28, 'Pass Schedule Management - DB9', 'MVP-2'),
    '5.19': ('FS-05', 'FR-400-410', 11, 'Pass Schedule List - DB9A', 'MVP-2'),
    '5.23': ('FS-16', 'FR-480-490', 11, 'Shift Summary - DB10', 'MVP-2'),
    '5.24': ('FS-20', 'FR-500-508', 9, 'OEE Dashboard', 'MVP-2'),
}

# Sections with no owning category, each for a stated reason.
SECTION_EXCLUDED = {
    '5.21': 'DB13 HMI schematic - WITHDRAWN 4 Aug 2026',
    '5.22': 'DB14 SCADA trends - WITHDRAWN 4 Aug 2026',
}


def req_sections():
    """[(section, title, [live FR ints], [struck FR ints])] from [REQ], in order."""
    req = F.read('10-requirements/BusinessRequirements.md')
    heads = [(m.start(), m.group(1), m.group(2))
             for m in re.finditer(r'^### (5\.\d+[a-z]?)\s+(.*)$', req, re.M)]
    out = []
    for k, (pos, num, title) in enumerate(heads):
        end = heads[k + 1][0] if k + 1 < len(heads) else len(req)
        live, dead = [], []
        for line in req[pos:end].split('\n'):
            m = re.match(r'^\|\s*(?:\S+\s*)?(~~)?\*\*`?FR-(\d{3})', line)
            if m:
                (dead if m.group(1) else live).append(int(m.group(2)))
        out.append((num, title.strip(), sorted(set(live)), sorted(set(dead))))
    return out


def esc(s):
    return (s or '').replace('|', r'\|').strip()


def read_expected_counts():
    """[(category, absorbed story count)] - the map's own view, not the files'.

    build_features.py needs to tell "this category never had a story" from "its
    task files have been retired", and only the map can answer that once the
    files are gone. Parsed from the generated summary so it survives them.
    """
    out = []
    for line in F.read(OUT).split('\n'):
        m = re.match(r'^\|\s*`(FS-\d+)`\s*\|[^|]*\|[^|]*\|\s*(\d+)\s*\|', line)
        if m:
            out.append((m.group(1), int(m.group(2))))
    return out

def categorise(t):
    """(category, reason) for one task file."""
    tid = t['id']
    if tid in OVERRIDES:
        return OVERRIDES[tid]
    if tid in RT_BACKBONE:
        return ('FS-04', 'real-time / PLC pipeline')
    if tid in SHARED_SCHEMA:
        return ('FS-15', 'shared-schema integration contract, [REQ 5.25-5.30]')
    if tid in ORDER_ALLOC:
        return ('FS-14', 'order allocation, [REQ 5.28]')
    ph = str(t.get('phase', '')).upper()
    cat = PHASE_CATEGORY.get(ph)
    return (cat, ('phase %s' % ph) if cat else None)


def streams_of(t):
    s = t.get('streams') or ([t['stream']] if t.get('stream') else [])
    if isinstance(s, str):
        s = [s]
    return [x for x in s if x]


def hsum(values):
    return sum(int(h) for h in values if str(h).isdigit())


def _audit_rules(by_id):
    """Every membership rule must be live: name a real story AND change the default.

    A rule that names a deleted id, or that restates the phase-derived answer, is
    dead configuration that still reads as a decision. Ten no-op OVERRIDES entries
    accumulated in one afternoon, so this is enforced rather than reviewed.
    """
    out = []
    for tid, (cat, _why) in sorted(OVERRIDES.items()):
        t = by_id.get(tid)
        if t is None:
            out.append('OVERRIDES names %s, which has no task file' % tid)
            continue
        if PHASE_CATEGORY.get(str(t.get('phase', '')).upper()) == cat:
            out.append('OVERRIDES[%s] -> %s is a NO-OP; the phase default already says %s'
                       % (tid, cat, cat))
    for name, ids, target in (('RT_BACKBONE', RT_BACKBONE, 'FS-04'),
                              ('SHARED_SCHEMA', SHARED_SCHEMA, 'FS-15'),
                              ('ORDER_ALLOC', ORDER_ALLOC, 'FS-14')):
        for tid in sorted(ids):
            t = by_id.get(tid)
            if t is None:
                out.append('%s names %s, which has no task file' % (name, tid))
                continue
            if PHASE_CATEGORY.get(str(t.get('phase', '')).upper()) == target:
                out.append('%s[%s] is a NO-OP; the phase default already says %s'
                           % (name, tid, target))
    overlap = (RT_BACKBONE & SHARED_SCHEMA) | (RT_BACKBONE & ORDER_ALLOC) \
        | (SHARED_SCHEMA & ORDER_ALLOC)
    if overlap:
        out.append('a story is in two membership sets: %s' % sorted(overlap))
    both = sorted(set(OVERRIDES) & (RT_BACKBONE | SHARED_SCHEMA | ORDER_ALLOC))
    if both:
        out.append('a story is both an OVERRIDE and in a membership set: %s' % both)
    # Every live [REQ] section must be owned or explicitly excluded, or a whole
    # block of requirements silently loses its category.
    known = set(SECTION_CATEGORY) | set(SECTION_EXCLUDED) | set(SECTION_MVP2)
    present = set()
    live_by_section = {}
    for num, title, live, _dead in req_sections():
        present.add(num)
        live_by_section[num] = live
        if num not in known:
            out.append('[REQ] section %s (%s, %d live FR) is in neither '
                       'SECTION_CATEGORY nor SECTION_EXCLUDED' % (num, title[:40], len(live)))
    for num, cat in sorted(SECTION_CATEGORY.items()):
        if cat not in CATEGORIES:
            out.append('SECTION_CATEGORY[%s] -> unknown category %s' % (num, cat))
        if num not in present:
            out.append('SECTION_CATEGORY names [REQ] section %s, which has no heading in [REQ]'
                       % num)
    for num in sorted(SECTION_EXCLUDED):
        if num not in present:
            out.append('SECTION_EXCLUDED names [REQ] section %s, which has no heading' % num)
    for num, (cat, _rng, _n, _subj, _note) in sorted(SECTION_MVP2.items()):
        if cat not in CATEGORIES:
            out.append('SECTION_MVP2[%s] -> unknown category %s' % (num, cat))
        if live_by_section.get(num):
            out.append('SECTION_MVP2 names [REQ] section %s, which still declares %d live '
                       'requirement(s) - move it to SECTION_CATEGORY'
                       % (num, len(live_by_section[num])))
    overlap = set(SECTION_MVP2) & (set(SECTION_CATEGORY) | set(SECTION_EXCLUDED))
    if overlap:
        out.append('section in two buckets: %s' % sorted(overlap))
    return out


def build():
    tasks = F.load_tasks()
    backlog = F.read(F.BACKLOG)
    carded = set(re.findall(r'^######\s+(?:~~)?\*{0,2}`?(FW-N?\d+)', backlog, re.M))
    by_id = {t['id']: t for t in tasks}

    problems = _audit_rules(by_id)
    if carded - set(by_id):
        problems.append('cards with no task file: %s' % sorted(carded - set(by_id)))
    if set(by_id) - carded:
        problems.append('task files with no card: %s' % sorted(set(by_id) - carded))

    rows = []
    seen = {}
    for t in tasks:
        cat, why = categorise(t)
        if cat is None:
            problems.append('%s (phase %r) matches no category' % (t['id'], t.get('phase')))
            continue
        if cat not in CATEGORIES:
            problems.append('%s assigned unknown category %s' % (t['id'], cat))
            continue
        if t['id'] in seen:
            problems.append('%s assigned twice' % t['id'])
        seen[t['id']] = cat
        cancelled = t.get('status') == 'cancelled'
        action = 'Retire' if cancelled else 'Consolidate'
        note = ('cancelled by D-32; ' + why) if cancelled else why
        rows.append((t['id'], t.get('title', ''), str(t.get('phase', '')),
                     streams_of(t), t.get('hours', ''), t.get('status', ''),
                     cat, action, note))

    if len(seen) != len(tasks):
        problems.append('assigned %d of %d task files' % (len(seen), len(tasks)))

    for r in FILELESS:
        if r[0] in by_id:
            problems.append('%s is listed as fileless but has a task file' % r[0])
        if r[3] not in CATEGORIES:
            problems.append('%s assigned unknown category %s' % (r[0], r[3]))

    # Hours must survive the partition exactly, per phase and per stream. This is
    # what proves the map neither drops nor duplicates a story.
    direct_phase, direct_stream = defaultdict(int), defaultdict(int)
    for t in tasks:
        h = int(t['hours']) if str(t.get('hours', '')).isdigit() else 0
        direct_phase[str(t.get('phase', ''))] += h
        for s in streams_of(t):
            direct_stream[s] += h
    part_phase, part_stream = defaultdict(int), defaultdict(int)
    for (_i, _t, ph, st, h, _s, _c, _a, _n) in rows:
        hv = int(h) if str(h).isdigit() else 0
        part_phase[ph] += hv
        for s in st:
            part_stream[s] += hv
    if dict(direct_phase) != dict(part_phase):
        problems.append('per-phase hour sums changed')
    if dict(direct_stream) != dict(part_stream):
        problems.append('per-stream hour sums changed')

    if problems:
        print('build_consolidation_map: REFUSING to emit -')
        for p in problems:
            print('  * %s' % p)
        return None

    L = [BEGIN, '']
    L.append('> Regenerated by `tools/build_consolidation_map.py`. **Do not edit inside the '
             'markers.** Sections 1 and 3 are hand-owned.')
    L.append('')
    L.append('### 2.1 Category summary')
    L.append('')
    L.append('| `FS-##` | Category | Phases | Stories | Stubs | Plans | Retained | h |')
    L.append('|---|---|---|---:|---:|---:|---:|---:|')
    for cid, (name, phases) in CATEGORIES.items():
        mine = [r for r in rows if r[6] == cid]
        stubs = sum(1 for r in mine if by_id[r[0]].get('has_plan') != 'true')
        ret = [r for r in FILELESS if r[3] == cid]
        L.append('| `%s` | %s | %s | %d | %d | %d | %d | %d |' % (
            cid, name, ' · '.join(phases) or '—', len(mine), stubs,
            len(mine) - stubs, len(ret), hsum([r[4] for r in mine])))
    L.append('| | **Total** | | **%d** | | | **%d** | **%d** |'
             % (len(rows), len(FILELESS), hsum([r[4] for r in rows])))
    L.append('')
    L.append("*The `h` column sums the absorbed stories' `hours:` front-matter. It is an audit of "
             'the partition, **not** a costing figure: `[CE §3e]` is the hours model of record '
             'and no `FS` file publishes an hours total.*')
    L.append('')
    # ---- 2.2 requirement coverage -----------------------------------------
    secs = req_sections()
    L.append('### 2.2 Requirement coverage by category')
    L.append('')
    L.append('Built from `[REQ]`\'s own section headings. ⚠ **Not from `[TB §11]`\'s coverage '
             'matrix**, whose live ranges stop at `FR-508` and which has no row for §5.3a or '
             '§5.25–§5.30 — so **%d live requirements fall outside every range it lists** while it '
             'states *"All 363 requirements map to a story"*. That is pre-existing and is not '
             'repaired here; this index simply covers what the matrix does not.'
             % sum(len(s[2]) for s in secs
                   if s[0] in SECTION_CATEGORY and (not s[2] or s[2][-1] > 508 or s[0] == '5.3a')))
    L.append('')
    L.append('| `[REQ]` § | Section | Live `FR` | n | Owning category |')
    L.append('|---|---|---|---:|---|')
    live_total = 0
    for num, title, live, _dead in secs:
        if num in SECTION_MVP2:
            continue          # rendered below, from the matrix range
        cat = SECTION_CATEGORY.get(num)
        if cat is None and num in SECTION_EXCLUDED:
            L.append('| ~~%s~~ | ~~%s~~ | — | — | *%s* |'
                     % (num, esc(title)[:46], SECTION_EXCLUDED[num]))
            continue
        rng = 'FR-%03d–%03d' % (live[0], live[-1]) if live else '—'
        live_total += len(live)
        L.append('| %s | %s | %s | %d | `%s` |'
                 % (num, esc(title)[:46], rng, len(live), cat))
    for num in sorted(SECTION_MVP2, key=float):
        cat, rng, n, subj, note = SECTION_MVP2[num]
        live_total += n
        L.append('| %s | %s — *not declared in `[REQ]`; %s* | %s | %d | `%s` |'
                 % (num, esc(subj), note, rng, n, cat))
    L.append('| | **Total mapped** | | **%d** | |' % live_total)
    L.append('')

    L.append('### 2.3 The map, by category')
    L.append('')
    for cid, (name, phases) in CATEGORIES.items():
        mine = sorted([r for r in rows if r[6] == cid],
                      key=lambda r: (F.phase_sort_key(r[2]), r[0]))
        ret = [r for r in FILELESS if r[3] == cid]
        L.append('#### `%s` — %s' % (cid, name))
        L.append('')
        if not mine and not ret:
            L.append('*No story maps here. This category is authored from specifications and '
                     'registers, not from the backlog.*')
            L.append('')
            continue
        L.append('| `FW-###` | Title | Ph | Streams | h | Status at consolidation | Action '
                 '| Basis |')
        L.append('|---|---|---|---|---:|---|---|---|')
        for (i, ti, ph, st, h, stat, _c, act, note) in mine:
            L.append('| `%s` | %s | %s | %s | %s | %s | %s | %s |' % (
                i, esc(ti)[:70], ph or '—', '·'.join(st) or '—',
                h or '—', stat, act, esc(note)))
        for (i, ti, fr, _c, act, note) in ret:
            L.append('| `%s` | %s | — | — | — | *no card, no task file* '
                     '| **%s** | %s — %s |' % (i, esc(ti)[:70], act, fr, esc(note)))
        L.append('')
    # ---- 2.3 category dependency direction --------------------------------
    # Collapsing nodes in a DAG can create cycles, and it does here: the task graph
    # carries one known cycle and the category graph carries dozens. This section
    # exists so that fact is measured rather than rediscovered, and it is why an FS
    # file carries NO depends_on - see the note below.
    task_cat = dict((r[0], r[6]) for r in rows)
    for fr in FILELESS:
        task_cat[fr[0]] = fr[3]
    weight = defaultdict(list)
    intra = 0
    for t in tasks:
        src = task_cat.get(t['id'])
        for d in t.get('depends_on', []):
            dst = task_cat.get(d)
            if dst is None:
                continue
            if dst == src:
                intra += 1
            else:
                weight[(src, dst)].append('%s→%s' % (t['id'], d))
    mutual = sorted({tuple(sorted(k)) for k in weight if (k[1], k[0]) in weight})

    L.append('### 2.4 Category dependency direction')
    L.append('')
    L.append('%d task-level `depends_on` edges: **%d collapse inside a category** (which is the '
             'fragmentation this consolidation removes) and %d cross a boundary.'
             % (sum(len(t.get('depends_on', [])) for t in tasks), intra,
                sum(len(v) for v in weight.values())))
    L.append('')
    L.append('⛔ **An `FS` file therefore carries no `depends_on`.** Collapsing nodes in a directed '
             'acyclic graph can create cycles, and it does here: the task graph has **one** known '
             'cycle (`FW-071`/`FW-072`, `G63`) and the category graph has **%d** mutually dependent '
             'pairs. `check_docs.py` rule 2 treats a cycle as a hard error, so a mechanically '
             'derived category dependency list would be unusable. Dependencies live **per activity** '
             'inside each parent, where the original granularity keeps the graph acyclic, and the '
             'category-level direction below is for sequencing only.' % len(mutual))
    L.append('')
    L.append('| Pair | Dominant direction | Back-edges against it |')
    L.append('|---|---|---|')
    for a, b in mutual:
        ab, ba = weight[(a, b)], weight[(b, a)]
        if len(ab) >= len(ba):
            fwd, back, bl = a, b, ba
        else:
            fwd, back, bl = b, a, ab
        n = max(len(ab), len(ba))
        L.append('| `%s` ↔ `%s` | `%s` → `%s` (%d edge%s) | %d — %s |' % (
            a, b, fwd, back, n, '' if n == 1 else 's', len(bl),
            ', '.join('`%s`' % x for x in bl[:4]) + (' …' if len(bl) > 4 else '')))
    L.append('')
    L.append('*`FS-09` ↔ `FS-10` carries the pre-existing `FW-071`/`FW-072` cycle recorded as '
             '`G63`; consolidation neither creates nor fixes it.*')
    L.append('')

    L.append('### 2.5 Retired ids')
    L.append('')
    L.append('Ids **not** absorbed into a parent. Each keeps its number forever and is never '
             'reused (`TaskIdMap.md` rule 3).')
    L.append('')
    L.append('| `FW-###` | Why | Forwarding address |')
    L.append('|---|---|---|')
    for (i, _ti, _ph, _st, _h, _stat, cat, act, note) in rows:
        if act == 'Retire':
            L.append('| `%s` | %s | `%s` |' % (i, esc(note), cat))
    for (i, _ti, _fr, cat, act, note) in FILELESS:
        if act == 'Retire':
            L.append('| `%s` | %s | `%s` |' % (i, esc(note), cat))
    L.append('')
    L.append(END)
    return '\n'.join(L)


SCAFFOLD = """# Flat Wire — Story Consolidation Map (`FW-###` → `FS-##`)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Last Updated:** September 9, 2026 — created with the `FS-##` consolidation
**Document Type:** Register — the only home for the story → category pairing and the id-retirement ledger
**Status:** Active — section 2 is generated; sections 1 and 3 are hand-owned
**Owner:** Delivery lead
**Audience:** Delivery lead, anyone tracing a retired `FW-###`
**Shortcode:** `[SCM]`

---

## 1. Why this file exists

The granular `FW-###` stories are consolidated into **20 category-based parent stories**
(`FS-01`–`FS-20`), each of which becomes the single source of truth for its functional area.
This file is the join between the two, and it has four jobs that outlive the migration:

1. **The consolidation mapping** — which story became part of which category, and on what basis.
2. **The id-retirement ledger.** Ids are never renumbered in this repository, so every `FW-###` is
   retired **with a forwarding address** rather than deleted. No number is ever reused.
3. **The title lookup** for `tools/deliverables/build_development_plan_xlsx.py` and
   `build_trial_run_xlsx.py`, whose guards require every allocated story to resolve to a title.
4. **The forwarding address for ids the client already holds.** `[TRP]` declares story ids frozen
   and the repository's join key, and `FlatWire_TrialRunPlan.xlsx` puts them in client-visible
   cells. Retiring them as planning units is fine; letting them stop resolving is not.

⚠ **This file must be generated and reviewed BEFORE any task file is deleted.** After deletion
the source data is gone.

**Category membership is defined in `tools/build_consolidation_map.py` and nowhere else.**
`10-requirements/features/README.md` carries the human-readable copy and cites this file rather
than restating it.

### Actions

| Action | Meaning |
|---|---|
| **Consolidate** | Absorbed into the named parent, which becomes the source of truth for it |
| **Retire** | Cancelled or subsumed. Keeps its id forever; the parent is only a forwarding address |
| **Retain** | Tracked, not absorbed — MVP-2 deferrals and uncosted items with no card and no task file. They own `FR` ranges no task file covers, which is why a map built only from task files would lose them |
| **Split** | Not used. Nothing in this backlog needed splitting across categories |

---

## 2. The map

{GENERATED}

---

## 3. Sign-off

⛔ **The migration's one-way door is the deletion step, and this section is the gate in front of
it.** No task file is deleted and no plan archived until the review below is recorded.

The reviewer must confirm, against the tag named here:

- every story resolves to exactly one category, and the stated basis is right;
- every `FR-###` still reaches a category — including the `Retain` rows, which own ranges no task
  file covers;
- every `depends_on` edge either collapses inside a category or becomes a clean `FS` → `FS` edge,
  **and the merge creates no new dependency cycle**;
- the fourteen phase-overrides in section 2 are each correct;
- no acceptance criterion on a retired card is left without a home.

| Reviewed at tag | Reviewer | Date | Outcome |
|---|---|---|---|
| `pre-fs-consolidation` | *(unsigned)* | — | — |
"""


def main():
    body = build()
    if body is None:
        return 1
    path = os.path.join(F.ROOT, OUT)
    if os.path.isfile(path):
        cur = F.read(OUT)
        if BEGIN not in cur or END not in cur:
            print('build_consolidation_map: %s exists but has no marker block' % OUT)
            return 1
        new = cur.split(BEGIN)[0] + body + cur.split(END, 1)[1]
    else:
        new = SCAFFOLD.replace('{GENERATED}', body)

    if '--check' in sys.argv:
        if F.read(OUT) != new:
            print('build_consolidation_map: %s is STALE - re-run the tool' % OUT)
            return 1
        print('build_consolidation_map: %s is current' % OUT)
        return 0

    tmp = path + '.tmp'
    with open(tmp, 'w', encoding='utf-8', newline='') as fh:
        fh.write(new)
    os.replace(tmp, path)
    print('build_consolidation_map: wrote %s' % OUT)
    print('  %d task files -> %d categories, %d retained fileless ids, 0 unassigned'
          % (len(F.load_tasks()), len(CATEGORIES), len(FILELESS)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
