#!/usr/bin/env bash
set -euo pipefail

bundle_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d "${TMPDIR:-/tmp}/rwang-hook-XXXXXX")"
cleanup() {
  case "$fixture" in
    "${TMPDIR:-/tmp}"/rwang-hook-*) rm -rf -- "$fixture" ;;
    *) echo "refusing unsafe fixture cleanup: $fixture" >&2; exit 1 ;;
  esac
}
trap cleanup EXIT INT TERM

git -C "$fixture" init -q
git -C "$fixture" config user.email rwang-test@example.invalid
git -C "$fixture" config user.name 'RWANG Test'
mkdir -p "$fixture/docs" "$fixture/.rwang/meta/docs"
artifact='docs/My Spec.md'
meta='.rwang/meta/docs/My Spec.md.json'
printf '%s\n' initial > "$fixture/$artifact"
hash="$(sha256sum "$fixture/$artifact" | cut -d' ' -f1)"
printf '{"sha256":"%s","version":"0.1.0","status":"draft"}\n' "$hash" > "$fixture/$meta"
git -C "$fixture" add -- "$artifact" "$meta"
git -C "$fixture" commit -q -m initial
(cd "$fixture" && bash "$bundle_root/skills/rwang/scripts/pre-commit")

printf '%s\n' changed > "$fixture/$artifact"
git -C "$fixture" add -- "$artifact"
if (cd "$fixture" && bash "$bundle_root/skills/rwang/scripts/pre-commit"); then
  echo 'hook accepted a governed path with spaces without its staged sidecar' >&2
  exit 1
fi

hash="$(sha256sum "$fixture/$artifact" | cut -d' ' -f1)"
printf '{"sha256":"%s","version":"0.1.1","status":"draft"}\n' "$hash" > "$fixture/$meta"
git -C "$fixture" add -- "$meta"
(cd "$fixture" && bash "$bundle_root/skills/rwang/scripts/pre-commit")
git -C "$fixture" commit -q -m changed

git -C "$fixture" rm -q -- "$artifact"
if (cd "$fixture" && bash "$bundle_root/skills/rwang/scripts/pre-commit"); then
  echo 'hook accepted direct deletion of a governed artifact' >&2
  exit 1
fi

git -C "$fixture" reset --hard -q HEAD
git -C "$fixture" rm -q -- "$artifact" "$meta"
if (cd "$fixture" && bash "$bundle_root/skills/rwang/scripts/pre-commit"); then
  echo 'hook accepted co-deletion of a governed artifact and its sidecar' >&2
  exit 1
fi

echo 'PASS: pre-commit handles a staged governed filename with spaces'
echo 'PASS: pre-commit permits an empty staged set'
echo 'PASS: pre-commit requires the current sha256 field and staged sidecar'
echo 'PASS: pre-commit rejects direct governed-artifact deletion'
echo 'PASS: pre-commit rejects governed artifact and sidecar co-deletion'
