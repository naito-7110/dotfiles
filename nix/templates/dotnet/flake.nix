{
  description = "dotnet devShell (C# / VB.NET)";

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
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # C# / VB.NET 双方のコンパイラを含む。VB は net472 を狙う場合でも
              # PackageReference の Microsoft.NETFramework.ReferenceAssemblies で参照が解決する。
              dotnetCorePackages.sdk_10_0

              # C# 用 LSP。VB は扱えない（VisualBasic のアセンブリを同梱していない）。
              # VB 側の型チェックは Neovim の :DotnetBuild（<leader>bb）で
              # ビルド出力を quickfix に流して行う。
              roslyn-ls

              # 参照 DLL をソースに戻して読むため。VB に補完が無い分、
              # API の実体はデコンパイル結果を grep して確認する。
              ilspycmd
            ];
          };
        }
      );
    };
}
