{
  description = "Modular NixOS flake (prepared for user)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

    # Defaults (change if you like)
    username = "abc";
    hostname = "def";
  in
  {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/${hostname}/configuration.nix

        ./modules/system/users.nix
        ./modules/system/packages.nix
        ./modules/system/settings.nix

        ./modules/services/ssh.nix
        ./modules/desktop/hyprland.nix

        ./modules/dev/java-spring.nix
        ./modules/dev/python.nix
        ./modules/dev/react-node.nix
        ./modules/dev/angular.nix
        ./modules/dev/c-dev.nix

        # Enable flakes globally
        ({ ... }: { nix.settings.experimental-features = [ "nix-command" "flakes" ]; })

        # Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/default.nix;
        }

        # Pass username + hostname
        {
          networking.hostName = hostname;
          _module.args = { inherit username hostname; };
        }
      ];
    };
  };
}
