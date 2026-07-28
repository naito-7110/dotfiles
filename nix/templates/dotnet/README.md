# dotnet devShell Template (C# / VB.NET)

## Usage
```sh
direnv allow
```

| 同梱 | 用途 |
|------|------|
| `dotnetCorePackages.sdk_10_0` | `dotnet build` / `dotnet test`（C# も VB も同じコンパイラ基盤） |
| `roslyn-ls` | **C# 用**の LSP |
| `vb-ls` (0.4.0) | **VB.NET 用**の LSP。nixpkgs 未収録なのでこの flake 内で自前パッケージング |
| `ilspycmd` | 参照 DLL のデコンパイル（API 参照用） |

C# だけのプロジェクトは `csharp` テンプレートで足りる。VB.NET (`.vbproj`) が
混ざるならこちらを使う。

## VB.NET の LSP について

**nixpkgs には VB を扱える LSP が無い。** roslyn-ls も omnisharp-roslyn も Roslyn の
C# 側だけを載せており、`Microsoft.CodeAnalysis.VisualBasic.*` を同梱していない
（omnisharp は `.vb` を開いても補完ゼロ、`.vbproj` をロードしようともしない）。

そこで [vb-ls](https://github.com/CoolCoderSuper/visualbasic-language-server) を
NuGet の dotnet tool から展開して入れている。中身は
`Microsoft.CodeAnalysis.LanguageServer`（VS Code の C# 拡張や nixpkgs roslyn-ls と
同じ公式 Roslyn LSP）に **VB の Roslyn アセンブリを同梱し直したもの**。
net10.0 ターゲットなので同梱の SDK 10 でそのまま動く。

補完・ホバー・`BC*` の実時間診断が効く。Neovim 側の設定は dotfiles の
`.config/nvim/lua/config/lsp.lua`（`vb_ls`）。**`solution/open` を送らないと
機能がまるごと出ない**サーバなので、設定を書き直すときは `docs/neovim.md` を読むこと。

### 更新のしかた
nixpkgs 未収録なので手動。`flake.nix` の version と hash を両方直す:

```sh
nix store prefetch-file https://www.nuget.org/api/v2/package/vb-ls/<新しいバージョン>
```

nixpkgs に入ったら flake 内の derivation は消して `pkgs.vb-ls` に差し替えてよい。

## ビルド → quickfix

LSP とは別に、Neovim の `<leader>bb`（`:DotnetBuild`）でコンパイラを直接叩ける。
**LSP があっても要る**: サーバー側が受け付ける言語バージョンの確認や
ソリューション全体の最終確認はコンパイラでしかできない。

`dotnet` が PATH に無いと `nix develop --command` にフォールバックして毎回
nix の評価を待つので、**devShell に入って使うのが前提**。

## API 参照

補完だけで足りないとき（デコンパイルして実装を読む）:

```sh
ilspycmd -p -o reference/decompiled/<Name> libs/<Name>.dll
grep -rn "class FormScript" reference/decompiled/
```

## シンタックスハイライト

`.vb` は Neovim 同梱の `syntax/vb.vim` で色が付くが VB6 世代で `Imports` / `Class` /
`Inherits` / `Try` / `Of` を知らない。dotfiles の `after/syntax/vb.vim` で補っている
（treesitter に VB グラマーは無い）。
