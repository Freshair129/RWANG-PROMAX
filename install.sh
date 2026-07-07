#!/usr/bin/env sh
# Install the RWANG:MasterPlan skill for Claude Code (all projects on this machine).
set -e
src="$(cd "$(dirname "$0")" && pwd)/skills/rwang-masterplan"
dest="$HOME/.claude/skills/rwang-masterplan"
mkdir -p "$dest"
cp -f "$src"/* "$dest"/
echo "Installed RWANG:MasterPlan skill to $dest"
echo "Open any project in Claude Code and type: RWANG:MasterPlan"
