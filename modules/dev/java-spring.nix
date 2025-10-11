{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    temurin-jdk-21
    maven
    gradle
    spring-boot-cli
    git
    curl
    httpie
    jq
    docker
  ];

  virtualisation.docker.enable = true;
}
