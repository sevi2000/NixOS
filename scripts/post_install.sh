#!/bin/bash
set -euo pipefail

# --- APPLY HOME MANAGER ---
echo "🔧 Applying Home Manager..."
home-manager switch --flake "/etc/nixos#def"

# --- RESTART HYPRLAND ---
echo "🔧 Restarting Hyprland..."
hyprctl reload

echo "✅ Post-installation complete!"
