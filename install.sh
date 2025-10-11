#!/usr/bin/env bash
set -euo pipefail

GIT_REPO="${GIT_REPO:-https://github.com/<yourusername>/nixos-config.git}"
INSTALL_DIR="/mnt/etc/nixos"

echo "🌟 NixOS Full Installer (one-step)"
echo "=================================="
read -rp "Disk to use (default /dev/sda): " DISK
DISK=${DISK:-/dev/sda}
read -rp "Hostname (default def): " HOSTNAME
HOSTNAME=${HOSTNAME:-def}
read -rp "Username (default abc): " USERNAME
USERNAME=${USERNAME:-abc}

echo "⚠️  This will ERASE all data on $DISK"
read -rp "Type 'YES' to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }

echo "🧹 Wiping disk..."
wipefs -a "$DISK" || true
sgdisk --zap-all "$DISK" || true

echo "🔧 Partitioning..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary ext4 513MiB 100%

if [[ "$DISK" =~ nvme ]]; then
  EFI="${DISK}p1"
  ROOT="${DISK}p2"
else
  EFI="${DISK}1"
  ROOT="${DISK}2"
fi

echo "💽 Formatting..."
mkfs.vfat -F32 -n EFI "$EFI"
mkfs.ext4 -L nixos "$ROOT"

echo "📂 Mounting..."
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot

echo "📦 Cloning config repo..."
mkdir -p "$INSTALL_DIR"
git clone "$GIT_REPO" "$INSTALL_DIR"

echo "🔍 Generating hardware config..."
nixos-generate-config --root /mnt

echo "🧩 Injecting username and hostname module..."
mkdir -p "$INSTALL_DIR/hosts/${HOSTNAME}"
cat > "$INSTALL_DIR/hosts/${HOSTNAME}/user-host.nix" <<EOF
{ config, pkgs, ... }:
{
  networking.hostName = "${HOSTNAME}";
  users.users.${USERNAME} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
  };
}
EOF

echo "⚙️ Installing NixOS..."
nixos-install --no-root-passwd --flake "$INSTALL_DIR#${HOSTNAME}"

echo "✅ Installation complete! Rebooting in 5 seconds..."
sleep 5
reboot
