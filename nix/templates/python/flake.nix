{
  description = "Python devShell (uv)";

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
          pkgs = import nixpkgs { inherit system; };

          # プロジェクトのインタプリタ。上げるときは pyproject.toml の
          # requires-python も一緒に直すこと。
          python = pkgs.python313;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.uv
              python

              # LSP。バージョンはプロジェクトに合わせたいのでグローバル (nix/home/lsp.nix)
              # ではなくここで供給する。
              pkgs.basedpyright # 型チェック・補完・定義ジャンプ
              pkgs.ruff # lint / format (ruff server)
            ];

            env = {
              # uv は既定で python-build-standalone のビルド済みバイナリを落としてくる。
              # NixOS ではダイナミックリンカが合わず起動しないので、インタプリタは
              # nixpkgs のものに固定する。
              UV_PYTHON = python.interpreter;
              UV_PYTHON_DOWNLOADS = "never";

              # venv はプロジェクト直下の .venv 固定。Neovim 側 (lsp / dap) が
              # このパス前提でインタプリタを解決する。
              UV_PROJECT_ENVIRONMENT = ".venv";
            };

            # PyPI の manylinux wheel (numpy, pydantic 等) は nix の外の共有ライブラリを
            # 要求する。ソースビルドを避けたいので実行時パスだけ通しておく。
            shellHook = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
              export LD_LIBRARY_PATH=${
                pkgs.lib.makeLibraryPath [
                  pkgs.stdenv.cc.cc
                  pkgs.zlib
                ]
              }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
            '';
          };
        }
      );
    };
}
