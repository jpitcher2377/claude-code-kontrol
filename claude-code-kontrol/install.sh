#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"
MARKETPLACE="$REPO_DIR/.claude-plugin/marketplace.json"

# --- Dependency check ---
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

echo "Claude Code Kontrol — installing plugins..."
echo ""

# --- Ensure settings.json exists ---
if [ ! -f "$SETTINGS" ]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo '{}' > "$SETTINGS"
fi

# --- Install each plugin ---
while IFS= read -r source; do
  PLUGIN_DIR="$REPO_DIR/${source#./}"
  PLUGIN_NAME=$(jq -r '.name' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  PLUGIN_VERSION=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  HOOKS_REL=$(jq -r '.hooks' "$PLUGIN_DIR/.claude-plugin/plugin.json")
  HOOKS_FILE="$PLUGIN_DIR/${HOOKS_REL#./}"

  echo "  → $PLUGIN_NAME v$PLUGIN_VERSION"

  # Resolve CLAUDE_PLUGIN_ROOT to the actual plugin directory
  PROCESSED=$(jq \
    --arg root "$PLUGIN_DIR" \
    '(.. | strings) |= gsub("\\$\\{CLAUDE_PLUGIN_ROOT\\}"; $root)' \
    "$HOOKS_FILE")

  # Merge into settings.json — deduplicate by plugin dir to support re-installs
  UPDATED=$(jq \
    --argjson new_hooks "$PROCESSED" \
    --arg plugin_dir "$PLUGIN_DIR" \
    '
    .hooks //= {} |
    reduce ($new_hooks.hooks | to_entries[]) as $entry (
      .;
      .hooks[$entry.key] //= [] |
      .hooks[$entry.key] |= map(
        select(
          (.hooks // [] | map(.command) | any(contains($plugin_dir))) | not
        )
      ) |
      .hooks[$entry.key] += $entry.value
    )
    ' \
    "$SETTINGS")

  echo "$UPDATED" > "$SETTINGS"
  echo "    ✓ installed"
done < <(jq -r '.plugins[].source' "$MARKETPLACE")

echo ""
echo "Done. Restart Claude Code to apply changes."
