{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unzip
    htop
    neofetch
    man-pages
  ];

  services.dbus.enable = true;
  services.udisks2.enable = true;
}

