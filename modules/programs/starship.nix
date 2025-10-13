{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ starship ];
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      add_newline = false;
      palette = "catppuccin-mocha";
      [module.user] format = "[$user]($style) ";
      [module.hostname] format = "[$hostname]($style) ";
      [module.directory] truncation_length = 3;
    };
  };
}

