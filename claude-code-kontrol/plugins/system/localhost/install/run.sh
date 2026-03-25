#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.cck"
CONFIG="$CONFIG_DIR/localhost.conf"

mkdir -p "$CONFIG_DIR"
[ -f "$CONFIG" ] || touch "$CONFIG"

# --- Helpers ---

config_get() {
  grep "^${1}=" "$CONFIG" 2>/dev/null | cut -d= -f2- || true
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
echo "Claude Code Kontrol — localhost setup"
echo ""

for probe_file in "$INSTALL_DIR/probes"/[0-9]*.sh; do
  [ -f "$probe_file" ] || continue

  PROBE_NAME=""
  PROBE_KEYS=()
  probe_run() { :; }

  # shellcheck source=/dev/null
  source "$probe_file"

  if [ "${PROBE_AUTO:-false}" = "true" ]; then
    printf "  %-20s auto-detecting...\n" "$PROBE_NAME"
  elif probe_is_configured "${PROBE_KEYS[@]}"; then
    printf "  %-20s already configured. Update? [y/N]: " "$PROBE_NAME"
    read -r ans
    [[ "$ans" =~ ^[Yy]$ ]] || continue
    echo "  --- $PROBE_NAME ---"
  else
    echo "  --- $PROBE_NAME ---"
  fi

  probe_run
  echo ""
done

echo "Saved to $CONFIG"
