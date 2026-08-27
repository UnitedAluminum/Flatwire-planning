"""
Prove that the schema documentation cannot drift away from the DDL again.

    python MVP-1/ProjectPlan/Tools/verify_schema_counts.py           # check, exit 1 on drift
    python MVP-1/ProjectPlan/Tools/verify_schema_counts.py --emit    # also print the tables

WHY THIS EXISTS
    Eight different table counts circulated in one folder simultaneously: 20, 21, 22, 24,
    25, 27, 28 and 32, against an as-built 34. [DEP 4.2]'s deployment gate asserted figures
    that would REJECT a correct deployment three separate times, and phase-01c's acceptance
    criteria asserted 25 tables and 33 FKs while five other lines in the same file said
    otherwise. Six tables were built, constrained and indexed while appearing in no design
    document and no seed script.

    None of that is a hard problem. It is an unmeasured one. So the measurement is now
    fatal, and the number in the document cannot drift away from the scripts again. Same
    shape as the coverage guard in build_coverage_matrix.py, deliberately.

WHAT IS AUTHORITATIVE
    The DDL. Always. [DBD 6.2] is the single site that PUBLISHES the counts, and this
    script proves that what it publishes is what the scripts create. If they disagree the
    document is wrong -- never regenerate the DDL from the markdown.

WHAT IT CHECKS
    C1  Object counts: tables, FKs, index statements, procedures, triggers -- counted from
        the files the runners actually include, then compared with [DBD 6.2]'s group table.
    C2  Documentation coverage: every table appears in its own script's header block, in at
        least one Schema/FlatWireSchema_*.md, in phase-01c's group table, and as an entity in
        [DBD] section 7's ER diagrams. This is the check that would have caught all six
        undocumented tables. The last two targets were added after a hand audit found both
        of them six tables behind -- phase-01c because CLAUDE.md names it one of the three
        artifacts that must stay in sync, and section 7 because Mapping.md's ASCII ERD was
        deleted on the grounds that section 7 supersedes it.
    C3  Seed coverage: every table has seed rows or an explicit "NO SEED:" marker. A
        deliberate gap is fine; a silent one is not.
    C4  Reachability and guards: every object-creating file is included by some runner
        (the teardown excepted, deliberately), and every CREATE is guarded so the runners
        stay idempotent.
    C6  Count claims in prose: any file that states a table/FK/index/procedure/trigger count
        disagreeing with the DDL. FATAL for the closed set of sites [DBD 6.2] permits to
        restate the figures (its own definition, [DEP 4.2]'s gate, phase-01c, the runner
        banners, the 06/07 script headers, MVP2-SCOPE.md), because a wrong number in one of
        those rejects a correct deployment or fails a correct story -- which has happened
        five times. ADVISORY everywhere else, because most survivors are legitimate dated
        audit trail that must NOT be swept: [DBD 6.2] states the exemption outright,
        "statements dated before 23 Aug 2026 are audit trail and keep their numbers by
        design." A claim sitting beside a history marker ("previously", "superseded",
        "until", "stale", "was") is exempt in both tiers. C1 already pins [DBD 6.2] and
        [DEP 4.2]'s numeric gate; C6 is what catches the same figure restated in a
        SENTENCE, which is how phase-01c came to publish 34/57/69 in three places while
        its own body said 33.
    C5  Seed FK ordering: a nullable FK whose parent is seeded LATER in the seed chain
        must be NULL at INSERT and populated by a later UPDATE. Three such columns exist
        and one of them was seeded with a live value when this check was written -- a
        defect no amount of counting would have found. An INSERT...SELECT cannot be
        checked positionally, so those require an explicit "C5-OK: Table.Column" comment
        in the seed file -- the same bargain C3 strikes with "NO SEED:": the check will
        not guess, and the author has to state the claim.

TWO MEASUREMENT TRAPS THIS SCRIPT AVOIDS -- DO NOT "SIMPLIFY" THEM AWAY
    * The procedure count is scoped to the runner chain. sp_IngestRodFromCoils is a
      FlatWireDB object that ships in Database/Scripts/ and is in no runner, so a checker
      that globs every .sql file reports 2 procedures where the baseline says 1. That is
      the same trap [DBD 6.2] warns about for an incremental sys.procedures count,
      reproduced statically.
    * The include list is PARSED from each runner's :r lines rather than hard-coded, so
      this script survives a renumbering and simultaneously proves the runners complete.

REQUIREMENTS
    None. Standard library only.
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))

SQL_DIR = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL')
SCHEMA_DIR = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', 'Database', 'Schema')
DBD = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', 'Database', 'DatabaseDesign.md')
PHASE1C = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', 'Development', 'Phases',
                       'phase-01c-database-foundation.md')
MAPPING = os.path.join(SCHEMA_DIR, 'FlatWireSchema_Mapping.md')
# [DEP]'s deployment gate. Added to C1 on 26 Aug 2026 after Q89's index took the count
# 69 -> 70 and left V3 asserting 69 -- the FIFTH time that gate would have rejected a
# correct deployment, and the first caused by a change made in this repository. The
# docstring above already cited three of the four earlier ones; nothing was checking it.
DEP = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', 'Operations', 'Deployment.md')

MVP1_RUNNER = 'FlatWire_DDL_RunAll.sql'
MVP2_RUNNER = 'FlatWire_DDL_RunAll_MVP2.sql'
SEED_RUNNER = 'FlatWire_SampleData_RunAll.sql'
TEARDOWN = 'FlatWire_DDL_99_Teardown.sql'

RE_TABLE = re.compile(r'CREATE\s+TABLE\s+\[dbo\]\.\[(\w+)\]', re.I)
RE_FK = re.compile(r'ADD\s+CONSTRAINT\s+\[(FK_\w+)\]', re.I)
RE_IDX = re.compile(r'^\s*CREATE\s+(?:UNIQUE\s+)?(?:NON)?CLUSTERED\s+INDEX\s+\[(\w+)\]',
                    re.I | re.M)
RE_PROC = re.compile(r'CREATE\s+(?:OR\s+ALTER\s+)?PROCEDURE\s+\[dbo\]\.\[(\w+)\]', re.I)
RE_TRIG = re.compile(r'CREATE\s+(?:OR\s+ALTER\s+)?TRIGGER\s+\[dbo\]\.\[(\w+)\]', re.I)
RE_INCLUDE = re.compile(r'^\s*:r\s+(\S+)', re.M)
# child table, constraint name, child column, parent table -- one FK per match
RE_FK_FULL = re.compile(
    r'ALTER\s+TABLE\s+\[dbo\]\.\[(\w+)\]\s*'
    r'ADD\s+CONSTRAINT\s+\[(\w+)\]\s*'
    r'FOREIGN\s+KEY\s*\(\[(\w+)\]\)\s*'
    r'REFERENCES\s+\[dbo\]\.\[(\w+)\]', re.I | re.S)

HEADER_NOISE = {'header', 'placed', 'here', 'so', 'can', 'reference', 'it', 'and', 'the'}


def read(path):
    with open(path, encoding='utf-8') as fh:
        return fh.read()


def includes(runner):
    """The ordered file list a runner actually pulls in. Parsed, never hard-coded."""
    path = os.path.join(SQL_DIR, runner)
    if not os.path.exists(path):
        sys.exit('FATAL: runner not found: %s' % os.path.relpath(path, ROOT))
    names = RE_INCLUDE.findall(read(path))
    if not names:
        sys.exit('FATAL: no :r includes found in %s' % runner)
    for n in names:
        if not os.path.exists(os.path.join(SQL_DIR, n)):
            sys.exit('FATAL: %s includes %s, which does not exist' % (runner, n))
    return names


def objects(files):
    """Count objects across a list of SQL files in SQL_DIR."""
    out = {'tables': [], 'fks': [], 'indexes': [], 'procs': [], 'triggers': []}
    per_file = {}
    for f in files:
        s = read(os.path.join(SQL_DIR, f))
        t, k = RE_TABLE.findall(s), RE_FK.findall(s)
        i, p = RE_IDX.findall(s), RE_PROC.findall(s)
        g = RE_TRIG.findall(s)
        per_file[f] = (len(t), len(k), len(i), len(p), len(g))
        out['tables'] += t
        out['fks'] += k
        out['indexes'] += i
        out['procs'] += p
        out['triggers'] += g
    return out, per_file


def dbd_group_table():
    """The per-group counts and the total published by [DBD 6.2]."""
    s = read(DBD)
    m = re.search(r'###\s*6\.2\b.*?\n(.*?)\n###', s, re.S)
    if not m:
        sys.exit('FATAL: could not locate section 6.2 in DatabaseDesign.md')
    block = m.group(1)
    groups, total = {}, None
    row = re.compile(r'^\|\s*(.*?)\s*\|\s*`?([\w.]*)`?\s*\|\s*\*\*(\d+)\*\*\s*\|', re.M)
    for mm in row.finditer(block):
        label = re.sub(r'[*`]', '', mm.group(1)).strip()
        script, count = mm.group(2), int(mm.group(3))
        if not label:
            total = count
        elif script:
            groups[script] = (label, count)
    if not groups:
        sys.exit('FATAL: no group rows parsed from [DBD 6.2] -- has the table been reformatted?')
    return groups, total


def header_tables(f):
    """The table names a script names in its own header comment block."""
    s = read(os.path.join(SQL_DIR, f))
    cut = s.find('USE [')
    head = s[:cut] if cut > 0 else s[:2000]
    m = re.search(r'--\s*Tables\s*:\s*(.*?)(?:\n--\s*(?:Dependencies|Note|=)|\n\n)', head, re.S)
    if not m:
        return None
    return set(re.findall(r'\w+', m.group(1))) - HEADER_NOISE


def split_top(text):
    """Split on commas at paren-depth 0."""
    out, depth, cur = [], 0, ''
    for ch in text:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return [x.strip() for x in out]


def seed_fk_order(seeds, fks):
    """C5. A nullable FK whose parent is seeded LATER in the chain must be NULL at
    INSERT and populated by a later UPDATE. Getting this wrong fails the deploy on
    the seed step, and it is invisible to every static check that only counts things.

    Three such columns exist -- RodStaging.WipRejectionId,
    SpoolTraceability.WeldEventId and RodOrderConsumption.RodCheckoutId -- and one
    of them was seeded with a live value when this check was written.
    """
    findings = []
    # first INSERT position per table, as (file index, offset)
    pos = {}
    text = {}
    for fi, f in enumerate(seeds):
        body = read(os.path.join(SQL_DIR, f))
        text[f] = body
        for m in re.finditer(r'INSERT\s+INTO\s+\[dbo\]\.\[(\w+)\]', body, re.I):
            pos.setdefault(m.group(1), (fi, m.start(), f))

    for child, name, col, parent in fks:
        if child == parent or child not in pos or parent not in pos:
            continue
        if pos[child][:2] >= pos[parent][:2]:
            continue                                    # parent seeded first: fine
        fi, off, f = pos[child]
        body = text[f]
        # the INSERT's column list
        cl = body.find('(', off)
        depth, end = 0, None
        for k in range(cl, min(cl + 4000, len(body))):
            if body[k] == '(':
                depth += 1
            elif body[k] == ')':
                depth -= 1
                if depth == 0:
                    end = k
                    break
        if end is None:
            continue
        cols = [c.strip().strip('[]') for c in split_top(body[cl + 1:end])]
        if col not in cols:
            continue                                    # column not seeded at all: fine
        idx = cols.index(col)
        vm = re.search(r'VALUES', body[end:end + 400], re.I)
        if not vm:
            # INSERT ... SELECT cannot be checked positionally. Require the author to
            # assert it instead, the same way C3 accepts a 'NO SEED:' marker: an
            # unverifiable case becomes a deliberate claim rather than a silent pass.
            if ('C5-OK: %s.%s' % (child, col)) in body:
                continue
            findings.append('C5: %s.%s (%s) -- parent %s is seeded later in the chain, and '
                            'this is an INSERT...SELECT that cannot be checked positionally. '
                            'Confirm the column is NULL at insert, then assert it with a '
                            'comment reading "C5-OK: %s.%s" in %s.'
                            % (child, col, name, parent, child, col, f))
            continue
        vstart = end + vm.end()
        # each row is a top-level (...) group
        depth, cur, rows_ = 0, '', []
        for ch in body[vstart:vstart + 20000]:
            if ch == '(':
                depth += 1
                if depth == 1:
                    cur = ''
                    continue
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    rows_.append(cur)
                    continue
            if depth >= 1:
                cur += ch
            if depth == 0 and ch == ';':
                break
        for r in rows_:
            vals = split_top(r)
            if idx < len(vals) and vals[idx].upper() != 'NULL':
                findings.append('C5: %s.%s is seeded %s in %s, but its parent %s is seeded '
                                'LATER in the chain -- %s will fail. Seed it NULL and apply '
                                'the value with an UPDATE once %s exists.'
                                % (child, col, vals[idx], f, parent, name, parent))
                break
    return findings


# Sites [DBD 6.2] permits to restate the figures, plus the script headers that carry them.
# A wrong number in one of these rejects a deployment or fails a story, so C6 is fatal here.
C6_FATAL = (
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'DatabaseDesign.md'),
    os.path.join('MVP-1', 'ProjectPlan', 'Operations', 'Deployment.md'),
    os.path.join('MVP-1', 'ProjectPlan', 'Development', 'Phases',
                 'phase-01c-database-foundation.md'),
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL',
                 'FlatWire_DDL_RunAll.sql'),
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL',
                 'FlatWire_DDL_RunAll_MVP2.sql'),
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL',
                 'FlatWire_DDL_06_ForeignKeys.sql'),
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL',
                 'FlatWire_DDL_07_Indexes.sql'),
    os.path.join('MVP-1', 'ProjectPlan', 'Database', 'Schema', 'SQL', 'MVP2-SCOPE.md'),
)

# Not scanned. CHANGELOG entries keep their original numbers by design; BaseDocuments/ is
# read-only business input; and this script's own docstring recites every wrong count there
# has ever been, which is the whole point of it.
C6_SKIP_DIRS = ('.git', 'node_modules', 'BaseDocuments')
C6_SKIP_FILES = ('CHANGELOG.md', 'verify_schema_counts.py')

# Propagation ledgers are records of drift found on a given date -- they QUOTE the wrong
# figures other files carried, by design, and correcting them would destroy the evidence.
C6_SKIP_SUFFIXES = ('_SyncPlan.md',)

# The exemption [DBD 6.2] actually states: "statements dated before 23 Aug 2026 are audit
# trail and keep their numbers by design." A date in the sentence IS the marker, so a year
# beside the claim exempts it -- which is why "Counted from the scripts 23 Aug 2026: ..."
# is left alone while an undated "Deployed FlatWireDB reports ..." is not.
# A DATE, not merely a four-digit number: "SQL Server 2019" is a product version and must
# not exempt the live claim sitting beside it, which is exactly what a bare \d{4} did.
_C6_MONTH = (r'(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*')
RE_C6_DATED = re.compile(r'%s\.? ?[0-9]{1,2}(?:st|nd|rd|th)?,? ?20[0-9]{2}'
                         r'|[0-9]{1,2}(?:st|nd|rd|th)? %s,? ?20[0-9]{2}'
                         r'|20[0-9]{2}-[0-9]{2}-[0-9]{2}' % (_C6_MONTH, _C6_MONTH))

# A claim sitting beside one of these is history, not an assertion.
C6_HISTORY = ('previously', 'superseded', 'stale', 'until ', 'predates', 'pre-merge',
              'no longer', 'retired', 'audit trail', 'not restated', 'was ', 'were ',
              'asserted', 'published', 'said ', 'formerly', 'corrected', 'this line',
              'this row', 'this clause', 'this section', 'would have', 'rejects',
              'never held', 'moved to', 'moved the', 'history', 'earlier', 'old ',
              'then ', 'briefly', 'wrong', 'defect', 'drift', 'withdrawn', 'struck',
              'previous', 'for reference', 'pre-', 'any "', 'used to')

# The claim must actually be ABOUT the FlatWireDB object set. Without this, a rate-card
# line such as "3 tables @ 4 h = 12 h" reads as a table-count claim.
C6_CONTEXT = ('flatwiredb', 'fk', 'foreign key', 'index', 'baseline', 'dbd', 'runall',
              'teardown', 'deploy', 'schema', 'procedure', 'trigger', 'runner', 'count',
              'seed', 'ddl')

# What a BASELINE claim looks like, as against a legitimate subset count.
#
# This distinction is the whole difficulty of the check. "their 10 foreign keys and their 6
# indexes" (the PassSchedule subset), "7 FKs in 06 and 11 index statements" (the rod-order
# pair) and "3 tables @ 4 h" (a rate-card sum) are all correct and must not be flagged. The
# defect class that has rejected a correct deployment five times is the WHOLE-SET figure,
# and it always appears in one of two shapes:
#
#   TUPLE      "34 tables . 57 FKs . 69 index statements"  -- a table count >= MIN_WHOLE
#              paired with an FK or index count nearby. Subsets are small; the schema is not.
#   TOTALISER  "all 55 FKs", "ALL 69 index statements", "complete 32-table FlatWireDB"
#              -- an explicit claim to completeness, whatever the number.
#
# Anything else is left alone. A checker that flagged every integer next to the word "table"
# produced 24 findings, 24 of them wrong, which is how a guard gets switched off.
C6_MIN_WHOLE = 15

RE_C6_TABLES = re.compile(r'(\d+)[ -]tables?\b', re.I)
RE_C6_FKS = re.compile(r'(\d+) (?:FKs|FK constraints|foreign[- ]keys?|'
                       r'foreign key constraints)', re.I)
RE_C6_IDX = re.compile(r'(\d+) index(?: statement)?e?s?\b', re.I)
RE_C6_PROCS = re.compile(r'(\d+) (?:stored )?procedures?\b', re.I)
RE_C6_TRIGS = re.compile(r'(\d+) triggers?\b', re.I)

RE_C6_TOTAL = (
    (re.compile(r'\ball (\d+) (?:FKs|FK constraints|foreign[- ]keys?)', re.I), 'fks'),
    (re.compile(r'\ball (\d+) index(?: statement)?e?s?\b', re.I), 'indexes'),
    (re.compile(r'\bcomplete (\d+)[- ]table\b', re.I), 'tables'),
    (re.compile(r'\ball (\d+) tables?\b', re.I), 'tables'),
)

C6_NEAR = 160          # how far from the table count a tuple member may sit


def count_claims(got):
    """C6. Baseline count claims in prose that disagree with the DDL.

    Returns (fatal, advisory). Fatal covers only the closed set of sites permitted to
    restate the figures; everything else is reported for triage, because sweeping a dated
    statement would destroy the history the audit-trail exemption exists to protect.
    """
    actual = {'tables': len(got['tables']), 'fks': len(got['fks']),
              'indexes': len(got['indexes']), 'procs': len(got['procs']),
              'triggers': len(got['triggers'])}
    fatal, advisory = [], []

    def emit(bucket, rel, lineno, claimed, kind, shape):
        bucket.append('C6: %s:%d claims %s %s (%s); the DDL creates %d -- restate it, or '
                      'mark it as dated audit trail'
                      % (rel, lineno, claimed, kind, shape, actual[kind]))

    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in C6_SKIP_DIRS]
        for fn in sorted(filenames):
            if not fn.endswith(('.md', '.sql')) or fn in C6_SKIP_FILES:
                continue
            if fn.endswith(C6_SKIP_SUFFIXES):
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, ROOT)
            try:
                body = read(full)
            except (OSError, UnicodeDecodeError):
                continue
            is_fatal = rel in C6_FATAL
            bucket = fatal if is_fatal else advisory

            lines = body.split('\n')
            for lineno, line in enumerate(lines, 1):
                low = line.lower()
                # Markdown wraps a sentence across lines, so the date or the "previously"
                # qualifying a claim is routinely on the line ABOVE it -- a single-line
                # window reported five such claims as live. The sentence is the
                # neighbourhood, so the window is the neighbourhood.
                i = lineno - 1
                near = ' '.join(lines[max(0, i - 2):i + 3]).lower()

                def exempt(at):
                    """Is the claim at this offset dated audit trail?

                    The window is the claim's OWN LINE, in both tiers. A neighbourhood
                    window was tried and rejected: mutation tests showed an explanatory
                    note on the next line disarming the check for a live claim in a
                    permitted site, and a date elsewhere in a table disarming it for a
                    live claim in the advisory tier. Both are the failure this check
                    exists to prevent, so the marker has to sit with the claim it
                    qualifies -- which is also the only place a reader would look for it.
                    """
                    w = low[max(0, at - 300):at + 300]
                    return (any(h in w for h in C6_HISTORY)
                            or RE_C6_DATED.search(w) is not None)

                def in_context(at):
                    w = low[max(0, at - 260):at + 260] + ' ' + near
                    return any(c in w for c in C6_CONTEXT)

                # ---- shape 1: the baseline tuple, anchored on a whole-schema table count
                for mt in RE_C6_TABLES.finditer(line):
                    if int(mt.group(1)) < C6_MIN_WHOLE:
                        continue                       # a subset, not the schema
                    if line[mt.end():mt.end() + 4].lstrip().startswith('@'):
                        continue                       # rate-card sum
                    lo, hi = max(0, mt.start() - C6_NEAR), mt.end() + C6_NEAR
                    # NOT named `near` -- that is the multi-line exemption neighbourhood
                    # the closures above read, and rebinding it here shadowed them, so
                    # every claim looked undated no matter what the line above said.
                    tuple_span = line[lo:hi]
                    partners = []
                    for rx, kind in ((RE_C6_FKS, 'fks'), (RE_C6_IDX, 'indexes'),
                                     (RE_C6_PROCS, 'procs'), (RE_C6_TRIGS, 'triggers')):
                        mm = rx.search(tuple_span)
                        if mm:
                            partners.append((kind, int(mm.group(1)), lo + mm.start()))
                    if not partners and not is_fatal:
                        # A bare table count in ordinary prose is too ambiguous to judge --
                        # it is as likely to be a subset, a rate-card sum or a sentence
                        # about something else. In a PERMITTED site it is not ambiguous at
                        # all: those files exist to state the baseline, so "Result: 33
                        # tables" in the runner banner is a baseline claim with or without
                        # a partner figure beside it. A mutation test walked 33 -> 34
                        # straight past the tuple rule for exactly this reason.
                        continue
                    if exempt(mt.start()) or not in_context(mt.start()):
                        continue
                    shape = 'baseline tuple' if partners else 'baseline, permitted site'
                    if int(mt.group(1)) != actual['tables']:
                        emit(bucket, rel, lineno, mt.group(1), 'tables', shape)
                    for kind, val, at in partners:
                        if val != actual[kind]:
                            emit(bucket, rel, lineno, val, kind, 'baseline tuple')

                # ---- shape 2: an explicit claim to completeness
                for rx, kind in RE_C6_TOTAL:
                    for m in rx.finditer(line):
                        if int(m.group(1)) == actual[kind]:
                            continue
                        if exempt(m.start()) or not in_context(m.start()):
                            continue
                        emit(bucket, rel, lineno, m.group(1), kind, 'stated as complete')
    return fatal, advisory


def main():
    emit = '--emit' in sys.argv
    fail = []

    mvp1, mvp2, seeds = includes(MVP1_RUNNER), includes(MVP2_RUNNER), includes(SEED_RUNNER)
    got, per_file = objects(mvp1)
    tables = got['tables']

    # ---- C1
    groups, total = dbd_group_table()
    print('== C1  object counts (MVP-1 runner chain: %d files) ==' % len(mvp1))
    print('   tables %d | FKs %d | index statements %d | procedures %d | triggers %d'
          % (len(tables), len(got['fks']), len(got['indexes']),
             len(got['procs']), len(got['triggers'])))

    if total is None:
        fail.append('C1: [DBD 6.2] publishes no total row')
    elif total != len(tables):
        fail.append('C1: [DBD 6.2] publishes %d tables; the DDL creates %d'
                    % (total, len(tables)))

    for f in mvp1:
        key = f.replace('FlatWire_DDL_', '').replace('.sql', '')
        if key in groups:
            label, want = groups[key]
            have = per_file[f][0]
            if want != have:
                fail.append('C1: [DBD 6.2] row "%s" says %d tables; %s creates %d'
                            % (label, want, f, have))

    # [DEP]'s V1/V2/V3 deploy gate must agree with the DDL. Both the SQL comment
    # ("-- Expected: N") and the checklist line ("- [ ] V1 returns **N**") are parsed,
    # because they have disagreed with each other before now.
    dep = read(DEP)
    for tag, want, what in (('V1', len(tables), 'tables'),
                            ('V2', len(got['fks']), 'FKs'),
                            ('V3', len(got['indexes']), 'index statements')):
        box = re.search(r'-\s*\[\s*\]\s*%s returns\s*\*\*(\d+)\*\*' % tag, dep)
        if not box:
            fail.append('C1: [DEP] has no "%s returns **N**" checklist line' % tag)
        elif int(box.group(1)) != want:
            fail.append('C1: [DEP] %s checklist expects %s %s; the DDL creates %d -- this gate '
                        'REJECTS a correct deployment' % (tag, box.group(1), what, want))
        blk = re.search(r'--\s*%s\..*?--\s*Expected:\s*(\d+)' % tag, dep, re.S)
        if not blk:
            fail.append('C1: [DEP] has no "-- Expected: N" for %s' % tag)
        elif int(blk.group(1)) != want:
            fail.append('C1: [DEP] %s SQL comment expects %s %s; the DDL creates %d'
                        % (tag, blk.group(1), what, want))

    dupes = sorted({n for n in tables if tables.count(n) > 1})
    if dupes:
        fail.append('C1: duplicate table definitions: %s' % ', '.join(dupes))

    m2, _ = objects(mvp2)
    if m2['tables'] or m2['fks'] or m2['indexes']:
        fail.append('C1: the MVP-2 runner adds tables/FKs/indexes; it should add procedures only')
    if 'sp_ShiftSummary' in got['procs']:
        fail.append('C1: sp_ShiftSummary is in the MVP-1 chain. It is MVP-2 -- phase-01b is '
                    'explicit: do not create, drop or grant it.')

    # ---- C2
    print('== C2  documentation coverage ==')
    schema_docs = sorted(fn for fn in os.listdir(SCHEMA_DIR)
                         if fn.startswith('FlatWireSchema_') and fn.endswith('.md'))
    schema_text = ''.join(read(os.path.join(SCHEMA_DIR, fn)) for fn in schema_docs)
    undocumented = [t for t in tables
                    if not re.search(r'\b%s\b' % re.escape(t), schema_text)]
    if undocumented:
        fail.append('C2: created but absent from every Schema/FlatWireSchema_*.md: %s'
                    % ', '.join(sorted(set(undocumented))))
    for f in mvp1:
        if per_file[f][0] == 0:
            continue
        named = header_tables(f)
        if named is None:
            fail.append('C2: %s creates tables but has no "Tables :" header block' % f)
            continue
        missing = [t for t in RE_TABLE.findall(read(os.path.join(SQL_DIR, f)))
                   if t not in named]
        if missing:
            fail.append('C2: %s header omits tables it creates: %s' % (f, ', '.join(missing)))
    print('   %d tables checked against %d schema documents' % (len(tables), len(schema_docs)))

    # phase-01c is one of the three artifacts CLAUDE.md requires to stay in sync with the
    # DDL, and its group table was six tables behind when this was added -- found by hand.
    if os.path.exists(PHASE1C):
        p1c = read(PHASE1C)
        gone = [t for t in set(tables) if ('`%s`' % t) not in p1c]
        if gone:
            fail.append('C2: absent from phase-01c-database-foundation.md: %s'
                        % ', '.join(sorted(gone)))
        print('   phase-01c names %d of %d tables' % (len(set(tables)) - len(gone), len(set(tables))))

    # [DBD] section 7's ER diagrams. Mapping.md's ASCII ERD was deleted on the grounds that
    # these supersede it, so letting them fall behind makes that justification false.
    dbd = read(DBD)
    sec7 = dbd[dbd.index('### 7.'):] if '### 7.' in dbd else ''
    ents = set(re.findall(r'^\s{4}(\w+) \{', sec7, re.M))
    undrawn = [t for t in set(tables) if t not in ents]
    if undrawn:
        fail.append('C2: built but absent from every [DBD section 7] ER diagram: %s'
                    % ', '.join(sorted(undrawn)))
    print('   %d of %d tables drawn in [DBD] section 7' % (len(set(tables)) - len(undrawn),
                                                           len(set(tables))))

    # Mapping.md's Table Inventory carries the per-table CHANGE TYPE, which [DBD] does not,
    # and which a legacy migration needs. Its heading counts had been corrected to (24)
    # without the rows being added -- a heading lying about its own list.
    if os.path.exists(MAPPING):
        mp = read(MAPPING)
        inv = re.search(r'## Table Inventory(.*?)## Enumeration Reference', mp, re.S)
        if not inv:
            fail.append('C2: FlatWireSchema_Mapping.md has no "Table Inventory" section')
        else:
            body = inv.group(1)
            absent = [t for t in set(tables) if ('`%s`' % t) not in body]
            if absent:
                fail.append("C2: absent from FlatWireSchema_Mapping.md Table Inventory: %s"
                            % ', '.join(sorted(absent)))
            # every "### Heading (N)" must match the rows beneath it
            head_pat = re.compile(r'### ([^(\n]*)\((\d+)\)([^\n]*)\n(.*?)(?=\n### |\Z)',
                                  re.S)
            for hm in head_pat.finditer(body):
                claimed = int(hm.group(2))
                rows_ = [l for l in hm.group(4).split(chr(10)) if l.startswith('| `')]
                actual = len(rows_)
                if claimed != actual:
                    fail.append('C2: Mapping.md inventory heading "%s(%d)" has %d rows'
                                % (hm.group(1).strip(), claimed, actual))
            print('   Mapping.md inventory: %d of %d tables, headings consistent'
                  % (len(set(tables)) - len(absent), len(set(tables))))

    # ---- C3
    print('== C3  seed coverage ==')
    seed_text = ''.join(read(os.path.join(SQL_DIR, f)) for f in seeds)
    exempt = set(re.findall(r'NO SEED:\s*(\w+)', seed_text))
    unseeded = [t for t in set(tables)
                if t not in exempt
                and not re.search(r'INSERT\s+INTO\s+\[?dbo\]?\.\[?%s\]?' % re.escape(t),
                                  seed_text, re.I)]
    if unseeded:
        fail.append('C3: no seed rows and no "NO SEED: <table>" marker: %s'
                    % ', '.join(sorted(unseeded)))
    print('   %d of %d seeded or explicitly exempt'
          % (len(set(tables)) - len(unseeded), len(set(tables))))

    # ---- C4
    print('== C4  reachability and guards ==')
    on_disk = {f for f in os.listdir(SQL_DIR) if f.endswith('.sql')}
    runners = {MVP1_RUNNER, MVP2_RUNNER, SEED_RUNNER}
    reachable = set(mvp1) | set(mvp2) | set(seeds) | runners | {TEARDOWN}
    orphans = sorted(on_disk - reachable)
    if orphans:
        fail.append('C4: in the folder but included by no runner: %s' % ', '.join(orphans))
    for f in sorted(on_disk - runners - {TEARDOWN}):
        s = read(os.path.join(SQL_DIR, f))
        creates = len(RE_TABLE.findall(s)) + len(RE_PROC.findall(s)) + len(RE_TRIG.findall(s))
        if not creates:
            continue
        guards = (len(re.findall(r'IF\s+NOT\s+EXISTS', s, re.I))
                  + len(re.findall(r'IF\s+OBJECT_ID', s, re.I))
                  + len(re.findall(r'CREATE\s+OR\s+ALTER', s, re.I)))
        if guards == 0:
            fail.append('C4: %s creates objects with no guard -- the runner is not idempotent'
                        % f)
    print('   %d files on disk, %d reachable, %d orphan (expected 0)'
          % (len(on_disk), len(on_disk & reachable), len(orphans)))

    # ---- C5
    print('== C5  seed FK ordering ==')
    fks = RE_FK_FULL.findall(read(os.path.join(SQL_DIR, 'FlatWire_DDL_06_ForeignKeys.sql')))
    c5 = seed_fk_order(seeds, fks)
    fail.extend(c5)
    print('   %d FK constraints examined against the seed order; %d finding(s)'
          % (len(fks), len(c5)))

    # ---- C6
    print('== C6  count claims in prose ==')
    c6_fatal, c6_advisory = count_claims(got)
    fail.extend(c6_fatal)
    print('   %d disagreeing claim(s) in permitted sites, %d advisory elsewhere'
          % (len(c6_fatal), len(c6_advisory)))
    for line in c6_advisory:
        print('   ~ %s' % line)

    if emit:
        print()
        print('== per-file ==')
        print('   %-44s %6s %5s %5s %5s %5s'
              % ('file', 'tables', 'fks', 'idx', 'proc', 'trig'))
        for f in mvp1:
            t, k, i, p, g = per_file[f]
            print('   %-44s %6d %5d %5d %5d %5d' % (f, t, k, i, p, g))

    print()
    if fail:
        print('FAILED -- %d finding(s):' % len(fail))
        for f in fail:
            print('  * %s' % f)
        sys.exit(1)
    print('OK -- the DDL, the script headers, the schema documents, the seeds '
          'and [DBD 6.2] all agree.')


if __name__ == '__main__':
    main()
