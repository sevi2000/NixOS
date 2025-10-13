{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bat fd ripgrep eza dust duf procs bottom zoxide hyperfine tealdeer starship atuin
  ];
  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      cat = "bat --paging=never";
      find = "fd";
      grep = "rg";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btm";
      cd = "zoxide";
    };
    initExtra = ''
      if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init zsh)"
      fi
      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi
    '';
  };
  environment.variables = { PAGER = "bat"; MANPAGER = "sh -c 'col -bx | bat -l man -p'"; };
}