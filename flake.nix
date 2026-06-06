{
  description = "7110 Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
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

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      nix-darwin,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "aarch64-darwin" ];

      perSystem =
        { system, pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              lua-language-server
              stylua
              nil
              nixfmt-rfc-style
              marksman
              lefthook
            ];
            shellHook = ''
              lefthook install --force >/dev/null
            '';
          };
          formatter = pkgs.nixfmt-rfc-style;
        };

      flake = {
        templates = {
          node = {
            path = ./nix/templates/node;
            description = "Node LTS";
          };
          rust = {
            path = ./nix/templates/rust;
            description = "rust";
          };
          dotnet = {
            path = ./nix/templates/dotnet;
            description = "dotnet";
          };
          typst = {
            path = ./nix/templates/typst;
            description = "typst";
          };
        };
        darwinConfigurations."7110" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix/modules/darwin
            home-manager.darwinModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
            }
            (
              { pkgs, ... }:
              let
                pkgs-master = import inputs.nixpkgs-master {
                  system = "aarch64-darwin";
                  config.allowUnfree = true;
                };
              in
              {
                ids.gids.nixbld = 350;
                users.users.n7110 = {
                  home = "/Users/n7110";
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit pkgs-master; };
                home-manager.users.n7110 = import ./nix/home;
              }
            )
          ];
        };
      };
    };
}
