{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ lua-language-server stylua ];
    configure = {
      customRC = ''
        set number
        set relativenumber
        set expandtab
        set shiftwidth=2
        set tabstop=2
        syntax on
        colorscheme desert
      '';
    };
  };
}

