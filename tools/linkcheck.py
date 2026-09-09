#!/usr/bin/env python3
"""Inventory and verify every path reference in the planning repo.

This is the migration's test suite. Run it BEFORE moving anything to capture a
baseline, then after every move: the set of resolvable references must not shrink.

    python tools/linkcheck.py --baseline    # write tools/_linkcheck_baseline.json
    python tools/linkcheck.py               # check against baseline, exit 1 on regression
    python tools/linkcheck.py --report      # also dump unresolved detail

Reference kinds it understands, because all four exist in this repo:
  md-link    [text](relative/path.md#anchor)
  backtick   `SomeDoc.md` / `FlatWire_DDL_04_Runs.sql` - resolved by BASENAME, which is
             how this repo actually cites; a move is harmless while the basename is unique
  sqlcmd     :r FlatWire_DDL_04_Runs.sql - the DDL runner chain
  html       src=/href= in the mockups (one is a relative ../../ path)

Deliberately NOT flagged: http(s)/mailto, in-page #anchors, and backticked names with no
file extension, which would swamp the report with prose.
"""
import json
import os
import re
import sys
from collections import defaultdict

SCAN_EXT = {'.md', '.sql', '.html', '.js', '.py'}
FILE_EXT = {'.md', '.sql', '.html', '.js', '.py', '.css', '.scss', '.docx', '.xlsx',
            '.png', '.gif', '.woff2', '.xlsm', '.bas', '.json', '.code-workspace'}
SKIP_DIRS = {'.git', '__pycache__', 'node_modules', '.claude'}

RE_MDLINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')
RE_BACKTICK = re.compile(r'`([A-Za-z0-9_./\\-]+\.[A-Za-z0-9]{1,14})`')
RE_SQLCMD = re.compile(r'^\s*:r\s+(\S+)', re.M)
RE_HTMLREF = re.compile(r'(?:src|href)\s*=\s*["\']([^"\']+)["\']')

EXTERNAL = ('http://', 'https://', 'mailto:', '#', 'data:', 'tel:')


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        # .git is a directory in a normal clone and a FILE inside a git worktree.
        if os.path.exists(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('linkcheck: cannot find repo root (.git)')


ROOT = repo_root()
BASELINE = os.path.join(ROOT, 'tools', '_linkcheck_baseline.json')


def walk_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            yield os.path.join(dirpath, fn)


def build_index():
    idx = defaultdict(list)
    for p in walk_files():
        rel = os.path.relpath(p, ROOT).replace('\\', '/')
        idx[os.path.basename(p).lower()].append(rel)
    return idx


def is_external(t):
    return t.startswith(EXTERNAL)


def extract(rel, text):
    ext = os.path.splitext(rel)[1].lower()
    for m in RE_MDLINK.finditer(text):
        yield 'md-link', m.group(1)
    for m in RE_BACKTICK.finditer(text):
        yield 'backtick', m.group(1)
    if ext == '.sql':
        for m in RE_SQLCMD.finditer(text):
            yield 'sqlcmd', m.group(1)
    if ext in ('.html', '.js'):
        for m in RE_HTMLREF.finditer(text):
            yield 'html', m.group(1)


def clean(target):
    t = target.split('#')[0].split('?')[0].strip().strip('"').strip("'")
    return t.replace('\\', '/')


def looks_like_file(t):
    return bool(t) and not is_external(t) and os.path.splitext(t)[1].lower() in FILE_EXT


def resolve(target, src_rel, index):
    t = clean(target)
    if not looks_like_file(t):
        return None
    base = os.path.dirname(os.path.join(ROOT, src_rel))
    cand = os.path.normpath(os.path.join(base, t))
    if os.path.isfile(cand):
        return os.path.relpath(cand, ROOT).replace('\\', '/')
    cand = os.path.normpath(os.path.join(ROOT, t))
    if os.path.isfile(cand):
        return os.path.relpath(cand, ROOT).replace('\\', '/')
    hits = index.get(os.path.basename(t).lower(), [])
    if len(hits) == 1:
        return hits[0]
    return None


def scan():
    index = build_index()
    refs, unresolved = [], []
    for p in walk_files():
        if os.path.splitext(p)[1].lower() not in SCAN_EXT:
            continue
        rel = os.path.relpath(p, ROOT).replace('\\', '/')
        try:
            with open(p, encoding='utf-8', errors='replace') as fh:
                text = fh.read()
        except OSError:
            continue
        seen = set()
        for kind, raw in extract(rel, text):
            if (kind, raw) in seen:
                continue
            seen.add((kind, raw))
            tgt = resolve(raw, rel, index)
            if tgt:
                refs.append({'src': rel, 'kind': kind, 'raw': raw, 'target': tgt})
            elif looks_like_file(clean(raw)):
                unresolved.append({'src': rel, 'kind': kind, 'raw': raw})
    return refs, unresolved


def write_text(path, body):
    tmp = path + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as fh:
        fh.write(body)
    os.replace(tmp, path)


def key(ref):
    return '%s|%s|%s' % (ref['src'], ref['kind'], ref['raw'])


def target_key(ref):
    """Identify a reference by what it POINTS AT, not by how it is spelled.

    A re-tree deliberately rewrites the spelling of thousands of citations, so a
    raw-text comparison reports every rewritten link as lost. What must be preserved
    is the target: file X still reaches document Y. Targets are compared by basename
    because the target moves too.
    """
    return '%s|%s' % (os.path.basename(ref['src']), os.path.basename(ref['target']))


def norm(s):
    src, kind, raw = s.split('|', 2)
    return (os.path.basename(src), kind, raw)



# ---------------------------------------------------------------------------
# Filesystem paths in prose. Added 8 Sep 2026.
#
# WHY. The 29 Aug 2026 re-tree removed MVP-1/ProjectPlan/, and four runner headers went on
# telling the reader to `cd` into it for ten days. linkcheck did not see them, because a
# `cd` target is a DIRECTORY and resolve() only considers strings with a file extension --
# and a `Specification:` header path is prose, not a citation. Both are instructions a
# person follows literally, and a `cd` to a path that does not exist makes every relative
# `:r` in the runner fail. So they are checked as what they are: paths on disk.
RE_CD = re.compile('cd' + r'\s+"([^"' + chr(10) + ']+)"')
RE_SPECPATH = re.compile(r'(?:Specification|See)\s*:?\s+'
                         r'((?:MVP-\d[\/])?[A-Za-z0-9_.-]+'
                         r'(?:[\/][A-Za-z0-9_.-]+)+\.md)')


BS_ = chr(92)


def check_fs_paths():
    """Every `cd "..."` directory and `Specification:` file path must exist."""
    bad = []
    for rel in walk_files():
        if os.path.splitext(rel)[1].lower() not in ('.sql', '.md'):
            continue
        # 95-archive is history, never a requirement (CLAUDE.md), so a path that was
        # correct when it was archived is not a break. walk_files() yields ABSOLUTE
        # paths, so normalise before testing the prefix.
        relp = os.path.relpath(rel, ROOT).replace(BS_, '/')
        if relp.startswith('95-archive/'):
            continue
        try:
            with open(rel, encoding='utf-8', errors='replace') as fh:
                text = fh.read()
        except (OSError, UnicodeDecodeError):
            continue
        here = os.path.dirname(rel)
        for m in RE_CD.finditer(text):
            raw = m.group(1)
            cand = raw.replace(BS_, '/')
            if not os.path.isabs(cand):
                cand = os.path.join(here, cand)
            cand = os.path.normpath(cand)
            # Only judge paths INSIDE this repository. A `cd` into a sibling code repo
            # (Tools/FlatWireSimConsole, ../ual-angular) is a real instruction, but this
            # checkout cannot see it, and reporting it as broken would be a false alarm
            # that trains people to ignore the check.
            if not cand.replace(BS_, '/').lower().startswith(
                    os.path.normpath(ROOT).replace(BS_, '/').lower()):
                continue
            if not os.path.isdir(cand):
                bad.append((relp, 'cd', raw))
        for m in RE_SPECPATH.finditer(text):
            raw = m.group(1).replace(BS_, '/')
            # A repo-rooted path and a path relative to the citing file are both used;
            # accept either rather than force one spelling.
            if not (os.path.isfile(os.path.join(ROOT, raw))
                    or os.path.isfile(os.path.join(here, raw))):
                bad.append((relp, 'spec-path', raw))
    return bad


def main():
    args = set(sys.argv[1:])
    refs, unresolved = scan()
    by_kind = defaultdict(int)
    for r in refs:
        by_kind[r['kind']] += 1
    print('linkcheck: %d resolvable references, %d unresolved, across %d citing files'
          % (len(refs), len(unresolved), len({r['src'] for r in refs})))
    for k in sorted(by_kind):
        print('   %-9s %5d' % (k, by_kind[k]))

    fs_bad = check_fs_paths()
    if fs_bad:
        print('')
        print('BROKEN FILESYSTEM PATHS: %d (a `cd` or `Specification:` target that '
              'does not exist)' % len(fs_bad))
        for src, kind, raw in sorted(fs_bad):
            print('   %-46s %-10s %s' % (src, kind, raw))
        return 1
    print('   %-9s %5s' % ('fs-path', 'OK'))

    if '--report' in args:
        lines = ['%s\t%s\t%s' % (u['src'], u['kind'], u['raw'])
                 for u in sorted(unresolved, key=lambda x: (x['src'], x['raw']))]
        write_text(os.path.join(ROOT, 'tools', '_linkcheck_unresolved.txt'),
                   '\n'.join(lines) + '\n')
        print('   unresolved detail -> tools/_linkcheck_unresolved.txt')

    current = {key(r) for r in refs}
    current_t = {target_key(r) for r in refs}

    if '--baseline' in args:
        write_text(BASELINE, json.dumps(
            {'resolvable': sorted(current), 'targets': sorted(current_t),
             'unresolved_count': len(unresolved)},
            indent=1, sort_keys=True))
        print('   baseline written: %d references pinned' % len(current))
        return 0

    if not os.path.isfile(BASELINE):
        print('   no baseline yet - run with --baseline first')
        return 0

    with open(BASELINE, encoding='utf-8') as fh:
        data = json.load(fh)
    base = set(data['resolvable'])

    # After an intentional re-tree the spelling of a citation changes on purpose, so
    # compare what each file REACHES rather than how it spells the path.
    if '--targets' in args or 'targets' in data:
        base_t = set(data.get('targets', []))
        lost_t = base_t - current_t
        if lost_t:
            print('\nREGRESSION: %d file->document links resolved before and do not now:'
                  % len(lost_t))
            for t in sorted(lost_t)[:40]:
                print('   %s' % t.replace('|', '  ->  '))
            if len(lost_t) > 40:
                print('   ... and %d more' % (len(lost_t) - 40))
            return 1
        print('   OK - every file->document link in the baseline still resolves'
              ' (%d links, %d references)' % (len(current_t), len(refs)))
        return 0
    # The citing file's own path legitimately changes during a move, so compare on
    # (basename-of-citer, kind, raw): a moved file is not a break, a broken link is.
    lost = {norm(s) for s in base} - {norm(s) for s in current}
    if lost:
        print('\nREGRESSION: %d references resolved in the baseline and do not now:' % len(lost))
        for src, kind, raw in sorted(lost)[:40]:
            print('   %-44s %-9s %s' % (src, kind, raw))
        if len(lost) > 40:
            print('   ... and %d more' % (len(lost) - 40))
        return 1
    print('   OK - no reference lost against the baseline')
    return 0


if __name__ == '__main__':
    sys.exit(main())
