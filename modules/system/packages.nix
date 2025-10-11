{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    firefox
    vscode
    curl
    wget
    htop
    unzip

    # LaTeX
    texlive.combined.scheme-full
    texlive.bin
    texlive.format
  ];
}
