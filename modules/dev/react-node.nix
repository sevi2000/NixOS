{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nodejs_22 nodePackages.pnpm nodePackages.yarn nodePackages.npm nodePackages.vite ];
}
