{
  description = "Modular NixOS + Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs: {
    nixosConfigurations = {
      # Hostname is set by the install script
      "${inputs.hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${inputs.hostname}/configuration.nix
          ./modules/system/users.nix
          ./modules/system/packages.nix
          ./modules/system/settings.nix
          ./modules/services/ssh.nix
          ./modules/desktop/hyprland.nix
          ./modules/dev/java-spring.nix
          ./modules/dev/c.nix
          ./modules/dev/csharp.nix
          ./modules/dev/angular.nix
          ./modules/dev/react.nix
          ./modules/programs/neovim.nix
          ./modules/programs/starship.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${inputs.username} = import ./home/default.nix;
          }
        ];
      };
    };
  };
}

