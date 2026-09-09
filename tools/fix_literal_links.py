"""Repair markdown links whose literal path stopped resolving after a file move.

`retree.py` repoints a citation only when it RESOLVED it before the move and one end
of it moved. Two classes fall outside that and are left behind:

  * a bare-basename citation - `[FW-158.md](FW-158.md)` between two stories that used
    to share a directory. retree skips these deliberately, because they resolve by
    basename and the basename does not change. True for linkcheck's fallback tier,
    false for a literal path once the CITER moves.
  * a citation linkcheck's extractor never saw. It missed 256 md-links whose link
    text contains brackets - the repo's own `[`[UIC]`](path)` idiom - until that was
    fixed, so retree never knew they existed.

Both are invisible to an ordinary `linkcheck` run, because resolve() falls back to a
unique-basename index. `linkcheck --literal` is what surfaces them, and this repairs
what it finds.

    python tools/fix_literal_links.py             # report only
    python tools/fix_literal_links.py --apply

    A link is repaired ONLY when its basename is unique in the repository, so the
    target is unambiguous. Anything ambiguous or unmatched is reported and left
    alone - guessing between two files with the same name is how a citation ends up
    pointing at the wrong document, which is exactly what this class of bug does.

History is never rewritten: 95-archive/ and CHANGELOG.md are skipped, the same rule
`--literal` and `retree.NO_REWRITE` apply.
"""
import os
import re
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

BS = chr(92)
SKIP_DIRS = {'.git', '__pycache__', 'node_modules', '.claude'}
NO_REWRITE = ('95-archive/', 'CHANGELOG.md')
RE_LINK = re.compile(r'[]][(]([^)]+)[)]')
RE_LINKABLE = re.compile(r'[.](?:md|sql|py|html|js|json|xlsx|css|scss|txt|cs)$', re.I)


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        if os.path.exists(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


ROOT = repo_root()


def walk():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            yield os.path.join(dirpath, fn)


def basename_index():
    """lowercased basename -> [repo-relative paths]. Ambiguity is kept, not hidden."""
    idx = defaultdict(list)
    for p in walk():
        rel = os.path.relpath(p, ROOT).replace(BS, '/')
        idx[os.path.basename(rel).lower()].append(rel)
    return idx


def main():
    apply_ = '--apply' in sys.argv
    idx = basename_index()
    fixed, ambiguous, unmatched = 0, [], []
    per_file = defaultdict(list)

    for p in walk():
        rel = os.path.relpath(p, ROOT).replace(BS, '/')
        if rel.startswith(NO_REWRITE) or rel in NO_REWRITE:
            continue
        if os.path.splitext(rel)[1].lower() != '.md':
            continue
        try:
            with open(p, encoding='utf-8', errors='replace') as fh:
                text = fh.read()
        except (OSError, UnicodeDecodeError):
            continue
        for raw in set(RE_LINK.findall(text)):
            target = raw.split('#')[0].strip()
            anchor = raw[len(target):]
            if not target or target.startswith(('http', 'mailto', 'tel')):
                continue
            if not RE_LINKABLE.search(target):
                continue
            if os.path.isfile(os.path.normpath(os.path.join(os.path.dirname(p), target))):
                continue
            hits = idx.get(os.path.basename(target).lower(), [])
            if len(hits) > 1:
                ambiguous.append((rel, target, len(hits)))
                continue
            if not hits:
                unmatched.append((rel, target))
                continue
            new = os.path.relpath(os.path.join(ROOT, hits[0]),
                                  os.path.dirname(p)).replace(BS, '/')
            if new + anchor == raw:
                continue
            per_file[rel].append((raw, new + anchor))
            fixed += 1

    print('fix_literal_links: %d link(s) repairable in %d file(s)'
          % (fixed, len(per_file)))
    print('   %d ambiguous (basename matches more than one file) - LEFT ALONE'
          % len(ambiguous))
    print('   %d unmatched (no file of that basename) - LEFT ALONE' % len(unmatched))
    for rel, t, n in sorted(ambiguous)[:10]:
        print('      ambiguous %-40s %-34s (%d matches)' % (rel[:40], t[:34], n))
    for rel, t in sorted(unmatched)[:10]:
        print('      unmatched %-40s %s' % (rel[:40], t[:44]))

    if not apply_:
        print('   dry run - pass --apply to write')
        return 0

    for rel, subs in sorted(per_file.items()):
        path = os.path.join(ROOT, rel)
        with open(path, encoding='utf-8', newline='') as fh:
            text = fh.read()
        for old, new in subs:
            # Wrapped in the link's own syntax so a short path cannot match a longer
            # one it is a suffix of - the same precaution retree.py takes.
            text = text.replace('](%s)' % old, '](%s)' % new)
        tmp = path + '.tmp'
        with open(tmp, 'w', encoding='utf-8', newline='') as fh:
            fh.write(text)
        os.replace(tmp, path)
    print('   rewrote %d file(s) (%d substitutions)' % (len(per_file), fixed))
    return 0


if __name__ == '__main__':
    sys.exit(main())
