{ config, pkgs, username, ... }:

{
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  services.dbus.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    rofi
    alacritty
    hyprpaper
    brightnessctl
    pavucontrol
    networkmanagerapplet
    grim slurp swappy wl-clipboard
    xdg-utils
  ];

  services.getty.autologinUser = username;
  services.xserver.enable = false;
}
