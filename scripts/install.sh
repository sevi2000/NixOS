#!/bin/bash
set -euo pipefail

# --- USER INPUT ---
DISK="/dev/sda"          # CHANGE THIS to your disk (check with `lsblk`)
HOSTNAME="abc"  # Your hostname
USERNAME="def"  # Your username
read -s -r -p "Mot de passe : " USERPASS
ROOTPASS=$USERPASS  # Root password (plaintext, will be hashed)
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

# --- GENERATE HARDWARE CONFIG ---
echo "🔧 Generating hardware config..."
nixos-generate-config --root /mnt

# --- HASH PASSWORDS ---
echo "🔧 Hashing passwords..."
USERHASH=$(mkpasswd -m sha-512 "$USERPASS")
ROOTHASH=$(mkpasswd -m sha-512 "$ROOTPASS")

# --- UPDATE CONFIGURATION.NIX WITH HASHED PASSWORDS ---
sed -i "s/yourhashedpassword/$USERHASH/" /mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix

# --- COPY CONFIG FILES ---
echo "🔧 Copying config files..."
cp -r hosts users flake.nix /mnt/etc/nixos/

# --- INSTALL NIXOS ---
echo "🔧 Installing NixOS..."
nixos-install --flake "/mnt/etc/nixos#$HOSTNAME" --no-root-password --root-password "$ROOTHASH"

echo "✅ Installation complete! Reboot now."
