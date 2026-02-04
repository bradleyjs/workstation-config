#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status

# 1. CONSTANTS
# ------------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/config_backups_$(date +%Y%m%d_%H%M%S)"
ZSHRC_TEMPLATE="$REPO_DIR/zsh/zshrc"

echo ">> Setting up workstation-config from: $REPO_DIR"

# 2. HELPER FUNCTIONS
# ------------------------------------------------------------------------------
backup_path() {
    local path="$1"
    if [ -e "$path" ] || [ -L "$path" ]; then
        # Check if it's already a symlink to our repo (idempotency)
        if [ -L "$path" ] && [ "$(readlink "$path")" == "$2" ]; then
            echo "   [OK] $path is already correctly linked."
            return 1 # Return 1 to signal "no action needed"
        fi

        echo "   [BACKUP] Moving existing $path to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "$path" "$BACKUP_DIR/"
    fi
    return 0
}

# 3. SETUP EMACS
# ------------------------------------------------------------------------------
echo ">> Configuring Emacs..."

# Handle legacy ~/.emacs file (we want to use .emacs.d now)
if [ -f "$HOME/.emacs" ]; then
    backup_path "$HOME/.emacs" "LEGACY"
fi

# Create Emacs cache directories (keeps repo clean)
EMACS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/emacs"
mkdir -p "$EMACS_CACHE_DIR"/{elpa,auto-save,auto-save-list,backup}

# Handle ~/.emacs.d directory
TARGET_EMACS_DIR="$REPO_DIR/emacs"
LINK_NAME="$HOME/.emacs.d"

if backup_path "$LINK_NAME" "$TARGET_EMACS_DIR"; then
    echo "   [LINK] Linking $LINK_NAME -> $TARGET_EMACS_DIR"
    ln -s "$TARGET_EMACS_DIR" "$LINK_NAME"
fi

# 4. SETUP ZSH
# ------------------------------------------------------------------------------
echo ">> Configuring Zsh..."

TARGET_ZSHRC="$HOME/.zshrc"
SOURCE_CMD="source $ZSHRC_TEMPLATE"
LOCAL_SECRETS="$HOME/.zshrc.local"

# Create secrets file if it doesn't exist
if [ ! -f "$LOCAL_SECRETS" ]; then
    echo "   [CREATE] Creating empty $LOCAL_SECRETS for local tokens"
    touch "$LOCAL_SECRETS"
fi

# Check if .zshrc exists
if [ ! -f "$TARGET_ZSHRC" ]; then
    echo "   [CREATE] Creating new .zshrc"
    echo "$SOURCE_CMD" > "$TARGET_ZSHRC"
else
    # Check if we already sourced our config
    if grep -Fq "$ZSHRC_TEMPLATE" "$TARGET_ZSHRC"; then
        echo "   [OK] .zshrc already sources workstation-config"
    else
        echo "   [APPEND] Adding source line to existing .zshrc"
        # We append rather than replace to be safe, but create a backup just in case
        cp "$TARGET_ZSHRC" "$TARGET_ZSHRC.bak"
        echo "" >> "$TARGET_ZSHRC"
        echo "# Load workstation-config" >> "$TARGET_ZSHRC"
        echo "$SOURCE_CMD" >> "$TARGET_ZSHRC"
    fi
fi

# 5. FINISH
# ------------------------------------------------------------------------------
echo ">> Done!"
if [ -d "$BACKUP_DIR" ]; then
    echo "   !! Backups stored in: $BACKUP_DIR"
fi
echo "   -> Please restart your shell or run 'source ~/.zshrc'"
echo "   -> Start Emacs to install packages."
