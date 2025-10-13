{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs-18_x yarn npm angular-cli
  ];
}

