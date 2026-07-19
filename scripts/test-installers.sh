#!/usr/bin/env sh
set -eu

bundle_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/rwang-installer-XXXXXX")"
cleanup() {
  case "$fixture" in
    "${TMPDIR:-/tmp}"/rwang-installer-*) rm -rf -- "$fixture" ;;
    *) echo "refusing unsafe fixture cleanup: $fixture" >&2; exit 1 ;;
  esac
}
trap cleanup EXIT INT TERM

mkdir -p "$fixture/.agents/skills/rwang-core" "$fixture/.agents/skills/rwang"
printf '%s\n' legacy > "$fixture/.agents/skills/rwang-core/marker.txt"
printf '%s\n' stale > "$fixture/.agents/skills/rwang/stale.txt"

HOME="$fixture" sh "$bundle_root/install.sh"

skill_count="$(find "$fixture/.agents/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | wc -l | tr -d ' ')"
[ "$skill_count" = 3 ]
for name in rwang rwang-review rwang-optimize; do
  [ -f "$fixture/.agents/skills/$name/SKILL.md" ]
done
[ ! -e "$fixture/.agents/skills/rwang/stale.txt" ]
[ ! -e "$fixture/.agents/skills/rwang-core" ]
[ "$(find "$fixture/.rwang/legacy-backups" -name marker.txt -type f | wc -l | tr -d ' ')" = 1 ]
[ "$(find "$fixture/.rwang/legacy-backups" -name stale.txt -type f | wc -l | tr -d ' ')" = 1 ]

printf '%s\n' 'stale toolkit' > "$fixture/.rwang/skills/rwang/SKILL.md"
printf '%s\n' 'stale installed' > "$fixture/.agents/skills/rwang/second-stale.txt"
HOME="$fixture" sh "$bundle_root/install.sh"
cmp "$bundle_root/skills/rwang/SKILL.md" "$fixture/.rwang/skills/rwang/SKILL.md"
[ ! -e "$fixture/.agents/skills/rwang/second-stale.txt" ]
[ "$(find "$fixture/.rwang/legacy-backups" -name second-stale.txt -type f | wc -l | tr -d ' ')" = 1 ]

project="$fixture/project"
HOME="$fixture" sh "$bundle_root/rwang-init.sh" "$project"
HOME="$fixture" sh "$bundle_root/rwang-init.sh" "$project"
for name in rwang rwang-review rwang-optimize; do
  [ -L "$project/.agents/skills/$name" ]
  [ "$(readlink "$project/.agents/skills/$name")" = "$fixture/.agents/skills/$name" ]
done

refusal_project="$fixture/refusal-project"
mkdir -p "$refusal_project/.agents/skills/rwang"
printf '%s\n' 'keep me' > "$refusal_project/.agents/skills/rwang/marker.txt"
if HOME="$fixture" sh "$bundle_root/rwang-init.sh" "$refusal_project"; then
  echo 'project init unexpectedly overwrote a real local skill copy' >&2
  exit 1
fi
[ "$(cat "$refusal_project/.agents/skills/rwang/marker.txt")" = 'keep me' ]

echo 'PASS: isolated Unix install keeps exactly three clean public skills'
echo 'PASS: replaced and retired payloads are recoverably backed up'
echo 'PASS: local-clone rerun refreshes toolkit and installed SSOT'
echo 'PASS: project init link targets and idempotency'
echo 'PASS: project init refuses and preserves a real local skill copy'
