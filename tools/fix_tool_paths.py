#!/usr/bin/env python3
"""Repoint the seven client-deliverable generators after the re-tree.

Each computed its repo root by counting directory levels from its own location:

    ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))

That is exactly the line that broke the last time these scripts moved - build_docx.py
still carries the comment recording it, when a two-level count made every path resolve
under MVP-1/MVP-1/. Counting levels encodes the tree depth in seven places. This replaces
it with marker-based discovery, which survives any future move:

    ROOT = _repo_root()   # walks up until it finds .git

It then rewrites the folder names in each explicit path join, and - the part that is easy
to miss - the LEAKS guard lists. Those regexes name the old folders literally and exist to
stop an internal path reaching a CLIENT cell. Renaming the folders without updating them
leaves the guard passing vacuously.
"""
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DELIV = os.path.join(HERE, 'deliverables')

FINDER = '''

def _repo_root():
    """Walk up to the directory holding .git.

    Deliberately NOT a level count. These scripts have moved twice and a hard-coded
    depth broke them both times; a marker survives the next move too.
    """
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        # .git is a directory in a normal clone and a FILE inside a git worktree.
        if os.path.exists(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot locate repository root (no .git found above %s)' % __file__)

'''

# old path segments -> new, as tuples of os.path.join arguments
JOIN_MAP = [
    ("'MVP-1', 'ProjectPlan', 'Business', 'Screens'", "'10-requirements', 'screens'"),
    ("'MVP-1', 'ProjectPlan', 'Business'", "'10-requirements'"),
    ("'MVP-1', 'ProjectPlan', 'Architecture'", "'20-architecture'"),
    ("'MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL'", "'30-database', 'sql'"),
    ("'MVP-1', 'ProjectPlan', 'Database', 'Schema'", "'30-database', 'schema'"),
    ("'MVP-1', 'ProjectPlan', 'Database'", "'30-database'"),
    ("'MVP-1', 'ProjectPlan', 'Backend'", "'40-backend'"),
    ("'MVP-1', 'ProjectPlan', 'Frontend'", "'50-frontend'"),
    ("'MVP-1', 'ProjectPlan', 'Development', 'Phases'", "'60-delivery', 'phases'"),
    ("'MVP-1', 'ProjectPlan', 'Development'", "'60-delivery'"),
    ("'MVP-1', 'ProjectPlan', 'Testing'", "'70-testing'"),
    ("'MVP-1', 'ProjectPlan', 'Operations'", "'80-operations'"),
    ("'MVP-1', 'ProjectPlan', 'Tools'", "'tools', 'deliverables'"),
    ("'MVP-1', 'SRS'", "'deliverables'"),
    ("'MVP-2', 'SRS'", "'deliverables'"),
    ("'Analysis'", "'90-registers'"),
    ("'LatestDocument'", "'95-archive', 'design-notes'"),
]

# The register files were renamed as they moved into 90-registers/.
FILE_RENAME = [
    ("'FlatWireOpenQuestions.md'", "'Questions.md'"),
    ("'FlatWireDecidedQuestions.md'", "'Decisions.md'"),
    ("'GapsRegister.md'", "'Gaps.md'"),
    ("'RodOrderAllocation_WorkedExamples.md'", "'RodOrderAllocation_WorkedExamples.md'"),
]

# The client-leakage guards match folder names literally. If these are not updated the
# guard still runs, still passes, and no longer guards anything.
LEAK_OLD = ('MVP-1|MVP-2|Analysis|BaseDocuments|LatestDocument|DevelopmentPlan|')
LEAK_OLD2 = ("r'RequirementDocuments|Mockups|DBChanges|ProjectPlan|ShopfloorPlan|Screens|Phases)/',")
LEAK_NEW = ('00-overview|10-requirements|20-architecture|30-database|40-backend|'
            '50-frontend|60-delivery|70-testing|80-operations|90-registers|95-archive|')
LEAK_NEW2 = ("r'deliverables|tools|screens|phases|tasks|mockups|schema|sql|scripts)/',")


def main():
    dry = '--dry-run' in sys.argv
    total = 0
    for fn in sorted(os.listdir(DELIV)):
        if not fn.endswith('.py'):
            continue
        p = os.path.join(DELIV, fn)
        s = io.open(p, encoding='utf-8').read()
        before = s
        notes = []

        # 1. marker-based root
        m = re.search(r"^(ROOT|REPO)\s*=\s*os\.path\.abspath\(os\.path\.join\(HERE(?:,\s*'\.\.')+\)\)",
                      s, re.M)
        if m:
            name = m.group(1)
            if '_repo_root' not in s:
                # insert the helper just above the assignment
                s = s[:m.start()] + FINDER.lstrip('\n') + '\n' + s[m.start():]
                m = re.search(r"^(ROOT|REPO)\s*=\s*os\.path\.abspath\(os\.path\.join\(HERE(?:,\s*'\.\.')+\)\)",
                              s, re.M)
            s = s[:m.start()] + '%s = _repo_root()' % name + s[m.end():]
            notes.append('root->marker')

        # 2. path joins
        for old, new in JOIN_MAP:
            if old in s:
                s = s.replace(old, new)
                notes.append('join')

        # 3. renamed register files
        for old, new in FILE_RENAME:
            if old != new and old in s:
                s = s.replace(old, new)
                notes.append('rename')

        # 4. the client-leakage guard
        if LEAK_OLD in s:
            s = s.replace(LEAK_OLD, LEAK_NEW)
            notes.append('LEAKS-1')
        if LEAK_OLD2 in s:
            s = s.replace(LEAK_OLD2, LEAK_NEW2)
            notes.append('LEAKS-2')

        if s != before:
            total += 1
            print('  %-38s %s' % (fn, ' '.join(sorted(set(notes)))))
            if not dry:
                tmp = p + '.tmp'
                io.open(tmp, 'w', encoding='utf-8', newline='').write(s)
                os.replace(tmp, p)
    print('%s %d file(s)' % ('would patch' if dry else 'patched', total))
    return 0


if __name__ == '__main__':
    sys.exit(main())
