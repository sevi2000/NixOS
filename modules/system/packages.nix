{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git curl wget htop unzip vim neovim firefox vscode
    temurin-jdk-21 maven gradle spring-boot-cli
    python312 nodejs_22 gcc cmake
    texlive.combined.scheme-full
    btrfs-progs grub-btrfs
  ];
}