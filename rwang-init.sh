#!/usr/bin/env sh
# Install RWANG into a project so ANY agent (Codex, Cursor, Claude, local LLM) can use it.
# Usage: ./rwang-init.sh /path/to/your/project   (defaults to current directory)
set -e
here="$(cd "$(dirname "$0")" && pwd)"
target="${1:-.}"
mkdir -p "$target"

for f in RWANG-MASTERPLAN.md RWANG-REVIEW.md RWANG-OPTIMIZE.md; do
  if [ -f "$target/$f" ]; then echo "keep   $f (already present)"; else cp "$here/$f" "$target/$f"; echo "add    $f"; fi
done
for pointer in AGENTS.md CLAUDE.md; do
  if [ -f "$target/$pointer" ]; then echo "keep   $pointer (already present)"; else cp "$here/templates/$pointer" "$target/$pointer"; echo "add    $pointer"; fi
done

echo ""
echo "RWANG installed into: $target"
echo "Put your project spec/notes in $target/project/ then tell your agent: RWANG:MasterPlan"
