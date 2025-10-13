{
  description = "Modular NixOS flake (deploy-ready, Home Manager fzf/starship/atuin, default zsh)";

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
    username = "abc";
    hostname = "def";
  in
  {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit username hostname; };

      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/system/users.nix
        ./modules/system/packages.nix
        ./modules/system/settings.nix
        ./modules/services/ssh.nix
        ./modules/desktop/hyprland.nix
        ./modules/programs/default.nix
        ./modules/programs/rust-tools.nix
        ./modules/dev/java-spring.nix
        ./modules/dev/python.nix
        ./modules/dev/react-node.nix
        ./modules/dev/angular.nix
        ./modules/dev/c-dev.nix
        ({ ... }: { nix.settings.experimental-features = [ "nix-command" "flakes" ]; })
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/default.nix;
        }
        { networking.hostName = hostname; }
      ];
    };
  };
}
