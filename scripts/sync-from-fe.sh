#!/usr/bin/env bash
#
# Regenerate this grammar repo from a ref of the upstream Fe monorepo.
#
# The Fe grammar lives in argotorg/fe at crates/tree-sitter-fe. Its generated
# artifacts (parser.c, grammar.json, node-types.json, wasm) are NOT tracked
# there. This script pulls the grammar *definition* (grammar.js, scanner.c,
# queries, tree-sitter.json) from a given ref of that repo, regenerates
# parser.c with the pinned tree-sitter CLI, and records the source commit in
# .source-commit. Packaging and bindings in this repo are kept as-is.
#
# The compiled wasm is NOT built here (it's gitignored); release jobs build and
# attach it separately.
#
# Usage: scripts/sync-from-fe.sh [FE_REF]      (FE_REF default: master)
#   FE_REF may be a branch, tag, or commit SHA of argotorg/fe.
#
# Env:
#   FE_REPO  override the upstream repo URL (default https://github.com/argotorg/fe.git)
#
# Exit codes: 0 ok, 2 grammar not present at FE_REF (caller may skip), 1 error.
#
# Requires: git, node/npm (installs the pinned tree-sitter CLI).
set -euo pipefail

FE_REF="${1:-master}"
FE_REPO="${FE_REPO:-https://github.com/argotorg/fe.git}"
FE_GRAMMAR_SUBDIR="crates/tree-sitter-fe"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Fetching $FE_REPO @ $FE_REF ..."
git init -q "$work/fe"
git -C "$work/fe" remote add origin "$FE_REPO"
# Fetch works uniformly for a branch, tag, or commit SHA.
git -C "$work/fe" -c protocol.version=2 fetch -q --depth 1 origin "$FE_REF"
git -C "$work/fe" checkout -q --detach FETCH_HEAD
source_commit="$(git -C "$work/fe" rev-parse HEAD)"

src="$work/fe/$FE_GRAMMAR_SUBDIR"
if [ ! -f "$src/grammar.js" ]; then
  echo "ERROR: $FE_GRAMMAR_SUBDIR/grammar.js not found at $FE_REF" >&2
  exit 2
fi

echo "Copying grammar definition ..."
cp "$src/grammar.js" "$repo_root/grammar.js"
cp "$src/tree-sitter.json" "$repo_root/tree-sitter.json"
cp "$src/src/scanner.c" "$repo_root/src/scanner.c"
# Overlay queries so upstream updates propagate while preserving repo-local
# extras (e.g. tags.scm) that upstream doesn't carry.
mkdir -p "$repo_root/queries"
cp "$src"/queries/*.scm "$repo_root/queries/"

echo "Installing pinned tree-sitter CLI ..."
cd "$repo_root"
# --ignore-scripts skips the unused Node-addon build; rebuild fetches the CLI.
npm ci --ignore-scripts
npm rebuild tree-sitter-cli

echo "Generating parser (ABI 14) ..."
npx tree-sitter generate --abi=14

printf '%s\n' "$source_commit" > "$repo_root/.source-commit"
echo "Done. Synced from argotorg/fe@$source_commit"
