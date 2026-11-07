#!/bin/bash
# partition-disk.sh - NixOS disk partitioning and mounting
# Usage: sudo ./partition-disk.sh /dev/vda

set -euo pipefail

DISK="${1:-}"

if [ -z "$DISK" ]; then
    echo "Usage: $0 /dev/vdX"
    exit 1
fi

if [ ! -b "$DISK" ]; then
    echo "ERROR: $DISK is not a valid block device."
    exit 1
fi

# Check that disk and partitions are not mounted
if lsblk -nrpo MOUNTPOINT "$DISK" | grep -q .; then
    echo "ERROR: $DISK or its partitions are mounted."
    exit 1
fi

echo "WARNING: ALL DATA ON $DISK WILL BE DESTROYED!"
read -rp "Continue? Type YES: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Operation cancelled."
    exit 1
fi

echo "Partitioning $DISK..."

# Determine partition naming convention
if [[ "$DISK" =~ [0-9]$ ]]; then
    PART1="${DISK}p1"
    PART2="${DISK}p2"
    PART3="${DISK}p3"
else
    PART1="${DISK}1"
    PART2="${DISK}2"
    PART3="${DISK}3"
fi

# Create GPT partition table
parted -s "$DISK" mklabel gpt

# Partition 1: 1 GiB EFI
parted -s "$DISK" mkpart boot fat32 1MiB 1025MiB
parted -s "$DISK" set 1 esp on

# Partition 2: 4 GiB Swap
parted -s "$DISK" mkpart swap linux-swap 1025MiB 5121MiB

# Partition 3: Remaining space for NixOS
parted -s "$DISK" mkpart nixos ext4 5121MiB 100%

# Reload partition table
partprobe "$DISK"
udevadm settle

# Format partitions
mkfs.fat -F 32 -n boot "$PART1"
mkswap -L swap "$PART2"
mkfs.ext4 -L nixos "$PART3"

# Mount NixOS root partition
mount "$PART3" /mnt

# Mount EFI boot partition
mount --mkdir "$PART1" /mnt/boot

# Enable swap
swapon "$PART2"

echo ""
echo "=================================="
echo " NixOS disk setup completed!"
echo "=================================="

echo ""
echo "Partition layout:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DISK"

echo ""
echo "Mounted filesystems:"
df -h /mnt /mnt/boot

echo ""
echo "Active swap:"
swapon --show

echo ""
echo "You can now run:"
echo "nixos-generate-config --root /mnt"
