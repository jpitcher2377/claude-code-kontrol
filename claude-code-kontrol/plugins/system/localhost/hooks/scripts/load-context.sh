#!/usr/bin/env bash

set -euo pipefail

CONFIG="$HOME/.cck/localhost.conf"

if [ ! -f "$CONFIG" ]; then
  exit 0
fi

# shellcheck source=/dev/null
source "$CONFIG"

CONTEXT=$(cat <<EOF
## Localhost — System Context

### Machine
- OS: ${SYS_OS:-unknown} ${SYS_VERSION:-}
- Arch: ${SYS_ARCH:-unknown}
- CPU: ${SYS_CPU:-unknown}
- RAM: ${SYS_RAM_GB:-?}GB
EOF
)

if [ -n "${DB_HOST:-}" ]; then
  CONTEXT+=$(cat <<EOF


### Database
- MySQL: ${DB_HOST}:${DB_PORT:-3306} (user: ${DB_USER:-root})${DB_SOCKET:+ | socket: $DB_SOCKET}
EOF
)
fi

if [ -n "${PHP_VERSION:-}" ]; then
  CONTEXT+=$(cat <<EOF


### PHP
- Version: ${PHP_VERSION}${PHP_BINARY:+ | binary: $PHP_BINARY}${PHP_INI:+ | ini: $PHP_INI}
EOF
)
fi

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
