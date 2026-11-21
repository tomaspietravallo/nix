#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  echo "Skipping Mac activation on a non-macOS system."
  exit 0
fi

from_ref="${PRE_COMMIT_FROM_REF:-}"
to_ref="${PRE_COMMIT_TO_REF:-}"
if [[ -n "$from_ref" && -n "$to_ref" ]] &&
   git cat-file -e "$from_ref^{commit}" 2>/dev/null &&
   git cat-file -e "$to_ref^{commit}" 2>/dev/null; then
  changes="$(git diff --name-only --no-renames "$from_ref" "$to_ref")"
  mac_changes="$(printf '%s\n' "$changes" | awk 'NF && $0 !~ /^hosts\/nixos\// && $0 !~ /^modules\/nixos\// && $0 != "README.md"')"
  if [[ -z "$mac_changes" ]]; then
    echo "No Mac configuration changes; skipping activation."
    exit 0
  fi
fi

while IFS= read -r git_env; do
  unset "$git_env"
done < <(git rev-parse --local-env-vars)

exec sudo -H darwin-rebuild switch --flake ".?submodules=1#Tomass-MacBook-Pro" </dev/tty >/dev/tty 2>/dev/tty
