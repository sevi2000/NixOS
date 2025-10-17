{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  security.polkit.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    foot
    waybar
    dunst
    bemenu
    swaybg
    neovim
  ];
}

