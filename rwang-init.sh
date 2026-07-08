#!/usr/bin/env sh
# Install RWANG into a project so ANY agent (Codex, Cursor, Claude, local LLM) can use it.
# Usage: ./rwang-init.sh /path/to/your/project   (defaults to current directory)
set -e
here="$(cd "$(dirname "$0")" && pwd)"
target="${1:-.}"
mkdir -p "$target"

for f in RWANG-MASTERPLAN.md RWANG-CORE.md RWANG-REVIEW.md RWANG-OPTIMIZE.md RWANG-VERSION.md; do
  if [ -f "$target/$f" ]; then echo "keep   $f (already present)"; else cp "$here/$f" "$target/$f"; echo "add    $f"; fi
done
for pointer in AGENTS.md CLAUDE.md; do
  if [ -f "$target/$pointer" ]; then echo "keep   $pointer (already present)"; else cp "$here/templates/$pointer" "$target/$pointer"; echo "add    $pointer"; fi
done

# workspace skills for Codex CLI / Antigravity CLI (.agents/skills is the cross-tool standard)
for skill in "$here/skills"/*/; do
  name="$(basename "$skill")"
  mkdir -p "$target/.agents/skills/$name"
  cp -f "$skill"* "$target/.agents/skills/$name/"
done
echo "add    .agents/skills/ (workspace skills — Codex & Antigravity pick these up)"

# install the RWANG write gate (pre-commit hook) if the target is a git repo
if [ -d "$target/.git" ]; then
  if [ -f "$target/.git/hooks/pre-commit" ]; then
    echo "keep   .git/hooks/pre-commit (already exists — merge gate/pre-commit manually)"
  else
    cp "$here/gate/pre-commit" "$target/.git/hooks/pre-commit"
    chmod +x "$target/.git/hooks/pre-commit"
    echo "add    .git/hooks/pre-commit (RWANG write gate)"
  fi
else
  echo "note   not a git repo — write gate not installed (run 'git init' then re-run to enable it)"
fi

echo ""
echo "RWANG installed into: $target"
echo "Put your project spec/notes in $target/project/ then tell your agent: RWANG:MasterPlan"
