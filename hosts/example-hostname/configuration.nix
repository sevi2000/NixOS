{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/system/users.nix
    ../../modules/system/packages.nix
    ../../modules/system/settings.nix
    ../../modules/services/ssh.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/dev/java-spring.nix
    ../../modules/dev/c.nix
    ../../modules/dev/csharp.nix
    ../../modules/dev/angular.nix
    ../../modules/dev/react.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/starship.nix
  ];
}

