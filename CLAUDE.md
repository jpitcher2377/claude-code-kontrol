# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

**Claude Code Kontrol (CCK)** is a plugin system that injects local developer environment context (OS, PHP, MySQL) into Claude Code sessions at startup, solving the "blank slate" problem. Config persists in `~/.cck/localhost.conf` and is injected via a `SessionStart` hook.

## Key File Locations

| Purpose | Path |
|---|---|
| Main install script | `claude-code-kontrol/install.sh` |
| `/cck` command template | `claude-code-kontrol/commands/cck.md.tpl` |
| `/cck:settings` command template | `claude-code-kontrol/commands/cck/settings.md.tpl` |
| SessionStart hook script | `claude-code-kontrol/plugins/system/localhost/hooks/scripts/load-context.sh` |
| Interactive setup wizard | `claude-code-kontrol/plugins/system/localhost/install/run.sh` |
| Environment probes | `claude-code-kontrol/plugins/system/localhost/install/probes/` |
| Language strings | `claude-code-kontrol/lang/en.sh` |
| User config (runtime) | `~/.cck/localhost.conf` |
| Installed commands (runtime) | `~/.claude/commands/cck.md`, `~/.claude/commands/cck/settings.md` |

## Architecture

### How It Fits Together

1. **`install.sh`** — bootstraps everything: processes `.tpl` command files via `envsubst` (substituting `${MSG_*}` lang vars only), registers the `SessionStart` hook into `~/.claude/settings.json`, runs the interactive setup wizard
2. **`load-context.sh`** — runs at every session start, sources `~/.cck/localhost.conf`, outputs a JSON `additionalContext` block that Claude sees as system context
3. **`/cck`** — main menu (3 options: Settings, Re-run setup, View hooks)
4. **`/cck:settings`** — direct access to the settings screen, bypassing the menu; same editor as `/cck` option 1

### Plugin / Probe System

Probes in `install/probes/` are numbered shell scripts (00, 01, 02...) with a standard interface:
- `PROBE_NAME`, `PROBE_KEYS[]`, `PROBE_AUTO` variables
- `probe_run()` function
- Auto probes run silently; interactive probes prompt the user
- `run.sh` sources each probe in order and handles the "already configured, update?" logic

### Config File Format

`~/.cck/localhost.conf` is plain `KEY="value"` shell syntax. It is sourced directly by `load-context.sh` and edited via `sed -i.bak ... && rm *.bak` (atomic pattern used everywhere).

## Settings Schema

The canonical key list for `~/.cck/localhost.conf`. This is the source of truth for forward-compatibility checks (detect missing keys and prompt to add them).

| # | Key | Section | Type | Validation Rule |
|---|---|---|---|---|
| — | `SYS_OS` | System | string | read-only, always "macOS" |
| — | `SYS_VERSION` | System | string | read-only, auto-detected |
| — | `SYS_ARCH` | System | string | read-only, auto-detected |
| — | `SYS_CPU` | System | string | read-only, auto-detected |
| — | `SYS_RAM_GB` | System | integer | read-only, auto-detected |
| 2 | `DB_HOST` | Database | string | valid hostname or IP; not empty, no spaces, alphanumeric/dots/hyphens |
| 3 | `DB_PORT` | Database | integer | numeric 1–65535 |
| 4 | `DB_USER` | Database | string | non-empty |
| 5 | `DB_PASS` | Database | string | any value (blank allowed) |
| 6 | `DB_SOCKET` | Database | path | path must exist on disk if set |
| 7 | `PHP_VERSION` | PHP | string | semver format (x.y.z) |
| 8 | `PHP_BINARY` | PHP | path | path must exist on disk |
| 9 | `PHP_INI` | PHP | path | path must exist on disk |

System keys (—) are display-only in `/cck:settings`; editable keys are numbered 2–9.

After saving any DB field ([2]–[6]), a full DB connection test is run automatically using `mysqladmin ping` with the current values of all DB fields. Uses socket if `DB_SOCKET` is set, otherwise host:port. Result is shown before redisplaying the settings screen.

Validation behavior: warn and confirm if a value looks wrong, but allow user to save anyway (trust but verify, user has final say).

## Critical Conventions

- **Never edit installed files directly.** Always edit `.tpl` files in the repo (`cck.md.tpl`, `settings.md.tpl`). The installed `~/.claude/commands/` versions are build artifacts.
- **Slash commands must use only built-in Claude Code tools** (Read, Edit, Write, Glob, Grep, Bash) — no `jq`, `python`, or other external dependencies.
- **All user-facing strings** belong in `lang/en.sh` as `MSG_*` variables; reference them in templates.
- **`envsubst` scope** in install.sh is intentionally limited to `${MSG_*}` — other `${}` variables in templates are left for Claude Code to resolve at runtime.

## Development Workflow

**Never directly copy or edit files in `~/.claude/commands/`.** Those are build artifacts produced by the installer. Direct edits bypass `envsubst` (which processes `MSG_*` lang vars) and skip validation of the full install pipeline.

### Making and deploying a change

1. Edit the `.tpl` file in the repo
2. Commit and push
3. User runs the installer to deploy:

```bash
bash claude-code-kontrol/install.sh
```

The installer will prompt "already configured, update? [y/N]" for existing config — press Enter (or `n`) to skip re-running probes. Hook registration is idempotent (deduplicates by plugin directory).

### To re-run just the setup wizard (no hooks/commands reinstalled):
```bash
bash claude-code-kontrol/plugins/system/localhost/install/run.sh
```

## Planned / In Progress

- **`/cck:settings` validation** — per-field validation using the schema above; warn + confirm flow when value looks wrong
- **Forward-compatibility check** — settings screen detects keys missing from `~/.cck/localhost.conf` (new fields added in future versions) and prompts to add them
- **Install script bridge** — after first-run setup, installer prints: "Run `/cck:settings` in Claude Code to review your settings"
- **Linux support** — system info probes (`00-system.sh`) are macOS-only; needs OS detection and Linux equivalents
