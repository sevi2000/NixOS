# NixOS Modular Flake - Final

This repo is a ready-to-push modular NixOS flake with:
- Btrfs installer (subvolumes, zstd compression)
- Hyprland desktop
- Dev stacks (Java, Python, Node/React, Angular, C)
- Neovim + LaTeX
- Rust CLI tools (bat, fd, ripgrep, eza, dust, duf, procs, bottom, zoxide)
- Starship prompt + Atuin history manager initialization

Defaults:
- Disk: /dev/vda
- Username: abc
- Hostname: def

## Install (from NixOS live ISO)
sudo ./install.sh /dev/vda def abc

Set GIT_REPO env var or edit install.sh to point to your repo URL before running.
