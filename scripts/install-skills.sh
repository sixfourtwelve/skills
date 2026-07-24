#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${SKILLS_DEST:-$HOME/.dotfiles/home/.agents/skills}"

mkdir -p "$DEST"

installed=0
for skill_md in "$REPO"/*/SKILL.md; do
  [[ -f "$skill_md" ]] || continue

  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  rm -rf "$target"
  cp -R "$src" "$target"
  rm -rf "$target/.git"
  echo "installed $name -> $target"
  ((installed += 1))
done

if ((installed == 0)); then
  echo "No skills found in $REPO" >&2
  exit 1
fi
