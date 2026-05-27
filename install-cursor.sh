#!/usr/bin/env bash
# install-cursor.sh
# Symlinks the canonical agent docs from ./agents into the current project's
# .cursor/rules/ folder as .mdc files. This keeps Cursor and Claude Code on
# the same source of truth — one doc, two install targets.
#
# Run from inside the project where you want the agents available:
#   /path/to/agents-repo/install-cursor.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"
AGENTS_DIR="$REPO_DIR/agents"
CURSOR_RULES_DIR="$PROJECT_DIR/.cursor/rules"

if [ "$PROJECT_DIR" = "$REPO_DIR" ]; then
  echo "Error: don't run install-cursor.sh from inside the agents repo itself."
  echo "Run it from inside a project where you want the agents available."
  exit 1
fi

if [ ! -d "$AGENTS_DIR" ]; then
  echo "Error: agents directory not found: $AGENTS_DIR"
  exit 1
fi

mkdir -p "$CURSOR_RULES_DIR"

count=0

echo "Installing agents from: $AGENTS_DIR"
echo "Into project: $PROJECT_DIR"
echo ""

for agent_file in "$AGENTS_DIR"/*.md; do
  [ -e "$agent_file" ] || continue

  base="$(basename "$agent_file" .md)"
  target="$CURSOR_RULES_DIR/$base.mdc"

  # Guard: only install files that start with YAML frontmatter.
  if [ "$(head -n 1 "$agent_file")" != "---" ]; then
    echo "  Skipping $base.md: missing YAML frontmatter"
    continue
  fi

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    echo "  Backing up existing: $target -> $backup"
    mv "$target" "$backup"
  fi

  if [ -L "$target" ]; then
    rm "$target"
  fi

  ln -s "$agent_file" "$target"
  echo "  Linked: $base.mdc"
  count=$((count + 1))
done

echo ""
echo "Done. Installed $count Cursor rule(s)."
echo "Open Cursor settings/rules to verify they appear."
