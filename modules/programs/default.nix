{ config, pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    bash.enableCompletion = true;
    neovim = { enable = true; viAlias = true; vimAlias = true; };
    git = { enable = true; userName = "Sevi Dervishi"; userEmail = "you@example.com"; };
    tmux.enable = true;
    fzf.enable = true;
    direnv.enable = true;
  };
  environment.variables = { EDITOR = "nvim"; VISUAL = "nvim"; };
}