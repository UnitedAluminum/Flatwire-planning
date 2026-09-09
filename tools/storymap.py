"""Where each story file belongs: 10-requirements/features/<category>/<STREAM>/.

THE PLACEMENT RULE LIVES HERE AND NOWHERE ELSE. `check_docs.py` rule 6 compares the
tree against `destination_stream()` rather than against a folder->stream table, so
the rule that files a story and the rule that checks it cannot drift apart.

    destination_stream(story) = first of [FE, BE, RT, DB, QA, BA] in story.streams

One line, total coverage: single- and multi-stream stories alike, no fallback list
and no exceptions. 35 of the 204 carry more than one stream.

    WARNING - 18 stories therefore sit in a folder that disagrees with their own
    `stream:` field, because precedence pulls a DB-BE story to BE. That is the rule
    working, not failing: the folder answers WHICH BUILD SURFACE LEADS this story,
    not what its `stream:` says. Gap G62 does not close - it changes character from
    an inherited accident into a stated rule.

Three inputs, all existing, all generated - nothing here is a typed table, which is
what `pathmap.py`'s DIR_MAP/FILE_MAP got wrong and why it could not express a
fan-out from one folder into many:

  * the category, from [SCM] via fwtasks.load_consolidation_map()
  * the folder NAME, from the parent's own filename via fwtasks.load_features() -
    the slug `FS-07-rod-checkin-plc-config` exists only there, not in [SCM], which
    carries ids and titles
  * the stream folder, from destination_stream()

    python tools/storymap.py            # the move list, with every guard
    python tools/storymap.py --check    # is every story already where it belongs?

`build()` and `ROOT` match `pathmap.py`'s shape so `tools/retree.py` consumes this
module unchanged - retree's only mapping dependency is `P.build()`.
"""
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fwtasks as F  # noqa: E402

BS = chr(92)

# The order a multi-stream story is filed by. Front end first, then the build
# surfaces inward, then the two non-build streams.
PRECEDENCE = ['FE', 'BE', 'RT', 'DB', 'QA', 'BA']

# Story ids are FW-### or FW-N##. An output-coil alpha is FW-#####-C## - domain data,
# never a story id - so RE_STORY_ID is anchored on both length and boundary and can
# never match one. CLAUDE.md's bulk-rewrite guard is the reason.
#
#     MEASURED 9 Sep 2026, and CLAUDE.md's figure is wrong: it says "there are 299 of
#     them". There are 142 in the full FW-#####-C## form and 340 in the bare
#     FW-##### form. Neither is 299. The guard below counts the BARE form because it
#     is the superset - it catches corruption of either shape - and what it asserts
#     is the INVARIANT, not the absolute number: the count before a write must equal
#     the count after.
RE_STORY_ID = re.compile(r'^FW-(?:[0-9]{3}|N[0-9]{2})$')
RE_COIL_ALPHA = re.compile(r'\bFW-[0-9]{5}\b')

SCAN_EXT = {'.md', '.sql', '.py', '.html', '.js', '.json', '.txt', '.code-workspace'}
SKIP = {'.git', '__pycache__', 'node_modules', '.claude'}

ROOT = F.ROOT


def destination_stream(task):
    """The one definition of which stream folder a story is filed under."""
    streams = [s for s in (task.get('streams') or []) if s]
    if not streams:
        primary = (task.get('stream') or '').strip()
        streams = [primary] if primary else []
    for candidate in PRECEDENCE:
        if candidate in streams:
            return candidate
    return streams[0] if streams else ''


def category_folders():
    """FS-## -> the parent's filename stem, which is the folder name."""
    out = {}
    for front in F.load_features():
        cid = front.get('id')
        path = front.get('path') or ''
        stem = os.path.basename(path)[:-3] if path.endswith('.md') else ''
        if cid and stem:
            out[cid] = stem
    return out


def destination(task, cmap, folders):
    """Repo-relative destination for one story, or None with a stated reason."""
    cid = cmap.get(task['id'])
    if not cid:
        return None, 'in no category in [SCM]'
    folder = folders.get(cid)
    if not folder:
        return None, 'category %s has no parent file to name its folder' % cid
    stream = destination_stream(task)
    if stream not in PRECEDENCE:
        return None, 'no usable stream (streams=%r stream=%r)' % (
            task.get('streams'), task.get('stream'))
    return '%s/%s/%s/%s' % (F.FEATURE_DIR, folder, stream,
                            os.path.basename(task['path'])), None


def plan():
    """(moves, stays, problems, disagreements) - computed, never typed."""
    tasks = F.load_tasks()
    cmap = F.load_consolidation_map()
    folders = category_folders()
    moves, stays, problems, disagree = [], [], [], []
    for t in tasks:
        if not RE_STORY_ID.match(t['id']):
            problems.append((t['id'], 'id is not a story id'))
            continue
        dst, why = destination(t, cmap, folders)
        if not dst:
            problems.append((t['id'], why))
            continue
        stream = destination_stream(t)
        if stream != (t.get('stream') or '').strip():
            disagree.append((t['id'], (t.get('stream') or ''), stream,
                             t.get('streams') or []))
        (stays if dst == t['path'] else moves).append((t['path'], dst))
    return moves, stays, problems, disagree


def build():
    """The (src, dst) list retree.py consumes. Guards run here, not only in main."""
    moves, stays, problems, _dis = plan()
    total = len(moves) + len(stays)
    if problems:
        raise SystemExit('storymap: REFUSING - %d story(ies) have no destination: %s'
                         % (len(problems), problems[:5]))
    expected = len(F.load_tasks())
    if total != expected:
        raise SystemExit('storymap: REFUSING - planned %d destinations for %d task '
                         'files' % (total, expected))
    seen = {}
    for src, dst in moves + stays:
        seen.setdefault(dst, []).append(src)
    clashes = {d: v for d, v in seen.items() if len(v) > 1}
    if clashes:
        raise SystemExit('storymap: REFUSING - %d destination collision(s): %s'
                         % (len(clashes), list(clashes.items())[:3]))
    return moves


def coil_alpha_count():
    """Bare FW-##### occurrences - domain data. Count BEFORE any write.

    340 today, of which 142 are the full FW-#####-C## coil-alpha form. The bare
    pattern is deliberate: it is the superset, so it catches corruption of either
    shape. What matters is that the count is UNCHANGED across a write, not its value.

    fix_task_links.py compares its equivalent count AFTER the writes land, so its
    'ABORT' reports damage already on disk. Call this before and after instead.
    """
    total = 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP]
        for fn in filenames:
            if os.path.splitext(fn)[1].lower() not in SCAN_EXT:
                continue
            try:
                with open(os.path.join(dirpath, fn), encoding='utf-8',
                          errors='replace') as fh:
                    total += len(RE_COIL_ALPHA.findall(fh.read()))
            except OSError:
                continue
    return total


def main():
    args = set(sys.argv[1:])
    moves, stays, problems, disagree = plan()

    if '--check' in args:
        # The durable payoff: this layout makes `streams:` edits into file moves, so
        # the drift to catch is a story left behind, or moved by hand to the wrong
        # folder. This replaces rule 6's folder logic entirely.
        print('storymap --check: %d story(ies) are not where the rule puts them'
              % len(moves))
        if problems:
            print('   %d with no destination at all:' % len(problems))
            for sid, why in problems[:10]:
                print('      %-9s %s' % (sid, why))
        for src, dst in sorted(moves)[:25]:
            print('      %-40s -> %s' % (src, dst))
        if len(moves) > 25:
            print('      ... and %d more' % (len(moves) - 25))
        return 1 if (moves or problems) else 0

    build()  # runs every guard, raises with a stated reason

    print('storymap: %d file(s) move, %d already in place' % (len(moves), len(stays)))
    bucket = {}
    for _src, dst in moves + stays:
        bucket[os.path.dirname(dst)] = bucket.get(os.path.dirname(dst), 0) + 1
    cats = sorted({d.split('/')[2] for d in bucket})
    print('   %d destination folder(s) across %d categor(ies)' % (len(bucket), len(cats)))
    print('   %d bare FW-##### occurrences on disk now (142 in the full -C## form) -'
          % coil_alpha_count())
    print('   assert the same count after the move; it is the invariant, not the number')
    print('')
    print('   %d story(ies) land in a folder that disagrees with their `stream:`.'
          % len(disagree))
    print('   That is the precedence rule, on the record - not a defect:')
    for sid, declared, actual, streams in sorted(disagree):
        print('      %-9s stream: %-3s -> %s/   streams: %s'
              % (sid, declared, actual, ','.join(streams)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
