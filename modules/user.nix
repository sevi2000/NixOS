{ config, pkgs, ... }:

let
  userVars = import ./user-vars.nix;
in {
  users.users.${userVars.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = userVars.password;
  };

  networking.hostName = userVars.hostname;
  security.sudo.wheelNeedsPassword = true;
}

