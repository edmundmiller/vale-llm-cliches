# Repository guide

LLMCliches is a Vale style, not an AI detector. Preserve the product boundary in
`README.md`: alerts are prompts for editorial judgment, so prefer narrow,
explainable matches over broad word bans.

## Sources of truth and task routing

- `package/LLMCliches/<Rule>.yml` owns a rule's behavior, message, severity,
  scope, and documentation link. Its paired `<Rule>.test.yml` owns executable
  positive and accepted examples. Change both when behavior changes.
- `package/LLMCliches/meta.json` owns published package metadata.
- `README.md` owns user-facing installation and development guidance;
  `package/LLMCliches/README.md` is the README shipped inside the package.
- `examples/.vale.ini` and `examples/sample.md` demonstrate local package use.
- `Makefile` owns public development targets and the Vale version. The scripts
  in `scripts/` own bootstrap, archive construction, and the test/install flow.
- `.github/workflows/test.yml` owns CI and should invoke the same entry point
  used locally rather than duplicate its steps.

For rule work, first read only the target `.yml` and its adjacent `.test.yml`.
Use scoped searches such as `rg -n 'pivotal' package/LLMCliches` to find
overlap with other rules. Read `Makefile` and the relevant script only when
changing tooling or packaging; do not load every rule to edit one rule.

## Rule and test contract

- Keep rule and test basenames identical. Tests use Vale's native fixture
  format: `name`, `rule`, `input`, and exact `want` diagnostics.
- Cover a phrase that must alert and nearby prose that must not. Add case,
  Markdown-code, punctuation, or boundary cases only when the rule depends on
  them. Expected line, column, rule ID, matched text, and message are part of
  the contract.
- Keep regexes compatible with Vale's engine. Follow existing YAML quoting:
  regex backslashes remain literal in single-quoted scalars and are escaped in
  double-quoted scalars.
- Avoid moving a phrase between rules accidentally. If patterns can overlap,
  test which rule should own the diagnostic and run the complete suite.

## Generated and ignored paths

Do not hand-edit or commit `.bin/`, `build/`, or `styles/`; `.gitignore` marks
all three as generated:

- `make bootstrap` installs the pinned Vale binary in `.bin/`.
- `make build` rebuilds `build/LLMCliches.zip` solely from
  `package/LLMCliches/`.
- Any `styles/` directory is Vale Sync output; the example command creates
  `examples/styles/`.

Edit the owning source or script instead. `make clean` removes the root `.bin/`,
`build/`, and `styles/` paths; remove nested Sync output when its config owns it.

## Verification by change

Run commands from the repository root.

| Change | Required verification |
| --- | --- |
| Rule or paired fixture | `make test` |
| Package metadata, build/bootstrap/test script, Makefile, or CI | `make clean && make test` |
| Example configuration or sample | `make bootstrap build`, then `cd examples && ../.bin/vale sync --plain-progress && ../.bin/vale sample.md` |
| Prose-only documentation | Check referenced paths and commands; run `make test` if instructions or package contents changed |

`make test` is the CI-equivalent check. It runs the source rule suites, builds
the archive, installs it with Vale Sync in a temporary directory, reruns the
suites against the installed style, and compares installed metadata. Do not
replace it with a YAML parser or a regex-only test: those skip Vale semantics
and package installation.
