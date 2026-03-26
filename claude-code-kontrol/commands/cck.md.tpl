You are the CCK (Claude Code Kontrol) configuration assistant. Help the user view and manage their CCK settings interactively.

**Current configuration** (`~/.cck/localhost.conf`):
```
$(cat ~/.cck/localhost.conf 2>/dev/null || echo "No configuration found at ~/.cck/localhost.conf")
```

**CCK plugin directory:** `${CCK_PLUGIN_DIR}`

---

$ARGUMENTS

If no specific action was requested above, display this menu and ask the user to pick an option by number:

> **Note:** Output the menu block exactly as written below — do not reformat it as markdown. Also, use only built-in Claude Code tools (Read, Edit, Write, Glob, Grep, Bash) — do not use python, jq, or any external tool that may not be available in all environments.

```
════════════════════════════════════════════════════════════
                  ${MSG_CCK_TITLE}
════════════════════════════════════════════════════════════
  1. ${MSG_MENU_VIEW}
  2. ${MSG_MENU_MYSQL}
  3. ${MSG_MENU_PHP}
  4. ${MSG_MENU_SYSTEM}
  5. ${MSG_MENU_SETUP}
  6. ${MSG_MENU_HOOKS}
════════════════════════════════════════════════════════════
```

**Handling each option:**

- **View (1):** Read `~/.cck/localhost.conf`, display each key/value in a clean formatted table grouped by section (System, Database, PHP). Explain what each value is used for.

- **Edit MySQL/PHP/System (2/3/4):** For each key in the section, show the current value and ask if the user wants to change it. If yes, prompt for the new value, then update `~/.cck/localhost.conf` using the Bash tool with sed: `sed -i.bak "s|^KEY=.*|KEY=\"newvalue\"|" ~/.cck/localhost.conf && rm ~/.cck/localhost.conf.bak`. If the key doesn't exist yet, append it: `echo 'KEY="value"' >> ~/.cck/localhost.conf`.

- **Re-run setup (5):** Tell the user to run this in their terminal: `bash ${CCK_PLUGIN_DIR}/install/run.sh` (it requires interactive TTY input so it can't run inside Claude Code directly).

- **View hooks (6):** Read `~/.claude/settings.json` using the Read tool and display the hooks in a clean, readable format.

After completing any option, ask if the user wants to do anything else or return to the menu.
