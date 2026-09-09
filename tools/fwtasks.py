#!/usr/bin/env python3
"""Shared reader for task front-matter, phases and the registers.

Imported by build_status.py and check_docs.py so the board and the checker can
never disagree about what the task files say. Deliberately dependency-free: the
front-matter subset used here is `key: scalar` and `key: [a, b]`, nothing more,
so a YAML library would be a dependency bought for no benefit.
"""
import os
import re

# Where a story file may live. Searched RECURSIVELY and covering BOTH layouts on
# purpose, so the tree can be restructured without a window in which load_tasks()
# returns nothing.
#
#     That window is the danger. This loader was five literal directories read with
#     a non-recursive os.listdir(), and a missing directory is skipped rather than
#     raised - so moving the files anywhere nested made load_tasks() return [], and
#     every consumer then took its "the task files were retired" fallback. check_docs
#     exits 0 having asserted nothing about all 204 files; build_status and
#     build_features regenerate into retired mode. The failure is SILENT GREEN.
#
# `10-requirements/features` holds the story folders <category>/<STREAM>/FW-###.md;
# the five `*/tasks` entries are the pre-9-Sep-2026 layout, kept until the move is
# committed and verified. Keep this list in step with tools/hooks/pre-commit's grep.
TASK_DIRS = ['10-requirements/features',
             '30-database/tasks', '40-backend/tasks', '50-frontend/tasks',
             '70-testing/tasks', '60-delivery/tasks']
# The consolidated parent stories. Deliberately NOT in TASK_DIRS: an FS file is
# not a task, has no status of its own, and must not reach the phase board or the
# card-parity rule as if it were one.
FEATURE_DIR = '10-requirements/features'
CONSOLIDATION_MAP = '90-registers/StoryConsolidationMap.md'
PHASE_DIR = '60-delivery/phases'
BACKLOG = '60-delivery/TaskBreakdown.md'
GAPS = '90-registers/Gaps.md'
QUESTIONS = '90-registers/Questions.md'
DECIDED = '90-registers/Decisions.md'
MASTERSPEC = '10-requirements/MasterSpecification.md'
PLCSPEC = '20-architecture/PLCTagSpecification.md'

STATUSES = ['not-started', 'in-progress', 'blocked', 'in-review', 'done', 'cancelled']
STREAMS = ['FE', 'BE', 'DB', 'RT', 'QA', 'BA']

GLYPH = {'done': 'OK', 'in-review': 'REV', 'in-progress': 'WIP',
         'blocked': 'BLOCKED', 'not-started': '-', 'cancelled': 'CANCELLED'}

RE_FRONT = re.compile(r'^---\r?\n(.*?)\r?\n---\r?\n', re.S)
RE_ROW_ID = re.compile(r'^\|\s*~?~?\*{0,2}((?:G|OI-|Q)\d+)\*{0,2}~?~?[^|]*\|(.*)$')
# The register writes an entry as:  **Q22** MIDDOT `High` MIDDOT Owner: X MIDDOT `Open` [- note]
# The separator is U+00B7 MIDDLE DOT. It is written as an escape, not literally, because a
# locale-mismatched write once turned the literal character into mojibake and this regex
# silently matched nothing at all.
RE_Q_ENTRY = re.compile(
    r'^\*\*(Q\d+)\*\*\s*\u00b7\s*`?([A-Za-z]+)`?'
    r'\s*\u00b7\s*Owner:\s*(.*?)\s*\u00b7\s*`?([A-Za-z]+)`?.*?$', re.M)


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        # .git is a directory in a normal clone and a FILE inside a git worktree.
        if os.path.exists(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


ROOT = repo_root()


def canon(rid):
    """Canonical register id: strip zero padding so Q05 and Q5, OI-02 and OI-2 unify.

    The registers and the citations disagree about padding, and treating them as
    different ids reports phantom missing blockers.
    """
    m = re.match(r'^([A-Za-z-]+?)-?0*(\d+)$', (rid or '').strip())
    if not m:
        return rid
    pre = m.group(1)
    return '%s-%s' % (pre, m.group(2)) if pre.endswith('-') or pre == 'OI' else '%s%s' % (pre, m.group(2))


def read(rel):
    p = os.path.join(ROOT, rel)
    if not os.path.isfile(p):
        return ''
    with open(p, encoding='utf-8', errors='replace') as fh:
        return fh.read()


def parse_front(block):
    out = {}
    for line in block.splitlines():
        m = re.match(r'^([a-z_]+):\s*(.*)$', line)
        if not m:
            continue
        k, v = m.group(1), m.group(2).strip()
        if v.startswith('[') and v.endswith(']'):
            inner = v[1:-1].strip()
            out[k] = [x.strip() for x in inner.split(',') if x.strip()]
        else:
            out[k] = v.strip('"')
    return out


def load_tasks():
    """All task files, as dicts with a `path` key. Sorted by numeric id."""
    tasks = []
    seen = set()
    for d in TASK_DIRS:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full):
            continue
        for dirpath, dirnames, filenames in os.walk(full):
            dirnames[:] = [x for x in dirnames if not x.startswith('.')]
            for fn in sorted(filenames):
                if not re.match(r'^FW-N?\d+\.md$', fn):
                    continue
                rel = os.path.relpath(os.path.join(dirpath, fn),
                                      ROOT).replace(chr(92), '/')
                if rel in seen:
                    continue
                m = RE_FRONT.match(read(rel))
                if not m:
                    continue
                seen.add(rel)
                t = parse_front(m.group(1))
                t['path'] = rel
                t['folder'] = os.path.dirname(rel)
                # The stream segment, stated rather than reverse-engineered. Rule 6
                # used to take folder.split('/')[-2], which silently yields the
                # CATEGORY under the nested layout and made the rule a no-op.
                t['stream_folder'] = os.path.basename(os.path.dirname(rel))
                tasks.append(t)

    def sortkey(t):
        i = t.get('id', '')
        n = re.sub(r'\D', '', i)
        return (0 if 'N' not in i else 1, int(n) if n else 0)

    return sorted(tasks, key=sortkey)


def load_phases():
    """phase key ('1A', '4') -> {'title':..., 'paths':[...]}.

    A phase can own MORE THAN ONE file. Phases 11 and 13 were carved by scope, so each
    has an MVP-1 document and an MVP-2 one; the re-tree brought both into this folder
    because MVP is a field, not a path. Keying on the first file found silently hid the
    other, so every path is kept and the caller links them all.
    """
    out = {}
    d = os.path.join(ROOT, PHASE_DIR)
    if not os.path.isdir(d):
        return out
    for fn in sorted(os.listdir(d)):
        if not fn.endswith('.md'):
            continue
        rel = PHASE_DIR + '/' + fn
        head = read(rel).split('\n', 1)[0]
        # "# PHASE 11 — ..." and "# PHASE 11 (MVP-2 part) — ..." are the same phase.
        # The scope qualifier is a field, not a separate phase, so it is parsed off.
        m = re.match(r'^#\s*PHASE\s+([0-9]+[A-Ca-c]?)\s*(?:\([^)]*\))?\s*[-—]+\s*(.*)$',
                     head.strip())
        if not m:
            continue
        key = m.group(1).upper()
        entry = out.setdefault(key, {'title': m.group(2).strip(), 'paths': []})
        entry['paths'].append(rel)
        # Prefer the MVP-1 document's title when a phase owns both.
        if 'mvp2' not in fn:
            entry['title'] = m.group(2).strip()
    for e in out.values():
        e['path'] = e['paths'][0]
    return out


def _first_cell(rest):
    cell = rest.split('|')[0]
    cell = re.sub(r'[*`~]', '', cell)
    return re.sub(r'\s+', ' ', cell).strip()


def load_registers():
    """id -> {'text':..., 'open':bool, 'owner':..., 'home':...} for G##, OI-##, Q##."""
    reg = {}

    for line in read(GAPS).splitlines():
        m = RE_ROW_ID.match(line)
        if m and m.group(1).startswith('G'):
            cells = [c.strip() for c in m.group(2).split('|')]
            status = re.sub(r'[*`]', '', cells[-2] if len(cells) >= 2 else '').strip()
            reg[m.group(1)] = {
                'text': _first_cell(m.group(2))[:120],
                'open': not re.match(r'(?i)^\s*(resolved|closed|✅)', status),
                'owner': '', 'home': GAPS, 'raw_status': status[:60]}

    for line in read(MASTERSPEC).splitlines():
        m = RE_ROW_ID.match(line)
        if m and m.group(1).startswith('OI-'):
            cells = [c.strip() for c in m.group(2).split('|')]
            text = _first_cell(m.group(2))
            struck = line.strip().startswith('| ~~')
            resolved = bool(re.search(r'(?i)\b(RESOLVED|DECIDED|CLOSED|DELIVERED)\b', text[:60]))
            reg.setdefault(m.group(1), {
                'text': text[:120],
                'open': not (struck or resolved),
                'owner': cells[-1][:40] if cells else '',
                'home': MASTERSPEC, 'raw_status': ''})

    qtext = read(QUESTIONS)
    for m in RE_Q_ENTRY.finditer(qtext):
        qid, prio, owner, state = m.groups()
        after = qtext[m.end():m.end() + 300].lstrip('\r\n')
        title = after.split('\n', 1)[0]
        reg[qid] = {'text': re.sub(r'[*`]', '', title).strip()[:120],
                    'open': state.lower().startswith('open'),
                    'owner': owner.strip()[:40], 'home': QUESTIONS,
                    'raw_status': state, 'priority': prio}
    for m in re.finditer(r'^\*\*(Q\d+)\*\*', read(DECIDED), re.M):
        reg.setdefault(m.group(1), {'text': '(decided)', 'open': False, 'owner': '',
                                    'home': DECIDED, 'raw_status': 'Decided'})

    # PLC-Q## is a register in its own right, on the client-facing tag specification.
    # Its rows wrap the id in backticks inside bold, which the generic row regex misses.
    for line in read(PLCSPEC).splitlines():
        m = re.match(r'^\|\s*\*{0,2}`?(PLC-Q\d+)`?\*{0,2}\s*\|(.*)$', line)
        if m:
            reg.setdefault(m.group(1), {
                'text': _first_cell(m.group(2))[:120], 'open': True,
                'owner': 'Controls engineer', 'home': PLCSPEC,
                'raw_status': 'Open - client sign-off sheet'})
    for rid in list(reg):
        reg.setdefault(canon(rid), reg[rid])
    return reg


def load_features():
    """The FS-## parent stories, as dicts with `path`. Sorted by id.

    Read from FEATURE_DIR, which is NOT part of TASK_DIRS - a parent is not a
    task. It carries no `status:`, no `phase:` and no `stream:`, so nothing here
    may be passed to a function expecting a task.
    """
    out = []
    d = os.path.join(ROOT, FEATURE_DIR)
    if not os.path.isdir(d):
        return out
    for fn in sorted(os.listdir(d)):
        if not re.match(r'^FS-\d+-[a-z0-9-]+\.md$', fn):
            continue
        rel = FEATURE_DIR + '/' + fn
        m = RE_FRONT.match(read(rel))
        if not m:
            continue
        f = parse_front(m.group(1))
        f['path'] = rel
        out.append(f)
    return sorted(out, key=lambda x: x.get('id', ''))


def load_consolidation_map(full=False):
    """id -> category, or id -> full row dict when `full=True`.

    The category is in the `#### FS-##` heading, not in the row. After the task
    files are retired this table is the ONLY record of each story's phase, sprint,
    MVP, streams, hours and title, which is why it carries all of them.
    """
    out = {}
    cat = None
    for line in read(CONSOLIDATION_MAP).split(chr(10)):
        h = re.match(r'^####\s+`(FS-\d+)`', line)
        if h:
            cat = h.group(1)
            continue
        if line.startswith('### '):
            cat = None
            continue
        m = re.match(r'^\|\s*`(FW-N?\d+)`\s*\|(.*)\|\s*$', line)
        if not (m and cat):
            continue
        if not full:
            out[m.group(1)] = cat
            continue
        c = [x.strip() for x in m.group(2).split('|')]
        if len(c) < 9:
            continue                      # the retired-ids table, three columns
        dash = '—'
        val = lambda x: '' if x in ('', dash) else x
        out[m.group(1)] = {
            'id': m.group(1), 'category': cat, 'title': c[0],
            'phase': val(c[1]), 'sprint': val(c[2]), 'mvp': val(c[3]) or '1',
            'streams': [y for y in c[4].split('·') if y and y != dash],
            'hours': val(c[5]), 'status_at_consolidation': val(c[6]),
            'action': val(c[7]).replace('*', ''),
        }
    return out


ACT_BEGIN = '<!-- BEGIN GENERATED: absorbed-stories -->'
ACT_END = '<!-- END GENERATED: absorbed-stories -->'


RE_ROW = re.compile(r'^\|\s*`([^`]+)`\s*\|(.*)\|\s*$')


def parse_activity_block(text):
    """Parse back an activity table this tool wrote, for use after deletion."""
    rows = []
    if ACT_BEGIN not in text or ACT_END not in text:
        return rows
    block = text.split(ACT_BEGIN, 1)[1].split(ACT_END, 1)[0]
    for line in block.split('\n'):
        m = RE_ROW.match(line.strip())
        if not m:
            continue
        cells = [c.strip() for c in m.group(2).split('|')]
        if len(cells) < 5:
            continue
        # Column order is: name | streams | status | depends_on | blocked_by.
        # An earlier version read cells[1] as the status, which is the STREAMS
        # column, so every row failed the status-enum check and this parser
        # silently returned nothing. It is the post-deletion fallback, so the
        # defect would only have surfaced once the task files were gone.
        name, streams, status_cell, deps, blk = cells[0], cells[1], cells[2], cells[3], cells[4]
        raw = re.sub(r'[*`✅🔵🟡⛔⬜⊘]', '', status_cell)
        raw = raw.replace('⚠', '').replace('*inferred*', '').strip()
        status = raw.split()[0] if raw else ''
        if status not in STATUSES:
            continue
        rows.append({
            'ref': m.group(1),
            'name': name,
            'streams': [x.strip() for x in re.split(r'[·,]', streams)
                        if x.strip() not in ('', '—')],
            'status': status,
            'depends_on': re.findall(r'FW-N?\d+|FS-\d+', deps),
            'blocked_by': re.findall(r'(?:PLC-Q|OQ-|OI-|FR-|[A-Z])\d+', blk),
            'evidence': '',
            'unconfirmed': False,
        })
    return rows



def load_activity_status():
    """id -> status, from whichever source still exists.

    While the task files are present their `status:` is the authority, exactly as
    STATUS.md has always been built. Once they are retired the parents' generated
    activity tables are the only remaining record, so they become the source.
    Callers get one dict either way and do not need to know which.
    """
    tasks = load_tasks()
    if tasks:
        return dict((t['id'], t.get('status', 'not-started')) for t in tasks)
    out = {}
    for f in load_features():
        for r in parse_activity_block(read(f['path'])):
            out[r['ref']] = r['status']
    return out


def load_units():
    """The rows the phase board is built from, whichever source still exists.

    While the task files are present this returns load_tasks() UNCHANGED, so
    STATUS.md is byte-identical - that is the safety property this function
    exists to preserve. Once they are retired it reconstitutes the same shape by
    joining the consolidation map (phase, sprint, MVP, streams, hours, title) to
    the parents' activity tables (live status, dependencies, blockers), and points
    each row's link at the owning parent instead of a deleted file.
    """
    tasks = load_tasks()
    if tasks:
        return tasks
    rows = load_consolidation_map(full=True)
    live = {}
    paths = {}
    owners = {}
    for f in load_features():
        for r in parse_activity_block(read(f['path'])):
            live[r['ref']] = r
            paths[r['ref']] = f['path']
            # Ownership moved UP a tier with the consolidation. It used to live in
            # each task file's `owner:`; with those gone the board's Owner column
            # was every row a placeholder. The parent's `owner:` is now the one
            # writable home, so an activity reports the owner of its category.
            owners[r['ref']] = f.get('owner', '')
    out = []
    for tid, m in rows.items():
        if m['action'] == 'Retain':
            continue                     # tracked, never a board row
        a = live.get(tid, {})
        # A board row must have had a task file. The fileless ids carry no phase,
        # no hours and the literal text "no card, no task file" where a status
        # would be, so two Retire-action ones leaked onto the board as rows with
        # that phrase as their status.
        status = a.get('status') or m['status_at_consolidation']
        if status not in STATUSES:
            continue
        out.append({
            'id': tid,
            'title': m['title'],
            'status': status,
            'status_confirmed': 'true',
            'phase': m['phase'],
            'mvp': m['mvp'],
            'streams': a.get('streams') or m['streams'],
            'stream': (m['streams'] or [''])[0],
            'hours': m['hours'],
            'sprint': m['sprint'],
            'owner': owners.get(tid, ''),
            'depends_on': a.get('depends_on', []),
            'blocked_by': a.get('blocked_by', []),
            'has_plan': 'false',
            'path': paths.get(tid, FEATURE_DIR + '/README.md'),
            'folder': FEATURE_DIR,
        })

    def sortkey(t):
        n = re.sub(r'\D', '', t['id'])
        return (0 if 'N' not in t['id'] else 1, int(n) if n else 0)

    return sorted(out, key=sortkey)


def phase_sort_key(p):
    m = re.match(r'^(\d+)([A-Ca-c]?)$', p or '')
    if not m:
        return (999, '', p or '')
    return (int(m.group(1)), m.group(2).upper(), '')
