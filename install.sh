#!/bin/bash

# it-be-me-dots install script
# Creates symlinks from home directory to dotfiles repo

DOTFILES_DIR="$HOME/it-be-me-dots"

echo "Installing dotfiles from $DOTFILES_DIR..."

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to create symlink (backs up existing file if present)
link_file() {
    local src="$1"
    local dest="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Backup existing file/directory if it exists and is not a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up $dest to $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    # Remove existing symlink if present
    [ -L "$dest" ] && rm "$dest"

    # Create symlink
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

# Home directory dotfiles
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# .config files
link_file "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# Ghostty (macOS specific location)
link_file "$DOTFILES_DIR/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

echo ""
echo "Done! Backups saved to $BACKUP_DIR (if any)"
echo "You may need to restart your terminal for changes to take effect."
