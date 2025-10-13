#!/usr/bin/env bash
set -euo pipefail
GIT_REPO="${GIT_REPO:-https://github.com/<yourusername>/nixos-config.git}"
INSTALL_DIR="/mnt/etc/nixos"
DISK=${1:-/dev/vda}
HOSTNAME=${2:-def}
USERNAME=${3:-abc}
echo "Installing to $DISK as $USERNAME@$HOSTNAME (this will erase disk)"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }
umount -R /mnt 2>/dev/null || true
swapoff -a 2>/dev/null || true
wipefs -a "$DISK" || true
sgdisk --zap-all "$DISK" || true
sleep 1
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary 513MiB 100%
if [[ "$DISK" == *"nvme"* ]]; then EFI="${DISK}p1"; ROOT="${DISK}p2"; else EFI="${DISK}1"; ROOT="${DISK}2"; fi
sync; sleep 1; udevadm settle || true; blockdev --rereadpt "$DISK" 2>/dev/null || true
for i in {1..10}; do if [ -b "$ROOT" ]; then break; fi; sleep 1; done
if [ ! -b "$ROOT" ]; then echo "Partition not found: $ROOT"; exit 1; fi
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
git clone "$GIT_REPO" "$INSTALL_DIR"
nixos-generate-config --root /mnt
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
nixos-install --no-root-passwd --flake "$INSTALL_DIR#${HOSTNAME}"
mount --bind /dev /mnt/dev || true
mount --bind /proc /mnt/proc || true
mount --bind /sys /mnt/sys || true
chroot /mnt /bin/sh -c "systemctl enable --now snapper-cleanup.timer || true; systemctl enable --now snapper-schedule.timer || true; grub-mkconfig -o /boot/grub/grub.cfg || true"
echo "Done. Rebooting in 5s..."
sleep 5
reboot
