#!/usr/bin/env python3
"""Stamp status glyphs into TrialOrchestration.md's sprint grids from the task files.

Section 2's T1/T2/T3 grids categorise the 66 trial stories by phase and stream, but a
story id alone does not say whether it is done, in review or not started. This writes
that in - and writes it FROM the front-matter, so the grids cannot drift the way a
hand-typed status board does. It is the same rule STATUS.md is built on: the card's
`status:` is the authority, everything else is generated from it.

Only table rows inside section 2 are touched, and only the BE/FE/RT/DB columns. Prose,
blockquotes, the `h` footer and every other section are left alone. Re-running is
idempotent: an existing glyph is replaced, never stacked.

    python tools/stamp_trial_status.py            # stamp the grids
    python tools/stamp_trial_status.py --check    # exit 1 if the grids are stale (CI)
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fwtasks as F  # noqa: E402

DOC = '40-backend/tasks/TrialOrchestration.md'
START, END = '### T1 — ', '## 3. '

# The glyphs are build_status.py's MARK, deliberately - the two pages must not develop
# separate vocabularies for the same six states.
GLYPH = {'done': '✅', 'in-review': '🔵', 'in-progress': '🟡',
         'blocked': '⛔', 'not-started': '⬜', 'cancelled': '⊘'}

RE_ID = re.compile(r'FW-(?:N\d{2}|\d{3})')
RE_LEAD = re.compile(r'^(?:%s|\s)+' % '|'.join(GLYPH.values()))
STREAMS = ('BE', 'FE', 'RT', 'DB')


def stamp(text, status_of):
    """Return (new_text, changes, unknown_ids)."""
    a = text.index(START)
    b = text.index(END)
    head, body, tail = text[:a], text[a:b], text[b:]
    out, changes, unknown = [], 0, []
    cols = []

    for line in body.split('\n'):
        if not line.startswith('|'):
            out.append(line)
            continue
        cells = line.strip().strip('|').split('|')
        first = cells[0].strip()
        if first in ('Phase', 'Group'):          # header - remember the column order
            cols = [c.strip() for c in cells]
            out.append(line)
            continue
        if first.startswith('---') or first.startswith('**h**') or not cols:
            out.append(line)
            continue

        new = []
        for i, cell in enumerate(cells):
            col = cols[i] if i < len(cols) else ''
            if col not in STREAMS or not RE_ID.search(cell):
                new.append(cell)
                continue
            parts = []
            for seg in cell.split(' · '):
                m = RE_ID.search(seg)
                if not m:
                    parts.append(seg)
                    continue
                bare = RE_LEAD.sub('', seg.strip())
                st = status_of.get(m.group(0))
                if st is None:
                    unknown.append(m.group(0))
                    parts.append(seg)
                    continue
                stamped = '%s %s' % (GLYPH[st], bare)
                if stamped != seg.strip():
                    changes += 1
                parts.append(stamped)
            new.append(' ' + ' · '.join(parts) + ' ')
        out.append('|' + '|'.join(new) + '|')

    return head + '\n'.join(out) + tail, changes, unknown


def main():
    check = '--check' in sys.argv
    root = F.repo_root()
    path = os.path.join(root, DOC)
    text = io.open(path, encoding='utf-8', newline='').read()
    status_of = {t['id']: t.get('status', 'not-started') for t in F.load_tasks()}

    new, changes, unknown = stamp(text, status_of)

    if unknown:
        print('stamp_trial_status: no task file for %s' % ', '.join(sorted(set(unknown))))
        return 1
    if check:
        if changes:
            print('stamp_trial_status: %s is STALE - %d marker(s) differ. '
                  'Run python tools/stamp_trial_status.py' % (DOC, changes))
            return 1
        print('stamp_trial_status: %s is current' % DOC)
        return 0
    if not changes:
        print('stamp_trial_status: no change - %s already current' % DOC)
        return 0

    tmp = path + '.tmp'
    with io.open(tmp, 'w', encoding='utf-8', newline='') as f:
        f.write(new)
    os.replace(tmp, path)
    print('stamp_trial_status: stamped %d marker(s) into %s' % (changes, DOC))
    return 0


if __name__ == '__main__':
    sys.exit(main())
