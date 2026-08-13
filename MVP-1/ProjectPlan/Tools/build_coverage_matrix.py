"""
Prove that every MVP-1 requirement reaches a test case.

    python MVP-1/DevelopmentPlan/Tools/build_coverage_matrix.py            # check, exit 1 on a hole
    python MVP-1/DevelopmentPlan/Tools/build_coverage_matrix.py --emit     # also print the tables

WHY THIS EXISTS
    06-TestPlanAndTestCases.md section 10.1 mapped SRS *section ranges* to TC ranges
    ("FR-100 - FR-120 -> TC-130 - TC-147") and concluded a coverage percentage from it.
    A range mapping cannot show that an individual requirement was tested, and 41 of them
    turned out to have no case at all - 26 of those priority Must. The percentage was
    computed from the range table, so nothing contradicted it.

    Coverage is now measured per requirement and the measurement is fatal, so the number
    in the document cannot drift away from the cases again. This is the same shape as the
    coverage guard in build_questions_xlsx.py, deliberately.

WHAT COUNTS AS COVERED, IN PRECEDENCE ORDER
    1. Direct    - a section 5 case names the requirement in its "FR / Source" column.
                   That column, not the whole row: a requirement mentioned in an expected
                   result is discussed, not proven.
    2. Indirect  - the SRS non-functional table names both the requirement and a TC.
                   FR-018 (recording cadence) is proven this way by TC-601 - TC-603.
    3. Declared  - section 10.4 records it as knowingly not covered, with a reason.
                   A declared hole is a decision; an undeclared one is an accident, and
                   only the second kind fails this script.

SCOPE
    02-SRS.md carries MVP-1 requirements only. Sections 5.10, 5.18, 5.19, 5.23 and 5.24
    moved to MVP-2 on 11 Aug 2026 and 5.21 / 5.22 were withdrawn with the DB13/DB14
    descope, so those rows are simply absent and need no range filter here. Requirements
    struck through as ~~**FR-###**~~ are withdrawn individually and are not counted -
    FR-111 is one, and counting it is how a false positive enters.

KNOWN LIMITATION - DO NOT "FIX" BY GUESSING
    05-SprintPlanAndBacklog.md section 11 ("every FR-### reaches a story") has the same
    range granularity as the old 10.1, but unlike the test plan it holds no per-requirement
    data to check against: stories are assigned to ranges, never to single requirements.
    Making it per-requirement means authoring ~263 story assignments, which is an authoring
    decision for the backlog owner and not a correction this script can make. It is
    reported below as an advisory count and never affects the exit status.

REQUIREMENTS
    None. Standard library only.
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))

SRS = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', '02-SRS.md')
TESTPLAN = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', '06-TestPlanAndTestCases.md')
BACKLOG = os.path.join(ROOT, 'MVP-1', 'ProjectPlan', '05-SprintPlanAndBacklog.md')

# The "FR / Source" column of every section 5 case table. The tables carry either 8 or 9
# columns depending on whether they have a Data column, but the first five are identical.
FR_COLUMN = 4


def read(path):
    with open(path, encoding='utf-8') as fh:
        return fh.read()


def clean(cell):
    """Strip markdown emphasis so a cell can be compared and printed."""
    return re.sub(r'[*`~]', '', cell).strip()


# ----------------------------------------------------------------- the requirements


def parse_requirements(text):
    """Return ({id: {...}}, {withdrawn ids}) from the SRS requirement tables.

    A requirement is defined by a table row that *starts* with its identifier. Anything
    else - a range endpoint in a summary table, a cross-reference in prose - is a mention,
    not a definition, and must not enter the denominator.
    """
    live, withdrawn = {}, set()
    section = '(before 5.0)'

    for line in text.splitlines():
        head = re.match(r'^### (5\.\d+[a-z]?)\s*(.*)$', line)
        if head:
            section = head.group(1)
            continue

        row = re.match(r'^\|\s*(~~)?\*\*FR-(\d{3})\*\*(~~)?\s*\|', line)
        if not row:
            continue

        fid = 'FR-' + row.group(2)
        if row.group(1):
            withdrawn.add(fid)
            continue

        cells = [clean(c) for c in line.strip('|').split('|')]
        live[fid] = {
            'section': section,
            'priority': cells[2] if len(cells) > 2 else '',
            'text': cells[1] if len(cells) > 1 else '',
        }

    if not live:
        sys.exit('FATAL: no requirement rows found in %s' % os.path.relpath(SRS, ROOT))
    return live, withdrawn


# ----------------------------------------------------------------- the evidence


def parse_direct(text):
    """{FR id: [TC ids]} from the FR / Source column of every section 5 case row."""
    hits = {}
    for line in text.splitlines():
        row = re.match(r'^\|\s*\*\*(TC-\d+[a-z]?)\*\*\s*\|', line)
        if not row:
            continue
        cells = line.strip('|').split('|')
        if len(cells) <= FR_COLUMN:
            continue
        for fid in re.findall(r'FR-\d{3}', cells[FR_COLUMN]):
            hits.setdefault(fid, []).append(row.group(1))
    if not hits:
        sys.exit('FATAL: no test-case rows found in %s' % os.path.relpath(TESTPLAN, ROOT))
    return hits


def parse_indirect(text):
    """{FR id: [TC ids]} from the SRS non-functional table, where a row names both."""
    hits = {}
    for line in text.splitlines():
        if not re.match(r'^\|\s*\*\*NFR\d+\*\*', line):
            continue
        tcs = re.findall(r'TC-\d+[a-z]?', line)
        if not tcs:
            continue
        for fid in re.findall(r'FR-\d{3}', line):
            hits.setdefault(fid, []).extend(tcs)
    return hits


def parse_declared(text):
    """{FR id: reason} from section 10.4, expanding 'FR-280 - FR-282' style ranges.

    Scoped from the 10.4 heading to the next H2, so its 10.4.x subsections are included.
    Matching on the literal '### 10.4' would truncate at '### 10.4.1'.
    """
    start = re.search(r'^### 10\.4(?!\.\d)', text, re.M)
    if not start:
        sys.exit('FATAL: section 10.4 not found in %s' % os.path.relpath(TESTPLAN, ROOT))
    rest = text[start.end():]
    end = re.search(r'^## ', rest, re.M)
    body = rest[:end.start()] if end else rest

    declared = {}
    reason_col = 1          # re-read from each table's header; 10.4.1 and 10.4.2 differ
    for line in body.splitlines():
        if not line.startswith('|') or re.match(r'^\|[\s:|-]+\|$', line):
            continue
        cells = line.strip('|').split('|')
        if len(cells) < 2:
            continue

        # Header row: locate the column carrying the prose. 10.4.1 is
        # "Not covered | Reason"; 10.4.2 is "FR | Pri | § | Why ... | What closes it".
        headers = [clean(c).lower() for c in cells]
        if any(h.startswith(('not covered', 'fr-###', '`fr-###`')) for h in headers):
            reason_col = next((i for i, h in enumerate(headers)
                               if 'reason' in h or h.startswith('why')), 1)
            continue

        subject = cells[0]
        reason = clean(cells[reason_col]) if reason_col < len(cells) else ''

        ids = set()
        for lo, hi in re.findall(r'FR-(\d{3})\s*[–-]\s*FR-(\d{3})', subject):
            ids |= {'FR-%03d' % n for n in range(int(lo), int(hi) + 1)}
        ids |= set(re.findall(r'FR-\d{3}', subject))
        for fid in ids:
            declared[fid] = reason
    return declared


def backlog_advisory(text):
    """Advisory only: does section 11 assign stories per requirement or per range?"""
    try:
        body = text.split('## 11.')[1].split('\n## ')[0]
    except IndexError:
        return None
    per_fr = len(re.findall(r'^\|\s*\*\*FR-\d{3}\*\*', body, re.M))
    ranges = len(re.findall(r'FR-\d{3}\s*[–-]\s*FR-\d{3}', body))
    return per_fr, ranges


# ----------------------------------------------------------------- output


def emit_tables(live, direct, indirect, declared):
    print('\n<!-- generated by build_coverage_matrix.py - do not hand-edit -->\n')
    print('| `FR-###` | Priority | Test case(s) | Basis |')
    print('|---|---|---|---|')
    for fid in sorted(live, key=lambda f: int(f[3:])):
        if fid in direct:
            tcs, basis = direct[fid], 'direct'
        elif fid in indirect:
            tcs, basis = indirect[fid], 'indirect — via `NFR` table'
        elif fid in declared:
            tcs, basis = [], '**declared not covered** — %s' % declared[fid]
        else:
            tcs, basis = [], '**NO CASE**'
        cases = ', '.join('`%s`' % t for t in dict.fromkeys(tcs)) if tcs else '—'
        print('| **%s** | %s | %s | %s |' % (fid, live[fid]['priority'] or '—', cases, basis))


def main():
    srs_text = read(SRS)
    tp_text = read(TESTPLAN)

    live, withdrawn = parse_requirements(srs_text)
    direct = parse_direct(tp_text)
    indirect = parse_indirect(srs_text)
    declared = parse_declared(tp_text)

    covered_direct = [f for f in live if f in direct]
    covered_indirect = [f for f in live if f not in direct and f in indirect]
    covered_declared = [f for f in live
                        if f not in direct and f not in indirect and f in declared]
    holes = sorted((f for f in live
                    if f not in direct and f not in indirect and f not in declared),
                   key=lambda f: int(f[3:]))

    total = len(live)
    # "has a case", not "is executable": a written-but-blocked case (TC-350 - TC-352 on
    # wire break) still names its requirement, and nothing parseable distinguishes it from
    # a runnable one. Section 10.4 carries that nuance in prose; this number must not
    # silently claim it.
    with_case = len(covered_direct) + len(covered_indirect)

    print('Requirement coverage — MVP-1')
    print('=' * 60)
    print('  %-42s %4d' % ('MVP-1 requirements (02-SRS.md rows)', total))
    print('  %-42s %4d' % ('withdrawn, not counted', len(withdrawn)))
    print('  %-42s %4d' % ('covered by a case (direct)', len(covered_direct)))
    print('  %-42s %4d' % ('covered via the NFR table (indirect)', len(covered_indirect)))
    print('  %-42s %4d' % ('declared not covered (§10.4)', len(covered_declared)))
    print('  %-42s %4d' % ('NO CASE, NOT DECLARED', len(holes)))
    print('-' * 60)
    print('  %-42s %4.1f %%' % ('requirements with a case', 100.0 * with_case / total))

    advisory = backlog_advisory(read(BACKLOG))
    if advisory:
        print('\n  advisory — 05-SprintPlanAndBacklog.md §11 assigns stories to '
              '%d range(s) and %d individual requirement(s).' % (advisory[1], advisory[0]))
        print('  Per-requirement story coverage cannot be checked while it is range-based; '
              'see the header note.')

    if '--emit' in sys.argv:
        emit_tables(live, direct, indirect, declared)

    if holes:
        must = [f for f in holes if live[f]['priority'] == 'Must']
        print('\nFATAL — %d requirement(s) have no test case and no §10.4 entry '
              '(%d of them Must):' % (len(holes), len(must)))
        for fid in holes:
            print('  %-8s %-8s %-6s %s' % (fid, live[fid]['priority'],
                                           live[fid]['section'], live[fid]['text'][:72]))
        print('\nEither write a case, or record the requirement in §10.4 with the reason. '
              'A declared hole is a decision; an undeclared one is an accident.')
        sys.exit(1)

    print('\nOK — every MVP-1 requirement has a case or a declared reason.')


if __name__ == '__main__':
    main()
