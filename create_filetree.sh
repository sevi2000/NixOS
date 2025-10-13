#!/usr/bin/env bash
set -euo pipefail

# Base directory
BASE_DIR="."

# Create base directory
mkdir -p "$BASE_DIR"

# Create home directory and file
mkdir -p "$BASE_DIR/home"
touch "$BASE_DIR/home/default.nix"

# Create hosts directory and example configuration
mkdir -p "$BASE_DIR/hosts/example-hostname"
touch "$BASE_DIR/hosts/example-hostname/configuration.nix"

# Create modules directory and subdirectories/files
mkdir -p "$BASE_DIR/modules/desktop"
touch "$BASE_DIR/modules/desktop/hyprland.nix"

mkdir -p "$BASE_DIR/modules/dev"
touch "$BASE_DIR/modules/dev/java-spring.nix"
touch "$BASE_DIR/modules/dev/c.nix"
touch "$BASE_DIR/modules/dev/csharp.nix"
touch "$BASE_DIR/modules/dev/angular.nix"
touch "$BASE_DIR/modules/dev/react.nix"

mkdir -p "$BASE_DIR/modules/programs"
touch "$BASE_DIR/modules/programs/neovim.nix"
touch "$BASE_DIR/modules/programs/starship.nix"

mkdir -p "$BASE_DIR/modules/services"
touch "$BASE_DIR/modules/services/ssh.nix"

mkdir -p "$BASE_DIR/modules/system"
touch "$BASE_DIR/modules/system/packages.nix"
touch "$BASE_DIR/modules/system/settings.nix"
touch "$BASE_DIR/modules/system/users.nix"

# Create flake.nix and install.sh in the base directory
touch "$BASE_DIR/flake.nix"
touch "$BASE_DIR/install.sh"

# Make install.sh executable
chmod +x "$BASE_DIR/install.sh"

echo "File tree created in the '$BASE_DIR' directory."

