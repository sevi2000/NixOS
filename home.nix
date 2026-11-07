{ config, pkgs, ... }:

{
  home.username = "sese";
  home.homeDirectory = "/home/sese";
  programs.git.enable = true;
  home.stateVersion = "26.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
  };
}
