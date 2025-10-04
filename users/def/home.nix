{ config, pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
          tap-to-click = "yes";
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      bind = [
        { key = "SUPER, Return";   action = "exec, kitty"; }
        { key = "SUPER, Q";       action = "killactive,"; }
        { key = "SUPER, E";       action = "exec, thunar"; }
        { key = "SUPER, F";       action = "fullscreen,"; }
        { key = "SUPER, D";       action = "exec, rofi -show drun"; }
        { key = "SUPER, Shift, R"; action = "exec, hyprctl reload"; }
        { key = "SUPER, Left";    action = "movefocus, l"; }
        { key = "SUPER, Right";   action = "movefocus, r"; }
        { key = "SUPER, Up";      action = "movefocus, u"; }
        { key = "SUPER, Down";    action = "movefocus, d"; }
      ];

      windowrule = [
        { rule = "float";         value = "^(.*)$"; }
        { rule = "size 80% 80%";  value = "firefox"; }
        { rule = "center 1";      value = "pavucontrol"; }
      ];

      monitor = ",preferred,auto,auto";

      exec-once = [
        "waybar"
        "swayidle -w"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      decoration = {
        rounding = 5;
        blur = { size = 3; passes = 2; };
        drop_shadow = "yes";
      };

      anim = {
        enabled = "yes";
        bezier = "0.05, 0.9, 0.1, 1";
        speed = 8;
      };
    };
  };

  waybar.enable = true;

  home.packages = with pkgs; [
    kitty
    waybar
    swayidle
    thunar
    rofi
    firefox
    pavucontrol
    blueman
    neovim
    git
    wget
    curl
  ];

  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set relativenumber
        set tabstop=2
        set shiftwidth=2
        set expandtab
      '';
    };
  };
}
