#!/usr/bin/env sh
# RWANG one-command installer (macOS / Linux / Git Bash)
# Usage (one line, no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.sh | sh
# Or from a local clone:  ./install.sh
#
# 1. Puts the toolkit at ~/.rwang (RWANG's global home — like ~/.claude)
# 2. Registers the skill family for Claude Code, Codex CLI, and Antigravity CLI.
# No per-project step: the skill sets a project up by itself on first use.
set -e
RWANG_HOME="$HOME/.rwang"
script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"

if [ ! -d "$RWANG_HOME/skills" ]; then
  if [ -n "$script_dir" ] && [ -d "$script_dir/skills" ]; then
    mkdir -p "$RWANG_HOME"
    cp -R "$script_dir"/. "$RWANG_HOME"/
    rm -rf "$RWANG_HOME/.git"
  else
    git clone --depth 1 https://github.com/Freshair129/RWANG-PROMAX.git "$RWANG_HOME" \
      || { echo "clone failed - install git or clone manually"; exit 1; }
  fi
else
  git -C "$RWANG_HOME" pull -q 2>/dev/null || true
fi
echo "toolkit home -> $RWANG_HOME"

src="$RWANG_HOME/skills"
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
echo "Done. Open any project and type:  RWANG:MasterPlan   (Codex: \$rwang-masterplan, Antigravity: /skills)"
echo "The skill installs RWANG into that project by itself on first run."
