{
  description = "Minimal Hyprland + Neovim NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.minimal = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/default/configuration.nix
          ./modules/system.nix
          ./modules/user.nix
          ./modules/hyprland.nix
          ./modules/neovim.nix
          ./modules/common.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
