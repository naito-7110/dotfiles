{
  description = "Bun devShell";

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
          bun
          typescript-language-server
          vscode-langservers-extracted
        ];

        shellHook = ''
          echo "Bun: $(bun -v)"
        '';
      };
    };
}
