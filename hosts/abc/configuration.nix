{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # Basic system settings
  networking.hostName = "abc";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hyprland (system service)
  programs.hyprland.enable = true;
  systemd.users.services.hyprland = {
    enable = true;
    wantedBy = [ "graphical-session.target" ];
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Users (with hashed password)
  users.users.def = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    password = "PASSWORD_PLACEHOLDER";  # This will be replaced by the script
  };

  # Home Manager
  programs.home-manager.enable = true;
}
