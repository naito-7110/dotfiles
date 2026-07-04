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

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              lua-language-server
              stylua
              nil
              nixfmt
              marksman
              lefthook
            ];
            shellHook = ''
              lefthook install --force >/dev/null
            '';
          };
          formatter = pkgs.nixfmt;
        };

      flake =
        let
          # 全 nixpkgs import で共有する config。
          # permittedInsecurePackages: vue-language-server がビルド時に pnpm 10.34.0 を
          # 名指しで使う（nixpkgs 側で pnpm_10_34_0 に固定）。この版は CVE で insecure
          # 指定されたが、パッチ版(10.34.4/11)は integrity 無しの tarball インストールを
          # 拒否し、vue の lockfile がまさにそれに依存しているためビルドできない。
          # pnpm はサンドボックス内ビルドでしか動かず実行時クロージャには入らないので、
          # この版だけ許可する。上流が lockfile を修正して pin が外れたら削除してよい。
          nixpkgsConfig = {
            allowUnfree = true;
            permittedInsecurePackages = [ "pnpm-10.34.0" ];
          };

          # nixpkgs-master（bleeding edge）を任意 system 向けに import するヘルパー。
          # claude-code など master 追従したいパッケージ用。darwin / WSL で共用する。
          mkMaster =
            system:
            import inputs.nixpkgs-master {
              inherit system;
              config = nixpkgsConfig;
            };

          # ホストごとに異なるアイデンティティはここに集約する。
          # extraSpecialArgs にそのまま展開され、common.nix / git.nix が受け取る。
          hosts = {
            darwin = {
              username = "n7110";
              homeDirectory = "/Users/n7110";
              gitUserName = "naito-7110";
              gitUserEmail = "shige.7110.330@gmail.com";
            };
            wsl = {
              username = "naito-7110";
              homeDirectory = "/home/naito-7110";
              gitUserName = "rsi-7110";
              gitUserEmail = "naito@realsoft.co.jp";
            };
          };
        in
        {
          templates = import ./nix/templates;
          darwinConfigurations."7110" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./nix/modules/darwin
              home-manager.darwinModules.home-manager
              {
                nixpkgs.config = nixpkgsConfig;
              }
              (
                { pkgs, ... }:
                let
                  pkgs-master = mkMaster "aarch64-darwin";
                  host = hosts.darwin;
                in
                {
                  ids.gids.nixbld = 350;
                  users.users.${host.username} = {
                    home = host.homeDirectory;
                  };
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = {
                    inherit pkgs-master;
                  }
                  // host;
                  home-manager.users.${host.username} = import ./nix/home;
                }
              )
            ];
          };

          # WSL (Ubuntu) 用の standalone home-manager 構成。
          # 適用: home-manager switch --flake .#naito-7110@wsl
          homeConfigurations."naito-7110@wsl" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = nixpkgsConfig;
            };
            extraSpecialArgs = {
              pkgs-master = mkMaster "x86_64-linux";
            }
            // hosts.wsl;
            modules = [ ./nix/home/linux.nix ];
          };
        };
    };
}
