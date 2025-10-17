#!/usr/bin/env bash
set -e

echo "🌀 Minimal Hyprland + Neovim NixOS Installer"

# Prompt for user input
read -p "👤 Enter username: " USERNAME
read -p "💻 Enter hostname: " HOSTNAME
read -s -p "🔐 Enter password: " PASSWORD
echo ""

echo "You entered:"
echo "  Username: $USERNAME"
echo "  Hostname: $HOSTNAME"
read -p "Proceed? (y/N) " CONFIRM
[[ "$CONFIRM" != "y" ]] && echo "❌ Aborted." && exit 1

# Create user-vars.nix
cat > ./modules/user-vars.nix <<EOF
{
  username = "$USERNAME";
  hostname = "$HOSTNAME";
  password = "$PASSWORD";
}
EOF
echo "✅ user-vars.nix written."

# Disk selection
echo ""
lsblk
echo ""
read -p "Enter your disk device (e.g. /dev/sda or /dev/nvme0n1): " DISK

echo "⚠️  This will ERASE all data on $DISK!"
read -p "Continue? (y/N): " WIPE
[[ "$WIPE" != "y" ]] && echo "❌ Aborted." && exit 1

echo "💽 Partitioning $DISK..."
sgdisk -Z "$DISK" # zap disk
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$DISK"
sgdisk -n 2:0:0 -t 2:8300 -c 2:"NIXOS" "$DISK"

EFI_PART="${DISK}p1"
ROOT_PART="${DISK}p2"
[ -b "${DISK}1" ] && EFI_PART="${DISK}1"
[ -b "${DISK}2" ] && ROOT_PART="${DISK}2"

mkfs.vfat -F 32 -n EFI "$EFI_PART"
mkfs.ext4 -L NIXOS "$ROOT_PART"

echo "📦 Mounting partitions..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

# Install NixOS
echo "🚀 Installing system..."
nixos-install --flake .#minimal --no-root-passwd

echo "🎉 Installation complete! Reboot and login as $USERNAME"

