#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.cck"
CONFIG="$CONFIG_DIR/localhost.conf"

# --- Load language ---
_cck_root="$(cd "$INSTALL_DIR/../../../.." && pwd)"
_lang_file="$_cck_root/lang/${CCK_LANG:-en}.sh"
[ -f "$_lang_file" ] || _lang_file="$_cck_root/lang/en.sh"
# shellcheck source=/dev/null
source "$_lang_file"

mkdir -p "$CONFIG_DIR"
[ -f "$CONFIG" ] || touch "$CONFIG"

# --- Helpers ---

config_get() {
  grep "^${1}=" "$CONFIG" 2>/dev/null | cut -d= -f2- | sed 's/^"\(.*\)"$/\1/' || true
}

config_set() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$CONFIG" 2>/dev/null; then
    sed -i.bak "s|^${key}=.*|${key}=\"${val}\"|" "$CONFIG" && rm -f "${CONFIG}.bak"
  else
    echo "${key}=\"${val}\"" >> "$CONFIG"
  fi
}

ask() {
  local key="$1" question="$2" default="${3:-}"
  local existing hint value

  existing=$(config_get "$key")
  hint="${existing:-$default}"

  if [ -n "$hint" ]; then
    printf "  %s [%s]: " "$question" "$hint"
  else
    printf "  %s: " "$question"
  fi

  read -r value
  value="${value:-$hint}"
  config_set "$key" "$value"
}

probe_is_configured() {
  local keys=("$@")
  for key in "${keys[@]}"; do
    [ -n "$(config_get "$key")" ] || return 1
  done
  return 0
}

# --- Run probes ---

echo ""
echo "$MSG_SETUP_TITLE"
echo ""

for probe_file in "$INSTALL_DIR/probes"/[0-9]*.sh; do
  [ -f "$probe_file" ] || continue

  PROBE_NAME=""
  PROBE_KEYS=()
  PROBE_AUTO=false
  probe_run() { :; }

  # shellcheck source=/dev/null
  source "$probe_file"

  if [ "${PROBE_AUTO:-false}" = "true" ]; then
    printf "  %-20s %s\n" "$PROBE_NAME" "$MSG_AUTO_DETECTING"
  elif probe_is_configured "${PROBE_KEYS[@]}"; then
    printf "  %-20s %s" "$PROBE_NAME" "$MSG_ALREADY_CONFIGURED"
    read -r ans
    [[ "$ans" =~ ^[Yy]$ ]] || continue
    echo "  --- $PROBE_NAME ---"
  else
    echo "  --- $PROBE_NAME ---"
  fi

  probe_run
  echo ""
done

echo "$MSG_SAVED_TO $CONFIG"
