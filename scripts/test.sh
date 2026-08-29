#!/usr/bin/env sh
set -eu

vale="${VALE_BIN:-vale}"

(cd tests && "../$vale" test ../package/LLMCliches)

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cp build/LLMCliches.zip "$tmp/LLMCliches.zip"
cat >"$tmp/.vale.ini" <<EOF
StylesPath = styles
MinAlertLevel = suggestion
Packages = $tmp/LLMCliches.zip

[*.{md,mdx}]
BasedOnStyles = LLMCliches
EOF

(cd "$tmp" && "$OLDPWD/$vale" sync --plain-progress)
(cd "$tmp" && "$OLDPWD/$vale" test styles/LLMCliches)
cmp package/LLMCliches/meta.json "$tmp/styles/LLMCliches/meta.json"

echo "Rule suites and package installation passed."
