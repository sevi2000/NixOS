#!/usr/bin/env bash

# Exit on error
set -e

# Default values (override with environment variables or prompt)
DISK="${DISK:-/dev/sda}"  # Target disk
USERNAME="${USERNAME:-alice}"  # Default username
HOSTNAME="${HOSTNAME:-my-laptop}"  # Default hostname
TIMEZONE="${TIMEZONE:-America/New_York}"  # Default timezone
PASSWORD="${PASSWORD:-}"  # Leave empty to prompt during install

# Check if running as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

# Check if disk exists
if [ ! -b "$DISK" ]; then
  echo "Disk $DISK not found. Please set DISK variable (e.g., DISK=/dev/nvme0n1)."
  exit 1
fi

# Idempotent Partitioning
echo "Checking disk $DISK for existing partitions..."
# Check if EFI and root partitions exist
EFI_PART="${DISK}1"
ROOT_PART="${DISK}2"
PARTITIONED=false

if parted -s "$DISK" print | grep -q "msdos\|gpt"; then
  # Check if EFI (FAT32) and root (ext4) partitions exist
  if lsblk -f | grep "$EFI_PART" | grep -q "vfat" && lsblk -f | grep "$ROOT_PART" | grep -q "ext4"; then
    echo "Partitions already exist and are correctly formatted. Skipping partitioning."
    PARTITIONED=true
  fi
fi

if [ "$PARTITIONED" = false ]; then
  echo "Partitioning $DISK..."
  # Wipe disk and create GPT
  parted -s "$DISK" mklabel gpt
  # EFI partition: 1GB
  parted -s "$DISK" mkpart primary fat32 1MiB 1GiB
  parted -s "$DISK" set 1 esp on
  # Root partition: rest of disk
  parted -s "$DISK" mkpart primary ext4 1GiB 100%
  # Format partitions
  mkfs.fat -F 32 "$EFI_PART"
  mkfs.ext4 -F "$ROOT_PART"
  echo "Partitioning complete."
else
  echo "Using existing partitions: $EFI_PART (EFI), $ROOT_PART (root)."
fi

# Mount filesystems
echo "Mounting filesystems..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

# Generate hardware configuration
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

# Create flake directory
echo "Setting up flake configuration..."
mkdir -p /mnt/etc/nixos/my-nixos
cd /mnt/etc/nixos/my-nixos

# Write flake.nix
cat > flake.nix << EOL
{
  description = "Minimal Hyprland + Neovim NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    hyprland.url = "github:hyprwm/Hyprland/v0.44.1";
  };

  outputs = { self, nixpkgs, hyprland, ... }: {
    nixosConfigurations.minimal = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hyprland.nixosModules.default
        ({ config, pkgs, ... }: {
          # Bootloader
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # Networking
          networking.hostName = "$HOSTNAME";

          # Timezone and Locale
          time.timeZone = "$TIMEZONE";
          i18n.defaultLocale = "en_US.UTF-8";

          # User
          users.users.$USERNAME = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            ${if [ -n "$PASSWORD" ]; then "initialPassword = \"$PASSWORD\";" else "# Password will be prompted during install";}
          };

          # Minimal Packages
          environment.systemPackages = with pkgs; [
            neovim
            git
            networkmanager
          ];

          # Hyprland
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
          };

          # Minimal Graphics
          hardware.opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
          };

          # System Version
          system.stateVersion = "24.05";
        })
      ];
    };
  };
}
EOL

# Install NixOS
echo "Installing NixOS..."
nix-env -iA nixpkgs.nixFlakes || true  # Ensure nixFlakes is installed
if [ -n "$PASSWORD" ]; then
  nixos-install --flake .#minimal --no-root-passwd
else
  nixos-install --flake .#minimal --no-root-passwd
  echo "You will be prompted to set the password for $USERNAME during installation."
fi

echo "Installation complete! Reboot with 'reboot' and log in as $USERNAME."
echo "Start Hyprland with 'Hyprland' from TTY (Ctrl+Alt+F3)."
echo "Change password with 'passwd' if using a temporary one."
