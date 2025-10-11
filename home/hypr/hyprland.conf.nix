{ config, pkgs, ... }:

{
  xdg.configFile."hypr/hyprland.conf".text = ''
    monitor=,preferred,auto,1
    exec-once = waybar &
    exec-once = nm-applet &
    exec-once = hyprpaper &
    exec-once = alacritty

    input {
      kb_layout = fr
      follow_mouse = 1
      sensitivity = 0
    }

    general {
      gaps_in = 6
      gaps_out = 10
      border_size = 2
    }

    bind = SUPER, Return, exec, alacritty
    bind = SUPER, D, exec, rofi -show drun
  '';
}
