{ config, pkgs, username, hostname, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = hostname;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.snapper.enable = true;
  services.snapper.configs = { };
  environment.systemPackages = with pkgs; [ btrfs-progs grub-btrfs ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}