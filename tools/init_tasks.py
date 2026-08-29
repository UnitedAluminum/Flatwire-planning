#!/usr/bin/env python3
"""Create one task file per backlog story, with machine-readable front-matter.

Reads the 163 story cards in Development/TaskBreakdown.md section 7 and, for each:

  * if a plan file already exists in <stream>/tasks/FW-###.md, prepend front-matter
    to it and leave the body completely alone;
  * otherwise write a stub carrying the card, so every story has a home.

The card already carries Hours, Priority, Sprint, Phase, Stream, Dependencies and
Blockers - those are lifted verbatim, not re-derived. The two fields it has never
carried, `status` and `owner`, are what this whole exercise exists to add.

Status is inferred from the existing plan's prose `**Status:**` line and is marked
`status_confirmed: false` when inferred, because that prose is genuinely ambiguous
("Tables BUILT" + a blocking gap in the same sentence). The original wording is kept
verbatim in `status_note` so a human can confirm or correct without losing anything.

    python tools/init_tasks.py --dry-run
    python tools/init_tasks.py
"""
import os
import re
import sys
from collections import OrderedDict

PLAN = 'MVP-1/ProjectPlan'
BACKLOG = PLAN + '/Development/TaskBreakdown.md'

# stream -> folder holding that stream's task files
STREAM_DIR = {
    'FE': PLAN + '/Frontend/tasks',
    'BE': PLAN + '/Backend/tasks',
    'RT': PLAN + '/Backend/tasks',      # real-time lives with the backend, as today
    'DB': PLAN + '/Database/tasks',
    'QA': PLAN + '/Testing/tasks',
    'BA': PLAN + '/Development/tasks',  # the only folder that is not a build stream
}

RE_CARD = re.compile(r'^######\s+(?:~~)?\*{0,2}`?(FW-N?\d+)`?\*{0,2}(?:~~)?\s*(?:·|-)\s*(.+?)\s*$', re.M)
RE_PHASE_HEAD = re.compile(r'^#####\s+.*?Phase\s+([0-9]+[A-Ca-c]?)\b', re.M)
RE_HOURS = re.compile(r'(\d+(?:,\d+)?)\s*h\s*([A-Z]{2})')
RE_FIELD = {
    'priority': re.compile(r'\*\*Priority:\*\*\s*\*{0,2}([A-Za-z]+)'),
    'sprint': re.compile(r'\*\*Sprint:\*\*\s*\*{0,2}([A-Za-z0-9]+)'),
    'phase': re.compile(r'\*\*Phase:\*\*\s*\*{0,2}([0-9]+[A-Ca-c]?)'),
    'stream': re.compile(r'\*\*Stream:\*\*\s*\*{0,2}([A-Z]{2}(?:\s*\+\s*[A-Z]{2})*)'),
}
RE_DEPS = re.compile(r'^\*\*Dependencies:\*\*\s*(.+?)$', re.M)
RE_BLOCK = re.compile(r'^\*\*Blockers:\*\*\s*(.+?)$', re.M)
RE_ID = re.compile(r'\b(FW-N?\d+)\b')
RE_REG = re.compile(r'\b((?:G|OI-|Q|PLC-Q|OQ-)\d+)\b')
RE_STATUS_LINE = re.compile(r'^\*\*Status:\*\*\s*(.+?)$', re.M)
RE_FRONT = re.compile(r'^---\r?\n.*?\r?\n---\r?\n', re.S)

# Ids the backlog itself marks as out of MVP-1 scope, plus the two cancelled by D-32.
MVP2_IDS = {'FW-010', 'FW-011', 'FW-012', 'FW-013', 'FW-068', 'FW-069', 'FW-N07', 'FW-N09'}
CANCELLED_IDS = {'FW-001', 'FW-002'}


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        if os.path.isdir(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


ROOT = repo_root()


def read(rel):
    with open(os.path.join(ROOT, rel), encoding='utf-8') as fh:
        return fh.read()


def find_existing():
    """FW id -> repo-relative path of an existing plan file."""
    out = {}
    for sub in ('Frontend', 'Backend', 'Database', 'Testing', 'Development'):
        d = os.path.join(ROOT, PLAN, sub, 'tasks')
        if not os.path.isdir(d):
            continue
        for fn in os.listdir(d):
            m = re.match(r'^(FW-N?\d+)\.md$', fn)
            if m:
                out[m.group(1)] = '%s/%s/tasks/%s' % (PLAN, sub, fn)
    return out


def parse_cards(text):
    """Yield dicts, one per story card, in document order."""
    # Phase context comes from the nearest preceding '##### ... Phase N' heading.
    phase_at = [(m.start(), m.group(1)) for m in RE_PHASE_HEAD.finditer(text)]
    marks = [(m.start(), m.end(), m.group(1), m.group(2)) for m in RE_CARD.finditer(text)]
    for i, (start, end, sid, title) in enumerate(marks):
        stop = marks[i + 1][0] if i + 1 < len(marks) else len(text)
        body = text[end:stop]
        meta = body[:600]  # the metadata line sits immediately under the heading

        ctx_phase = ''
        for pos, ph in phase_at:
            if pos < start:
                ctx_phase = ph
            else:
                break

        card = {'id': sid, 'title': re.sub(r'`', '', title).strip(), 'body': body.strip()}
        for k, rx in RE_FIELD.items():
            m = rx.search(meta)
            card[k] = m.group(1).strip() if m else ''
        if not card['phase']:
            card['phase'] = ctx_phase

        hrs = RE_HOURS.findall(meta)
        card['hours'] = sum(int(h.replace(',', '')) for h, _ in hrs)
        card['hours_by_stream'] = OrderedDict((s, int(h.replace(',', ''))) for h, s in hrs)

        streams = [s.strip() for s in card['stream'].split('+') if s.strip()] if card['stream'] else []
        if not streams and hrs:
            streams = list(OrderedDict.fromkeys(s for _, s in hrs))
        card['streams'] = streams

        m = RE_DEPS.search(body)
        card['depends_on'] = [d for d in RE_ID.findall(m.group(1))] if m else []
        m = RE_BLOCK.search(body)
        card['blocked_by'] = sorted(set(RE_REG.findall(m.group(1)))) if m else []
        yield card


def infer_status(plan_text):
    """(status, confirmed, note) from an existing plan's prose Status line."""
    if plan_text is None:
        return 'not-started', True, ''
    m = RE_STATUS_LINE.search(plan_text)
    if not m:
        return 'not-started', False, ''
    note = re.sub(r'\s+', ' ', m.group(1)).strip()
    plain = note.replace('*', '')
    built = re.search(r'\b(BUILT|Built|EXECUTED|Executed)\b', plain)
    blocked = ('⛔' in plain) or re.search(r'\bBlocked\b', plain, re.I)
    unverified = re.search(r'unverified|still owed|record only|is owed', plain, re.I)
    if built and blocked:
        # e.g. "Tables BUILT. Blocked - G34 has no persistence target"
        return 'in-review', False, note
    if built and unverified:
        return 'in-review', False, note
    if built:
        return 'done', False, note
    if blocked:
        return 'blocked', False, note
    return 'not-started', False, note


def yaml_list(vals):
    return '[' + ', '.join(vals) + ']' if vals else '[]'


def front_matter(card, status, confirmed, note, existing_path):
    mvp = 2 if card['id'] in MVP2_IDS else 1
    if card['id'] in CANCELLED_IDS:
        status, confirmed = 'cancelled', True
    streams = card['streams']
    lines = [
        '---',
        'id: %s' % card['id'],
        'legacy_id:',
        'title: %s' % card['title'].replace(':', ' -'),
        'status: %s' % status,
        'status_confirmed: %s' % ('true' if confirmed else 'false'),
        'owner:',
        'jira:',
        'mvp: %d' % mvp,
        'phase: "%s"' % card['phase'],
        'stream: %s' % (streams[0] if streams else ''),
        'streams: %s' % yaml_list(streams),
        'priority: %s' % (card['priority'].lower() if card['priority'] else ''),
        'hours: %d' % card['hours'],
        'sprint: %s' % card['sprint'],
        'depends_on: %s' % yaml_list(card['depends_on']),
        'blocked_by: %s' % yaml_list(card['blocked_by']),
        'has_plan: %s' % ('true' if existing_path else 'false'),
        'started:',
        'completed:',
    ]
    if note:
        lines.insert(6, 'status_note: %s' % ('"%s"' % note.replace('"', "'")[:400]))
    lines.append('---')
    return '\n'.join(lines) + '\n'


STUB_BODY = """
# {id} - {title}

> **No implementation plan has been written for this story yet.**
> The card below is the contract from `[TB]`. Before starting, replace this notice
> with the sections in the task template: *What to build* / *Context you need* /
> *Build order* / *Decisions made here* / *Verification* / *Handoff*.

## 1. What to build

{body}
"""


def main():
    dry = '--dry-run' in sys.argv
    text = read(BACKLOG)
    existing = find_existing()
    cards = list(parse_cards(text))

    created = updated = 0
    per_status = {}
    unresolved_stream = []
    for card in cards:
        streams = card['streams']
        primary = streams[0] if streams else 'BE'
        target_dir = STREAM_DIR.get(primary)
        if target_dir is None:
            unresolved_stream.append((card['id'], card['stream']))
            target_dir = STREAM_DIR['BE']

        path_rel = existing.get(card['id'])
        plan_text = read(path_rel) if path_rel else None
        status, confirmed, note = infer_status(plan_text)
        if card['id'] in CANCELLED_IDS:
            status = 'cancelled'
        per_status[status] = per_status.get(status, 0) + 1

        fm = front_matter(card, status, confirmed, note, path_rel)

        if path_rel:
            body = RE_FRONT.sub('', plan_text, count=1)
            out, dest = fm + body, path_rel
            updated += 1
        else:
            out = fm + STUB_BODY.format(id=card['id'], title=card['title'], body=card['body'])
            dest = '%s/%s.md' % (target_dir, card['id'])
            created += 1

        if not dry:
            full = os.path.join(ROOT, dest)
            os.makedirs(os.path.dirname(full), exist_ok=True)
            tmp = full + '.tmp'
            with open(tmp, 'w', encoding='utf-8', newline='') as fh:
                fh.write(out)
            os.replace(tmp, full)

    print('cards parsed        : %d' % len(cards))
    print('   front-matter added to existing plans : %d' % updated)
    print('   stubs created for stories with none  : %d' % created)
    print('status distribution :')
    for k in sorted(per_status):
        print('   %-12s %3d' % (k, per_status[k]))
    if unresolved_stream:
        print('   !! %d cards with an unmapped stream:' % len(unresolved_stream))
        for i, s in unresolved_stream[:10]:
            print('      %s  stream=%r' % (i, s))
    if dry:
        print('(dry run - nothing written)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
