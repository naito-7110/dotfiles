{
  description = "Node LTS devShell";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_24
          pnpm
          vscode-langservers-extracted
          typescript-language-server
        ];

        shellHook = ''
          echo "Node: $(node -v)"
        '';
      };
    };
}
