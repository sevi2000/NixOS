{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs_22
    nodePackages.yarn
    nodePackages.npm
    nodePackages."@angular/cli"
  ];
}
