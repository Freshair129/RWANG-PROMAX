#!/usr/bin/env sh
# Link a project to globally installed RWANG skills without copying module payloads.
# Usage: ./rwang-init.sh /path/to/project
set -e
here="$(cd "$(dirname "$0")" && pwd)"
target="${1:-.}"
global_skills="$HOME/.agents/skills"
mkdir -p "$target/.agents/skills"

create_skill_link() {
  link="$1"; skill="$2"
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*)
      cmd.exe //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$skill")" >/dev/null
      ;;
    *) ln -s "$skill" "$link" ;;
  esac
}

for pointer in AGENTS.md CLAUDE.md; do
  if [ -f "$target/$pointer" ]; then echo "keep   $pointer (already present)"
  else cp "$here/templates/$pointer" "$target/$pointer"; echo "add    $pointer"
  fi
done

for name in rwang rwang-review rwang-optimize; do
  skill="$global_skills/$name"
  [ -f "$skill/SKILL.md" ] || { echo "missing globally installed skill: $skill; run install.sh first"; exit 1; }
  link="$target/.agents/skills/$name"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "refusing to overwrite project-local skill copy: $link"; exit 1
  fi
  if [ -L "$link" ]; then
    current_target="$(readlink "$link")"
    if [ "$current_target" = "$skill" ]; then
      echo "keep   .agents/skills/$name (correct link already present)"
      continue
    fi
    rm "$link"
    echo "replace .agents/skills/$name (stale link target: $current_target)"
  fi
  create_skill_link "$link" "$skill"
  echo "link   .agents/skills/$name -> $skill"
done

if [ -d "$target/.git" ]; then
  hook="$target/.git/hooks/pre-commit"
  if [ -f "$hook" ]; then echo "keep   .git/hooks/pre-commit (merge the RWANG gate manually if needed)"
  else
    hook_source="$global_skills/rwang/scripts/pre-commit"
    [ -f "$hook_source" ] || { echo "missing pre-commit source: $hook_source"; exit 1; }
    cp "$hook_source" "$hook"
    chmod +x "$hook"
    echo "add    .git/hooks/pre-commit (governed-artifact gate)"
  fi
else
  echo "note   not a git repo; write gate not installed"
fi

echo "RWANG linked into: $target"
echo "Put project materials at the root or in project/, then invoke RWANG:init"
