{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;

  imports = [
    ./hypr/hyprland.conf.nix
  ];

  home.packages = with pkgs; [
    bat
    fzf
    zoxide
    neofetch
    vscode
    neovim
    texlive.combined.scheme-full
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.myPlugins = with pkgs.vimPlugins; [
        vim-nix
        vim-plug
        coc-nvim
        latex-suite
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Sevi Dervishi";
    userEmail = "you@example.com";
  };

  home.stateVersion = "24.05";
}
