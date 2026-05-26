#!/usr/bin/env bash
# install-global.sh
# Symlinks all agent docs in this repo into ~/.claude/agents/ for Claude Code.
# Run from the repo root: ./install-global.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"

mkdir -p "$CLAUDE_AGENTS_DIR"

echo "Installing agents from: $REPO_DIR"
echo "Into: $CLAUDE_AGENTS_DIR"
echo ""

# Symlink every top-level .md file except README
for agent_file in "$REPO_DIR"/*.md; do
  filename=$(basename "$agent_file")

  # Skip the README
  if [ "$filename" = "README.md" ]; then
    continue
  fi

  target="$CLAUDE_AGENTS_DIR/$filename"

  # If a file already exists at the target, back it up
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  Backing up existing: $target -> $target.backup"
    mv "$target" "$target.backup"
  fi

  # Remove existing symlink before creating a new one
  if [ -L "$target" ]; then
    rm "$target"
  fi

  ln -s "$agent_file" "$target"
  echo "  Linked: $filename"
done

echo ""
echo "Done. Agents are now globally available in Claude Code."
echo ""
echo "For Cursor, run install-cursor.sh from inside each project that needs them."
