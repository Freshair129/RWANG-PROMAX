#!/usr/bin/env sh
# Install the RWANG: skill family into every agent harness on this machine.
# Targets: Claude Code (~/.claude/skills), Codex CLI (~/.agents/skills),
#          Antigravity CLI (~/.gemini/antigravity-cli/skills — only if ~/.gemini exists)
set -e
src="$(cd "$(dirname "$0")" && pwd)/skills"

install_to() {
  dest="$1"; label="$2"
  mkdir -p "$dest"
  for skill in "$src"/*/; do
    name="$(basename "$skill")"
    mkdir -p "$dest/$name"
    cp -f "$skill"* "$dest/$name/"
  done
  echo "installed -> $label  ($dest)"
}

install_to "$HOME/.claude/skills" "Claude Code"
install_to "$HOME/.agents/skills" "Codex CLI (agents standard)"
if [ -d "$HOME/.gemini" ]; then
  install_to "$HOME/.gemini/antigravity-cli/skills" "Antigravity CLI"
else
  echo "skip      Antigravity CLI (no ~/.gemini on this machine)"
fi

echo ""
echo "Invoke:  Claude Code: RWANG:MasterPlan   Codex: \$rwang-masterplan   Antigravity: /skills"
echo "Restart the CLI if a skill does not appear."
