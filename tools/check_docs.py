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
import build_consolidation_map as CMAP  # noqa: E402

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
    feats = F.load_features()
    cmap = F.load_consolidation_map()

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
        # README: "`blocked` must always name a register id." Nothing enforced it.
        # Rule 3 fires only when a cited blocker is unknown or already closed, never
        # when there is none - so a blocked story with an empty blocked_by was
        # invisible, and the "stopping work right now" roll-up could not show it.
        if st == 'blocked' and not t.get('blocked_by'):
            rep.warn('1-blocked-no-id',
                     '%s is `blocked` and names no register id (README requires one)'
                     % t['id'])
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

    # --- 4. backlog parity, on whichever side the backlog is keyed ---------------
    #
    # The backlog is being re-keyed from 204 FW cards to 20 FS cards. Those two
    # changes cannot land in one commit, so this rule follows the backlog rather
    # than assuming FW: while FW cards exist it checks them against the task files
    # exactly as before; once they are gone it checks the FS cards against the
    # parent files instead, and the task files are covered by rule 8's map parity.
    # Without this, the card rewrite and the file deletion would be forced into a
    # single atomic change and neither could be reviewed on its own.
    backlog = F.read(F.BACKLOG)
    carded = set(re.findall(r'^######\s+(?:~~)?\*{0,2}`?(FW-N?\d+)`?', backlog, re.M))
    fs_carded = set(re.findall(r'^######\s+(?:~~)?\*{0,2}`?(FS-\d+)`?', backlog, re.M))
    if carded and by_id:
        # both sides live: the original invariant
        for sid in sorted(carded - set(by_id)):
            rep.error('4-parity', '%s has a backlog card but no task file' % sid)
        for sid in sorted(set(by_id) - carded):
            rep.error('4-parity', '%s has a task file but no backlog card' % sid)
        if fs_carded:
            rep.warn('4-parity-mixed',
                     'the backlog carries both FW cards (%d) and FS cards (%d) - '
                     'expected only during the re-key' % (len(carded), len(fs_carded)))
    elif carded:
        # The task files are retired and the cards remain as the costing ledger.
        # Their counterpart is now the consolidation map, which is the durable
        # record of every retired id. Checking them against task files here would
        # report all 204 as orphaned.
        for sid in sorted(carded - set(cmap)):
            rep.error('4-parity', '%s has a backlog card and no row in the '
                                  'consolidation map' % sid)
        for sid in sorted(set(cmap) - carded):
            if sid in {r[0] for r in CMAP.FILELESS}:
                continue          # fileless ids never had a card
            rep.error('4-parity', '%s is in the map and has no backlog card' % sid)
    else:
        fs_ids_p = {f.get('id') for f in feats}
        for sid in sorted(fs_carded - fs_ids_p):
            rep.error('4-parity', '%s has a backlog card but no parent file' % sid)
        for sid in sorted(fs_ids_p - fs_carded):
            rep.error('4-parity', '%s has a parent file but no backlog card' % sid)


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

    # --- 7. an FS parent's phases resolve, and it carries no task-only field ---
    for f in feats:
        ph = f.get('phases') or []
        if isinstance(ph, str):
            ph = [ph]
        for x in ph:
            if str(x).upper() not in phases:
                rep.error('7-fs-phase', '%s claims phase %r, which has no phase file'
                          % (f.get('id'), x))
        bad = [k for k in ('status', 'phase', 'stream', 'streams', 'hours', 'depends_on')
               if f.get(k)]
        if bad:
            rep.error('7-fs-field',
                      '%s carries %s, which a parent must not have - status is '
                      'generated, hours would be a fifth published figure, and a '
                      'category depends_on would be cyclic' % (f.get('id'), bad))

    # --- 8. the map and the parents agree, both directions ---------------------
    fs_ids = {f.get('id') for f in feats}
    mapped = set(cmap.values())
    for cid in sorted(mapped - fs_ids):
        rep.error('8-map', 'the map assigns stories to %s, which has no parent file'
                  % cid)
    # A parent with no stories is legitimate ONLY where the map's own 2.1 summary
    # declares an expected count of 0 - FS-05 (the pass-schedule consumer contract)
    # and FS-20 (the unhosted requirements). This was a blanket warning reading
    # "by design for a contract category", which made a mistyped or orphaned parent
    # indistinguishable from those two and left it as a warning nobody had to act on.
    try:
        declared_empty = {c for c, n in CMAP.read_expected_counts() if n == 0}
    except Exception:
        declared_empty = set()
    for cid in sorted(fs_ids - mapped):
        if cid in declared_empty:
            rep.warn('8-map-empty', '%s has a parent file and no story maps to it - '
                     'declared 0 in the map summary, so this is by design' % cid)
        else:
            rep.error('8-map-orphan',
                      '%s has a parent file, no story maps to it, and the map summary '
                      'does not declare it empty - it is orphaned or mistyped. Only %s '
                      'are declared 0' % (cid, ', '.join(sorted(declared_empty)) or 'none'))
    unmapped = sorted(set(by_id) - set(cmap))
    if unmapped:
        rep.error('8-map', '%d task file(s) are in no map row: %s'
                  % (len(unmapped), unmapped[:8]))

    # --- 9. a card's Blockers line still agrees with the owning story ----------
    #
    # Card-vs-story blocker drift was never checked. It surfaced only indirectly,
    # through the task-scoped rules, and when the FS-## consolidation briefly
    # retired the task files those rules lost their input and the drift went
    # INVISIBLE rather than getting fixed - which is what this rule was written
    # for. It is kept now the stories are back, because it checks something no
    # other rule does: that the costing card and the story agree on what is
    # blocking the work.
    #
    # The STORY is authoritative - its `blocked_by:` front-matter while the task
    # files exist, and the activity row in its parent if they are ever retired
    # again. A card's Blockers line is prose nobody regenerates. Ids are filtered
    # to real register entries, because the prose carries tokens like `L1`, `M2`
    # and `K007` that a bare [A-Z]\d+ pattern reads as blocker ids.
    ids_re = re.compile(r'(?:PLC-Q|OQ-|OI-|FR-|[A-Z])\d+')
    if tasks:
        activity = {t['id']: t for t in tasks}
        authority = 'the story front-matter'
    else:
        activity = {}
        for f in F.load_features():
            for r in F.parse_activity_block(F.read(f['path'])):
                activity[r['ref']] = r
        authority = 'the activity row in its parent'
    backlog = F.read(F.BACKLOG)
    for m in re.finditer(r'^###### (FW-N?\d+)\s.*?(?=^###### |\Z)', backlog, re.S | re.M):
        cid, body = m.group(1), m.group(0)
        line = re.search(r'^\*\*Blockers:\*\*(.*)$', body, re.M)
        row = activity.get(cid)
        if not line or not row:
            continue
        on_card = {x for x in ids_re.findall(line.group(1)) if x in reg}
        on_row = set(row['blocked_by'])
        if on_card == on_row:
            continue
        gone = sorted(on_card - on_row)
        missing = sorted(on_row - on_card)
        bits = []
        if missing:
            bits.append('the card is missing %s' % ', '.join(missing))
        if gone:
            bits.append('the card still lists %s' % ', '.join(gone))
        rep.warn('9-card-blocker-drift',
                 '%s: %s - %s is authoritative' % (cid, '; '.join(bits), authority))

    return tasks, phases, reg


def main():
    strict = '--strict' in sys.argv
    rep = Report()
    tasks, phases, reg = check(rep)

    print('check_docs: %d tasks, %d phases, %d register items, %d parents'
          % (len(tasks), len(phases), len(reg), len(F.load_features())))

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
