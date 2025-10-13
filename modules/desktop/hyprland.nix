{ config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    settings = {
      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
      };
      decor = {
        rounding = 5;
        blur = { size = 3; passes = 1; };
      };
    };
  };
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  wayland.windowManager.xwayland.enable = true;
  environment.systemPackages = with pkgs; [ hyprland waybar rofi ];
}

