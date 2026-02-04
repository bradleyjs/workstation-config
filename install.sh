#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status

# 1. CONSTANTS
# ------------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/config_backups_$(date +%Y%m%d_%H%M%S)"
ZSHRC_TEMPLATE="$REPO_DIR/zsh/zshrc"
RUN_OSX=false
OS_NAME="$(uname -s)"

# 2. ARGUMENTS
# ------------------------------------------------------------------------------
usage() {
    echo "Usage: $0 [--osx]"
    echo "  --osx   Run macOS defaults scripts (fails on non-macOS)."
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --osx)
            RUN_OSX=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

echo ">> Setting up workstation-config from: $REPO_DIR"

# 3. HELPER FUNCTIONS
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

# 4. SETUP EMACS
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

# 5. SETUP ZSH
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

# 6. OPTIONAL: macOS DEFAULTS
# ------------------------------------------------------------------------------
if [[ "$RUN_OSX" = true ]]; then
    if [[ "$OS_NAME" != "Darwin" ]]; then
        echo ">> [ERROR] --osx requested, but OS is $OS_NAME. Aborting." >&2
        exit 1
    fi
    echo ">> Applying macOS defaults..."
    for script in "$REPO_DIR"/osx/*.sh; do
        if [[ -f "$script" ]]; then
            echo "   [RUN] $(basename "$script")"
            "$script"
        fi
    done
fi

# 7. FINISH
# ------------------------------------------------------------------------------
echo ">> Done!"
if [ -d "$BACKUP_DIR" ]; then
    echo "   !! Backups stored in: $BACKUP_DIR"
fi
echo "   -> Please restart your shell or run 'source ~/.zshrc'"
echo "   -> Start Emacs to install packages."
