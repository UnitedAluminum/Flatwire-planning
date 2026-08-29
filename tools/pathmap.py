#!/usr/bin/env python3
"""The old -> new path map for the re-tree, as data, plus the mover that applies it.

Two principles, both load-bearing:

  * Subject is the folder. MVP, phase, stream and status are FIELDS, not paths - which
    is what stops the next scope change from moving files, the way Phase 9 and the three
    PassSchedule* tables moved between MVP-1/ and MVP-2/ and back.
  * Filenames that other artifacts cite by name do not change. Seven .sql files cite the
    phase filenames, the DDL runners cite each other with :r, and 22 mockups cite doc
    filenames. Those keep their names; only their folder moves.

    python tools/pathmap.py --print     # show the mapping, move nothing
    python tools/pathmap.py --apply     # git mv everything, then rewrite references
"""
import os
import re
import subprocess
import sys

PP = 'MVP-1/ProjectPlan'

# --- directory-level moves. Longest prefix wins, so subfolders can override parents. ---
DIR_MAP = [
    # requirements and business
    (PP + '/Business/Screens',          '10-requirements/screens'),
    (PP + '/Business',                  '10-requirements'),
    # architecture
    (PP + '/Architecture',              '20-architecture'),
    # database - the SQL keeps its own filenames and its :r chain
    (PP + '/Database/Schema/SQL',       '30-database/sql'),
    (PP + '/Database/Schema',           '30-database/schema'),
    (PP + '/Database/Scripts',          '30-database/scripts'),
    (PP + '/Database/tasks',            '30-database/tasks'),
    (PP + '/Database',                  '30-database'),
    # backend / frontend
    (PP + '/Backend/tasks',             '40-backend/tasks'),
    (PP + '/Backend',                   '40-backend'),
    (PP + '/Frontend/Mockups',          '50-frontend/mockups'),
    (PP + '/Frontend/tasks',            '50-frontend/tasks'),
    (PP + '/Frontend',                  '50-frontend'),
    # delivery
    (PP + '/Development/Phases',        '60-delivery/phases'),
    (PP + '/Development/tasks',         '60-delivery/tasks'),
    (PP + '/Development',               '60-delivery'),
    # testing / operations
    (PP + '/Testing/tasks',             '70-testing/tasks'),
    (PP + '/Testing',                   '70-testing'),
    (PP + '/Operations',                '80-operations'),
    # the client-deliverable renderers join the repo-level tools
    (PP + '/Tools',                     'tools/deliverables'),
    # generated client output
    ('MVP-1/SRS',                       'deliverables'),
    ('MVP-2/SRS',                       'deliverables'),
    # MVP-2 dissolves into the same subject folders; scope is the `mvp:` field
    ('MVP-2/RequirementDocuments',      '10-requirements/screens'),
    ('MVP-2/Mockups',                   '50-frontend/mockups'),
    ('MVP-2/DevelopmentPlan/ShopfloorPlan', '60-delivery/phases'),
    ('MVP-2/DevelopmentPlan',           '60-delivery'),
    ('MVP-2/ProjectPlan',               '60-delivery'),
    # audit trail - nothing here is citable as a requirement
    ('BaseDocuments',                   '95-archive/source-documents'),
]

# --- individual files that do not follow their folder ---------------------------------
FILE_MAP = {
    # the index becomes the repo-level document map
    PP + '/README.md':                       'DOCUMENTS.md',
    PP + '/Flat Wire.code-workspace':        'Flat Wire.code-workspace',
    # overview
    PP + '/Business/VisionAndScope.md':      '00-overview/VisionAndScope.md',
    PP + '/Development/Roadmap.md':          '00-overview/Roadmap.md',
    # registers - ids are unchanged, only the home moves
    'Analysis/FlatWireOpenQuestions.md':     '90-registers/Questions.md',
    'Analysis/FlatWireDecidedQuestions.md':  '90-registers/Decisions.md',
    PP + '/Development/GapsRegister.md':     '90-registers/Gaps.md',
    PP + '/Development/TaskIdMap.md':        '90-registers/TaskIdMap.md',
    PP + '/Development/REVIEW.md':           '95-archive/design-notes/REVIEW.md',
    # process narrative stays citable by step number, so it keeps its name
    'Analysis/FlatWireEndToEndProcess.md':   '10-requirements/EndToEndProcess.md',
    'Analysis/FlatWireProcessWalkthrough.md': '10-requirements/ProcessWalkthrough.md',
    # design rationale - explicitly "not citable as a requirement"
    'Analysis/FlatWirePlan.md':              '95-archive/design-notes/FlatWirePlan.md',
    'Analysis/FlatWireShopfloorDashboards.md': '95-archive/design-notes/FlatWireShopfloorDashboards.md',
    PP + '/Business/Spool.md':               '95-archive/design-notes/Spool.md',
    PP + '/Business/PartialRodReCheckin.md': '95-archive/design-notes/PartialRodReCheckin.md',
    # the master specification and its satellites
    'LatestDocument/FlatWire_MasterSpecification.md': '10-requirements/MasterSpecification.md',
    'LatestDocument/ProjectPlanPrompt.md':   'tools/prompts/ProjectPlanPrompt.md',
    'LatestDocument/RodOrderAllocation.md':  '95-archive/design-notes/RodOrderAllocation.md',
    'LatestDocument/RodOrderAllocation_DesignPlan.md': '95-archive/design-notes/RodOrderAllocation_DesignPlan.md',
    'LatestDocument/RodOrderAllocation_WorkedExamples.md': '95-archive/design-notes/RodOrderAllocation_WorkedExamples.md',
    'LatestDocument/RodOrderAllocation_WorkedExamples.html': '95-archive/design-notes/RodOrderAllocation_WorkedExamples.html',
    # propagation ledgers - live work, tracked as G64/G65, archived together
    'LatestDocument/RodOrderAllocation_SyncPlan.md': '95-archive/sync-plans/RodOrderAllocation_SyncPlan.md',
    'LatestDocument/LatestDocumentSync_2026-08-25_SyncPlan.md': '95-archive/sync-plans/LatestDocumentSync_2026-08-25_SyncPlan.md',
    'LatestDocument/WeldedCoilAlpha_2026-08-26_SyncPlan.md': '95-archive/sync-plans/WeldedCoilAlpha_2026-08-26_SyncPlan.md',
    # scope-decision records
    'MVP-1/README.md':                       '95-archive/design-notes/MVP-1-scope-note.md',
    'MVP-2/README.md':                       '95-archive/design-notes/MVP-2-scope-note.md',
}

# Files matching these keep their basename wherever they land (cited by name elsewhere).
SKIP = {'.git', '__pycache__', 'node_modules', '.claude'}


def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    while d != os.path.dirname(d):
        if os.path.isdir(os.path.join(d, '.git')):
            return d
        d = os.path.dirname(d)
    raise SystemExit('cannot find repo root')


ROOT = repo_root()


def tracked_files():
    out = subprocess.check_output(['git', 'ls-files'], cwd=ROOT)
    return [l for l in out.decode('utf-8').splitlines() if l]


def destination(rel):
    if rel in FILE_MAP:
        return FILE_MAP[rel]
    best = None
    for src, dst in DIR_MAP:
        if rel.startswith(src + '/') and (best is None or len(src) > len(best[0])):
            best = (src, dst)
    if best:
        return best[1] + rel[len(best[0]):]
    return None


def build():
    moves = []
    for rel in tracked_files():
        if rel.split('/')[0] in SKIP:
            continue
        dst = destination(rel)
        if dst and dst != rel:
            moves.append((rel, dst))
    return moves


def main():
    moves = build()
    if '--print' in sys.argv or not sys.argv[1:]:
        by_dest = {}
        for s, d in moves:
            by_dest.setdefault(d.split('/')[0], []).append((s, d))
        print('pathmap: %d files move' % len(moves))
        for top in sorted(by_dest):
            print('  %-24s %4d' % (top + '/', len(by_dest[top])))
        # a destination collision would silently lose a file
        seen = {}
        for s, d in moves:
            seen.setdefault(d, []).append(s)
        clashes = {d: v for d, v in seen.items() if len(v) > 1}
        if clashes:
            print('\n  !! %d destination collision(s):' % len(clashes))
            for d, v in sorted(clashes.items())[:20]:
                print('     %s  <-  %s' % (d, ', '.join(v)))
            return 1
        print('\n  no destination collisions')
        return 0

    if '--apply' in sys.argv:
        for src, dst in moves:
            full = os.path.join(ROOT, dst)
            os.makedirs(os.path.dirname(full), exist_ok=True)
            subprocess.check_call(['git', 'mv', src, dst], cwd=ROOT)
        print('pathmap: moved %d files' % len(moves))
        return 0
    return 0


if __name__ == '__main__':
    sys.exit(main())
