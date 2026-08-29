#!/usr/bin/env python3
"""Rewrite citations of task plan files after the id-only rename.

Stage 1 shortened the long task-plan filenames to id-only and renamed the folder
that held them. Two things had to follow across the whole repo:

  1. the folder segment  <old plans folder>/ -> tasks/
  2. the filename        FW-138-Some-Words.md -> FW-138.md

NOTE: this script excludes itself from the scan. On its first run it did not, and
it rewrote the very examples in this docstring - harmless but confusing.

Both are done as whole-token rewrites, never as a bare `FW-138` substitution - a
bare id replace would corrupt the output-coil alpha `FW-00421-C01`, which is domain
data, not a story id. Here we only ever touch text that ends in `.md`, so the alpha
form cannot match; the guard below asserts that.
"""
import os
import re
import sys

SCAN_EXT = {'.md', '.sql', '.html', '.js', '.py', '.json', '.code-workspace'}
SKIP_DIRS = {'.git', '__pycache__', 'node_modules'}

# FW-138-Some-Words.md -> FW-138.md   (also the FW-N## series)
RE_TASKFILE = re.compile(r'\bFW-(N?\d+)-[A-Za-z0-9][A-Za-z0-9-]*\.md\b')
RE_FOLDER = re.compile(r'\bTaskBreakdownPlans/')
# The thing we must never damage: 5-digit coil alphas such as FW-00421-C01.
RE_COIL_ALPHA = re.compile(r'\bFW-\d{5}\b')


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        if os.path.isdir(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


ROOT = repo_root()


def walk():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if os.path.splitext(fn)[1].lower() not in SCAN_EXT:
                continue
            full = os.path.join(dirpath, fn)
            if os.path.abspath(full) == os.path.abspath(__file__):
                continue  # never rewrite our own examples
            yield full


def main():
    dry = '--dry-run' in sys.argv
    files = touched = subs_file = subs_dir = 0
    alpha_before = alpha_after = 0
    for p in walk():
        try:
            with open(p, encoding='utf-8') as fh:
                text = fh.read()
        except (OSError, UnicodeDecodeError):
            continue
        files += 1
        alpha_before += len(RE_COIL_ALPHA.findall(text))
        new, n1 = RE_TASKFILE.subn(lambda m: 'FW-%s.md' % m.group(1), text)
        new, n2 = RE_FOLDER.subn('tasks/', new)
        alpha_after += len(RE_COIL_ALPHA.findall(new))
        if n1 or n2:
            touched += 1
            subs_file += n1
            subs_dir += n2
            if not dry:
                tmp = p + '.tmp'
                with open(tmp, 'w', encoding='utf-8', newline='') as fh:
                    fh.write(new)
                os.replace(tmp, p)

    print('scanned %d files, rewrote %d' % (files, touched))
    print('   filename citations  FW-###-Words.md -> FW-###.md : %d' % subs_file)
    print('   folder citations    plans folder -> tasks/ : %d' % subs_dir)
    print('   coil-alpha guard    FW-##### before=%d after=%d' % (alpha_before, alpha_after))
    if alpha_before != alpha_after:
        print('ABORT: coil alphas were altered - this is domain data, not story ids')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
