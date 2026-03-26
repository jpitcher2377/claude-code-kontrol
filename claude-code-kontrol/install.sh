#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"
MARKETPLACE="$REPO_DIR/.claude-plugin/marketplace.json"

# --- Load language ---
_lang_file="$REPO_DIR/lang/${CCK_LANG:-en}.sh"
[ -f "$_lang_file" ] || _lang_file="$REPO_DIR/lang/en.sh"
# shellcheck source=/dev/null
source "$_lang_file"

# --- Dependency check ---
if ! command -v jq &>/dev/null; then
  echo "$MSG_ERR_JQ"
  exit 1
fi

echo "$MSG_INSTALL_TITLE"
echo ""

# --- Ensure settings.json exists ---
if [ ! -f "$SETTINGS" ]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo '{}' > "$SETTINGS"
fi

# --- Install global commands ---
GLOBAL_COMMANDS_DIR="$REPO_DIR/commands"
if [ -d "$GLOBAL_COMMANDS_DIR" ]; then
  CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
  mkdir -p "$CLAUDE_COMMANDS_DIR"
  for cmd_file in "$GLOBAL_COMMANDS_DIR"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name="$(basename "$cmd_file")"
    cp "$cmd_file" "$CLAUDE_COMMANDS_DIR/$cmd_name"
    echo "  $MSG_COMMAND_INSTALLED /${cmd_name%.md}"
  done
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
  echo "    $MSG_HOOKS_REGISTERED"

  # Install slash commands if present
  PLUGIN_COMMANDS_DIR="$PLUGIN_DIR/commands"
  if [ -d "$PLUGIN_COMMANDS_DIR" ]; then
    CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
    mkdir -p "$CLAUDE_COMMANDS_DIR"
    for cmd_file in "$PLUGIN_COMMANDS_DIR"/*.md; do
      [ -f "$cmd_file" ] || continue
      cmd_name="$(basename "$cmd_file")"
      sed "s|\${CCK_PLUGIN_DIR}|$PLUGIN_DIR|g" "$cmd_file" > "$CLAUDE_COMMANDS_DIR/$cmd_name"
      echo "    $MSG_COMMAND_INSTALLED /${cmd_name%.md}"
    done
  fi

  # Run interactive installer if present
  PLUGIN_INSTALLER="$PLUGIN_DIR/install/run.sh"
  if [ -f "$PLUGIN_INSTALLER" ]; then
    bash "$PLUGIN_INSTALLER" </dev/tty
  fi
done < <(jq -r '.plugins[].source' "$MARKETPLACE")

echo ""
echo "$MSG_INSTALL_DONE"
