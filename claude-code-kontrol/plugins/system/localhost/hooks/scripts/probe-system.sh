#!/usr/bin/env bash

set -euo pipefail

# --- OS & Hardware ---
OS_NAME=$(sw_vers -productName)
OS_VERSION=$(sw_vers -productVersion)
OS_BUILD=$(sw_vers -buildVersion)
ARCH=$(uname -m)
HOSTNAME=$(hostname -s)

# --- CPU & RAM ---
CPU=$(sysctl -n machdep.cpu.brand_string)
RAM_BYTES=$(sysctl -n hw.memsize)
RAM_GB=$(( RAM_BYTES / 1073741824 ))

# --- Shell ---
SHELL_NAME=$(basename "$SHELL")
SHELL_VERSION=$($SHELL --version 2>/dev/null | head -1 || echo "not installed")

# --- Package Managers ---
HOMEBREW=$(brew --version 2>/dev/null | head -1 || echo "not installed")
NPM=$(npm --version 2>/dev/null || echo "not installed")
YARN=$(yarn --version 2>/dev/null || echo "not installed")
PNPM=$(pnpm --version 2>/dev/null || echo "not installed")
COMPOSER=$(composer --version 2>/dev/null | head -1 || echo "not installed")

# --- Runtimes ---
NODE=$(node --version 2>/dev/null | head -1 || echo "not installed")
PYTHON=$(python3 --version 2>/dev/null | head -1 || echo "not installed")
PHP=$(php --version 2>/dev/null | head -1 || echo "not installed")
RUBY=$(ruby --version 2>/dev/null | head -1 || echo "not installed")

# --- MAMP PRO ---
MAMP_CONF=~/Library/Application\ Support/appsolute/MAMP\ PRO/httpd.conf

MAMP_PHP_ACTIVE=$(grep "LoadModule php_module" "$MAMP_CONF" 2>/dev/null \
  | grep -o 'php[0-9][0-9.]*' | head -1 || echo "not found")

MAMP_PHP_VERSIONS=$(ls /Applications/MAMP/bin/php/ 2>/dev/null \
  | grep "^php" | tr '\n' ' ' || echo "not found")

MAMP_VHOSTS=$(grep "ServerName" "$MAMP_CONF" 2>/dev/null \
  | grep -v "^#\|___default___\|localhost:8888" \
  | awk '{print $2}' | tr '\n' ' ' || echo "not found")

MAMP_DOCROOT=$(grep "^DocumentRoot" "$MAMP_CONF" 2>/dev/null \
  | head -1 | awk '{print $2}' | tr -d '"' || echo "not found")

MAMP_PORT="8888"

# --- MySQL (MAMP) ---
MAMP_MYSQL=/Applications/MAMP/Library/bin/mysql
MYSQL_VER=$($MAMP_MYSQL --version 2>/dev/null | grep -o 'Distrib [0-9.]*' | awk '{print $2}' || echo "not found")
MYSQL_SOCKET=$(ls /Applications/MAMP/tmp/mysql/mysql.sock 2>/dev/null || echo "not found")
MYSQL_PORT="3306"

# --- Git ---
GIT=$(git --version 2>/dev/null | head -1 || echo "not installed")
GIT_USER=$(git config --global user.name 2>/dev/null || echo "not set")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "not set")

# --- Open Ports ---
OPEN_PORTS=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null \
  | awk 'NR>1 {split($9,a,":"); print a[length(a)]}' \
  | sort -nu | tr '\n' ' ' || echo "unable to list")

# --- Output to Claude ---
CONTEXT=$(cat <<EOF
## Localhost — System Context

### Machine
- Host: $HOSTNAME
- OS: $OS_NAME $OS_VERSION (Build $OS_BUILD)
- Arch: $ARCH
- CPU: $CPU
- RAM: ${RAM_GB}GB

### Shell
- $SHELL_NAME: $SHELL_VERSION

### Package Managers
- Homebrew: $HOMEBREW
- npm: $NPM
- yarn: $YARN
- pnpm: $PNPM
- Composer: $COMPOSER

### Runtimes
- Node: $NODE
- Python: $PYTHON
- Ruby: $RUBY

### MAMP PRO
- Active PHP: $MAMP_PHP_ACTIVE
- PHP Versions: $MAMP_PHP_VERSIONS
- Virtual Hosts: $MAMP_VHOSTS
- Document Root: $MAMP_DOCROOT
- Apache Port: $MAMP_PORT

### MySQL MAMP
- Version: $MYSQL_VER
- Socket: $MYSQL_SOCKET
- Port: $MYSQL_PORT

### Git
- Version: $GIT
- User: $GIT_USER
- Email: $GIT_EMAIL

### Open Ports
- Listening: $OPEN_PORTS
EOF
)

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
