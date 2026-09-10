/*
 * PreToolUse hook - injects the Angular coding rules before Claude writes an Angular file.
 *
 * The rules live in the APPLICATION repository, not this one:
 *   <ual-angular>/.claude/instructions/          the full rule files
 *   <ual-angular>/.claude/instructions/digests/  the compact "what actually gets broken" versions
 *
 * ual-angular already runs its own copy of this idea (.claude/hooks/inject-rules.cjs), but project
 * settings only load for the directory Claude Code was STARTED in. A session started here - which is
 * how flat wire work is driven, this repo being the spec - writes into ual-angular with none of its
 * rules loaded. This hook closes that gap: same digests, same mandate, from whichever repo you sit in.
 *
 * Reads the hook payload on stdin, matches tool_input.file_path, prints
 * hookSpecificOutput.additionalContext.
 *
 * FAILS OPEN, always. Unreadable rules, a malformed payload, an ual-angular checkout that is not
 * where it is expected - exit 0 having printed nothing, so a broken hook can never block an edit.
 *
 * Verify without a tool call:  node .claude/hooks/inject-angular-rules.cjs --dry-run <file-path>
 *                              node .claude/hooks/inject-angular-rules.cjs --selftest
 */
const fs = require('fs');
const path = require('path');

/* where the rules live. First hit wins; UAL_ANGULAR_DIR overrides everything. */
const ANGULAR_CANDIDATES = [
  process.env.UAL_ANGULAR_DIR,
  path.join(__dirname, '..', '..', '..', 'Second-Branch', 'ual-angular'),
  path.join(__dirname, '..', '..', '..', 'ual-angular'),
  'C:\\UAL\\Second-Branch\\ual-angular',
  'C:\\UAL\\ual-angular'
];

/*
 * First match wins, so the specific patterns are listed before the general ones. Each entry lists
 * the rule files to inject, relative to <ual-angular>/.claude/ - a digest where one exists, the full
 * instruction file where it does not (service, model, directive and pipe have no digest, and are
 * small enough to send whole).
 */
const RULES = [
  [/\.spec\.ts$/i, ['instructions/digests/spec.md']],
  [/(^|[\\/])content-data[\\/].*\.json$/i, ['instructions/digests/content-data.md']],
  [/\.component\.html$/i, ['instructions/digests/template.md']],
  [/\.component\.ts$/i, ['instructions/digests/component.md']],
  [/\.(interface|enum)\.ts$/i, ['instructions/digests/interface.md']],
  [/\.service\.ts$/i, ['instructions/service.md', 'instructions/digests/ts-common.md']],
  [/\.model\.ts$/i, ['instructions/model.md', 'instructions/digests/ts-common.md']],
  [/\.directive\.ts$/i, ['instructions/directive.md', 'instructions/digests/ts-common.md']],
  [/\.pipe\.ts$/i, ['instructions/pipe.md', 'instructions/digests/ts-common.md']],
  [/\.(scss|css)$/i, ['instructions/digests/style.md']],
  [/\.html$/i, ['instructions/digests/template.md']],
  [/\.ts$/i, ['instructions/digests/ts-common.md']]
];

/* the rule files too large to inject on every write, named instead so they can be read on demand */
const ON_DEMAND =
  'Writing a FORM component? Read .claude/instructions/form.md first. ' +
  'Writing a dialog or popup? Read .claude/instructions/popup.md first. ' +
  'Writing a .spec.ts? .claude/commands/generate-tests.md carries the 14 absolute rules.';

/**
 * method to locate the ual-angular checkout that owns the rules
 * @returns {string|null} absolute path to the checkout, or null when no candidate has one
 */
function angularRoot() {
  const found = ANGULAR_CANDIDATES.filter(Boolean)
    .map((candidate) => path.resolve(candidate))
    .find((candidate) => fs.existsSync(path.join(candidate, '.claude', 'instructions', 'digests')));
  return found || null;
}

/**
 * method to decide whether a path is Angular application code rather than a file in this repo
 * @param {string} filePath the path the tool is about to write
 * @param {string} root the resolved ual-angular checkout
 * @returns {boolean} true when the file sits in an Angular workspace
 */
function isAngularCode(filePath, root) {
  const normalised = path.resolve(filePath).replace(/\\/g, '/').toLowerCase();
  const inCheckout = normalised.startsWith(root.replace(/\\/g, '/').toLowerCase() + '/');
  /* the mockups in this repo are .css/.scss/.js and must NOT collect Angular rules */
  return inCheckout || /\/ual-angular\//.test(normalised) || /\/projects\/[^/]+\/src\//.test(normalised);
}

/**
 * method to pick the rule files that match a file path
 * @param {string} filePath the path the tool is about to write
 * @returns {string[]} rule files relative to <ual-angular>/.claude/, empty when nothing matches
 */
function rulesFor(filePath) {
  const match = RULES.find(([pattern]) => pattern.test(filePath));
  return match ? match[1] : [];
}

/**
 * method to assemble the injected context for one file
 * @param {string} filePath the path the tool is about to write
 * @returns {string|null} the context to inject, or null when this file needs none
 */
function contextFor(filePath) {
  const root = angularRoot();
  if (!root || !isAngularCode(filePath, root)) {
    return null;
  }
  const sources = rulesFor(filePath);
  if (!sources.length) {
    return null;
  }
  const bodies = sources
    .map((source) => path.join(root, '.claude', source))
    .filter((source) => fs.existsSync(source))
    .map((source) => fs.readFileSync(source, 'utf8').trim());
  if (!bodies.length) {
    return null;
  }
  return (
    'These project rules are MANDATORY for ' +
    path.basename(filePath) +
    '. Apply them as you write, not afterwards - ng lint does NOT catch most of them. They are ' +
    'owned by ' +
    path.join(root, '.claude') +
    ', which is the authority; this is a verbatim copy.\n\n' +
    bodies.join('\n\n---\n\n') +
    '\n\n---\n\n' +
    ON_DEMAND +
    '\nAfter writing: /generate-tests for the spec, then /angular-review before the PR.'
  );
}

/**
 * method to emit the rules as PreToolUse additional context
 * @param {string} raw the hook payload received on stdin
 * @returns {void}
 */
function run(raw) {
  const filePath = (JSON.parse(raw).tool_input || {}).file_path;
  if (!filePath) {
    return;
  }
  const additionalContext = contextFor(filePath);
  if (!additionalContext) {
    return;
  }
  process.stdout.write(
    JSON.stringify({ hookSpecificOutput: { hookEventName: 'PreToolUse', additionalContext } })
  );
}

module.exports = { contextFor, rulesFor, isAngularCode, angularRoot };

if (require.main === module && process.argv[2] === '--dry-run') {
  process.stdout.write(contextFor(process.argv[3] || '') || '(no rules injected for this path)\n');
} else if (require.main === module && process.argv[2] === '--selftest') {
  require(path.join(__dirname, 'inject-angular-rules.selftest.cjs'));
} else if (require.main === module) {
  let input = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (chunk) => (input += chunk));
  process.stdin.on('end', () => {
    try {
      run(input);
    } catch {
      /* fail open: say nothing rather than block the edit */
    }
  });
}
