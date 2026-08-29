#!/usr/bin/env python3
"""Shared reader for task front-matter, phases and the registers.

Imported by build_status.py and check_docs.py so the board and the checker can
never disagree about what the task files say. Deliberately dependency-free: the
front-matter subset used here is `key: scalar` and `key: [a, b]`, nothing more,
so a YAML library would be a dependency bought for no benefit.
"""
import os
import re

TASK_DIRS = ['30-database/tasks', '40-backend/tasks', '50-frontend/tasks',
             '70-testing/tasks', '60-delivery/tasks']
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
    for d in TASK_DIRS:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full):
            continue
        for fn in sorted(os.listdir(full)):
            if not re.match(r'^FW-N?\d+\.md$', fn):
                continue
            rel = d + '/' + fn
            m = RE_FRONT.match(read(rel))
            if not m:
                continue
            t = parse_front(m.group(1))
            t['path'] = rel
            t['folder'] = d
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


def phase_sort_key(p):
    m = re.match(r'^(\d+)([A-Ca-c]?)$', p or '')
    if not m:
        return (999, '', p or '')
    return (int(m.group(1)), m.group(2).upper(), '')
