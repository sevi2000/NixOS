{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ neovim ];
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set number
        set relativenumber
        set termguicolors
        colo catppuccin-mocha
      '';
    };
  };
}

