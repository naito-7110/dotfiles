{
  description = "7110 Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, nix-darwin, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "aarch64-darwin" ];

      perSystem = { system, ... }: {
      };

      flake = {
        darwinConfigurations."7110" =
           nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./nix/modules/darwin
              home-manager.darwinModules.home-manager
              {
		ids.gids.nixbld = 350;
                users.users.n7110 = {
                  home = "/Users/n7110";
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.users.n7110 =
                  import ./nix/home;
              }
            ];
          };

      };
    };
}
