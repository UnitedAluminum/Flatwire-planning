#!/usr/bin/env python3
"""Fail the build when the task files and the documents they point at disagree.

Modelled on the repo's existing verify_schema_counts.py: a fact that is not measured
drifts, so every relationship the board depends on is asserted here.

    python tools/check_docs.py            # developer run - errors fail, warnings inform
    python tools/check_docs.py --strict   # CI / nightly - warnings fail too

The split matters. Rule 3 (a task still claiming a blocker that has since closed) is a
WARNING on a developer's commit and an ERROR under --strict: closing G2 must not break
the build for whoever happens to own FW-157. The signal is loud on STATUS.md either way.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fwtasks as F  # noqa: E402

# Which streams may own a task file in each folder. RT appears in both build folders
# on purpose: the real-time stream spans the hub and its Angular client, and three
# RT-labelled stories (FW-135/136/137) have always lived with the frontend.
FOLDER_STREAM = {
    '50-frontend': {'FE', 'RT'},
    '40-backend': {'BE', 'RT'},
    '30-database': {'DB'},
    '70-testing': {'QA'},
    '60-delivery': {'BA'},
}

# Register ids cited as blockers that resolve to nothing. All 21 use the retired `OQ-`
# prefix; the registers were renumbered to `Q##` in Aug 2026 and this file was missed.
# They are NOT mapped here by guesswork - the old->new map is in CHANGELOG.md and the
# retarget was done by subject, so `OQ-22` is not necessarily `Q22`. Tracked as G61;
# delete an entry from this list as it is resolved, and the checker will hold the line.
STALE_BLOCKER_IDS = {
    'OQ-2', 'OQ-3', 'OQ-4', 'OQ-5', 'OQ-6', 'OQ-10', 'OQ-12', 'OQ-13', 'OQ-14',
    'OQ-15', 'OQ-17', 'OQ-18', 'OQ-22', 'OQ-23', 'OQ-24', 'OQ-25', 'OQ-62',
    'OQ-67', 'OQ-73', 'OQ-76', 'OQ-79',
}

# Dependency cycles that are recorded rather than silently broken. Cutting an edge is a
# delivery decision, not a tooling one. Tracked as G63; delete the entry once the edge is
# removed and the checker goes back to treating any cycle as fatal.
KNOWN_CYCLES = {frozenset(('FW-071', 'FW-072'))}

# Stories whose card names one stream while their plan has always lived in another
# folder. Inherited disagreement, not something this migration introduced or should
# silently pick a winner for. Tracked as G62.
FOLDER_STREAM_EXCEPTIONS = {
    'FW-081', 'FW-202', 'FW-219', 'FW-220', 'FW-223', 'FW-225', 'FW-229',
    'FW-230', 'FW-231', 'FW-243', 'FW-249',
}


class Report(object):
    def __init__(self):
        self.errors = []
        self.warnings = []

    def error(self, rule, msg):
        self.errors.append((rule, msg))

    def warn(self, rule, msg):
        self.warnings.append((rule, msg))


def check(rep):
    tasks = F.load_tasks()
    phases = F.load_phases()
    reg = F.load_registers()
    by_id = {t['id']: t for t in tasks}

    def known(rid):
        return rid in reg or F.canon(rid) in reg

    def info(rid):
        return reg.get(rid) or reg.get(F.canon(rid))

    # --- 1. status enum, and an owner once work has started ---------------------
    for t in tasks:
        st = t.get('status', '')
        if st not in F.STATUSES:
            rep.error('1-status', '%s has status %r, not one of %s'
                      % (t['id'], st, '|'.join(F.STATUSES)))
        if st in ('in-progress', 'blocked', 'in-review') and not t.get('owner'):
            rep.warn('1-owner', '%s is %s but has no owner' % (t['id'], st))
        if t.get('status_confirmed') == 'false':
            rep.warn('1-inferred', '%s status %r was inferred from prose and is unconfirmed'
                     % (t['id'], st))

    # --- 2. dependencies resolve, and do not cycle ------------------------------
    for t in tasks:
        for d in t.get('depends_on', []):
            if d not in by_id:
                rep.warn('2-dep', '%s depends on %s, which has no task file'
                         ' (upstream or withdrawn id)' % (t['id'], d))
    colour = {}

    def visit(tid, trail):
        if colour.get(tid) == 'done':
            return
        if colour.get(tid) == 'open':
            cyc = trail[trail.index(tid):] if tid in trail else [tid]
            path = ' -> '.join(cyc + [tid])
            if frozenset(cyc) in KNOWN_CYCLES:
                rep.warn('2-cycle-known', 'dependency cycle %s - recorded as G63' % path)
            else:
                rep.error('2-cycle', 'dependency cycle: %s' % path)
            return
        colour[tid] = 'open'
        for d in by_id.get(tid, {}).get('depends_on', []):
            if d in by_id:
                visit(d, trail + [tid])
        colour[tid] = 'done'

    for t in tasks:
        visit(t['id'], [])

    # --- 3. blockers exist, and are still open ----------------------------------
    for t in tasks:
        for b in t.get('blocked_by', []):
            if not known(b):
                if b in STALE_BLOCKER_IDS:
                    rep.warn('3-blocker-stale-prefix',
                             '%s cites %s - retired OQ- prefix, unresolved (G61)' % (t['id'], b))
                else:
                    rep.error('3-blocker-unknown',
                              '%s is blocked by %s, which is in no register' % (t['id'], b))
            elif not info(b)['open'] and t.get('status') == 'blocked':
                rep.warn('3-blocker-closed',
                         '%s is still `blocked` but %s is closed - update the task'
                         % (t['id'], b))

    # --- 4. backlog <-> task parity ---------------------------------------------
    backlog = F.read(F.BACKLOG)
    carded = set(re.findall(r'^######\s+(?:~~)?\*{0,2}`?(FW-N?\d+)`?', backlog, re.M))
    for sid in sorted(carded - set(by_id)):
        rep.error('4-parity', '%s has a backlog card but no task file' % sid)
    for sid in sorted(set(by_id) - carded):
        rep.error('4-parity', '%s has a task file but no backlog card' % sid)

    # --- 5. every task maps to a real phase -------------------------------------
    for t in tasks:
        ph = str(t.get('phase', '')).upper()
        if not ph:
            rep.error('5-phase', '%s names no phase' % t['id'])
        elif ph not in phases:
            rep.error('5-phase', '%s names phase %r, which has no phase file'
                      % (t['id'], ph))

    # --- 6. the folder a task sits in matches its stream ------------------------
    for t in tasks:
        sub = t['folder'].split('/')[-2]
        allowed = FOLDER_STREAM.get(sub, set())
        primary = (t.get('stream') or '').strip()
        if primary and allowed and primary not in allowed:
            # A stub this migration placed must be right; an inherited plan's
            # disagreement with its card is pre-existing and needs a human.
            if t['id'] in FOLDER_STREAM_EXCEPTIONS or t.get('has_plan') == 'true':
                rep.warn('6-folder-inherited',
                         '%s card says stream %s, plan lives in %s/ (G62)'
                         % (t['id'], primary, sub))
            else:
                rep.error('6-folder', '%s is stream %s but sits in %s/ (expects %s)'
                          % (t['id'], primary, sub, '|'.join(sorted(allowed))))

    return tasks, phases, reg


def main():
    strict = '--strict' in sys.argv
    rep = Report()
    tasks, phases, reg = check(rep)

    print('check_docs: %d tasks, %d phases, %d register items'
          % (len(tasks), len(phases), len(reg)))

    def dump(label, items):
        if not items:
            return
        print('\n%s (%d):' % (label, len(items)))
        seen = {}
        for rule, msg in items:
            seen.setdefault(rule, []).append(msg)
        for rule in sorted(seen):
            msgs = seen[rule]
            print('  [%s] %d' % (rule, len(msgs)))
            for m in msgs[:8]:
                print('      %s' % m)
            if len(msgs) > 8:
                print('      ... and %d more' % (len(msgs) - 8))

    dump('ERRORS', rep.errors)
    dump('WARNINGS', rep.warnings)

    if rep.errors:
        print('\nFAIL: %d error(s)' % len(rep.errors))
        return 1
    if strict and rep.warnings:
        print('\nFAIL (--strict): %d warning(s)' % len(rep.warnings))
        return 1
    print('\nOK%s' % (' (%d warnings)' % len(rep.warnings) if rep.warnings else ''))
    return 0


if __name__ == '__main__':
    sys.exit(main())
