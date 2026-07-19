#!/usr/bin/env sh
# RWANG one-command installer (macOS / Linux)
# Usage:  curl -fsSL https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.sh | sh
#         (or from a local clone: ./install.sh)   Windows: use install.ps1
#
# Design: SINGLE SOURCE OF TRUTH.
#   1. Toolkit lands at ~/.rwang
#   2. Skills are refreshed into ~/.agents/skills on each successful install (cross-tool SSOT; Codex reads it natively)
#   3. Claude Code and Antigravity get symlinks pointing at the SSOT.
set -e
RWANG_HOME="$HOME/.rwang"
script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"

toolkit_backup_stamp="$(date +%Y%m%d-%H%M%S)-$$"
if [ -n "$script_dir" ] && [ -d "$script_dir/skills" ] && [ "$script_dir" != "$RWANG_HOME" ]; then
  mkdir -p "$RWANG_HOME"
  toolkit_backup="$RWANG_HOME/toolkit-backups/$toolkit_backup_stamp"
  for directory_name in skills templates scripts docs; do
    [ -d "$script_dir/$directory_name" ] || continue
    if [ -e "$RWANG_HOME/$directory_name" ]; then
      mkdir -p "$toolkit_backup"
      mv "$RWANG_HOME/$directory_name" "$toolkit_backup/$directory_name"
    fi
    cp -R "$script_dir/$directory_name" "$RWANG_HOME/$directory_name"
  done
  for file_name in README.md LICENSE install.ps1 install.sh rwang-init.ps1 rwang-init.sh; do
    [ -f "$script_dir/$file_name" ] && cp "$script_dir/$file_name" "$RWANG_HOME/$file_name"
  done
  echo "refresh   local toolkit -> $RWANG_HOME"
elif [ ! -d "$RWANG_HOME/skills" ]; then
  if ! git clone --depth 1 https://github.com/Freshair129/RWANG-PROMAX.git "$RWANG_HOME"; then
    echo "clone failed - install git or clone manually"
    exit 1
  fi
elif [ -z "$script_dir" ] || [ "$script_dir" != "$RWANG_HOME" ]; then
  [ -d "$RWANG_HOME/.git" ] || { echo "cannot refresh stale toolkit without a local source or $RWANG_HOME/.git"; exit 1; }
  git -C "$RWANG_HOME" pull --ff-only -q
fi
echo "toolkit home -> $RWANG_HOME"

src="$RWANG_HOME/skills"
ssot="$HOME/.agents/skills"
skill_names="rwang rwang-review rwang-optimize"
retired_skill_names="rwang-core rwang-masterplan rwang-version rwang-quickstart"
backup_stamp="$(date +%Y%m%d-%H%M%S)-$$"
backup_root="$RWANG_HOME/legacy-backups/$backup_stamp"

retire_path() {
  old="$1"; label="$2"
  if [ -L "$old" ]; then rm "$old"; return 0; fi
  [ -e "$old" ] || return 0
  mkdir -p "$backup_root/$label"
  destination="$backup_root/$label/$(basename "$old")"
  [ ! -e "$destination" ] || { echo "backup collision: $destination"; exit 1; }
  mv "$old" "$destination"
  echo "backup    $old -> $destination"
}

create_skill_link() {
  link="$1"; target="$2"
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*)
      cmd.exe //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$target")" >/dev/null
      ;;
    *) ln -sfn "$target" "$link" ;;
  esac
}

mkdir -p "$ssot"
for name in $skill_names; do
  skill="$src/$name"
  [ -f "$skill/SKILL.md" ] || { echo "missing required skill: $skill"; exit 1; }
  retire_path "$ssot/$name" "agents-skills"
  mkdir -p "$ssot/$name"
  cp -Rf "$skill"/. "$ssot/$name"/
done
for name in $retired_skill_names; do
  if [ -e "$ssot/$name" ] || [ -L "$ssot/$name" ]; then
    retire_path "$ssot/$name" "agents-skills"
    echo "retire    $name (use RWANG:<command> through rwang)"
  fi
done
echo "SSOT      -> $ssot  (Codex reads this natively)"

link_harness() {
  dest="$1"; label="$2"; backup_label="$3"
  mkdir -p "$dest"
  for name in $skill_names; do
    retire_path "$dest/$name" "$backup_label"
    create_skill_link "$dest/$name" "$ssot/$name"
  done
  for name in $retired_skill_names; do retire_path "$dest/$name" "$backup_label"; done
  echo "linked    -> $label  ($dest -> SSOT)"
}

link_harness "$HOME/.claude/skills" "Claude Code" "claude-skills"
if [ -d "$HOME/.gemini" ]; then
  link_harness "$HOME/.gemini/antigravity-cli/skills" "Antigravity CLI" "antigravity-skills"
else
  echo "skip      Antigravity CLI (no ~/.gemini on this machine)"
fi

echo ""
echo "Done. Open any project and type:  RWANG:init"
echo "(Claude: /rwang, Codex: \$rwang, Antigravity: /skills)"
