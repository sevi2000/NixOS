# NixOS Modular Flake - ready to push

This repository is a modular NixOS flake prepared for one-step installation.

Defaults baked in:
- Disk default in installer: /dev/sda
- Default username: abc
- Default hostname: def

## Quick usage (from NixOS live ISO)

Run the installer directly:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<yourusername>/nixos-config/main/install.sh)
```

Or download and run:
```bash
wget https://raw.githubusercontent.com/<yourusername>/nixos-config/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

Before running, edit `install.sh` to set `GIT_REPO` to your repo URL (or pass via environment variable):
```bash
GIT_REPO="https://github.com/yourusername/nixos-config.git" bash install.sh
```

## Structure
See `modules/` for modular configuration (desktop, dev stacks, services, etc).

