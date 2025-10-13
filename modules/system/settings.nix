{ config, pkgs, ... }:
{
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  system.stateVersion = "23.11";
}

