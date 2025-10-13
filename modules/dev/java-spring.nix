{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jdk17 maven gradle spring-boot-cli
  ];
}

