{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nodejs_22 nodePackages."@angular/cli" nodePackages.yarn nodePackages.npm ];
}
