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

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
