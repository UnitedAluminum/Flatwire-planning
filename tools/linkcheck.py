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
        if os.path.isdir(os.path.join(d, '.git')):
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


def norm(s):
    src, kind, raw = s.split('|', 2)
    return (os.path.basename(src), kind, raw)


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

    if '--report' in args:
        lines = ['%s\t%s\t%s' % (u['src'], u['kind'], u['raw'])
                 for u in sorted(unresolved, key=lambda x: (x['src'], x['raw']))]
        write_text(os.path.join(ROOT, 'tools', '_linkcheck_unresolved.txt'),
                   '\n'.join(lines) + '\n')
        print('   unresolved detail -> tools/_linkcheck_unresolved.txt')

    current = {key(r) for r in refs}

    if '--baseline' in args:
        write_text(BASELINE, json.dumps(
            {'resolvable': sorted(current), 'unresolved_count': len(unresolved)},
            indent=1, sort_keys=True))
        print('   baseline written: %d references pinned' % len(current))
        return 0

    if not os.path.isfile(BASELINE):
        print('   no baseline yet - run with --baseline first')
        return 0

    with open(BASELINE, encoding='utf-8') as fh:
        base = set(json.load(fh)['resolvable'])
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
