#!/usr/bin/env bash
#
# Mirror new argotorg/fe release tags into this repo.
#
# For each fe release tag not already mirrored here, regenerate the grammar at
# that tag, create a matching tag pointing at a commit with the generated
# parser, and publish a GitHub release with the compiled wasm attached. The
# master branch is left untouched (release tag commits live only under their
# tag), so editor integrations can pin a stable release tag.
#
# Requires: gh (authenticated for this repo; public read of fe), node/npm, emcc.
set -euo pipefail

FE_REPO_SLUG="${FE_REPO_SLUG:-argotorg/fe}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

git config user.name "${GIT_AUTHOR_NAME:-fe-grammar-bot}"
git config user.email "${GIT_AUTHOR_EMAIL:-actions@github.com}"

mapfile -t fe_tags < <(gh release list --repo "$FE_REPO_SLUG" --limit 50 --json tagName --jq '.[].tagName')
existing_tags="$(git tag -l)"

made_any=0
for tag in "${fe_tags[@]}"; do
  if grep -qxF "$tag" <<<"$existing_tags"; then
    continue
  fi
  echo "::group::Mirroring $tag"
  # Build the grammar for this release on a throwaway branch off master so the
  # generated artifacts don't land on master; only the tag is published.
  git checkout -q -B mirror-tmp master
  if scripts/sync-from-fe.sh "$tag"; then
    npx tree-sitter build --wasm .
    src="$(cat .source-commit)"
    git add -A
    git commit -q -m "Grammar for fe $tag (${FE_REPO_SLUG}@${src:0:12})"
    git tag "$tag"
    git push -q origin "refs/tags/$tag"
    gh release create "$tag" tree-sitter-fe.wasm \
      --title "$tag" \
      --notes "Fe tree-sitter grammar generated from ${FE_REPO_SLUG}@${src:0:12} (release $tag)."
    made_any=1
  else
    echo "No grammar present at $tag; skipping."
  fi
  git checkout -q -f master
  git branch -qD mirror-tmp 2>/dev/null || true
  echo "::endgroup::"
done

[ "$made_any" = 1 ] || echo "No new fe releases to mirror."
