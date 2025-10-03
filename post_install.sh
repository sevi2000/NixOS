#!/bin/bash
set -euo pipefail

# --- NEOVIM CONFIG ---
echo "🔧 Setting up Neovim..."
mkdir -p ~/.config/nvim
cat > ~/.config/nvim/init.lua << 'EOL'
-- Minimal Neovim config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
EOL

# --- HYPRLAND USER CONFIG ---
echo "🔧 Setting up Hyprland user config..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'EOL'
# Example Hyprland user config
input {
  kb_layout = us
}
bind = SUPER, Return, exec, kitty
bind = SUPER, Q, killactive,
EOL

# --- REBUILD SYSTEM ---
echo "🔧 Rebuilding system with flake..."
sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)

echo "✅ Post-installation setup complete!"
