#!/bin/bash
set -euo pipefail

# --- USER INPUT ---
DISK="/dev/sda"          # CHANGE THIS to your disk (check with `lsblk`)
HOSTNAME="nixos-minimal" # Your hostname
USERNAME="sese"          # Your username
USERPASS="Bekimdervishi"  # CHANGE THIS
ROOTPASS="Bekimdervishi"  # CHANGE THIS
# -----------

# --- PARTITIONING ---
echo "🔧 Partitioning $DISK..."
sgdisk -Z "$DISK"  # Zap all partitions
sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"  # EFI partition
sgdisk -n 2:0:0 -t 2:8300 "$DISK"      # Root partition
mkfs.fat -F32 "${DISK}1"
mkfs.ext4 "${DISK}2"
mount "${DISK}2" /mnt
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi

# --- ENABLE FLAKES ---
echo "🔧 Enabling Nix Flakes..."
mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# --- CREATE DIRECTORY STRUCTURE ---
echo "🔧 Creating /etc/nixos structure..."
mkdir -p /mnt/etc/nixos/modules

# --- WRITE FLAKE.NIX ---
cat > /mnt/etc/nixos/flake.nix << EOL
{
  description = "Minimal NixOS with Hyprland, Neovim, and Dev Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.$HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        \${./modules/system.nix}
        \${./modules/users.nix}
        \${./modules/hyprland.nix}
        \${./modules/devtools.nix}
        \${./modules/media.nix}
        \${./modules/packages.nix}
      ];
    };
  };
}
EOL

# --- WRITE MODULES ---
echo "🔧 Writing NixOS modules..."

# system.nix
cat > /mnt/etc/nixos/modules/system.nix << EOL
{ config, pkgs, ... }: {
  networking.hostName = "$HOSTNAME";
  networking.networkmanager.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
EOL

# users.nix
cat > /mnt/etc/nixos/modules/users.nix << EOL
{ config, pkgs, ... }: {
  users.users.$USERNAME = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    password = "$USERPASS";
  };
}
EOL

# hyprland.nix
cat > /mnt/etc/nixos/modules/hyprland.nix << EOL
{ config, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    settings = {
      input = { kb_layout = "us"; };
      exec-once = [ "waybar" "swayidle -w" ];
    };
  };
  programs.waybar.enable = true;
  programs.swayidle.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
EOL

# devtools.nix
cat > /mnt/etc/nixos/modules/devtools.nix << EOL
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jdk21
    dotnet-sdk
    gcc
    texlive.combined.scheme-full
    nodejs
    yarn
  ];
}
EOL

# media.nix
cat > /mnt/etc/nixos/modules/media.nix << EOL
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    mpv
    cmus
  ];
}
EOL

# packages.nix
cat > /mnt/etc/nixos/modules/packages.nix << EOL
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    ripgrep
    fd
    fzf
    ranger
    firefox
  ];
}
EOL

# --- INSTALL NIXOS ---
echo "🔧 Installing NixOS using flake..."
nixos-install --flake "/mnt/etc/nixos#$HOSTNAME" --no-root-password

# --- FINAL MESSAGE ---
echo "✅ Installation complete!"
echo "🔄 Reboot now and log in as '$USERNAME' with password '$USERPASS'."
echo "🚀 After reboot, run: sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME"
