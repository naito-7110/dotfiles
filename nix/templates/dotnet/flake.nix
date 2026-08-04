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

          # C# / VB.NET 双方のコンパイラを含む。VB が net472 を狙う場合でも
          # PackageReference の Microsoft.NETFramework.ReferenceAssemblies で参照が解決する。
          sdk = pkgs.dotnetCorePackages.sdk_10_0;

          # VB.NET 用 LSP。nixpkgs には VB を扱えるサーバが無い（roslyn-ls も
          # omnisharp-roslyn も Microsoft.CodeAnalysis.VisualBasic.* を同梱していない）ため、
          # NuGet の dotnet tool をそのまま展開して使う。
          #
          # 中身は Microsoft.CodeAnalysis.LanguageServer（VS Code の C# 拡張や
          # nixpkgs roslyn-ls と同じ公式 Roslyn LSP）に VB の Roslyn アセンブリを
          # 同梱し直したもの。だから roslyn-ls と同じ流儀で動く。
          #
          # apphost 経由だと nix 環境で .NET を見つけられないので dotnet 直起動に包む。
          vb-ls = pkgs.stdenvNoCC.mkDerivation {
            pname = "vb-ls";
            version = "0.4.0";

            src = pkgs.fetchurl {
              name = "vb-ls-0.4.0.nupkg";
              url = "https://www.nuget.org/api/v2/package/vb-ls/0.4.0";
              hash = "sha256-2HcT4EQu96InU8ZfKTh6MITLNFuOL47VHdyPNjClldA=";
            };

            nativeBuildInputs = [
              pkgs.unzip
              pkgs.makeWrapper
            ];

            unpackPhase = ''
              runHook preUnpack
              unzip -qq $src -d nupkg
              runHook postUnpack
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib/vb-ls
              cp -r nupkg/tools/net10.0/any/. $out/lib/vb-ls/
              makeWrapper ${sdk}/bin/dotnet $out/bin/vb-ls \
                --add-flags "$out/lib/vb-ls/vb-ls.dll" \
                --set DOTNET_ROOT ${sdk} \
                --prefix PATH : ${sdk}/bin
              runHook postInstall
            '';

            meta = {
              description = "Visual Basic .NET language server (Roslyn LSP with the VB assemblies bundled)";
              homepage = "https://github.com/CoolCoderSuper/visualbasic-language-server";
              platforms = pkgs.lib.platforms.unix;
            };
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              sdk

              # C# 用 LSP。VB は扱えないので vb-ls と併用する。
              pkgs.roslyn-ls

              vb-ls

              # 参照 DLL をソースに戻して読むため。
              pkgs.ilspycmd
            ]
            # DAP デバッガ。macOS arm64 では署名・entitlement の制約で
            # nvim-dap から動かせないため Linux のみ (macOS は VSCode で代用)。
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.netcoredbg ];
          };
        }
      );
    };
}
