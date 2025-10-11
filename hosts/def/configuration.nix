{ config, pkgs, username, hostname, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = hostname;
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.printing.enable = false;

  system.stateVersion = "24.05";
}
