set -euo pipefail

repo="$(git rev-parse --show-toplevel)"
git_hook_index="${GIT_INDEX_FILE:-$(git rev-parse --git-path index)}"
while IFS= read -r git_env; do
  unset "$git_env"
done < <(git rev-parse --local-env-vars)
cd "$repo"
temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
snapshot="$temporary/source"
mkdir -p "$snapshot"
cp "$git_hook_index" "$temporary/index"

git archive "$(GIT_INDEX_FILE="$temporary/index" git write-tree)" | tar -xf - -C "$snapshot"
revision="$(GIT_INDEX_FILE="$temporary/index" git ls-files --stage -- secrets | awk '$1 == 160000 {print $2}')"
if [[ -z "$revision" ]]; then
  printf 'The secrets submodule must be staged before checking the configuration.\n' >&2
  exit 1
fi
while read -r mode submodule_revision _ path; do
  [[ "$mode" == 160000 ]] || continue
  mkdir -p "$snapshot/$path"
  git -C "$path" archive "$submodule_revision" | tar -xf - -C "$snapshot/$path"
done < <(GIT_INDEX_FILE="$temporary/index" git ls-files --stage)
if [[ -e "$snapshot/secrets/.private" ]]; then
  printf 'Private identity storage must not be tracked in the secrets submodule.\n' >&2
  exit 1
fi

case "$1" in
  update)
    nix flake lock "path:$snapshot"
    if ! cmp -s "$snapshot/flake.lock" "$repo/flake.lock"; then
      cp "$snapshot/flake.lock" "$repo/flake.lock"
      GIT_INDEX_FILE="$git_hook_index" git add -- flake.lock
    fi
    ;;
  check)
    nix flake check "path:$snapshot" --no-build --no-update-lock-file
    ;;
  build)
    nix build "path:$snapshot#darwinConfigurations.Tomass-MacBook-Pro.system" --no-link --no-update-lock-file
    ;;
  *)
    printf 'Expected update, check, or build.\n' >&2
    exit 1
    ;;
esac
