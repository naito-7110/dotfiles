{
  description = "Typst devShell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        typst
        tinymist
        typstyle
      ];

      shellHook = ''
        echo "Typst: $(typst --version)"
      '';
    };
  };
}
