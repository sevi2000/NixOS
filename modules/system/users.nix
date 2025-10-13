{ config, lib, username, ... }:
{
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
    shell = pkgs.zsh;
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];
}

