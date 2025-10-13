{ config, pkgs, username, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    description = "User ${username}";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [];
  };
  programs.zsh.enable = true;
}