#!/usr/bin/env bash
# install-global.sh
# Symlinks all Claude Code agent docs from ./agents into ~/.claude/agents/.
# Run from the repo root: ./install-global.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$REPO_DIR/agents"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"

if [ ! -d "$AGENTS_DIR" ]; then
  echo "Error: agents directory not found: $AGENTS_DIR"
  exit 1
fi

mkdir -p "$CLAUDE_AGENTS_DIR"

count=0

echo "Installing Claude Code agents from: $AGENTS_DIR"
echo "Into: $CLAUDE_AGENTS_DIR"
echo ""

for agent_file in "$AGENTS_DIR"/*.md; do
  [ -e "$agent_file" ] || continue

  filename="$(basename "$agent_file")"
  target="$CLAUDE_AGENTS_DIR/$filename"

  # Guard: only install files that start with YAML frontmatter.
  if [ "$(head -n 1 "$agent_file")" != "---" ]; then
    echo "  Skipping $filename: missing YAML frontmatter"
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
  echo "  Linked: $filename"
  count=$((count + 1))
done

echo ""
echo "Done. Installed $count Claude Code agent(s)."
echo "Run /agents in Claude Code to verify they appear."
