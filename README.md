# Claude Code Kontrol (CCK)

**Kontrol Your AI.**

CCK is a plugin architecture for Claude Code — built to
make AI-assisted development work *your* way, consistently, every session.

## The Problem

Every Claude Code session starts blank. No memory of how you like 
functions written, how your database should be structured, how you 
want debugging approached. You end up re-explaining your standards 
over and over.

CCK fixes that.

## What CCK Does

At session start, CCK injects your local system configuration into Claude Code —
your OS, PHP version, MySQL connection details, and more. Claude has that context
before it ever searches your system, so it can make informed decisions from the
first prompt without guessing or asking.

## Plugins

### 🖥️ system/localhost *(active)*
Detects and stores your local environment — OS, PHP version and binary,
MySQL host, port, user, and socket. Injected into every Claude Code session
at startup via a `SessionStart` hook.

## Translations

CCK supports multiple languages. All user-facing strings live in `claude-code-kontrol/lang/`.

**To use a different language**, set `CCK_LANG` before running the installer:

```bash
CCK_LANG=fr bash install.sh
```

**To add a translation:**

1. Copy `lang/en.sh` to `lang/<code>.sh` (e.g. `lang/fr.sh`)
2. Translate the values — do not change the variable names
3. Submit a pull request

The fallback is always `en.sh`, so partial translations are safe.

## Make It Yours

CCK is my system — but it's built to be forked.

1. Fork the repo
2. Modify the plugins to match your opinions
3. Add plugins for workflows I haven't thought of yet

Your rules. Claude's power.

## Status

Early development. System context plugin in progress. 
Architecture being built out.

---

Built by [Jonathan Pitcher](https://github.com/jpitcher2377)  
PHP/Laravel Engineer | AI-Native Development
