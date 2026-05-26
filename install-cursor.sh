#!/usr/bin/env bash
# install-cursor.sh
# Symlinks all agent docs from this repo into the current project's .cursor/rules/ folder.
# Run from inside the project where you want the agents available:
#   /path/to/agents-repo/install-cursor.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"
CURSOR_RULES_DIR="$PROJECT_DIR/.cursor/rules"

# Refuse to install into the agents repo itself
if [ "$PROJECT_DIR" = "$REPO_DIR" ]; then
  echo "Error: don't run install-cursor.sh from inside the agents repo itself."
  echo "Run it from inside a project where you want the agents available."
  exit 1
fi

mkdir -p "$CURSOR_RULES_DIR"

echo "Installing agents from: $REPO_DIR"
echo "Into project: $PROJECT_DIR"
echo ""

# Symlink every top-level .md file except README, with .mdc extension for Cursor
for agent_file in "$REPO_DIR"/*.md; do
  filename=$(basename "$agent_file" .md)

  # Skip the README
  if [ "$filename" = "README" ]; then
    continue
  fi

  target="$CURSOR_RULES_DIR/$filename.mdc"

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
  echo "  Linked: $filename.mdc"
done

echo ""
echo "Done. Agents are now available in this project for Cursor."
