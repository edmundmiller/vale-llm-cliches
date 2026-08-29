#!/usr/bin/env sh
set -eu

version="${1:-3.19.0}"
archive="vale_${version}_Linux_64-bit.tar.gz"

case "$version" in
  3.19.0) expected="c8f9d6c8055442bc7e9c121b2498e6f0e3fb670f4665e6ee577f1897f7665cf6" ;;
  *)
    echo "No recorded checksum for Vale $version" >&2
    exit 1
    ;;
esac

if [ -x .bin/vale ] && [ "$(.bin/vale --version)" = "vale version $version" ]; then
  exit 0
fi

mkdir -p .bin
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
url="https://github.com/errata-ai/vale/releases/download/v${version}/${archive}"
curl --fail --location --silent --show-error "$url" --output "$tmp/$archive"
printf '%s  %s\n' "$expected" "$tmp/$archive" | sha256sum --check --status
tar -xzf "$tmp/$archive" -C "$tmp" vale
install -m 0755 "$tmp/vale" .bin/vale
