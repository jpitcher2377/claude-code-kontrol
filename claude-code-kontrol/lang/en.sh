# Claude Code Kontrol — English language strings
# To add a new language, copy this file to e.g. fr.sh and translate the values.
# Set CCK_LANG=fr in your environment to use it.

# install.sh
MSG_ERR_JQ="Error: jq is required. Install with: brew install jq"
MSG_INSTALL_TITLE="Claude Code Kontrol — installing plugins..."
MSG_HOOKS_REGISTERED="✓ hooks registered"
MSG_INSTALL_DONE="Done. Restart Claude Code to apply changes."

# run.sh
MSG_COMMAND_INSTALLED="✓ command installed"
MSG_SETUP_TITLE="Claude Code Kontrol — localhost setup"
MSG_AUTO_DETECTING="auto-detecting..."
MSG_ALREADY_CONFIGURED="already configured. Update? [y/N]: "
MSG_SAVED_TO="Saved to"

# probes/01-mysql.sh
MSG_PROBE_MYSQL_NAME="MySQL"
MSG_MYSQL_MAMP_DETECTED="MAMP detected"
MSG_MYSQL_SYSTEM_DETECTED="System MySQL detected"
MSG_MYSQL_HOST="MySQL host"
MSG_MYSQL_PORT="MySQL port"
MSG_MYSQL_USER="MySQL user"
MSG_MYSQL_PASS_WARNING="Warning: password will be stored in plaintext at ~/.cck/localhost.conf"
MSG_MYSQL_PASS_BLANK="Leave blank to attempt connection with no password."
MSG_MYSQL_PASS_EXISTING="MySQL password [****]: "
MSG_MYSQL_PASS="MySQL password: "
MSG_MYSQL_SOCKET="MySQL socket"

# probes/02-php.sh
MSG_PROBE_PHP_NAME="PHP"
MSG_PHP_MAMP_DETECTED="MAMP PHP detected"
MSG_PHP_SYSTEM_DETECTED="System PHP detected"
MSG_PHP_NOT_DETECTED="No PHP detected"
MSG_PHP_VERSION="PHP version"
MSG_PHP_BINARY="PHP binary"
MSG_PHP_INI="PHP ini path"
