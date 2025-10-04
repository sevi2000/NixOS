#!/bin/bash
set -euo pipefail

# --- USER INPUT ---
DISK="/dev/sda"          # CHANGE THIS to your disk (check with `lsblk`)
HOSTNAME="def"  # Your hostname
USERNAME="abc"  # Your username
# -----------

# Function to ask for confirmation
confirm() {
  read -p "🤔 $1 (y/n) " choice
  case "$choice" in
    y|Y ) return 0 ;;
    n|N ) return 1 ;;
    * ) echo "Please answer y or n." && return 1 ;;
  esac
}

# Function to securely prompt for password
get_password() {
  local prompt="$1"
  local password
  while true; do
    read -s -p "🔐 $prompt: " password
    echo
    read -s -p "🔐 Confirm $prompt: " password_confirm
    echo
    if [ "$password" = "$password_confirm" ]; then
      echo "$password"
      return 0
    else
      echo "Passwords do not match. Try again."
    fi
  done
}

# --- PROMPT FOR PASSWORDS ---
echo "🔐 Setting up passwords..."
USERPASS=$(get_password "user password")
ROOTPASS=$(get_password "root password")

# --- CHECK IF DISK IS ALREADY PARTITIONED ---
if lsblk -o FSTYPE "$DISK" | grep -q "vfat\|ext4"; then
  if confirm "$DISK is already partitioned and formatted. Re-partition and format?"; then
    echo "🔧 Re-partitioning $DISK..."
    sgdisk -Z "$DISK"  # Zap all partitions
    sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"  # EFI partition
    sgdisk -n 2:0:0 -t 2:8300 "$DISK"      # Root partition
    mkfs.fat -F32 "${DISK}1"
    mkfs.ext4 "${DISK}2"
  else
    echo "⏩ Skipping disk partitioning and formatting."
  fi
else
  echo "🔧 Partitioning $DISK..."
  sgdisk -Z "$DISK"  # Zap all partitions
  sgdisk -n 1:0:+512M -t 1:ef00 "$DISK"  # EFI partition
  sgdisk -n 2:0:0 -t 2:8300 "$DISK"      # Root partition
  mkfs.fat -F32 "${DISK}1"
  mkfs.ext4 "${DISK}2"
fi

# --- MOUNT DISK IF NOT ALREADY MOUNTED ---
if ! mount | grep -q "/mnt "; then
  echo "🔧 Mounting disk..."
  mount "${DISK}2" /mnt
  mkdir -p /mnt/boot/efi
  mount "${DISK}1" /mnt/boot/efi
else
  if confirm "/mnt is already mounted. Remount?"; then
    echo "🔧 Remounting disk..."
    umount /mnt/boot/efi 2>/dev/null || true
    umount /mnt 2>/dev/null || true
    mount "${DISK}2" /mnt
    mkdir -p /mnt/boot/efi
    mount "${DISK}1" /mnt/boot/efi
  else
    echo "⏩ Skipping disk mounting."
  fi
fi

# --- ENABLE FLAKES ON TARGET SYSTEM ---
if [ ! -f "/mnt/etc/nix/nix.conf" ] || ! grep -q "experimental-features" "/mnt/etc/nix/nix.conf"; then
  echo "🔧 Enabling Nix Flakes on the target system..."
  mkdir -p /mnt/etc/nix
  echo "experimental-features = nix-command flakes" > /mnt/etc/nix/nix.conf
else
  if confirm "Nix Flakes are already enabled on the target system. Overwrite?"; then
    echo "🔧 Overwriting Nix Flakes configuration..."
    echo "experimental-features = nix-command flakes" > /mnt/etc/nix/nix.conf
  else
    echo "⏩ Skipping Nix Flakes configuration."
  fi
fi

# --- GENERATE HARDWARE CONFIG IF NOT EXISTS ---
if [ ! -f "/mnt/etc/nixos/hardware-configuration.nix" ]; then
  echo "🔧 Generating hardware config..."
  nixos-generate-config --root /mnt
else
  if confirm "Hardware config already exists. Overwrite?"; then
    echo "🔧 Overwriting hardware config..."
    nixos-generate-config --root /mnt
  else
    echo "⏩ Skipping hardware config generation."
  fi
fi

# --- HASH PASSWORDS ---
echo "🔧 Hashing passwords..."
USERHASH=$(mkpasswd -m sha-512 "$USERPASS")
ROOTHASH=$(mkpasswd -m sha-512 "$ROOTPASS")

# --- COPY CONFIG FILES IF NOT EXISTS ---
if [ ! -d "/mnt/etc/nixos/hosts" ]; then
  echo "🔧 Copying config files..."
  mkdir -p /mnt/etc/nixos/hosts
  mkdir -p /mnt/etc/nixos/users
  cp -r hosts users flake.nix /mnt/etc/nixos/
else
  if confirm "Config files already exist. Overwrite?"; then
    echo "🔧 Overwriting config files..."
    cp -r hosts users flake.nix /mnt/etc/nixos/
  else
    echo "⏩ Skipping config file copy."
  fi
fi

# --- UPDATE CONFIGURATION.NIX WITH HASHED PASSWORDS ---
if ! grep -q "$USERHASH" "/mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix"; then
  echo "🔧 Updating configuration.nix with hashed passwords..."
  sed -i "s/yourhashedpassword/$USERHASH/" "/mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix"
else
  if confirm "Passwords already updated in configuration.nix. Update again?"; then
    echo "🔧 Updating configuration.nix with hashed passwords..."
    sed -i "s/yourhashedpassword/$USERHASH/" "/mnt/etc/nixos/hosts/$HOSTNAME/configuration.nix"
  else
    echo "⏩ Skipping password update."
  fi
fi

# --- INSTALL NIXOS ---
if [ ! -f "/mnt/etc/NIXOS" ]; then
  echo "🔧 Installing NixOS..."
  nixos-install --flake "/mnt/etc/nixos#$HOSTNAME" --no-root-password
  echo "🔑 Setting root password..."
  echo "root:$ROOTPASS" | chpasswd -R /mnt
else
  if confirm "NixOS is already installed. Reinstall?"; then
    echo "🔧 Reinstalling NixOS..."
    nixos-install --flake "/mnt/etc/nixos#$HOSTNAME" --no-root-password
    echo "🔑 Setting root password..."
    echo "root:$ROOTPASS" | chpasswd -R /mnt
  else
    echo "⏩ Skipping NixOS installation."
  fi
fi

echo "✅ Installation complete! Reboot now."
