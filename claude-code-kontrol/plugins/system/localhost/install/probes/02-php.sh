PROBE_NAME="PHP"
PROBE_KEYS=(PHP_VERSION)

probe_run() {
  local _version="" _binary="" _ini=""

  # MAMP PHP takes priority
  if [ -d "/Applications/MAMP/bin/php" ]; then
    local _mamp_latest
    _mamp_latest=$(ls -1 /Applications/MAMP/bin/php | sort -V | tail -1)
    if [ -n "$_mamp_latest" ]; then
      _binary="/Applications/MAMP/bin/php/${_mamp_latest}/bin/php"
      _version=$("$_binary" -r 'echo PHP_VERSION;' 2>/dev/null || echo "")
      echo "    MAMP PHP detected ($_version)"
    fi
  fi

  # Fall back to system PHP
  if [ -z "$_version" ] && command -v php &>/dev/null; then
    _binary=$(command -v php)
    _version=$(php -r 'echo PHP_VERSION;' 2>/dev/null || echo "")
    echo "    System PHP detected ($_version)"
  fi

  if [ -z "$_version" ]; then
    echo "    No PHP detected"
  fi

  ask PHP_VERSION "PHP version" "$_version"
  ask PHP_BINARY  "PHP binary"  "$_binary"

  # Detect php.ini
  if [ -n "$_binary" ]; then
    _ini=$("$_binary" -r 'echo php_ini_loaded_file();' 2>/dev/null || echo "")
  fi
  if [ -n "$_ini" ]; then
    ask PHP_INI "PHP ini path" "$_ini"
  fi
}
