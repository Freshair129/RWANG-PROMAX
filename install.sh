#!/usr/bin/env sh
# Install the RWANG: skill family for Claude Code (all projects on this machine).
set -e
src="$(cd "$(dirname "$0")" && pwd)/skills"
dest="$HOME/.claude/skills"
mkdir -p "$dest"
for skill in "$src"/*/; do
  name="$(basename "$skill")"
  mkdir -p "$dest/$name"
  cp -f "$skill"* "$dest/$name/"
  echo "Installed $name"
done
echo ""
echo "Done. Open any project in Claude Code and type: RWANG:MasterPlan, RWANG:Review, or RWANG:Optimize"
