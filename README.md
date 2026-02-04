# Workstation Configuration

A collection of configuration files and setup scripts to create a reproducible
development environment across macOS and Linux machines.

## Overview

This repository manages the "dotfiles" and tooling for my personal and
professional workstations. It prioritizes:
* **Portability:** Works on macOS (Apple Silicon & Intel) and Linux.
* **Modularity:** Separates core configuration from machine-specific secrets.
* **Idempotence:** The installation script can be run multiple times safely.

## Repository Layout

```text
.
├── emacs/              # Modern Emacs setup (Literate Configuration)
│   ├── config.org      # The Source of Truth: Edit this file!
│   ├── init.el         # Bootstrap loader
│   └── early-init.el   # UI optimization & GC tuning
├── zsh/                # Shell configuration
│   ├── zshrc           # Master template (portable)
│   └── vterm.zsh       # Emacs vterm integration
├── git/                # Global git configuration
├── osx/                # macOS-specific utility scripts
├── archive/            # Retired configurations (Legacy 2026)
└── install.sh          # Setup script (Run this to deploy)
```

## Prerequisites

**Required**
* **Emacs 27+** (uses `early-init.el`).
* **git** (to clone and update the repo).
* **zsh** (the shell configuration assumes zsh).

**Recommended / Optional**
* **Homebrew** on macOS (or your Linux package manager) for dependencies.
* **coreutils** (for `gls`) to enable GNU-style `ls` behavior and Dired support
  on macOS (install via Homebrew).
* **pyenv** if you want the Python setup to take effect.
* **libvterm** if you use the Emacs `vterm` package (required to build the module).

## Quick Start (Installation)

To set up a new machine (or update an existing one), run the install script from
the root of the repository:

```bash
bash install.sh
```

Optional (macOS only):

```bash
bash install.sh --osx
```

Note: `--osx` will exit with an error if run on non-macOS systems.

**What this script does:**
1.  **Backs up** any existing configuration files (e.g., `~/.zshrc`,
    `~/.emacs.d`) to a timestamped folder (`~/config_backups_YYYYMMDD...`).
2.  **Symlinks** `~/.emacs.d` to the `emacs/` directory in this repo.
3.  **Appends** a source command to `~/.zshrc` to load the repo's shell config
    (preserving any local edits).
4.  **Checks** for `~/.zshrc.local` and creates it if missing (for secrets).
5.  **Creates** Emacs cache directories under `~/.cache/emacs` (or
    `$XDG_CACHE_HOME/emacs`) for packages, autosaves, and backups.
6.  **(Optional)** If `--osx` is provided, runs scripts in `osx/` to apply
    macOS defaults (e.g., Finder hidden files, Calendar event duration).

## Configuration Guide

### 1. Emacs (`emacs/`)
The Emacs setup has been modernized to use a **literate configuration** workflow.

* **`config.org`**: This is the main configuration file. It is an org mode file
  containing code blocks for packages, keybindings, and settings. **Make all
  edits here.**
* **`init.el`**: You do *not* need to touch this. It simply bootstraps
  `use-package` and loads `config.org`.
* **Cache separation**: Generated files (packages, autosaves, backups, and
  `custom.el`) are written to `~/.cache/emacs/` (or `$XDG_CACHE_HOME/emacs`) to
  keep the repo clean while preserving the “init in repo” pattern.
* **Safety net**: `emacs/.gitignore` ignores common generated artifacts in case
  anything lands in the repo.
* **Drift Prevention**: You do not need to manually tangle the org
  file. `init.el` reads the org file directly on startup.

### 2. zsh (`zsh/`)
The shell configuration is designed to be shared across multiple machines while
keeping secrets local.

* **`zsh/zshrc`**: The shared template. It handles paths, aliases, and pyenv.
* **`~/.zshrc.local`**: The installation script ensures this file exists on your
  machine. Put API keys, tokens, and machine-specific env vars here. This file
  resides outside the repository and will never be tracked by version control.
* **vterm support**: The config automatically detects if it is running inside
  Emacs (`vterm`) and loads `vterm.zsh` to enable directory tracking (`C-x C-f`)
  and prompt integration.

### 3. Git (`git/`)
Global git configurations are stored here. To apply them to your user
configuration without overwriting existing settings, use the include directive:

```bash
git config --global include.path "~/path/to/repo/git/gitconfig"
```

## Archive Strategy
Old configurations are moved to `archive/` rather than deleted, preserving
references for legacy logic or muscle memory settings.
* **`emacs-legacy-2026/`**: Contains the monolithic `.emacs` files and the old
  `dot_emacs.org` prior to the 2026 modernization.
