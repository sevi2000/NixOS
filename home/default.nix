{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;

  programs.zsh.enable = true;
  programs.zsh.defaultShell = true;

  programs.fzf.enable = true;
  programs.starship.enable = true;
  programs.atuin.enable = true;

  programs.starship.settings = {
    add_newline = false;
    format = "$directory$git_branch$character";
    character = { success_symbol = "[❯](bold green) "; error_symbol = "[❯](bold red) "; };
  };

  programs.atuin.settings = {
    auto_sync = true;
    sync_frequency = "10m";
    search_mode = "fuzzy";
  };

  home.packages = with pkgs; [
    bat fzf zoxide neofetch vscode neovim texlive.combined.scheme-full
  ];

  home.stateVersion = "24.05";
}
