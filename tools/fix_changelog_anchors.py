#!/usr/bin/env python3
"""Recompute CHANGELOG.md's table-of-contents anchors from its own headings.

CHANGELOG.md indexes its 166 sections with rows shaped

    | &nbsp;&nbsp;[Some/Path.md](#somepathmd) | 12 |

where the anchor is the GitHub slug of the heading text. Renaming a document
rewrites the visible link text and the heading, but not the slug baked into the
anchor - so the TOC silently stops jumping anywhere. This recomputes every anchor
from its link text and reports any that then match no heading in the file.
"""
import os
import re
import sys

RE_TOC = re.compile(r'(\[)([^\]]+?)(\]\(#)([a-z0-9-]*)(\))')
RE_HEAD = re.compile(r'^#{1,4}\s+(.*?)\s*$', re.M)
RE_HEADLINK = re.compile(r'^\[([^\]]+)\]\([^)]*\)$')


def slug(text):
    """GitHub heading slug: lowercase, drop all but [a-z0-9-], spaces to hyphens."""
    s = text.strip().lower()
    s = re.sub(r'[^a-z0-9 \-]', '', s)
    return re.sub(r'\s+', '-', s).strip('-')


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        # .git is a directory in a normal clone and a FILE inside a git worktree.
        if os.path.exists(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


def main():
    root = repo_root()
    path = os.path.join(root, 'CHANGELOG.md')
    dry = '--dry-run' in sys.argv
    with open(path, encoding='utf-8') as fh:
        text = fh.read()

    # Every anchor a heading in this file actually offers.
    valid = set()
    for m in RE_HEAD.finditer(text):
        head = m.group(1)
        inner = RE_HEADLINK.match(head)
        valid.add(slug(inner.group(1) if inner else head))

    fixed = [0]
    broken = []

    def repl(m):
        label, old = m.group(2), m.group(4)
        new = slug(label)
        if new != old:
            fixed[0] += 1
        if new not in valid:
            broken.append((label, new))
        return m.group(1) + label + m.group(3) + new + m.group(5)

    out = RE_TOC.sub(repl, text)

    print('CHANGELOG anchors: %d recomputed, %d headings available' % (fixed[0], len(valid)))
    if broken:
        print('   %d anchors match no heading:' % len(broken))
        for label, a in broken[:15]:
            print('      %-60s -> #%s' % (label[:60], a))
    if not dry and fixed[0]:
        tmp = path + '.tmp'
        with open(tmp, 'w', encoding='utf-8', newline='') as fh:
            fh.write(out)
        os.replace(tmp, path)
        print('   written')
    return 0


if __name__ == '__main__':
    sys.exit(main())
