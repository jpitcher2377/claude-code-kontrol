PROBE_NAME="MySQL"
PROBE_KEYS=(DB_HOST DB_PORT DB_USER)

probe_run() {
  local _host="localhost" _port="3306" _user="root" _socket=""

  if [ -d "/Applications/MAMP" ]; then
    echo "    MAMP detected"
    _port="8889"
    _socket="/Applications/MAMP/tmp/mysql/mysql.sock"
  elif command -v mysql &>/dev/null; then
    echo "    System MySQL detected"
  fi

  ask DB_HOST   "MySQL host"  "$_host"
  ask DB_PORT   "MySQL port"  "$_port"
  ask DB_USER   "MySQL user"  "$_user"

  echo ""
  echo "    Warning: password will be stored in plaintext at ~/.cck/localhost.conf"
  echo "    Leave blank to attempt connection with no password."
  local _existing _pass
  _existing=$(config_get DB_PASS)
  if [ -n "$_existing" ]; then
    printf "  MySQL password [****]: "
  else
    printf "  MySQL password: "
  fi
  read -r _pass
  _pass="${_pass:-$_existing}"
  config_set DB_PASS "$_pass"

  if [ -n "$_socket" ]; then
    ask DB_SOCKET "MySQL socket" "$_socket"
  fi
}
