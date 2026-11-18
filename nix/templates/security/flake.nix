{
  description = "Security scan devShell (nmap / nuclei / testssl / zap)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # zap のライセンス対策
            config.allowUnfree = true;
          };

          # レポート整形 (markdown -> weasyprint で PDF) 用
          py = pkgs.python3.withPackages (
            ps: with ps; [
              pyyaml
              markdown
              weasyprint
            ]
          );

          # weasyprint 用の日本語フォント。devShell 内だけで有効な fontconfig を作る
          fontsConf = pkgs.makeFontsConf {
            fontDirectories = [
              pkgs.noto-fonts-cjk-sans
              pkgs.noto-fonts
            ];
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nmap
              nuclei
              testssl
              zap
              jq
              yq-go
              py
              curl
              libxslt # nmap XML -> HTML (xsltproc)
            ];

            shellHook = ''
              export REPO_ROOT="$PWD"
              export FONTCONFIG_FILE="${fontsConf}"
              # nuclei テンプレートは store ではなくプロジェクト内に置く (更新可能にするため)
              export NUCLEI_TEMPLATES_DIR="$REPO_ROOT/.nuclei-templates"
              # ./scripts に置いた自前スクリプトを PATH に通す
              export PATH="$REPO_ROOT/scripts:$PATH"
            '';
          };
        }
      );
    };
}
