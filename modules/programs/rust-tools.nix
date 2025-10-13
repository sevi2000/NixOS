{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bat fd ripgrep eza dust duf procs bottom zoxide hyperfine tealdeer
  ];

  programs.zsh.shellAliases = {
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

  environment.variables = {
    PAGER = "bat";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
