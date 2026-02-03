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

## Quick Start (Installation)

To set up a new machine (or update an existing one), run the install script from
the root of the repository:

```bash
./install.sh
```

**What this script does:**
1.  **Backs up** any existing configuration files (e.g., `~/.zshrc`,
    `~/.emacs.d`) to a timestamped folder (`~/config_backups_YYYYMMDD...`).
2.  **Symlinks** `~/.emacs.d` to the `emacs/` directory in this repo.
3.  **Appends** a source command to `~/.zshrc` to load the repo's shell config
    (preserving any local edits).
4.  **Checks** for `~/.zshrc.local` and creates it if missing (for secrets).

## Configuration Guide

### 1. Emacs (`emacs/`)
The Emacs setup has been modernized to use a **literate configuration** workflow.

* **`config.org`**: This is the main configuration file. It is an Org Mode file
  containing code blocks for packages, keybindings, and settings. **Make all
  edits here.**
* **`init.el`**: You do *not* need to touch this. It simply bootstraps
  `use-package` and loads `config.org`.
* **Drift Prevention**: You do not need to manually tangle the Org
  file. `init.el` reads the Org file directly on startup.

### 2. Zsh (`zsh/`)
The shell configuration is designed to be shared across multiple machines while
keeping secrets local.

* **`zsh/zshrc`**: The shared template. It handles paths, aliases, Pyenv, and
  Puppeteer detection automatically.
* **`~/.zshrc.local`**: The installation script ensures this file exists on your
  machine. **Put API keys, tokens, and machine-specific env vars here.** This
  file is ignored by git.
* **VTerm support**: The config automatically detects if it is running inside
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
