#!/usr/bin/env sh
# RWANG one-command installer (macOS / Linux)
# Usage:  curl -fsSL https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.sh | sh
#         (or from a local clone: ./install.sh)   Windows: use install.ps1
#
# Design: SINGLE SOURCE OF TRUTH.
#   1. Toolkit lands at ~/.rwang
#   2. Skills are copied ONCE into ~/.agents/skills (cross-tool standard = SSOT; Codex reads it natively)
#   3. Claude Code and Antigravity get symlinks pointing at the SSOT.
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
ssot="$HOME/.agents/skills"
mkdir -p "$ssot"
for skill in "$src"/*/; do
  name="$(basename "$skill")"
  mkdir -p "$ssot/$name"
  cp -Rf "$skill". "$ssot/$name"/
done
echo "SSOT      -> $ssot  (Codex reads this natively)"

link_harness() {
  dest="$1"; label="$2"
  mkdir -p "$dest"
  for skill in "$src"/*/; do
    name="$(basename "$skill")"
    rm -rf "$dest/$name"
    ln -sfn "$ssot/$name" "$dest/$name"
  done
  echo "linked    -> $label  ($dest -> SSOT)"
}

link_harness "$HOME/.claude/skills" "Claude Code"
if [ -d "$HOME/.gemini" ]; then
  link_harness "$HOME/.gemini/antigravity-cli/skills" "Antigravity CLI"
else
  echo "skip      Antigravity CLI (no ~/.gemini on this machine)"
fi

echo ""
echo "Done. Open any project and type:  RWANG:QuickStart"
echo "(Claude: /rwang-quickstart, Codex: \$rwang-quickstart, Antigravity: /skills)"
