/*
 * Self-test for inject-angular-rules.cjs. Run: node .claude/hooks/inject-angular-rules.cjs --selftest
 *
 * Two things are worth asserting and neither is visible from reading the hook:
 *   1. the rules resolve at all - the ual-angular checkout is found where the candidates expect it;
 *   2. the guard holds - this repo's mockups are .css/.scss/.js and must collect NOTHING, because
 *      their tokens and conventions are deliberately not the application's.
 */
const path = require('path');
const { contextFor, rulesFor, angularRoot } = require(path.join(__dirname, 'inject-angular-rules.cjs'));

const ANGULAR = angularRoot();
const LIB = ANGULAR ? path.join(ANGULAR, 'projects', 'flat-wire', 'src', 'lib') : '';

/* [description, path, must the rules fire, a rule file the result must have come from] */
const CASES = [
  ['component ts', path.join(LIB, 'components', 'run.component.ts'), true, 'Component rules'],
  ['component html', path.join(LIB, 'components', 'run.component.html'), true, 'Template rules'],
  ['spec', path.join(LIB, 'components', 'run.component.spec.ts'), true, 'spec'],
  ['service', path.join(LIB, 'services', 'run.service.ts'), true, 'service'],
  ['model', path.join(LIB, 'models', 'run.model.ts'), true, 'model'],
  ['interface', path.join(LIB, 'interface', 'flat-wire.interface.ts'), true, 'Interface'],
  ['enum', path.join(LIB, 'enum', 'flat-wire.enum.ts'), true, 'Interface'],
  ['scss', path.join(LIB, 'components', 'run.component.scss'), true, 'SCSS rules'],
  ['plain ts', path.join(LIB, 'constants', 'flat-wire.constants.ts'), true, 'TypeScript rules'],
  ['planning mockup scss', 'c:/UAL/Flatwire-planning/50-frontend/mockups/flat-wire-shopfloor.styles.scss', false, ''],
  ['planning mockup js', 'c:/UAL/Flatwire-planning/50-frontend/mockups/fw-modal.js', false, ''],
  ['planning markdown', 'c:/UAL/Flatwire-planning/10-requirements/features/FS-01.md', false, '']
];

let failures = 0;

/**
 * method to report one assertion
 * @param {boolean} passed whether the assertion held
 * @param {string} message what was being asserted
 * @returns {void}
 */
function assert(passed, message) {
  if (!passed) {
    failures += 1;
  }
  process.stdout.write((passed ? '  ok   ' : '  FAIL ') + message + '\n');
}

process.stdout.write('inject-angular-rules selftest\n');
assert(Boolean(ANGULAR), 'ual-angular checkout found: ' + (ANGULAR || 'NONE - set UAL_ANGULAR_DIR'));

if (ANGULAR) {
  CASES.forEach(([label, file, shouldFire, marker]) => {
    const result = contextFor(file);
    if (shouldFire) {
      assert(Boolean(result), label + ' -> injects [' + rulesFor(file).join(', ') + ']');
      assert(Boolean(result) && result.includes(marker), label + ' -> content mentions "' + marker + '"');
    } else {
      assert(result === null, label + ' -> injects nothing (guard holds)');
    }
  });
}

process.stdout.write(failures ? '\n' + failures + ' FAILURE(S)\n' : '\nall assertions passed\n');
process.exitCode = failures ? 1 : 0;
