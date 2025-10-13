#!/usr/bin/env bash
set -euo pipefail

GIT_REPO="https://github.com/yourusername/nixos-config.git"
INSTALL_DIR="/mnt/etc/nixos"
DISK=${1:-/dev/vda}
HOSTNAME=${2:-nixos}
USERNAME=${3:-user}

echo "Installing to $DISK as $USERNAME@$HOSTNAME (this will erase disk)"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }

# Disk setup
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
wipefs -a "$DISK" || true
sgdisk --zap-all "$DISK" || true
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary 513MiB 100%
sync; sleep 1; udevadm settle || true; blockdev --rereadpt "$DISK" 2>/dev/null || true

# Partition variables
if [[ "$DISK" == *"nvme"* ]]; then
  EFI="${DISK}p1"; ROOT="${DISK}p2"
else
  EFI="${DISK}1"; ROOT="${DISK}2"
fi

# Check partitions
for i in {1..10}; do if [ -b "$ROOT" ]; then break; fi; sleep 1; done
if [ ! -b "$ROOT" ]; then echo "Partition not found: $ROOT"; exit 1; fi

# Format and mount
mkfs.vfat -F32 -n EFI "$EFI"
mkfs.btrfs -f -L nixos "$ROOT"
mount "$ROOT" /mnt
btrfs subvolume create /mnt/@ || true
btrfs subvolume create /mnt/@home || true
btrfs subvolume create /mnt/@nix || true
btrfs subvolume create /mnt/@var || true
umount /mnt
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@ "$ROOT" /mnt
mkdir -p /mnt/{boot,home,nix,var}
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@home "$ROOT" /mnt/home
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@nix "$ROOT" /mnt/nix
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@var "$ROOT" /mnt/var
mount "$EFI" /mnt/boot

# Clone and generate config
git clone "$GIT_REPO" "$INSTALL_DIR"
nixos-generate-config --root /mnt

# Create host config
mkdir -p "$INSTALL_DIR/hosts/${HOSTNAME}"
cat > "$INSTALL_DIR/hosts/${HOSTNAME}/configuration.nix" <<EOF
{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/system/users.nix
    ../../modules/system/packages.nix
    ../../modules/system/settings.nix
    ../../modules/services/ssh.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/dev/java-spring.nix
    ../../modules/dev/c.nix
    ../../modules/dev/csharp.nix
    ../../modules/dev/angular.nix
    ../../modules/dev/react.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/starship.nix
  ];
}
EOF

# Install NixOS
nixos-install --no-root-passwd --flake "$INSTALL_DIR#${HOSTNAME}"

# Post-install
mount --bind /dev /mnt/dev || true
mount --bind /proc /mnt/proc || true
mount --bind /sys /mnt/sys || true
chroot /mnt /bin/sh -c "systemctl enable --now snapper-cleanup.timer || true; systemctl enable --now snapper-schedule.timer || true; grub-mkconfig -o /boot/grub/grub.cfg || true"

echo "Done. Rebooting in 5s..."
sleep 5
reboot

