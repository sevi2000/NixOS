{ config, pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hyprland
    wl-clipboard
    rofi-wayland
    grim
    slurp
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = (import ./user-vars.nix).username;
      };
    };
  };

  environment.etc."xdg/hypr/hyprland.conf".text = ''
    monitor=*,preferred,auto,1
    exec-once = swaybg -m fill /etc/nixos-hypr-minimal/wallpaper.jpg
    exec-once = waybar
    exec-once = dunst
    bind = SUPER+Return, exec foot
    bind = SUPER+D, exec rofi -show drun
    bind = SUPER+Q, killactive
    bind = SUPER+E, exit
  '';
}

