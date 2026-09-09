#!/usr/bin/env python3
"""Apply the re-tree: resolve every reference, move every file, then repoint the links.

This has to be one operation. A path reference can only be resolved against the tree it
was written for, so the resolution snapshot is taken BEFORE the move and the rewrite is
computed from each citing file's NEW location afterwards.

    python tools/retree.py --map=storymap --dry-run   # resolve and report, move nothing
    python tools/retree.py --map=storymap --apply

The mapping module is chosen with --map and must expose build() -> [(src, dst)] and
ROOT. It defaults to `pathmap` for the 29 Aug 2026 re-tree it was written for.
WARNING - pathmap's DIR_MAP is now 96 % spent, and its one live rule still matches
BaseDocuments/flatwire tables.xlsx, so the default would ship an unrelated file move.
Pass --map=storymap for the story-folder layout.

What it deliberately does NOT rewrite: a bare basename citation such as `BusinessRules.md`.
Those resolve by basename, which is how most of this repo cites, and the basenames do not
change - so touching them would be churn with a chance of error and no benefit.
"""
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib      # noqa: E402
import linkcheck as L    # noqa: E402


def _mapping():
    name = 'pathmap'
    for a in sys.argv[1:]:
        if a.startswith('--map='):
            name = a.split('=', 1)[1]
    return importlib.import_module(name)


P = _mapping()
ROOT = P.ROOT
REWRITE_EXT = {'.md', '.sql', '.html', '.js', '.py', '.json', '.code-workspace'}

# History is never rewritten. A path that was correct when it was written is not a
# break - the rule linkcheck's --literal and check_fs_paths() both already apply.
#
#     This is not tidiness, it is a correctness guard, and a dry run caught it. Once
#     the sequencing boards were archived, CHANGELOG.md's reference to
#     `40-backend/tasks/Orchestration.md` no longer resolved by path - so resolve()
#     fell through to its unique-basename tier and matched
#     `50-frontend/spool-notification/Orchestration.md`, an unrelated document that
#     happens to share the basename. Rewriting would have repointed the changelog's
#     history at the wrong file, silently and in 300+ places.
NO_REWRITE = ('95-archive/', 'CHANGELOG.md')


def snapshot():
    """(citing file, kind, raw) -> resolved repo-relative target, in the CURRENT tree."""
    index = L.build_index()
    out = {}
    for p in L.walk_files():
        rel = os.path.relpath(p, ROOT).replace('\\', '/')
        if os.path.splitext(rel)[1].lower() not in REWRITE_EXT:
            continue
        try:
            with open(p, encoding='utf-8') as fh:
                text = fh.read()
        except (OSError, UnicodeDecodeError):
            continue
        for kind, raw in L.extract(rel, text):
            tgt = L.resolve(raw, rel, index)
            if tgt:
                out[(rel, kind, raw)] = tgt
    return out


def relpath(from_file, to_file):
    frm = os.path.dirname(from_file)
    r = os.path.relpath(to_file, frm if frm else '.').replace('\\', '/')
    return r if r.startswith('.') else './' + r if '/' not in r else r


def main():
    apply_ = '--apply' in sys.argv
    moves = P.build()
    move_map = dict(moves)

    print('retree: resolving references in the current tree...')
    snap = snapshot()
    print('        %d resolved references across %d files'
          % (len(snap), len({k[0] for k in snap})))

    # Group the work by citing file so each file is rewritten once.
    per_file = {}
    unchanged = 0
    for (src, kind, raw), tgt in snap.items():
        new_src = move_map.get(src, src)
        new_tgt = move_map.get(tgt, tgt)
        if src.startswith(NO_REWRITE) or src in NO_REWRITE:
            unchanged += 1
            continue
        # If NEITHER end moves, the citation's current spelling still resolves exactly
        # as it did, so there is nothing to fix and every reason not to touch it.
        #
        #     Without this, retree recomputes such a citation as relative-to-citer even
        #     when it currently resolves root-relative, and resolve()'s basename tier
        #     can have matched the WRONG file. Measured on the story-folder move: 81
        #     citations, including CLAUDE.md's cross-repo `UALUADEV/CLAUDE.md`, which
        #     resolved by basename to CLAUDE.md ITSELF and would have been rewritten to
        #     `./CLAUDE.md`. A dry run is the only thing that surfaces this.
        if src not in move_map and tgt not in move_map:
            unchanged += 1
            continue
        bare = os.path.basename(raw.split('#')[0])
        # A bare-basename citation keeps working; leave it alone.
        if raw.split('#')[0] == bare and os.path.basename(new_tgt) == bare:
            unchanged += 1
            continue
        anchor = raw.split('#', 1)[1] if '#' in raw else None
        if kind == 'sqlcmd':
            new_raw = os.path.basename(new_tgt)      # :r includes are same-folder
        else:
            new_raw = relpath(new_src, new_tgt)
        if anchor:
            new_raw += '#' + anchor
        if new_raw != raw:
            per_file.setdefault(new_src, []).append((kind, raw, new_raw))

    print('        %d citations keep working as bare basenames' % unchanged)
    print('        %d citations need repointing in %d files'
          % (sum(len(v) for v in per_file.values()), len(per_file)))

    if not apply_:
        sample = sorted(per_file.items())[:3]
        for f, subs in sample:
            print('\n  %s' % f)
            for kind, old, new in subs[:4]:
                print('     %-9s %s\n               -> %s' % (kind, old, new))
        return 0

    print('retree: moving %d files...' % len(moves))
    for src, dst in moves:
        full = os.path.join(ROOT, dst)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        subprocess.check_call(['git', 'mv', src, dst], cwd=ROOT)

    print('retree: repointing citations...')
    touched = subs_done = 0
    for new_src, subs in per_file.items():
        full = os.path.join(ROOT, new_src)
        if not os.path.isfile(full):
            continue
        with open(full, encoding='utf-8') as fh:
            text = fh.read()
        before = text
        for kind, old, new in subs:
            # Replace the reference in its syntactic context so a short path cannot
            # match a longer one it is a suffix of.
            if kind == 'md-link':
                text = text.replace('](%s)' % old, '](%s)' % new)
            elif kind == 'backtick':
                text = text.replace('`%s`' % old, '`%s`' % new)
            elif kind == 'sqlcmd':
                text = re.sub(r'(:r\s+)%s\b' % re.escape(old), r'\g<1>' + new, text)
            else:
                text = text.replace('"%s"' % old, '"%s"' % new)
                text = text.replace("'%s'" % old, "'%s'" % new)
            subs_done += 1
        if text != before:
            tmp = full + '.tmp'
            with open(tmp, 'w', encoding='utf-8', newline='') as fh:
                fh.write(text)
            os.replace(tmp, full)
            touched += 1
    print('        rewrote %d files (%d substitutions)' % (touched, subs_done))
    return 0


if __name__ == '__main__':
    sys.exit(main())
